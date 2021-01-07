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
    constant PC_JMP_UNUSED               : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
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
    
    -- CSR functions                  
    constant CSR_NOACTION                : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant CSR_WRITE                   : STD_LOGIC_VECTOR(2 downto 0) := "001"; 
    constant CSR_WRITESET                : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant CSR_WRITECLEAR              : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant CSR_READ                    : STD_LOGIC_VECTOR(2 downto 0) := "100"; 
    constant CSR_READWRITE               : STD_LOGIC_VECTOR(2 downto 0) := "101"; 
    constant CSR_READWRITESET            : STD_LOGIC_VECTOR(2 downto 0) := "110";
    constant CSR_READWRITECLEAR          : STD_LOGIC_VECTOR(2 downto 0) := "111";
         
         
    -- Barrel shifter options
    constant SHIFTER_LEFT_LOGICAL        : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant SHIFTER_LEFT_ARITH          : STD_LOGIC_VECTOR(1 downto 0) := "01";  -- not used
    constant SHIFTER_RIGHT_LOGICAL       : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant SHIFTER_RIGHT_ARITH         : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    -- Selction of what is going to the register file
    constant RESULT_ALU                  : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant RESULT_SHIFTER              : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant RESULT_MEMORY               : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant RESULT_CSR                  : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant RESULT_PC_PLUS_4            : STD_LOGIC_VECTOR(2 downto 0) := "100";
    
    constant SIGN_EX_WIDTH_B             : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant SIGN_EX_WIDTH_H             : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant SIGN_EX_WIDTH_W             : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant SIGN_EX_WIDTH_X             : STD_LOGIC_VECTOR(1 downto 0) := "11";
    
    constant SIGN_EX_SIGNED              : STD_LOGIC_VECTOR(0 downto 0) := "0";
    constant SIGN_EX_UNSIGNED            : STD_LOGIC_VECTOR(0 downto 0) := "1";   

    constant EXCEPTION_NONE              : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant EXCEPTION_RESET             : STD_LOGIC_VECTOR(2 downto 0) := "001";

    -- Values for the mcause CSR
    constant CAUSE_INSTR_MISALIGNED      : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    constant CAUSE_INSTR_ACCESS_FAULT    : STD_LOGIC_VECTOR(31 downto 0) := x"00000001";
    constant CAUSE_ILLEGAL_INSTR         : STD_LOGIC_VECTOR(31 downto 0) := x"00000002";
    constant CAUSE_BREAKPOINT            : STD_LOGIC_VECTOR(31 downto 0) := x"00000003";
    constant CAUSE_LOAD_ADDR_MISALIGNED  : STD_LOGIC_VECTOR(31 downto 0) := x"00000004";
    constant CAUSE_LOAD_ACCESS_FAULT     : STD_LOGIC_VECTOR(31 downto 0) := x"00000005";
    constant CAUSE_STORE_ADDR_MISALIGNED : STD_LOGIC_VECTOR(31 downto 0) := x"00000006";
    constant CAUSE_STORE_ACCESS_FAULT    : STD_LOGIC_VECTOR(31 downto 0) := x"00000007";
    constant CAUSE_ENV_CALL_U_MODE       : STD_LOGIC_VECTOR(31 downto 0) := x"00000008";
    constant CAUSE_ENV_CALL_S_MODE       : STD_LOGIC_VECTOR(31 downto 0) := x"00000009";
    constant CAUSE_ENV_CALL_M_MODE       : STD_LOGIC_VECTOR(31 downto 0) := x"0000000B";
    constant CAUSE_INSTR_PAGE_FAULT      : STD_LOGIC_VECTOR(31 downto 0) := x"0000000C";
    constant CAUSE_LOAD_PAGE_FAULT       : STD_LOGIC_VECTOR(31 downto 0) := x"0000000D";
    constant CAUSE_STORE_PAGE_FAULT      : STD_LOGIC_VECTOR(31 downto 0) := x"0000000F";

    constant CAUSE_U_INTERRUPT_SOFTWARE  : STD_LOGIC_VECTOR(31 downto 0) := x"80000000";
    constant CAUSE_S_INTERRUPT_SOFTWARE  : STD_LOGIC_VECTOR(31 downto 0) := x"80000001";
    constant CAUSE_M_INTERRUPT_SOFTWARE  : STD_LOGIC_VECTOR(31 downto 0) := x"80000003";
    constant CAUSE_U_INTERRUPT_TIMER     : STD_LOGIC_VECTOR(31 downto 0) := x"80000004";
    constant CAUSE_S_INTERRUPT_TIMER     : STD_LOGIC_VECTOR(31 downto 0) := x"80000005";
    constant CAUSE_M_INTERRUPT_TIMER     : STD_LOGIC_VECTOR(31 downto 0) := x"80000007";
    constant CAUSE_U_INTERRUPT_EXTERNAL  : STD_LOGIC_VECTOR(31 downto 0) := x"80000008";
    constant CAUSE_S_INTERRUPT_EXTERNAL  : STD_LOGIC_VECTOR(31 downto 0) := x"80000009";
    constant CAUSE_M_INTERRUPT_EXTERNAL  : STD_LOGIC_VECTOR(31 downto 0) := x"8000000B";
end package cpu_constants;
 
package body cpu_constants is
 
end package body cpu_constants;
