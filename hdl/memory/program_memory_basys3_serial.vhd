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
              0 => x"ff010113",
              1 => x"00812623",
              2 => x"01010413",
              3 => x"00000013",
              4 => x"8381a783",
              5 => x"0007c783",
              6 => x"0ff7f793",
              7 => x"fe079ae3",
              8 => x"8341a783",
              9 => x"0007c783",
             10 => x"0ff7f793",
             11 => x"00078513",
             12 => x"00c12403",
             13 => x"01010113",
             14 => x"00008067",
             15 => x"fe010113",
             16 => x"00812e23",
             17 => x"02010413",
             18 => x"fea42623",
             19 => x"00000013",
             20 => x"8301a783",
             21 => x"0007c783",
             22 => x"0ff7f793",
             23 => x"fe079ae3",
             24 => x"82c1a783",
             25 => x"fec42703",
             26 => x"0ff77713",
             27 => x"00e78023",
             28 => x"fec42783",
             29 => x"00078513",
             30 => x"01c12403",
             31 => x"02010113",
             32 => x"00008067",
             33 => x"fd010113",
             34 => x"02112623",
             35 => x"02812423",
             36 => x"03010413",
             37 => x"fca42e23",
             38 => x"fe042623",
             39 => x"02c0006f",
             40 => x"fdc42783",
             41 => x"0007c783",
             42 => x"00078513",
             43 => x"f91ff0ef",
             44 => x"fdc42783",
             45 => x"00178793",
             46 => x"fcf42e23",
             47 => x"fec42783",
             48 => x"00178793",
             49 => x"fef42623",
             50 => x"fdc42783",
             51 => x"0007c783",
             52 => x"fc0798e3",
             53 => x"fec42783",
             54 => x"00078513",
             55 => x"02c12083",
             56 => x"02812403",
             57 => x"03010113",
             58 => x"00008067",
             59 => x"fd010113",
             60 => x"02812623",
             61 => x"03010413",
             62 => x"fca42e23",
             63 => x"fe042623",
             64 => x"01c0006f",
             65 => x"fdc42783",
             66 => x"00178793",
             67 => x"fcf42e23",
             68 => x"fec42783",
             69 => x"00178793",
             70 => x"fef42623",
             71 => x"fdc42783",
             72 => x"0007c783",
             73 => x"fe0790e3",
             74 => x"fec42783",
             75 => x"00078513",
             76 => x"02c12403",
             77 => x"03010113",
             78 => x"00008067",
             79 => x"ff010113",
             80 => x"00112623",
             81 => x"00812423",
             82 => x"01010413",
             83 => x"f00007b7",
             84 => x"20878513",
             85 => x"f31ff0ef",
             86 => x"f00007b7",
             87 => x"21c78513",
             88 => x"f25ff0ef",
             89 => x"82418513",
             90 => x"f85ff0ef",
             91 => x"00050793",
             92 => x"03078793",
             93 => x"00078513",
             94 => x"ec5ff0ef",
             95 => x"f00007b7",
             96 => x"22878513",
             97 => x"f01ff0ef",
             98 => x"82418513",
             99 => x"ef9ff0ef",
            100 => x"82418513",
            101 => x"f59ff0ef",
            102 => x"00050793",
            103 => x"03078793",
            104 => x"00078513",
            105 => x"e99ff0ef",
            106 => x"100007b7",
            107 => x"01078513",
            108 => x"ed5ff0ef",
            109 => x"8401a783",
            110 => x"00010737",
            111 => x"fff70713",
            112 => x"00e7a023",
            113 => x"e3dff0ef",
            114 => x"00050793",
            115 => x"00078513",
            116 => x"e6dff0ef",
            117 => x"83c1a783",
            118 => x"0007a703",
            119 => x"83c1a783",
            120 => x"00170713",
            121 => x"00e7a023",
            122 => x"fddff06f",
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
