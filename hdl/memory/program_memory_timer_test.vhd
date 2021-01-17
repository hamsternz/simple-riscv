--###############################################################################
--# ./hdl/memory/program_memory.vhd  - DESCRIPTION_NEEDED
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

entity program_memory is
  port ( clk        : in  STD_LOGIC;
         -- Instruction interface
         progmem_enable     : in  STD_LOGIC;
         progmem_addr       : in  STD_LOGIC_VECTOR(31 downto 0);
         progmem_data_addr  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
         progmem_data       : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
         progmem_data_valid : out STD_LOGIC := '0';

         -- CPU Bus interface
         bus_busy       : out STD_LOGIC := '0';
         bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
         bus_enable     : in  STD_LOGIC;
         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));
end entity;

architecture Behavioral of program_memory is
    
    type a_prog_memory is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
    signal prog_memory : a_prog_memory := (
              0 => x"00018193",
              1 => x"20001117",
              2 => x"ffc10113",
              3 => x"00010433",
              4 => x"0040006f",
              5 => x"e00002b7",
              6 => x"02028293",
              7 => x"0042a303",
              8 => x"0002a503",
              9 => x"0042a583",
             10 => x"fe659ae3",
             11 => x"00550513",
             12 => x"00a66463",
             13 => x"00158593",
             14 => x"fff00313",
             15 => x"0062a623",
             16 => x"00a2a423",
             17 => x"00b2a623",
             18 => x"00000297",
             19 => x"02028293",
             20 => x"30529073",
             21 => x"08000293",
             22 => x"3042a073",
             23 => x"00800293",
             24 => x"3002a073",
             25 => x"0000006f",
             26 => x"ff010113",
             27 => x"00512223",
             28 => x"00612223",
             29 => x"00a12423",
             30 => x"00b12623",
             31 => x"e00002b7",
             32 => x"02028293",
             33 => x"0042a303",
             34 => x"0002a503",
             35 => x"0042a583",
             36 => x"fe659ae3",
             37 => x"00550513",
             38 => x"00a66463",
             39 => x"00158593",
             40 => x"fff00313",
             41 => x"0062a623",
             42 => x"00a2a423",
             43 => x"00b2a623",
             44 => x"00412283",
             45 => x"00412303",
             46 => x"00812503",
             47 => x"00c12583",
             48 => x"01010113",
             49 => x"30200073",
         1023   => "1111111" & "11101" & "11110" & "111" & "11101" & "1001100",  -- Just to make sure all bits are toggled
         others => "000000000001"      & "00001" & "000" & "00001" & "0010011"   -- r01 <= r01 + 1
    );
    attribute keep      : string;
    attribute ram_style : string;
    
    signal data_valid : STD_LOGIC := '1';
begin

------------------------
-- PROGRAM ROM INTERFACE
------------------------
process(clk)
    begin
        if rising_edge(clk) then
            if progmem_addr(31 downto 12) = x"F0000" then 
                progmem_data <= prog_memory(to_integer(unsigned(progmem_addr(11 downto 2))));
            else
                progmem_data <= (others => '0');
            end if; 
            progmem_data_valid <= progmem_enable;
            progmem_data_addr  <= progmem_addr;
        end if;
    end process;

---------------------------------------------------------
-- MAIN SYSTEM BUS INTERFACE
---------------------------------------------------------
process(bus_enable, bus_write_mask, data_valid)
begin
    bus_busy <= '0';
    if bus_enable = '1' and bus_write_mask = "0000" then
        if data_valid = '0' then
           bus_busy <= '1';
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        data_valid <= '0';
        if bus_enable = '1' then
            -- Writes are ignored

            if bus_write_mask = "0000" and data_valid = '0' then
                data_valid <= '1';
            end if;
            bus_read_data <= prog_memory(to_integer(unsigned(bus_addr)));
        end if;
    end if;
end process;

end Behavioral;
