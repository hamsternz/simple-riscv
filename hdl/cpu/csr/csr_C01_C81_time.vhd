--###############################################################################
--# ./hdl/cpu/exec/csr_F14.vhd  - CSR 0xF14 - HART ID register
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

entity csr_C01_C81_time is
  port ( clk          : in  STD_LOGIC;  
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;  
         csr_high_word: in  STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;  
         csr_failed   : out STD_LOGIC;  
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0)l
         max_count    : in  STD_LOGIC_VECTOR( 9 downto 0)); 
end entity;

architecture Behavioral of csr_C01_C81_time
   signal complete : std_logic := '0';
   signal failed   : std_logic := '0';
   signal result   : std_logic_vector(31 downto 0) := (others => '0');
   signal counter  : unsigned(63 downto 0) := (others => '0');
   signal divider  : unsigned(9 downto 0) := (others => '0');

begin
   csr_complete <= complete;
   csr_failed   <= failed;
   csr_result   <= result;

process(clk) 
   begin
      if rising_edge(clk) then
         result      <= (others => '0');
         complete    <= '0';
         failed      <= '0';
         if csr_active = '1' and complete = '0' and failed = '0' then
            case csr_mode is
               when CSR_NOACTION =>
                  complete    <= '1';
               when CSR_READ     =>
                  if csr_high_word = '0' then
                     complete    <= '1';
                     value <= std_logic_vector(counter(63 downto 32));
                     report "READ cycle high";
                  else
                     complete    <= '1';
                     value <= std_logic_vector(counter(31 downto 0));
                     report "READ cycle";
                  end if;
               when others   =>
                  failed      <= '1';
            end case; 
         end if;
         if divider = 0 then
            counter <= counter+1;
            divider <= max_count;
         else
            divider <= divider-1;
      end if;
   end process;  
end Behavioral;
