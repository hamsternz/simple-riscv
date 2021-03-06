--###############################################################################
--# ./hdl/cpu/exec/program_counter.vhd  - DESCRIPTION_NEEDED
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
use IEEE.numeric_std.all;

use work.cpu_constants.ALL;

entity program_counter is
    port ( clk                : in  STD_LOGIC; 
           completed          : in  STD_LOGIC;

           jump_active        : in  STD_LOGIC;
           jump_complete      : out STD_LOGIC;
           jump_failed        : out STD_LOGIC;
           pc_mode            : in  STD_LOGIC_VECTOR(1 downto 0);
           take_branch        : in  STD_LOGIC;
           pc_jump_offset     : in  STD_LOGIC_VECTOR(31 downto 0);
           a                  : in  STD_LOGIC_VECTOR(31 downto 0);
           
           pc                 : out STD_LOGIC_VECTOR(31 downto 0);
           pc_plus_four       : out STD_LOGIC_VECTOR(31 downto 0)); 
end entity;

architecture Behavioral of program_counter is
   signal current_pc   : unsigned(31 downto 0) := x"EFFFFFF0";
   signal next_instr   : unsigned(31 downto 0);
begin
    jump_complete <= jump_active;
    jump_failed   <= '0';
    pc           <= std_logic_vector(current_pc);
    pc_plus_four <= std_logic_vector(current_pc + 4);

process(pc_mode, current_pc, a, pc_jump_offset, take_branch)
    begin
        if take_branch = '1' then
            next_instr <= (unsigned(current_pc)  + unsigned(pc_jump_offset)) AND x"FFFFFFFC";
        else
            case pc_mode is
                when PC_JMP_RELATIVE             => next_instr <= (unsigned(current_pc)  + unsigned(pc_jump_offset)) AND x"FFFFFFFC";
                when PC_JMP_REG_RELATIVE         => next_instr <= (unsigned(a)           + unsigned(pc_jump_offset)) AND x"FFFFFFFC";
                when PC_JMP_RELATIVE_CONDITIONAL => next_instr <= current_pc + 4; 
                when others                      => next_instr <= current_pc + 4;
            end case;
        end if;
    end process;


process(clk) 
    begin
        if rising_edge(clk) then
            if completed = '1' then
                current_pc <= next_instr;
            end if;
        end if;
    end process;

end Behavioral;
