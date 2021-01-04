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
         c            : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         epc_set      : in  STD_LOGIC := '0';
         epc          : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         tval_set     : in  STD_LOGIC := '0';
         tval         : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         cause_set    : in  STD_LOGIC := '0';
         cause        : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
   ); 
end entity;

architecture Behavioral of csr_unit is
  signal local_csr_reg         : std_logic_vector(11 downto 0) := (others => '0');
  signal local_csr_value       : std_logic_vector(31 downto 0) := (others => '0');
  signal local_csr_mode        : std_logic_vector( 2 downto 0) := (others => '0');
  signal local_csr_in_progress : std_logic := '0';
  signal local_csr_complete    : std_logic := '0';
  signal local_csr_failed      : std_logic := '0';
  signal local_csr_result      : std_logic_vector(31 downto 0) := (others => '0');

  component csr_300_mstatus is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_300_active        : std_logic := '0';
  signal csr_300_complete      : std_logic := '0';
  signal csr_300_failed        : std_logic := '0';
  signal csr_300_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_301_misa is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_301_active        : std_logic := '0';
  signal csr_301_complete      : std_logic := '0';
  signal csr_301_failed        : std_logic := '0';
  signal csr_301_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_304_mie is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_304_active        : std_logic := '0';
  signal csr_304_complete      : std_logic := '0';
  signal csr_304_failed        : std_logic := '0';
  signal csr_304_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_305_mtvec is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_305_active        : std_logic := '0';
  signal csr_305_complete      : std_logic := '0';
  signal csr_305_failed        : std_logic := '0';
  signal csr_305_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_340_mscratch is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  signal csr_340_active        : std_logic := '0';
  signal csr_340_complete      : std_logic := '0';
  signal csr_340_failed        : std_logic := '0';
  signal csr_340_result        : std_logic_vector(31 downto 0) := (others => '0');

  component csr_341_mepc is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         epc          : in  STD_LOGIC_VECTOR(31 downto 0);
         epc_set      : in  STD_LOGIC
  );
  end component;
  signal csr_341_active        : std_logic := '0';
  signal csr_341_complete      : std_logic := '0';
  signal csr_341_failed        : std_logic := '0';
  signal csr_341_result        : std_logic_vector(31 downto 0) := (others => '0');


  component csr_342_mcause is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         cause        : in  STD_LOGIC_VECTOR(31 downto 0);
         cause_set    : in  STD_LOGIC
  );
  end component;
  signal csr_342_active        : std_logic := '0';
  signal csr_342_complete      : std_logic := '0';
  signal csr_342_failed        : std_logic := '0';
  signal csr_342_result        : std_logic_vector(31 downto 0) := (others => '0');


  component csr_343_mtval is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         tval         : in  STD_LOGIC_VECTOR(31 downto 0);
         tval_set     : in  STD_LOGIC
  );
  end component;
  signal csr_343_active        : std_logic := '0';
  signal csr_343_complete      : std_logic := '0';
  signal csr_343_failed        : std_logic := '0';
  signal csr_343_result        : std_logic_vector(31 downto 0) := (others => '0');


  component csr_344_mip is
  port ( clk          : in  STD_LOGIC;
         csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
         csr_active   : in  STD_LOGIC;
         csr_value    : in  STD_LOGIC_VECTOR(31 downto 0);
         csr_complete : out STD_LOGIC;
         csr_failed   : out STD_LOGIC;
         csr_result   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
  );
  end component;
  signal csr_344_active        : std_logic := '0';
  signal csr_344_complete      : std_logic := '0';
  signal csr_344_failed        : std_logic := '0';
  signal csr_344_result        : std_logic_vector(31 downto 0) := (others => '0');


  component csr_F11_mvendorid is
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

  component csr_F12_marchid is
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

  component csr_F13_mimpid is
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

  component csr_F14_mhartid is
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
                      OR csr_300_complete OR csr_301_complete OR csr_305_complete OR csr_305_complete
                      OR csr_340_complete OR csr_341_complete OR csr_342_complete OR csr_343_complete OR csr_344_complete
                      OR csr_other_complete;

   local_csr_failed   <= csr_F11_failed   OR csr_F12_failed   OR csr_F13_failed   OR csr_F14_failed
                      OR csr_300_failed   OR csr_301_failed   OR csr_304_failed   OR csr_305_failed  
                      OR csr_340_failed   OR csr_341_failed   OR csr_342_failed   OR csr_343_failed   OR csr_344_failed
                      OR csr_other_failed;

   local_csr_result   <= csr_F11_result   OR csr_F12_result   OR csr_F13_result   OR csr_F14_result
                      OR csr_300_result   OR csr_301_result   OR csr_304_result   OR csr_305_result
                      OR csr_340_result   OR csr_341_result   OR csr_342_result   OR csr_343_result   OR csr_344_result
                      OR csr_other_result;

