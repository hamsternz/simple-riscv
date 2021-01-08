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
              0 => x"0010c0b3",
              1 => x"00214133",
              2 => x"00108093",
              3 => x"00108133",
              4 => x"00110133",
              5 => x"00208133",
              6 => x"fffff137",
              7 => x"40215113",
              8 => x"00415113",
              9 => x"00211113",
             10 => x"12345117",
             11 => x"100003b7",
             12 => x"00238023",
             13 => x"002380a3",
             14 => x"00238123",
             15 => x"002381a3",
             16 => x"0003a183",
             17 => x"00239023",
             18 => x"00239123",
             19 => x"0003a183",
             20 => x"89abd137",
             21 => x"def10113",
             22 => x"0023a023",
             23 => x"0003a183",
             24 => x"00039103",
             25 => x"00239103",
             26 => x"00038103",
             27 => x"00138103",
             28 => x"00238103",
             29 => x"00338103",
             30 => x"0003d103",
             31 => x"0023d103",
             32 => x"0003c103",
             33 => x"0013c103",
             34 => x"0023c103",
             35 => x"0033c103",
             36 => x"66666137",
             37 => x"66610113",
             38 => x"ccccd1b7",
             39 => x"ccc18193",
             40 => x"00310233",
             41 => x"00218233",
             42 => x"40310233",
             43 => x"40218233",
             44 => x"00311233",
             45 => x"00219233",
             46 => x"00312233",
             47 => x"0021a233",
             48 => x"00313233",
             49 => x"0021b233",
             50 => x"00314233",
             51 => x"0021c233",
             52 => x"00315233",
             53 => x"0021d233",
             54 => x"40315233",
             55 => x"4021d233",
             56 => x"00316233",
             57 => x"0021e233",
             58 => x"00317233",
             59 => x"0021f233",
             60 => x"66618213",
             61 => x"6661a213",
             62 => x"6661b213",
             63 => x"6661c213",
             64 => x"6661e213",
             65 => x"6661f213",
             66 => x"00619213",
             67 => x"0061d213",
             68 => x"4061d213",
             69 => x"00007193",
             70 => x"0080026f",
             71 => x"0011e193",
             72 => x"0021e193",
             73 => x"0041e193",
             74 => x"00214133",
             75 => x"00810193",
             76 => x"00810213",
             77 => x"00418463",
             78 => x"00116113",
             79 => x"00419463",
             80 => x"00216113",
             81 => x"0041c463",
             82 => x"00416113",
             83 => x"0041d463",
             84 => x"00816113",
             85 => x"0041e463",
             86 => x"01016113",
             87 => x"0041f463",
             88 => x"02016113",
             89 => x"00214133",
             90 => x"00818213",
             91 => x"00418463",
             92 => x"00116113",
             93 => x"00419463",
             94 => x"00216113",
             95 => x"0041c463",
             96 => x"00416113",
             97 => x"0041d463",
             98 => x"00816113",
             99 => x"0041e463",
            100 => x"01016113",
            101 => x"0041f463",
            102 => x"02016113",
            103 => x"00214133",
            104 => x"fe010213",
            105 => x"00418463",
            106 => x"00116113",
            107 => x"00419463",
            108 => x"00216113",
            109 => x"0041c463",
            110 => x"00416113",
            111 => x"0041d463",
            112 => x"00816113",
            113 => x"0041e463",
            114 => x"01016113",
            115 => x"0041f463",
            116 => x"02016113",
            117 => x"f11022f3",
            118 => x"f12022f3",
            119 => x"f13022f3",
            120 => x"f14022f3",
            121 => x"f0000137",
            122 => x"20016113",
            123 => x"30511173",
            124 => x"20016113",
            125 => x"fff0007e",
            126 => x"00000000",
            127 => x"00000000",
            128 => x"342012f3",
            129 => x"341012f3",
            130 => x"00108093",
            131 => x"00108093",
            132 => x"00108093",
            133 => x"00108093",
            134 => x"00108093",
            135 => x"00108093",
            136 => x"00108093",
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
