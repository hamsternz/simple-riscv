--###############################################################################
--# ./hdl/cpu/exec/result_bus_mux.vhd  - DESCRIPTION_NEEDED
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

entity result_bus_mux is
    port ( res_src          : in  STD_LOGIC_VECTOR( 1 downto 0);
           res_alu          : in  STD_LOGIC_VECTOR(31 downto 0);
           res_shifter      : in  STD_LOGIC_VECTOR(31 downto 0);
           res_pc_plus_four : in  STD_LOGIC_VECTOR(31 downto 0);
           res_memory       : in  STD_LOGIC_VECTOR(31 downto 0);
           res_bus          : out STD_LOGIC_VECTOR(31 downto 0)); 
end entity;

architecture Behavioral of result_bus_mux is
   signal aux : std_logic_vector(31 downto 0);
begin

-- Select between things with less timing slack
process(res_src, res_alu, aux, res_shifter, res_pc_plus_four, res_memory) 
    begin
        case res_src is
            when RESULT_ALU => 
                res_bus <= res_alu;
            when RESULT_PC_PLUS_4 =>
                res_bus <= res_pc_plus_four;
            when RESULT_MEMORY =>
                res_bus <= res_memory;
            when RESULT_SHIFTER =>    
                res_bus <= res_shifter;
            when others =>
                res_bus <= res_alu; 
        end case;
    end process;

end Behavioral;
