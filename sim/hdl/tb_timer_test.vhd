--###############################################################################
--# ./sim/tb_timer_test.vhd  - Testing the system timer
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
use STD.textio.all;

entity tb_timer_test is
end tb_timer_test;

architecture Behavioral of tb_timer_test is

    procedure print(str : in string) is
       variable oline : line;
    begin
       write(oline, str);
       writeline(output, oline);
    end procedure;

    component top_level_expanded is
    generic ( clock_freq    : natural   := 50000000);
    port ( clk          : in  STD_LOGIC;
           uart_rxd_out : out STD_LOGIC := '1';
           uart_txd_in  : in  STD_LOGIC;
           debug_sel    : in  STD_LOGIC_VECTOR(4 downto 0);
           debug_data   : out STD_LOGIC_VECTOR(31 downto 0);
           debug_pc     : out STD_LOGIC_VECTOR(31 downto 0);
           gpio         : inout STD_LOGIC_VECTOR(15 downto 0));
    end component;
    signal clk          : STD_LOGIC;
    signal uart_rxd_out : STD_LOGIC := '1';
    signal uart_txd_in  : STD_LOGIC;
    signal debug_sel    : STD_LOGIC_VECTOR(4 downto 0) := "00001";
    signal debug_data   : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_pc     : STD_LOGIC_VECTOR(31 downto 0);
    signal gpio         : STD_LOGIC_VECTOR(15 downto 0);
begin

process 
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
uut: top_level_expanded
    generic map (clock_freq => 50000000)
    port map ( clk => clk,
             uart_rxd_out => uart_rxd_out,
             uart_txd_in  => uart_txd_in,
             debug_sel    => debug_sel,
             debug_data   => debug_data,
             debug_pc     => debug_pc,
             gpio         => gpio);
             
process
    begin
        wait until rising_edge(clk);
        wait for 0.5 ns;
        case debug_pc is
            when x"F0000000" =>             
            when x"effffff0" =>
            when x"effffff4" =>
            when x"effffff8" =>
            when x"effffffC" =>
            when others =>
                print("Unexpected address");
                assert debug_pc = x"00000000" report "FAIL: Unexpected address" severity FAILURE;
        end case;                        
    end process;
             
end Behavioral;
