--###############################################################################
--# ./hdl/cpu/exec/csr_304_mie.vhd  - CSR 0x304 - Machine interrupt enable
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

entity csr_304_mie is
  port ( clk          : in  STD_LOGIC;  
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;  
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;  
         csr_failed   : out STD_LOGIC;  
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
         m_eip        : in  STD_LOGIC;  
         m_tip        : in  STD_LOGIC;  
         m_sip        : in  STD_LOGIC); 
end entity;

architecture Behavioral of csr_304_mie is
   signal complete     : std_logic := '0';
   signal failed       : std_logic := '0';
   signal result       : std_logic_vector(31 downto 0) := (others => '0');
   signal stored_value : std_logic_vector(31 downto 0) := (others => '0');

   signal wpri         : std_logic := '0'; -- Hardwire zero
   signal meip         : std_logic := '0'; -- M external interrupt pending
   signal seip         : std_logic := '0'; -- Hardwire zero
   signal ueip         : std_logic := '0'; -- Hardwire zero
   signal mtip         : std_logic := '0'; -- M timer interrupt pending
   signal stip         : std_logic := '0'; -- Hardwire zero
   signal utip         : std_logic := '0'; -- Hardwire zero
   signal msip         : std_logic := '0'; -- M Software interrupt pending
   signal ssip         : std_logic := '0'; -- Hardwire zero
   signal usip         : std_logic := '0'; -- Hardwire zero
begin
   csr_complete <= complete;
   csr_failed   <= failed;
   csr_result   <= result;
   meip <= m_eip;
   mtip <= m_tip;
   msip <= m_sip;

   stored_value <= wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri
                 & wpri & wpri & wpri & wpri & meip & wpri & seip & ueip & mtip & wpri & stip & utip & msip & wpri & ssip & usip;


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
                  -- WARL with external status
                  report "WRITE mie CSR";

               when CSR_WRITESET =>
                  complete     <= '1';
                  -- WARL with external status
                  report "WRITESET mie CSR";

               when CSR_WRITECLEAR =>
                  complete     <= '1';
                  -- WARL with external status
                  report "WRITECLEAR mie CSR";

               when CSR_READ     =>
                  complete     <= '1';
                  result       <= stored_value;
                  report "READ mie CSR";

               when CSR_READWRITE =>
                  complete     <= '1';
                  result       <= stored_value;
                  -- WARL with external status
                  report "READWRITE mie CSR";

               when CSR_READWRITESET =>
                  complete     <= '1';
                  result       <= stored_value;
                  -- WARL with external status
                  report "READWRITESET mie CSR";

               when CSR_READWRITECLEAR =>
                  complete     <= '1';
                  result       <= stored_value;
                  -- WARL with external status
                  report "READWRITECLEAR mie CSR";

               when others   =>
                  failed      <= '1';
            end case;
         end if;
      end if;
   end process;
end Behavioral;
