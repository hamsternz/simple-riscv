--###############################################################################
--# ./hdl/cpu/exec/data_bus_mux_b.vhd  - DESCRIPTION_NEEDED
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

entity data_bus_mux_b is
    port ( bus_select     : in  STD_LOGIC_VECTOR( 0 downto 0);
           reg_read_port  : in  STD_LOGIC_VECTOR(31 downto 0);
           immedediate    : in  STD_LOGIC_VECTOR(31 downto 0);
           data_bus       : out STD_LOGIC_VECTOR(31 downto 0)); 
end entity;

architecture Behavioral of data_bus_mux_b is
begin

process(bus_select, reg_read_port, immedediate) 
    begin
        case bus_select is
            when B_BUS_IMMEDIATE => 
                data_bus <= immedediate;
            when others =>
                data_bus <= reg_read_port; 
        end case;
    end process;
end Behavioral;
