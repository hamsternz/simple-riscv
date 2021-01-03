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

  component csr_F11 is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_F11_active        : std_logic := '0';
  signal csr_F11_complete      : std_logic := '0';
  signal csr_F11_failed        : std_logic := '0';
  signal csr_F11_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_F12 is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_F12_active        : std_logic := '0';
  signal csr_F12_complete      : std_logic := '0';
  signal csr_F12_failed        : std_logic := '0';
  signal csr_F12_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_F13 is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_F13_active        : std_logic := '0';
  signal csr_F13_complete      : std_logic := '0';
  signal csr_F13_failed        : std_logic := '0';
  signal csr_F13_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_F14 is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_F14_active        : std_logic := '0';
  signal csr_F14_complete      : std_logic := '0';
  signal csr_F14_failed        : std_logic := '0';
  signal csr_F14_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_other is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
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
            end if;
         else 
            if local_csr_complete = '1' OR local_csr_failed = '1'  then
                local_csr_in_progress <= '0';
             end if; 
         end if; 
      end if;
   end process;

----------------------------------------------------
-- 0xF11 Vendor ID
----------------------------------------------------
i_csr_F11: csr_F11 port map ( 
    clk          => clk, 
    csr_active   => csr_F11_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_F11_complete,
    csr_failed   => csr_F11_failed,
    csr_result   => csr_F11_result
  );

----------------------------------------------------
-- 0xF12 architecture ID
----------------------------------------------------
i_csr_F12: csr_F12 port map ( 
    clk          => clk, 
    csr_active   => csr_F12_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_F12_complete,
    csr_failed   => csr_F12_failed,
    csr_result   => csr_F12_result
  );

----------------------------------------------------
-- 0xF13 implementation ID
----------------------------------------------------
i_csr_F13: csr_F13 port map ( 
    clk          => clk, 
    csr_active   => csr_F13_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_F13_complete,
    csr_failed   => csr_F13_failed,
    csr_result   => csr_F13_result
  );

----------------------------------------------------
-- 0xF14 HART ID
----------------------------------------------------
i_csr_F14: csr_F14 port map ( 
    clk          => clk, 
    csr_active   => csr_F14_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_F14_complete,
    csr_failed   => csr_F14_failed,
    csr_result   => csr_F14_result
  );

----------------------------------------------------
-- All others
----------------------------------------------------
i_csr_other: csr_other port map ( 
    clk          => clk, 
    csr_active   => csr_other_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_other_complete,
    csr_failed   => csr_other_failed,
    csr_result   => csr_other_result
  );

end Behavioral;
