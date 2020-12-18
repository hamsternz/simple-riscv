--###############################################################################
--# ./hdl/cpu/cpu_constants.pkg - Constants used inside the CPU design
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

package cpu_constants is

  -- MUXing of the A and B data
    constant A_BUS_REGISTER              : STD_LOGIC_VECTOR(0 downto 0) := "0";
    constant A_BUS_PC                    : STD_LOGIC_VECTOR(0 downto 0) := "1";
    
    constant B_BUS_REGISTER              : STD_LOGIC_VECTOR(0 downto 0) := "0";
    constant B_BUS_IMMEDIATE             : STD_LOGIC_VECTOR(0 downto 0) := "1";
    
    -- Deciding how the Program counter updates
    constant PC_JMP_RELATIVE             : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant PC_JMP_REG_RELATIVE         : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant PC_JMP_RELATIVE_CONDITIONAL : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant PC_RESET_STATE              : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    -- Tests for conditional branching  
    constant BRANCH_TEST_EQ              : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant BRANCH_TEST_NE              : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant BRANCH_TEST_TRUE            : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant BRANCH_TEST_FALSE           : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant BRANCH_TEST_LT              : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant BRANCH_TEST_GE              : STD_LOGIC_VECTOR(2 downto 0) := "101";
    constant BRANCH_TEST_LTU             : STD_LOGIC_VECTOR(2 downto 0) := "110";
    constant BRANCH_TEST_GEU             : STD_LOGIC_VECTOR(2 downto 0) := "111";
    
    -- Logical and addition functions
    constant ALU_OR                      : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant ALU_AND                     : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant ALU_XOR                     : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant ALU_UNUSED                  : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant ALU_ADD                     : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant ALU_SUB                     : STD_LOGIC_VECTOR(2 downto 0) := "101";
    constant ALU_LESS_THAN_SIGNED        : STD_LOGIC_VECTOR(2 downto 0) := "110";
    constant ALU_LESS_THAN_UNSIGNED      : STD_LOGIC_VECTOR(2 downto 0) := "111";
    
    -- Barrel shifter options
    constant SHIFTER_LEFT_LOGICAL        : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant SHIFTER_LEFT_ARITH          : STD_LOGIC_VECTOR(1 downto 0) := "01";  -- not used
    constant SHIFTER_RIGHT_LOGICAL       : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant SHIFTER_RIGHT_ARITH         : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    -- Selction of what is going to the reginster file
    constant RESULT_ALU                  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant RESULT_SHIFTER              : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant RESULT_MEMORY               : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant RESULT_PC_PLUS_4            : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    constant SIGN_EX_WIDTH_B             : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant SIGN_EX_WIDTH_H             : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant SIGN_EX_WIDTH_W             : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant SIGN_EX_WIDTH_X             : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    constant SIGN_EX_SIGNED              : STD_LOGIC_VECTOR(0 downto 0) := "0";
    constant SIGN_EX_UNSIGNED            : STD_LOGIC_VECTOR(0 downto 0) := "1";   
end package cpu_constants;
 
package body cpu_constants is
 
end package body cpu_constants;
