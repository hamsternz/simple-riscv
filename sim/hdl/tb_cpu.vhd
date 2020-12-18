--###############################################################################
--# ./sim/tb_cpu.vhd  - DESCRIPTION_NEEDED
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

entity tb_cpu is
end tb_cpu;

architecture Behavioral of tb_cpu is
    component cpu is
    Port( clk     : in  STD_LOGIC;
          progmem_addr    : out STD_LOGIC_VECTOR(31 downto 0);
          progmem_data    : in  STD_LOGIC_VECTOR(31 downto 0);
        
          reset         : in  STD_LOGIC;
        
          bus_busy      : in  STD_LOGIC;
          bus_addr      : out STD_LOGIC_VECTOR(31 downto 0);
          bus_width     : out STD_LOGIC_VECTOR(1 downto 0);  
          bus_dout      : out STD_LOGIC_VECTOR(31 downto 0);
          bus_write     : out STD_LOGIC;
          bus_enable    : out STD_LOGIC;
          bus_din       : in  STD_LOGIC_VECTOR(31 downto 0);
        
          debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
          debug_sel     : in  STD_LOGIC_VECTOR(4 downto 0);
          debug_data    : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component progmem is
    Port (  clk            : in  STD_LOGIC;
            progmem_enable : in  STD_LOGIC;
            progmem_data   : out STD_LOGIC_VECTOR (31 downto 0);
            progmem_addr   : in  STD_LOGIC_VECTOR (31 downto 0)
    );
    end component;


    signal clk           : STD_LOGIC := '0';
    signal progmem_data  : STD_LOGIC_VECTOR (31 downto 0);
    signal progmem_addr  : STD_LOGIC_VECTOR (31 downto 0);
    
            
    signal reset         : STD_LOGIC := '0';
    
    signal bus_busy      : STD_LOGIC := '0';
    signal bus_addr      : STD_LOGIC_VECTOR(31 downto 0);
    signal bus_width     : STD_LOGIC_VECTOR(1 downto 0);  
    signal bus_dout      : STD_LOGIC_VECTOR(31 downto 0);
    signal bus_write     : STD_LOGIC;
    signal bus_enable    : STD_LOGIC;
    signal bus_din       : STD_LOGIC_VECTOR(31 downto 0);
    
    signal debug_pc      : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_sel     : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal debug_data    : STD_LOGIC_VECTOR(31 downto 0);
begin

process 
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
uut: cpu port map(
    clk     => clk,
    progmem_data          => progmem_data,
    progmem_addr          => progmem_addr,        
    reset                 => reset,
    
    bus_busy      => bus_busy,
    bus_addr      => bus_addr,
    bus_width     => bus_width,  
    bus_dout      => bus_dout,
    bus_write     => bus_write,
    bus_enable    => bus_enable,
    bus_din       => bus_din,
    
    debug_pc      => debug_pc,
    debug_sel     => debug_sel,
    debug_data    => debug_data);

program : progmem port map (
        clk                   => clk,
        progmem_enable        => '1',
        progmem_data          => progmem_data,
        progmem_addr          => progmem_addr        
    );
end Behavioral;
