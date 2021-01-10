--###############################################################################
--# ./hdl/cpu/exec/shifter.vhd  - DESCRIPTION_NEEDED
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
use work.cpu_constants.ALL;

entity shifter is
  port ( clk             : in  STD_LOGIC;
         shift_mode      : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
         shift_active    : in  STD_LOGIC;  
         shift_complete  : out STD_LOGIC;  
         shift_failed    : out STD_LOGIC := '0';  
         a               : in  STD_LOGIC_VECTOR(31 downto 0);
         b               : in  STD_LOGIC_VECTOR(31 downto 0);
         c               : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
end entity;

architecture Behavioral of shifter is
   -- Must agree with decode.vhd
   signal padding : std_logic_vector(15 downto 0);
   signal result  : std_logic_vector(31 downto 0);
   signal phase   : std_logic := '0';
begin
    
process(shift_mode,a)
    begin
        -- Generate the padding for right shifts (either logical or arithmetic)
        if (shift_mode = SHIFTER_LEFT_ARITH OR shift_mode = SHIFTER_RIGHT_ARITH) AND a(a'high) = '1' then
            padding <= (others => '1');
        else
            padding <= (others => '0');
        end if; 
    end process;
    
process(shift_mode, a, b, padding)
    variable t : STD_LOGIC_VECTOR(31 downto 0);
    begin
            t := a;
            if shift_mode = SHIFTER_LEFT_LOGICAL OR shift_mode = SHIFTER_LEFT_ARITH then
                if b(4) = '1' then
                    t := t(15 downto 0) & x"0000";
                end if;
                
                if b(3) = '1' then
                    t := t(23 downto 0) & x"00";
                end if;
    
                if b(2) = '1' then
                    t := t(27 downto 0) & x"0";
                end if;
    
                if b(1) = '1' then
                    t := t(29 downto 0) & "00";
                end if;
    
                if b(0) = '1' then
                    t := t(30 downto 0) & "0";
                end if;
           else
                if b(4) = '1' then
                    t := padding(15 downto 0) & t(31 downto 16);
                end if;
                
                if b(3) = '1' then
                    t := padding(7 downto 0) & t(31 downto 8);
                end if;
    
                if b(2) = '1' then
                    t := padding(3 downto 0) & t(31 downto 4);
                end if;
    
                if b(1) = '1' then
                    t := padding(1 downto 0) & t(31 downto 2);
                end if;
    
                if b(0) = '1' then
                    t := padding(0 downto 0) & t(31 downto 1);
                end if;           
            end if;
    
            result <= t;
   end process;

process(clk)
   begin
      if rising_edge(clk) then
         shift_complete <= shift_active and not phase; 
         phase          <= shift_active and not phase; 
         c              <= result;
      end if;
   end process;

end Behavioral;
