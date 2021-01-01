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
begin
   -- Pass results to the outside world
   csr_complete  <= csr_active and local_csr_complete;
   csr_failed    <= csr_active and local_csr_failed;
   c             <= local_csr_result;
  
process(clk)
   begin
      if rising_edge(clk) then
         if local_csr_in_progress = '1' then
            local_csr_result      <= (others => '0');
            case local_csr_reg is 
                when x"F11" =>   -- Vendor ID
                   case local_csr_mode is
                      when CSR_NOACTION =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= (others => '0');
                      when CSR_READ     =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= x"F00DF00D";
                         report "READ Vendor ID";
                      when others   =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '0';
                         local_csr_failed      <= '1';
                         local_csr_result      <= (others => '0');
                   end case; 
                when x"F12" =>   -- Architecture ID
                   case local_csr_mode is
                      when CSR_NOACTION =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= (others => '0');
                      when CSR_READ     =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= x"FEEDFEED";
                      when others   =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '0';
                         local_csr_failed      <= '1';
                         local_csr_result      <= (others => '0');
                   end case; 
                when x"F13" =>   -- implementation ID
                   case local_csr_mode is
                      when CSR_NOACTION =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= (others => '0');
                      when CSR_READ     =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= x"DEADBEEF";
                      when others   =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '0';
                         local_csr_failed      <= '1';
                         local_csr_result      <= (others => '0');
                   end case; 
                when x"F14" =>   -- Hardware thread ID
                   case local_csr_mode is
                      when CSR_NOACTION =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= (others => '0');
                      when CSR_READ     =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '1';
                         local_csr_failed      <= '0';
                         local_csr_result      <= x"00000000";
                      when others   =>
                         local_csr_in_progress <= '0';
                         local_csr_complete    <= '0';
                         local_csr_failed      <= '1';
                         local_csr_result      <= (others => '0');
                   end case; 
                when others =>
                   if local_csr_mode = CSR_NOACTION then
                      local_csr_in_progress <= '0';
                      local_csr_complete    <= '1';
                      local_csr_failed      <= '0';
                   else 
                      local_csr_in_progress <= '0';
                      local_csr_complete    <= '0';
                      local_csr_failed      <= '1';
                   end if;
            end case;
         end if;

         -- Decouple the CSR transaction from the internal CPU buses
         if csr_active = '1' and local_csr_in_progress = '0' then
            local_csr_reg    <= csr_reg;
            local_csr_value  <= a;
            local_csr_mode   <= csr_mode;
            local_csr_in_progress <= '1';
         end if; 
      end if;
   end process;

end Behavioral;
