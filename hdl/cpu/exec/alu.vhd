--###############################################################################
--# ./hdl/cpu/exec/alu.vhd  - DESCRIPTION_NEEDED
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

entity alu is
  port ( clk          : in  STD_LOGIC;  
         alu_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         alu_active   : in  STD_LOGIC;  
         alu_complete : out STD_LOGIC;  
         alu_failed   : out STD_LOGIC := '0';  
         a            : in  STD_LOGIC_VECTOR(31 downto 0);
         b            : in  STD_LOGIC_VECTOR(31 downto 0);
         c            : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
end entity;

architecture Behavioral of alu is
begin
   alu_complete <= alu_active;
   
process(alu_mode, a, b)
    variable a_dash : unsigned(31 downto 0);
    variable b_dash : unsigned(31 downto 0);
    begin
        a_dash := unsigned(a);
        b_dash := unsigned(b);
        if alu_mode(0) = '0' then
            a_dash(31) := not a_dash(31);
            b_dash(31) := not b_dash(31);
        end if;
        case alu_mode is
            when ALU_OR =>
                c <= a OR b;
            when ALU_AND =>
                c <= a AND b;
            when ALU_XOR =>
                c <= a XOR b;
            when ALU_UNUSED =>
                c <= a XOR b;
            when ALU_ADD =>
                c <= std_logic_vector(unsigned(a) + unsigned(b));
            when ALU_SUB =>
                c <= std_logic_vector(unsigned(a) - unsigned(b));
            when ALU_LESS_THAN_SIGNED | ALU_LESS_THAN_UNSIGNED =>
                c <= (others => '0');
                if a_dash < b_dash then
                   c(0) <= '1';
                end if;                  
            when others =>
        end case;
    end process;
end Behavioral;
