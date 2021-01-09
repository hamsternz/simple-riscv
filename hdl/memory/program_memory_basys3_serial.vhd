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
              5 => x"144000ef",
              6 => x"00100073",
              7 => x"ff010113",
              8 => x"00812623",
              9 => x"01010413",
             10 => x"00000013",
             11 => x"86c1a783",
             12 => x"0007c783",
             13 => x"0ff7f793",
             14 => x"fe079ae3",
             15 => x"8681a783",
             16 => x"0007c783",
             17 => x"0ff7f793",
             18 => x"00078513",
             19 => x"00c12403",
             20 => x"01010113",
             21 => x"00008067",
             22 => x"fe010113",
             23 => x"00812e23",
             24 => x"02010413",
             25 => x"fea42623",
             26 => x"00000013",
             27 => x"8641a783",
             28 => x"0007c783",
             29 => x"0ff7f793",
             30 => x"fe079ae3",
             31 => x"8601a783",
             32 => x"fec42703",
             33 => x"0ff77713",
             34 => x"00e78023",
             35 => x"fec42783",
             36 => x"00078513",
             37 => x"01c12403",
             38 => x"02010113",
             39 => x"00008067",
             40 => x"fd010113",
             41 => x"02112623",
             42 => x"02812423",
             43 => x"03010413",
             44 => x"fca42e23",
             45 => x"fe042623",
             46 => x"02c0006f",
             47 => x"fdc42783",
             48 => x"0007c783",
             49 => x"00078513",
             50 => x"f91ff0ef",
             51 => x"fdc42783",
             52 => x"00178793",
             53 => x"fcf42e23",
             54 => x"fec42783",
             55 => x"00178793",
             56 => x"fef42623",
             57 => x"fdc42783",
             58 => x"0007c783",
             59 => x"fc0798e3",
             60 => x"fec42783",
             61 => x"00078513",
             62 => x"02c12083",
             63 => x"02812403",
             64 => x"03010113",
             65 => x"00008067",
             66 => x"fd010113",
             67 => x"02812623",
             68 => x"03010413",
             69 => x"fca42e23",
             70 => x"fe042623",
             71 => x"01c0006f",
             72 => x"fdc42783",
             73 => x"00178793",
             74 => x"fcf42e23",
             75 => x"fec42783",
             76 => x"00178793",
             77 => x"fef42623",
             78 => x"fdc42783",
             79 => x"0007c783",
             80 => x"fe0790e3",
             81 => x"fec42783",
             82 => x"00078513",
             83 => x"02c12403",
             84 => x"03010113",
             85 => x"00008067",
             86 => x"ff010113",
             87 => x"00112623",
             88 => x"00812423",
             89 => x"01010413",
             90 => x"82418513",
             91 => x"f35ff0ef",
             92 => x"83818513",
             93 => x"f2dff0ef",
             94 => x"85818513",
             95 => x"f8dff0ef",
             96 => x"00050793",
             97 => x"03078793",
             98 => x"00078513",
             99 => x"ecdff0ef",
            100 => x"84418513",
            101 => x"f0dff0ef",
            102 => x"85818513",
            103 => x"f05ff0ef",
            104 => x"85818513",
            105 => x"f65ff0ef",
            106 => x"00050793",
            107 => x"03078793",
            108 => x"00078513",
            109 => x"ea5ff0ef",
            110 => x"100007b7",
            111 => x"01078513",
            112 => x"ee1ff0ef",
            113 => x"8741a783",
            114 => x"00010737",
            115 => x"fff70713",
            116 => x"00e7a023",
            117 => x"e49ff0ef",
            118 => x"00050793",
            119 => x"00078513",
            120 => x"e79ff0ef",
            121 => x"8701a783",
            122 => x"0007a703",
            123 => x"8701a783",
            124 => x"00170713",
            125 => x"00e7a023",
            126 => x"fddff06f",
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
