--###############################################################################
--# ./hdl/cpu/exec/csr_340.vhd  - CSR 0x340 - mscratch register
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

entity csr_340_mscratch is
  port ( clk          : in  STD_LOGIC;  
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;  
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;  
         csr_failed   : out STD_LOGIC;  
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
end entity;

architecture Behavioral of csr_340_mscratch is
   signal complete     : std_logic := '0';
   signal failed       : std_logic := '0';
   signal result       : std_logic_vector(31 downto 0) := (others => '0');
   signal stored_value : std_logic_vector(31 downto 0) := (others => '0');
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

               when CSR_WRITE =>
                  complete     <= '1';
                  stored_value <= CSR_VALUE;
                  report "WRITE mscratch CSR";

               when CSR_WRITESET =>
                  complete     <= '1';
                  stored_value <= stored_value OR CSR_VALUE;
                  report "WRITESET mscratch CSR";

               when CSR_WRITECLEAR =>
                  complete     <= '1';
                  stored_value <= stored_value AND NOT CSR_VALUE;
                  report "WRITECLEAR mscratch CSR";

               when CSR_READ     =>
                  complete     <= '1';
                  result       <= stored_value;
                  report "READ mscratch CSR";

               when CSR_READWRITE =>
                  complete     <= '1';
                  result       <= stored_value;
                  stored_value <= CSR_VALUE;
                  report "READWRITE mscratch CSR";

               when CSR_READWRITESET =>
                  complete     <= '1';
                  result       <= stored_value;
                  stored_value <= stored_value OR CSR_VALUE;
                  report "READWRITESET mscratch CSR";

               when CSR_READWRITECLEAR =>
                  complete     <= '1';
                  result       <= stored_value;
                  stored_value <= stored_value AND NOT CSR_VALUE;
                  report "READWRITECLEAR mscratch CSR";

               when others   =>
                  failed      <= '1';
            end case;
         end if;
      end if;
   end process;
end Behavioral;
