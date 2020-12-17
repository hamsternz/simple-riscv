--###############################################################################
--# ./hdl/cpu/fetch/fetch_unit.vhd  - DESCRIPTION_NEEDED
--#
--# Part of the simple-riscv project. A simple three-stage RISC-V compatible CPU.
--#
--# See https://github.com/hamsternz/simple-riscv
--#
--# MIT License
--#
--###############################################################################
--#
--# Copyright (c) 2020 Mike Field
--#
--# Permission is hereby granted, free of charge, to any person obtaining a copy
--# of this software and associated documentation files (the "Software"), to deal
--# in the Software without restriction, including without limitation the rights
--# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--# copies of the Software, and to permit persons to whom the Software is
--# furnished to do so, subject to the following conditions:
--#
--# The above copyright notice and this permission notice shall be included in all
--# copies or substantial portions of the Software.
--#
--# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--# SOFTWARE.
--#
--############################################################################### 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fetch_unit is
    Port ( clk            : in  STD_LOGIC;
           -- from the exec unit
           exec_completed      : in  STD_LOGIC;
           exec_flush_required : in  STD_LOGIC;
           exec_current_pc     : in  STD_LOGIC_VECTOR (31 downto 0);
           -- to the decoder
           fetch_opcode        : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           fetch_addr          : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           -- to the memory
           progmem_enable      : out STD_LOGIC                      := '1';
           progmem_addr        : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
           progmem_data_addr   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
           progmem_data        : in  STD_LOGIC_VECTOR (31 downto 0);
           progmem_data_valid  : in  STD_LOGIC
   );
end fetch_unit;

architecture Behavioral of fetch_unit is
   signal next_addr           : unsigned(31 downto 0) := (others => '0');

   signal fetched_addr   : std_logic_vector(31 downto 0) := (others => '1');
   signal fetched_opcode : std_logic_vector(31 downto 0) := (others => '1');
   signal fetched_valid  : std_logic := '0';

   signal pending_addr   : std_logic_vector(31 downto 0) := (others => '1');
   signal pending_opcode : std_logic_vector(31 downto 0) := (others => '1');
   signal pending_valid  : std_logic := '0';

   signal flush_addr     : std_logic_vector(31 downto 0) := (others => '1');

begin
----------------------------------------------------------------
-- This is a steaming pile of goo, and needs to be re-written
-- from scratch
----------------------------------------------------------------
   fetch_opcode <= pending_opcode;
   fetch_addr   <= pending_addr;

process(clk) 
    begin
        if rising_edge(clk) then
            progmem_enable <= '0';
            if exec_completed = '1' then
                --------------------------------------------------
                -- Instruction completed - Move everything forward
                --------------------------------------------------
                if fetched_valid = '1' then
                    pending_addr   <= fetched_addr;
                    pending_opcode <= fetched_opcode;
                    pending_valid  <= '1';
                    if progmem_data_valid = '1' then
                        fetched_addr   <= progmem_data_addr;
                        fetched_opcode <= progmem_data;                    
                        fetched_valid  <= '1';
                    else
                        fetched_valid <= '0';
                    end if;
                elsif progmem_data_valid = '1' then
                    pending_addr   <= progmem_data_addr;
                    pending_opcode <= progmem_data;                    
                    pending_valid  <= '1';
                else
                    -- Don't have a valid instruction to move in
                end if;
                -- In all cases a read of an instruction is needed
                progmem_addr   <= std_logic_vector(next_addr);
                progmem_enable <= '1';
                next_addr      <= next_addr+4;
                
            elsif exec_flush_required = '1' then
                -------------------------
                -- Instruction miss
                -------------------------
                if pending_addr = exec_current_pc then
                    ---------------------------------------------------------
                    -- The required instruction is already pending decode.
                    -- Por example skipping ove an instruction
                    ---------------------------------------------------------
                    pending_addr   <= fetched_addr;
                    pending_opcode <= fetched_opcode;
                    pending_valid  <= fetched_valid;
                    
                    if progmem_data_valid = '1' then
                        fetched_addr   <= progmem_data_addr;
                        fetched_opcode <= progmem_data;                    
                        fetched_valid  <= '1';
                    else
                        fetched_valid  <= '0';
                    end if;
                    --- Issue request
                     progmem_addr   <= std_logic_vector(next_addr);
                    progmem_enable <= '1';
                    next_addr      <= next_addr+4;

                elsif fetched_valid = '1' and fetched_addr = exec_current_pc then
                    ---------------------------------------------------------
                    -- The required instruction is already fetched.
                    ---------------------------------------------------------
                    pending_addr   <= fetched_addr;
                    pending_opcode <= fetched_opcode;
                    pending_valid  <= fetched_valid;
                    if progmem_data_valid = '1' then
                        fetched_addr   <= progmem_data_addr;
                        fetched_opcode <= progmem_data;                    
                        fetched_valid  <= '1';
                    else
                        fetched_valid  <= '0';
                    end if;
                    --- Issue request
                    progmem_addr   <= std_logic_vector(next_addr);
                    progmem_enable <= '1';
                    next_addr      <= next_addr+4;
                elsif progmem_data_valid = '1' and progmem_data_addr = exec_current_pc then
                    pending_addr   <= progmem_data_addr;
                    pending_opcode <= progmem_data;
                    pending_valid  <= '1';
                    --- Issue request
                    progmem_addr   <= std_logic_vector(next_addr);
                    progmem_enable <= '1';
                    next_addr      <= next_addr+4;
                else
                    ---------------------------------------------------------
                    -- Full miss - We don't have the instruction anywhere
                    ---------------------------------------------------------
                    fetched_valid <= '0';
                    pending_valid <= '0';
                    if progmem_data_valid = '1' then
                        pending_addr   <= progmem_data_addr;
                        pending_opcode <= progmem_data;
                        pending_valid  <= '1';
                    end if;
                                        
                    --- Issue request for new instruction
                    if flush_addr /= exec_current_pc then                     
                        progmem_addr   <= exec_current_pc;
                        progmem_enable <= '1';
                        next_addr      <= unsigned(exec_current_pc)+4;
                        flush_addr <= exec_current_pc;
                    end if;
                end if;
            else  -- Note exec_completed & exec_flush_required will not be asserted at the same time
                -------------------------
                -- No instruction is being consumed.
                -------------------------
                if fetched_valid = '0' then
                    if progmem_data_valid = '1' then
                        fetched_addr   <= progmem_data_addr;
                        fetched_valid  <= '1';
                        fetched_opcode <= progmem_data;                    
                    else 
                        progmem_addr   <= std_logic_vector(next_addr);
                        progmem_enable <= '1';
                        next_addr      <= next_addr+4;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
