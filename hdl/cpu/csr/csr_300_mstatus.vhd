--###############################################################################
--# ./hdl/cpu/exec/csr_300.vhd  - CSR 0x300 - Machine status register
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

entity csr_300_mstatus is
  port ( clk          : in  STD_LOGIC;  
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;  
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;  
         csr_failed   : out STD_LOGIC;  
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         m_ie         : out STD_LOGIC); 
end entity;

architecture Behavioral of csr_300_mstatus is
   signal complete     : std_logic := '0';
   signal failed       : std_logic := '0';
   signal result       : std_logic_vector(31 downto 0) := (others => '0');
   signal stored_value : std_logic_vector(31 downto 0) := (others => '0');

   -- Split into fields
   signal wpri         : std_logic := '0'; -- Write preserve, readback ignore

   signal sd           : std_logic := '0';                                    -- Hardware zero - [f or x]State Dirty 
   signal tsr          : std_logic := '0';                                    -- Hardwire zero - Trap sret
   signal tw           : std_logic := '0';                                    -- Hardwire zero - Timeout wait
   signal tvm          : std_logic := '0';                                    -- Hardwire zero - Trap Vm
   signal mxr          : std_logic := '0';                                    -- Hardwire zero - Make eXecutable Readable      
   signal sum          : std_logic := '0';                                    -- Hardwire zero - Supervisor User Memory access
   signal mprv         : std_logic := '0';                                    -- Hardwure zero - Modify PRiVilege
   signal xs           : std_logic_vector(1 downto 0) := (others => '0');     -- Hardwire zero -- x state dirty
   signal fs           : std_logic_vector(1 downto 0) := (others => '0');     -- Hardwire zero -- f state dirty
   signal mie          : std_logic := '0';                                -- M interrupt enable
   signal sie          : std_logic := '0';                                    -- Hardwire zero - S interrupt enable
   signal uie          : std_logic := '0';                                    -- Hardwire zero - U interrupt enable
   signal mpp          : std_logic_vector(1 downto 0) := (others => '0'); -- M previous privilege - LSB hardwire zero
   signal spp          : std_logic_vector(0 downto 0) := (others => '0');     -- Hardwire zero - S previous privilege
   signal mpie         : std_logic := '0';                                -- M previous Interupt enable 
   signal spie         : std_logic := '0';                                    -- Hardwire zero - S previous interrupt enable
   signal upie         : std_logic := '0';                                    -- Hardwire zero - U previous interrupt enable
begin
   csr_complete <= complete;
   csr_failed   <= failed;
   csr_result   <= result;
   m_ie         <= mie;

   -- Note this layout follows the PDF diagram - 15 bits on the top line, 17 on the bottom.
   stored_value <= sd & wpri & wpri & wpri & wpri & wpri & wpri & wpri & wpri & tsr  & tw   & tvm  & mxr  & sum & mprv
                 & xs        & fs          & mpp         & wpri & wpri & spp  & mpie & wpri & spie & upie & mie & wpri & sie & uie;

  
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
                  complete <= '1';
                  mpp(1)   <= csr_value(12);
                  mpie     <= csr_value(7);
                  mie      <= csr_value(3);
                  report "WRITE mstatus CSR";

               when CSR_WRITESET =>
                  complete <= '1';
                  mpp(1)   <= mpp(1) OR csr_value(12);
                  mpie     <= mpie   OR csr_value(7);
                  mie      <= mie    OR csr_value(3);
                  report "WRITESET mstatus CSR";

               when CSR_WRITECLEAR =>
                  complete <= '1';
                  mpp(1)   <= mpp(1) AND NOT csr_value(12);
                  mpie     <= mpie   AND NOT csr_value(7);
                  mie      <= mie    AND NOT csr_value(3);
                  report "WRITECLEAR mstatus CSR";

               when CSR_READ     =>
                  complete <= '1';
                  result   <= stored_value;
                  report "READ mstatus CSR";

               when CSR_READWRITE =>
                  complete <= '1';
                  result   <= stored_value;
                  mpp(1)   <= csr_value(12);
                  mpie     <= csr_value(7);
                  mie      <= csr_value(3);
                  report "READWRITE mstatus CSR";

               when CSR_READWRITESET =>
                  complete <= '1';
                  result   <= stored_value;
                  mpp(1)   <= mpp(1) OR csr_value(12);
                  mpie     <= mpie   OR csr_value(7);
                  mie      <= mie    OR csr_value(3);
                  report "READWRITESET mstatus CSR";

               when CSR_READWRITECLEAR =>
                  complete <= '1';
                  result   <= stored_value;
                  mpp(1)   <= mpp(1) AND NOT csr_value(12);
                  mpie     <= mpie   AND NOT csr_value(7);
                  mie      <= mie    AND NOT csr_value(3);
                  report "READWRITECLEAR mstatus CSR";

               when others   =>
                  failed      <= '1';
            end case;
         end if;
      end if;
   end process;
end Behavioral;
