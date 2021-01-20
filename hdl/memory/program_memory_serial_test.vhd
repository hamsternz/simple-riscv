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
              5 => x"158000ef",
              6 => x"00100073",
              7 => x"ff010113",
              8 => x"00812623",
              9 => x"01010413",
             10 => x"00000013",
             11 => x"100007b7",
             12 => x"06c7a783",
             13 => x"0007c783",
             14 => x"0ff7f793",
             15 => x"fe0798e3",
             16 => x"100007b7",
             17 => x"0687a783",
             18 => x"0007c783",
             19 => x"0ff7f793",
             20 => x"00078513",
             21 => x"00c12403",
             22 => x"01010113",
             23 => x"00008067",
             24 => x"fe010113",
             25 => x"00812e23",
             26 => x"02010413",
             27 => x"fea42623",
             28 => x"00000013",
             29 => x"100007b7",
             30 => x"0647a783",
             31 => x"0007c783",
             32 => x"0ff7f793",
             33 => x"fe0798e3",
             34 => x"100007b7",
             35 => x"0607a783",
             36 => x"fec42703",
             37 => x"0ff77713",
             38 => x"00e78023",
             39 => x"fec42783",
             40 => x"00078513",
             41 => x"01c12403",
             42 => x"02010113",
             43 => x"00008067",
             44 => x"fd010113",
             45 => x"02112623",
             46 => x"02812423",
             47 => x"03010413",
             48 => x"fca42e23",
             49 => x"fe042623",
             50 => x"0300006f",
             51 => x"fdc42783",
             52 => x"0007c783",
             53 => x"00078513",
             54 => x"00000097",
             55 => x"f88080e7",
             56 => x"fdc42783",
             57 => x"00178793",
             58 => x"fcf42e23",
             59 => x"fec42783",
             60 => x"00178793",
             61 => x"fef42623",
             62 => x"fdc42783",
             63 => x"0007c783",
             64 => x"fc0796e3",
             65 => x"fec42783",
             66 => x"00078513",
             67 => x"02c12083",
             68 => x"02812403",
             69 => x"03010113",
             70 => x"00008067",
             71 => x"fd010113",
             72 => x"02812623",
             73 => x"03010413",
             74 => x"fca42e23",
             75 => x"fe042623",
             76 => x"01c0006f",
             77 => x"fdc42783",
             78 => x"00178793",
             79 => x"fcf42e23",
             80 => x"fec42783",
             81 => x"00178793",
             82 => x"fef42623",
             83 => x"fdc42783",
             84 => x"0007c783",
             85 => x"fe0790e3",
             86 => x"fec42783",
             87 => x"00078513",
             88 => x"02c12403",
             89 => x"03010113",
             90 => x"00008067",
             91 => x"ff010113",
             92 => x"00112623",
             93 => x"00812423",
             94 => x"01010413",
             95 => x"100007b7",
             96 => x"02478513",
             97 => x"00000097",
             98 => x"f2c080e7",
             99 => x"100007b7",
            100 => x"03878513",
            101 => x"00000097",
            102 => x"f1c080e7",
            103 => x"100007b7",
            104 => x"05878513",
            105 => x"00000097",
            106 => x"f78080e7",
            107 => x"00050793",
            108 => x"03078793",
            109 => x"00078513",
            110 => x"00000097",
            111 => x"ea8080e7",
            112 => x"100007b7",
            113 => x"04478513",
            114 => x"00000097",
            115 => x"ee8080e7",
            116 => x"100007b7",
            117 => x"05878513",
            118 => x"00000097",
            119 => x"ed8080e7",
            120 => x"100007b7",
            121 => x"05878513",
            122 => x"00000097",
            123 => x"f34080e7",
            124 => x"00050793",
            125 => x"03078793",
            126 => x"00078513",
            127 => x"00000097",
            128 => x"e64080e7",
            129 => x"100007b7",
            130 => x"01078513",
            131 => x"00000097",
            132 => x"ea4080e7",
            133 => x"100007b7",
            134 => x"0747a783",
            135 => x"00010737",
            136 => x"fff70713",
            137 => x"00e7a023",
            138 => x"00000097",
            139 => x"df4080e7",
            140 => x"00050793",
            141 => x"00078513",
            142 => x"00000097",
            143 => x"e28080e7",
            144 => x"100007b7",
            145 => x"0707a783",
            146 => x"0007a703",
            147 => x"100007b7",
            148 => x"0707a783",
            149 => x"00170713",
            150 => x"00e7a023",
            151 => x"fcdff06f",
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
