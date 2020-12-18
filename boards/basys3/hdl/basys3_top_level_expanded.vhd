--###############################################################################
--# ./boards/basys3/hdl/basys3_top_level.vhd  - Top level for Basys3 board
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

entity basys3_top_level is
  port ( clk          : in  STD_LOGIC;
         uart_rxd_out : out STD_LOGIC;
         uart_txd_in  : in  STD_LOGIC;
         leds         : inout STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture Behavioral of basys3_top_level is

    component top_level_expanded is
    generic ( clock_freq    : natural   := 100000000);
    port ( clk          : in  STD_LOGIC;
           uart_rxd_out : out STD_LOGIC;
           uart_txd_in  : in  STD_LOGIC;
           debug_sel    : in  STD_LOGIC_VECTOR(4 downto 0);
           debug_data   : out STD_LOGIC_VECTOR(31 downto 0);
           debug_pc     : out STD_LOGIC_VECTOR(31 downto 0);
           gpio         : inout STD_LOGIC_VECTOR(15 downto 0));
    end component;
begin
   
i_top_level_expanded: top_level_expanded generic map ( clock_freq => 100000000) port map (
    clk => clk,
    uart_rxd_out => uart_rxd_out,
    uart_txd_in  => uart_txd_in,
    debug_sel    => "00000",
    debug_data   => open,
    debug_pc     => open,
    gpio         => leds);

end Behavioral;
