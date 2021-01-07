--###############################################################################
--# ./hdl/cpu/decode/intex_unit.vhd  - Interrupt and Exception handler
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
use IEEE.NUMERIC_STD.ALL;

use work.cpu_constants.ALL;

entity intex_unit is
    Port (  clk                       : in  STD_LOGIC;
            reset                     : in  STD_LOGIC;

            intex_exception_raise     : out STD_LOGIC;
            intex_exception_cause     : out STD_LOGIC_VECTOR (31 downto 0);
            intex_exception_vector    : out STD_LOGIC_VECTOR (31 downto 0);

            exec_except_instr_misaligned : in std_logic := '0';
            exec_except_instr_access     : in std_logic := '0';
            exec_except_illegal_instr    : in std_logic := '0';
            exec_except_breakpoint       : in std_logic := '0';
            exec_except_load_misaligned  : in std_logic := '0';
            exec_except_load_access      : in std_logic := '0';
            exec_except_store_misaligned : in std_logic := '0';
            exec_except_store_access     : in std_logic := '0';

            -----------------------------
            -- From the CSR Unit
            -----------------------------
            m_ie         : in  STD_LOGIC;

            -- Interrupt enable (external, timer, software)
            m_eie        : in  STD_LOGIC;
            m_tie        : in  STD_LOGIC;
            m_sie        : in  STD_LOGIC;

            -- Trap vectoring
            m_tvec_base  : in  STD_LOGIC_VECTOR(31 downto 0);
            m_tvec_flag  : in  STD_LOGIC);
end intex_unit;

architecture Behavioral of intex_unit is
   signal cause_code     : STD_LOGIC_VECTOR (31 downto 0);
begin
   intex_exception_raise  <= reset 
                          OR exec_except_instr_misaligned
                          OR exec_except_instr_access
                          OR exec_except_illegal_instr
                          OR exec_except_breakpoint
                          OR exec_except_load_misaligned
                          OR exec_except_load_access
                          OR exec_except_store_misaligned
                          OR exec_except_store_access;

   -- Note - priority encoder
   -- Note INSTR_MISALIGNED and CAUSE_INSTR_ACCESS_FAULT must have priority over CAUSE_BREAKPOINT 
   -- Because a missaligned instruction is also an illegal instruction 
   cause_code           <= (others=>'0') when reset = '1' else
                            CAUSE_INSTR_MISALIGNED      when exec_except_instr_misaligned = '1' else
                            CAUSE_INSTR_ACCESS_FAULT    when exec_except_instr_access     = '1' else
                            CAUSE_ILLEGAL_INSTR         when exec_except_illegal_instr    = '1' else
                            CAUSE_BREAKPOINT            when exec_except_breakpoint       = '1' else
                            CAUSE_LOAD_ADDR_MISALIGNED  when exec_except_load_misaligned  = '1' else
                            CAUSE_LOAD_ACCESS_FAULT     when exec_except_load_access      = '1' else
                            CAUSE_STORE_ADDR_MISALIGNED when exec_except_store_misaligned = '1' else
                            CAUSE_STORE_ACCESS_FAULT    when exec_except_store_access     = '1' else
                        --  CAUSE_ENV_CALL_U_MODE       when
                        --  CAUSE_ENV_CALL_S_MODE       when
                        --  CAUSE_ENV_CALL_M_MODE       when
                        --  CAUSE_INSTR_PAGE_FAULT      when
                        --  CAUSE_LOAD_PAGE_FAULT       when
                        --  CAUSE_STORE_PAGE_FAULT      when
                            (others => '0');

   intex_exception_cause <= cause_code;

   intex_exception_vector <= x"F0000000" when reset = '1' else
                             m_tvec_base when m_tvec_flag = '0' else
                             std_logic_Vector(unsigned(m_tvec_base) + unsigned(cause_code(29 downto 0)&"00"));
end Behavioral;
