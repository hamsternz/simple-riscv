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
    Port (  clk                          : in  STD_LOGIC;
            reset                        : in  STD_LOGIC;

            interrupt_timer              : in  STD_LOGIC;
            interrupt_external           : in  STD_LOGIC;
            interrupt_software           : in  STD_LOGIC;

            intex_exception_raise        : out STD_LOGIC;
            intex_exception_cause        : out STD_LOGIC_VECTOR (31 downto 0);
            intex_exception_vector       : out STD_LOGIC_VECTOR (31 downto 0);

            intex_m_eip                  : out STD_LOGIC;
            intex_m_tip                  : out STD_LOGIC;
            intex_m_sip                  : out STD_LOGIC;

            exec_except_instr_misaligned : in  std_logic;
            exec_except_instr_access     : in  std_logic;
            exec_except_illegal_instr    : in  std_logic;
            exec_except_ebreak           : in  std_logic;
            exec_except_ecall            : in  std_logic;
            exec_except_load_misaligned  : in  std_logic;
            exec_except_load_access      : in  std_logic;
            exec_except_store_misaligned : in  std_logic;
            exec_except_store_access     : in  std_logic;

            exec_setting_mcause          : in  std_logic;
            exec_setting_mcause_value    : in  std_logic_vector(31 downto 0);
            -----------------------------
            -- From the CSR Unit
            -----------------------------
            exec_m_ie         : in  STD_LOGIC;
            -- Interrupt enable (external, timer, software)
            exec_m_eie        : in  STD_LOGIC;
            exec_m_tie        : in  STD_LOGIC;
            exec_m_sie        : in  STD_LOGIC;

            exec_m_tvec_base  : in  STD_LOGIC_VECTOR(31 downto 0);
            exec_m_tvec_flag  : in  STD_LOGIC);
end intex_unit;

architecture Behavioral of intex_unit is
   signal cause_code      : STD_LOGIC_VECTOR (31 downto 0);
   signal exception_raise : STD_LOGIC;
   signal intr_vector     : STD_LOGIC_VECTOR (31 downto 0);

   signal interrupt_timer_last     : STD_LOGIC := '0';
   signal interrupt_external_last  : STD_LOGIC := '0';
   signal interrupt_software_last  : STD_LOGIC := '0';
   signal m_eip                    : STD_LOGIC := '0';
   signal m_tip                    : STD_LOGIC := '0';
   signal m_sip                    : STD_LOGIC := '0';

begin

   intex_m_eip <= m_eip;
   intex_m_tip <= m_tip;
   intex_m_sip <= m_sip;

process(clk) 
   begin
      if rising_edge(clk) then
         -- Clear pending for any interrupts being serviced
         if exec_setting_mcause = '1' then
            if exec_setting_mcause_value = CAUSE_M_INTERRUPT_EXTERNAL then
               m_eip <= '0';
            end if;

            if exec_setting_mcause_value = CAUSE_M_INTERRUPT_TIMER then
               m_tip <= '0';
            end if;

            if exec_setting_mcause_value = CAUSE_M_INTERRUPT_SOFTWARE then
               m_sip <= '0';
            end if;
         end if;

         -- Set pending for any new incoming interrupts
         if interrupt_external_last = '0' and interrupt_external = '1' then
            m_eip <= '1';
         end if;

         if interrupt_timer_last = '0' and interrupt_timer = '1' then
            m_tip <= '1';
         end if;

         if interrupt_software_last = '0' and interrupt_software = '1' then
            m_sip <= '1';
         end if;

         -- Remeber the state of the interrupt request signal
         interrupt_external_last <= interrupt_external;
         interrupt_timer_last    <= interrupt_timer;
         interrupt_software_last <= interrupt_software;
      end if;         
   end process;

   exception_raise        <= reset 
                          OR exec_except_instr_misaligned
                          OR exec_except_instr_access
                          OR exec_except_illegal_instr
                          OR exec_except_ecall
                          OR exec_except_ebreak
                          OR exec_except_load_misaligned
                          OR exec_except_load_access
                          OR exec_except_store_misaligned
                          OR exec_except_store_access;
   intex_exception_raise  <= exception_raise;

   -- Note - priority encoder
   -- Note INSTR_MISALIGNED and CAUSE_INSTR_ACCESS_FAULT must have priority over CAUSE_BREAKPOINT 
   --      because a missaligned instruction is also an illegal instruction 
   --      likewise ebreak and ecall also decode as in illegal instruction
   cause_code            <= (others=>'0') when reset = '1' else
                             CAUSE_INSTR_MISALIGNED      when exec_except_instr_misaligned = '1' else
                             CAUSE_INSTR_ACCESS_FAULT    when exec_except_instr_access     = '1' else
                             CAUSE_BREAKPOINT            when exec_except_ebreak           = '1' else
                             CAUSE_ENV_CALL_M_MODE       when exec_except_ecall            = '1' else
                             CAUSE_ILLEGAL_INSTR         when exec_except_illegal_instr    = '1' else
                             CAUSE_LOAD_ADDR_MISALIGNED  when exec_except_load_misaligned  = '1' else
                             CAUSE_LOAD_ACCESS_FAULT     when exec_except_load_access      = '1' else
                             CAUSE_STORE_ADDR_MISALIGNED when exec_except_store_misaligned = '1' else
                             CAUSE_STORE_ACCESS_FAULT    when exec_except_store_access     = '1' else
                         --  CAUSE_ENV_CALL_U_MODE       when
                         --  CAUSE_ENV_CALL_S_MODE       when
                         --  CAUSE_INSTR_PAGE_FAULT      when
                         --  CAUSE_LOAD_PAGE_FAULT       when
                         --  CAUSE_STORE_PAGE_FAULT      when
                             CAUSE_M_INTERRUPT_EXTERNAL  when exec_m_ie = '1' and exec_m_eie = '1' and m_eip = '1' else
                             CAUSE_M_INTERRUPT_TIMER     when exec_m_ie = '1' and exec_m_tie = '1' and m_tip = '1' else
                             CAUSE_M_INTERRUPT_SOFTWARE  when exec_m_ie = '1' and exec_m_sie = '1' and m_sip = '1' else
                         --  CAUSE_S_INTERRUPT_EXTERNAL  when
                         --  CAUSE_S_INTERRUPT_SOFTWARE  when
                         --  CAUSE_S_INTERRUPT_TIMER     when
                         --  CAUSE_U_INTERRUPT_EXTERNAL  when
                         --  CAUSE_U_INTERRUPT_SOFTWARE  when
                         --  CAUSE_U_INTERRUPT_TIMER     when
                             (others => '0');

   -- Used only for intrerupt vectoring
   intr_vector           <=  CAUSE_M_INTERRUPT_EXTERNAL(29 downto 0) & "00"  when exec_m_ie = '1' and exec_m_eie = '1' and m_eip = '1' else
                             CAUSE_M_INTERRUPT_TIMER(29 downto 0)    & "00"  when exec_m_ie = '1' and exec_m_tie = '1' and m_tip = '1' else
                             CAUSE_M_INTERRUPT_SOFTWARE(29 downto 0) & "00"  when exec_m_ie = '1' and exec_m_sie = '1' and m_sip = '1' else
                             (others => '0');

   intex_exception_cause  <= cause_code;

   intex_exception_vector <= x"F0000000"      when reset            = '1' else
                             exec_m_tvec_base when exec_m_tvec_flag = '0' else
                             exec_m_tvec_base when exception_raise  = '1' else
                             std_logic_Vector(unsigned(exec_m_tvec_base) + unsigned(intr_vector));
end Behavioral;
