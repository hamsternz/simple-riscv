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
              0 => x"20001197",
              1 => x"80018193",
              2 => x"20001117",
              3 => x"ff810113",
              4 => x"00010433",
              5 => x"0040006f",
              6 => x"e00002b7",
              7 => x"02028293",
              8 => x"0042a303",
              9 => x"0002a503",
             10 => x"0042a583",
             11 => x"fe659ae3",
             12 => x"00550513",
             13 => x"00a66463",
             14 => x"00158593",
             15 => x"fff00313",
             16 => x"0062a623",
             17 => x"00a2a423",
             18 => x"00b2a623",
             19 => x"00000297",
             20 => x"05028293",
             21 => x"30529073",
             22 => x"08000293",
             23 => x"3042a073",
             24 => x"00800293",
             25 => x"3002a073",
             26 => x"e00002b7",
             27 => x"01428293",
             28 => x"e0000337",
             29 => x"01030313",
             30 => x"10000537",
             31 => x"01050513",
             32 => x"000105b7",
             33 => x"fff58593",
             34 => x"00b2a023",
             35 => x"00b32023",
             36 => x"00052583",
             37 => x"00b32023",
             38 => x"ff9ff06f",
             39 => x"34029073",
             40 => x"20000297",
             41 => x"f6028293",
             42 => x"0062a223",
             43 => x"00a2a423",
             44 => x"00b2a623",
             45 => x"34001373",
             46 => x"0062a023",
             47 => x"e00002b7",
             48 => x"02028293",
             49 => x"0042a303",
             50 => x"0002a503",
             51 => x"0042a583",
             52 => x"fe659ae3",
             53 => x"1f450513",
             54 => x"00a66463",
             55 => x"00158593",
             56 => x"fff00313",
             57 => x"0062a623",
             58 => x"00a2a423",
             59 => x"00b2a623",
             60 => x"10000537",
             61 => x"01050513",
             62 => x"00052583",
             63 => x"00158593",
             64 => x"00b52023",
             65 => x"20000297",
             66 => x"efc28293",
             67 => x"00c2a583",
             68 => x"0082a503",
             69 => x"0042a303",
             70 => x"0002a283",
             71 => x"30200073",
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
