--###############################################################################
--# ./hdl/cpu/exec/loadstore_unit.vhd  - DESCRIPTION_NEEDED
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

entity loadstore_unit is
    Port (  clk                       : in STD_LOGIC;

            loadstore_active          : in  STD_LOGIC;
            loadstore_complete        : out STD_LOGIC;
            loadstore_failed          : out STD_LOGIC := '0';

            decode_loadstore_enable   : in  STD_LOGIC;
            decode_loadstore_write    : in  STD_LOGIC;
            decode_loadstore_offset   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_loadstore_width    : in  STD_LOGIC_VECTOR(1 downto 0);
            decode_loadstore_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0) := "0";
            decode_loadstore_ex_width : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
    
            data_a                    : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            data_b                    : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            loadstore_data            : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

            bus_busy                  : in  STD_LOGIC;
            bus_addr                  : out STD_LOGIC_VECTOR(31 downto 0);
            bus_width                 : out STD_LOGIC_VECTOR(1 downto 0);  
            bus_dout                  : out STD_LOGIC_VECTOR(31 downto 0);
            bus_write                 : out STD_LOGIC;
            bus_enable                : out STD_LOGIC;
            bus_din                   : in  STD_LOGIC_VECTOR(31 downto 0));
end loadstore_unit;

architecture Behavioral of loadstore_unit is

    component sign_extender is
    port ( clk              : in  STD_LOGIC;
           sign_ex_active   : in  STD_LOGIC;  
           sign_ex_complete : out STD_LOGIC;  
           sign_ex_mode     : in  STD_LOGIC_VECTOR(0 downto 0);
           sign_ex_width    : in  STD_LOGIC_VECTOR(1 downto 0);
           a                : in  STD_LOGIC_VECTOR(31 downto 0);
           b                : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal sign_ex_active   : STD_LOGIC;  
    signal sign_ex_complete : STD_LOGIC;  
    signal sign_ex_data_in  : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    -- Set up the RAM address
    bus_write          <= decode_loadstore_write and not sign_ex_active;
    bus_enable         <= loadstore_active and not sign_ex_active;
    bus_width          <= decode_loadstore_width;
    bus_dout           <= data_b;
    bus_addr           <= std_logic_vector(unsigned(data_a)+unsigned(decode_loadstore_offset));

--------------------------------------------
-- THIS COULD BE CLOCKED TO IMPROVE TIMING
-- AT THE COST OF MEMORY READ LATENCY
--------------------------------------------
    loadstore_complete <= sign_ex_complete;
process(clk) 
    begin
        if rising_edge(clk) then
            sign_ex_data_in    <= bus_din;
            sign_ex_active     <= loadstore_active and (not bus_busy) and (not sign_ex_active);
        end if;
    end process;
--------------------------------------------
-- END OF CLOCKABLE BIT
--------------------------------------------

i_sign_extender: sign_extender  PORT MAP (
          clk              => clk,
          sign_ex_active   => sign_ex_active,
          sign_ex_complete => sign_ex_complete,
          sign_ex_mode     => decode_loadstore_ex_mode,
          sign_ex_width    => decode_loadstore_ex_width,
          a                => sign_ex_data_in,
          b                => loadstore_data);

end Behavioral;