process(clk)
   begin
      if rising_edge(clk) then
         --------------------------------------------------------------- 
         -- Assert the enable signal for the desired CSR
         ---------------------------------------------------------------
         csr_300_active   <= '0';
         csr_301_active   <= '0';
         csr_304_active   <= '0';
         csr_305_active   <= '0';
         csr_340_active   <= '0';
         csr_341_active   <= '0';
         csr_342_active   <= '0';
         csr_343_active   <= '0';
         csr_344_active   <= '0';
         csr_F11_active   <= '0';
         csr_F12_active   <= '0';
         csr_F13_active   <= '0';
         csr_F14_active   <= '0'; 
         csr_other_active <= '0'; 
         if local_csr_in_progress = '1' and local_csr_complete = '0' and local_csr_failed = '0' then
            case local_csr_reg is 
                when x"300" => csr_300_active   <= '1'; -- mstatus
                when x"301" => csr_301_active   <= '1'; -- misa
                when x"304" => csr_304_active   <= '1'; -- mie  
                when x"305" => csr_305_active   <= '1'; -- mtvec      
                when x"340" => csr_340_active   <= '1'; -- mscratch   
                when x"341" => csr_341_active   <= '1'; -- mepc   
                when x"342" => csr_342_active   <= '1'; -- mcause   
                when x"343" => csr_343_active   <= '1'; -- mtval  
                when x"344" => csr_344_active   <= '1'; -- mip   
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

i_csr_340: csr_340_mscratch port map ( 
    clk          => clk, 
    csr_active   => csr_340_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_340_complete,
    csr_failed   => csr_340_failed,
    csr_result   => csr_340_result
  );

i_csr_341: csr_341_mepc port map ( 
    clk          => clk, 
    csr_active   => csr_341_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_341_complete,
    csr_failed   => csr_341_failed,
    csr_result   => csr_341_result,
    epc          => epc,
    epc_set      => epc_set
  );

i_csr_342: csr_342_mcause port map ( 
    clk          => clk, 
    csr_active   => csr_342_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_342_complete,
    csr_failed   => csr_342_failed,
    csr_result   => csr_342_result,
    cause        => cause,
    cause_set    => cause_set
  );

i_csr_343: csr_343_mtval   port map ( 
    clk          => clk, 
    csr_active   => csr_343_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_343_complete,
    csr_failed   => csr_343_failed,
    csr_result   => csr_343_result,
    tval         => tval,
    tval_set     => tval_set
  );

i_csr_344: csr_344_mip   port map ( 
    clk          => clk, 
    csr_active   => csr_343_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_343_complete,
    csr_failed   => csr_343_failed,
    csr_result   => csr_343_result
  );

i_csr_F11: csr_F11_mvendorid port map ( 
    clk          => clk, 
    csr_active   => csr_F11_active,
    csr_mode     => local_csr_mode,
    csr_value    => local_csr_value,
    csr_complete => csr_F11_complete,
    csr_failed   => csr_F11_failed,
    csr_result   => csr_F11_result
  );

i_csr_F12: csr_F12_marchid port map ( 
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
i_csr_F13: csr_F13_mimpid port map ( 
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
i_csr_F14: csr_F14_mhartid port map ( 
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
