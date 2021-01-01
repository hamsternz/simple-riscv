--###############################################################################
--# ./hdl/cpu/exec/csr_unit.vhd  - Unit for processing CSR instructions
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

entity csr_unit is
  port ( clk          : in  STD_LOGIC;  
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_reg      : in  STD_LOGIC_VECTOR(11 downto 0);
         csr_active   : in  STD_LOGIC;  
         csr_complete : out STD_LOGIC;  
         csr_failed   : out STD_LOGIC;  
         a            : in  STD_LOGIC_VECTOR(31 downto 0);
         b            : in  STD_LOGIC_VECTOR(31 downto 0);
         c            : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
end entity;

architecture Behavioral of csr_unit is
begin
   csr_complete <= csr_active;
   csr_failed   <= '0';
   
process(csr_mode, a, b)
    begin
        case csr_mode is
            when CSR_NOACTION       =>
                c <= a OR b;
            when CSR_WRITE          =>
                c <= a OR b;
            when CSR_WRITESET       =>
                c <= a OR b;
            when CSR_WRITECLEAR     =>
                c <= a OR b;
            when CSR_READ           =>
                c <= a OR b;
            when CSR_READWRITE      =>
                c <= a OR b;
            when CSR_READWRITESET   =>
                c <= a OR b;
            when CSR_READWRITECLEAR =>
                c <= a OR b;
            when others =>
                c <= (others => '0');
        end case;
    end process;
end Behavioral;
