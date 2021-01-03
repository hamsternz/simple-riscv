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
  signal local_csr_reg         : std_logic_vector(11 downto 0) := (others => '0');
  signal local_csr_value       : std_logic_vector(31 downto 0) := (others => '0');
  signal local_csr_mode        : std_logic_vector( 2 downto 0) := (others => '0');
  signal local_csr_in_progress : std_logic := '0';
  signal local_csr_complete    : std_logic := '0';
  signal local_csr_failed      : std_logic := '0';
  signal local_csr_result      : std_logic_vector(31 downto 0) := (others => '0');

  signal csr_F11_active        : std_logic := '0';
  signal csr_F11_complete      : std_logic := '0';
  signal csr_F11_failed        : std_logic := '0';
  signal csr_F11_result        : std_logic_vector(31 downto 0) := (others => '0');

  signal csr_F12_active        : std_logic := '0';
  signal csr_F12_complete      : std_logic := '0';
  signal csr_F12_failed        : std_logic := '0';
  signal csr_F12_result        : std_logic_vector(31 downto 0) := (others => '0');

  signal csr_F13_active        : std_logic := '0';
  signal csr_F13_complete      : std_logic := '0';
  signal csr_F13_failed        : std_logic := '0';
  signal csr_F13_result        : std_logic_vector(31 downto 0) := (others => '0');

  signal csr_F14_active        : std_logic := '0';
  signal csr_F14_complete      : std_logic := '0';
  signal csr_F14_failed        : std_logic := '0';
  signal csr_F14_result        : std_logic_vector(31 downto 0) := (others => '0');

  signal csr_other_active      : std_logic := '0';
  signal csr_other_complete    : std_logic := '0';
  signal csr_other_failed      : std_logic := '0';
  signal csr_other_result      : std_logic_vector(31 downto 0) := (others => '0');
begin
   -- Pass results to the outside world
   csr_complete  <= csr_active and local_csr_complete;
   csr_failed    <= csr_active and local_csr_failed;
   c             <= local_csr_result;

   -- Merge back all the status and result signals
   local_csr_complete <= csr_F11_complete OR csr_F12_complete OR csr_F13_complete OR csr_F14_complete 
                      OR csr_other_complete;

   local_csr_failed   <= csr_F11_failed   OR csr_F12_failed   OR csr_F13_failed   OR csr_F14_failed
                      OR csr_other_failed;

   local_csr_result   <= csr_F11_result   OR csr_F12_result   OR csr_F13_result   OR csr_F14_result
                      OR csr_other_result;

process(clk)
   begin
      if rising_edge(clk) then
         --------------------------------------------------------------- 
         -- Assert the enable signal for the desired CSR
         ---------------------------------------------------------------
         csr_F11_active   <= '0';
         csr_F12_active   <= '0';
         csr_F13_active   <= '0';
         csr_F14_active   <= '0'; 
         csr_other_active <= '0'; 
         if local_csr_in_progress = '1' and local_csr_complete = '0' and local_csr_failed = '0' then
            case local_csr_reg is 
                when x"F11" => csr_F11_active   <= '1'; -- Vendor ID
                when x"F12" => csr_F12_active   <= '1'; -- Architecture ID
                when x"F13" => csr_F13_active   <= '1'; -- Vendor ID
                when x"F14" => csr_F14_active   <= '1'; -- Architecture ID
                when others => csr_other_active <= '1';
            end case;
         end if;

         --------------------------------------------------------------- 
         -- Decouple the CSR transaction from the internal CPU buses
         ---------------------------------------------------------------
         if local_csr_in_progress = '0' then
             if csr_active = '1' then
                local_csr_reg    <= csr_reg;
                local_csr_value  <= a;
                local_csr_mode   <= csr_mode;
                local_csr_in_progress <= '1';
                report "Start new CSR request";
            end if;
         else 
            if local_csr_complete = '1' OR local_csr_failed = '1'  then
                local_csr_in_progress <= '0';
                report "ENd of any CSR request";
             end if; 
         end if; 
      end if;
   end process;

----------------------------------------------------
-- 0xF11 Vendor ID
----------------------------------------------------
csr_F11: process(clk) 
   begin
      if rising_edge(clk) then
         csr_F11_result      <= (others => '0');
         csr_F11_complete    <= '0';
         csr_F11_failed      <= '0';
         if csr_F11_active = '1' and csr_F11_complete = '0' and csr_F11_failed = '0' then
            case local_csr_mode is
               when CSR_NOACTION =>
                  csr_F11_complete    <= '1';
               when CSR_READ     =>
                  csr_F11_complete    <= '1';
                  csr_F11_result      <= x"F00DF00D";
                  report "READ Vendor ID";
               when others   =>
                  csr_F11_failed      <= '1';
            end case; 
         end if;
      end if;
   end process;  

----------------------------------------------------
-- 0xF12 Architecture ID
----------------------------------------------------
csr_F12: process(clk) 
   begin
      if rising_edge(clk) then
         csr_F12_result      <= (others => '0');
         csr_F12_complete    <= '0';
         csr_F12_failed      <= '0';
         if csr_F12_active = '1' and csr_F12_complete = '0' and csr_F12_failed = '0' then
             case local_csr_mode is
                when CSR_NOACTION =>
                   csr_F12_complete    <= '1';
                when CSR_READ     =>
                   csr_F12_complete    <= '1';
                   csr_F12_result      <= x"FEEDFEED";
                   report "READ Architecture ID";
                when others   =>
                   csr_F12_failed      <= '1';
             end case; 
         end if;
      end if;
   end process;  

----------------------------------------------------
-- 0xF13 Implementation ID
----------------------------------------------------
csr_F13: process(clk) 
   begin
      if rising_edge(clk) then
         csr_F13_result      <= (others => '0');
         csr_F13_complete    <= '0';
         csr_F13_failed      <= '0';
         if csr_F13_active = '1' and csr_F13_complete = '0' and csr_F13_failed = '0' then
             case local_csr_mode is
                when CSR_NOACTION =>
                   csr_F13_complete    <= '1';
                when CSR_READ     =>
                   csr_F13_complete    <= '1';
                   csr_F13_result      <= x"DEADBEEF";
                   report "READ Implementation ID";
                when others   =>
                   csr_F13_failed      <= '1';
             end case; 
         end if;
      end if;
   end process;  


----------------------------------------------------
-- 0xF14 Architecture ID
----------------------------------------------------
csr_F14: process(clk) 
   begin
      if rising_edge(clk) then
         csr_F14_result      <= (others => '0');
         csr_F14_complete    <= '0';
         csr_F14_failed      <= '0';
         if csr_F14_active = '1' and csr_F14_complete = '0' and csr_F14_failed = '0' then
             case local_csr_mode is
                when CSR_NOACTION =>
                   csr_F14_complete    <= '1';
                when CSR_READ     =>
                   csr_F14_complete    <= '1';
                   report "READ Architecture ID";
                when others   =>
                   csr_F14_failed      <= '1';
             end case; 
         end if;
      end if;
   end process;  


----------------------------------------------------
-- Others - fail the request other than no action
----------------------------------------------------
csr_other: process(clk) 
   begin
      if rising_edge(clk) then
         csr_other_result      <= (others => '0');
         csr_other_complete    <= '0';
         csr_other_failed      <= '0';
         if csr_other_active = '1' then
            case local_csr_mode is
               when CSR_NOACTION =>
                  csr_other_complete    <= '1';
               when others   =>
                  csr_other_failed      <= '1';
            end case; 
         end if;
      end if;
   end process;  


end Behavioral;
