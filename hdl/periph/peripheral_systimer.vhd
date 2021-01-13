--###############################################################################
--# ./peripheral_systimer.vhd -  The System timer
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


entity peripheral_systimer is
  generic ( clock_freq   : natural );
  port ( clk             : in  STD_LOGIC;

         bus_busy        : out STD_LOGIC;
         bus_addr        : in  STD_LOGIC_VECTOR(3 downto 2);
         bus_enable      : in  STD_LOGIC;
         bus_write_mask  : in  STD_LOGIC_VECTOR(3 downto 0);
         bus_write_data  : in  STD_LOGIC_VECTOR(31 downto 0);
         bus_read_data   : out STD_LOGIC_VECTOR(31 downto 0);

         interrupt_timer : out STD_LOGIC);
end entity;

architecture Behavioral of peripheral_systimer is
    signal data_valid  : STD_LOGIC := '1';
    signal counter     : unsigned(63 downto 0) := (others => '0');
    signal counter_cmp : unsigned(63 downto 0) := (others => '0');
    signal divider     : unsigned(7 downto 0) := (others => '0');
begin

process(counter, counter_cmp) 
begin
    if counter <  counter_cmp then 
        interrupt_timer <= '0';
    else
        interrupt_timer <= '1';
    end if;
end process;


process(bus_enable, bus_write_mask, data_valid)
begin
    bus_busy <= '0';
    if bus_enable = '1' and bus_write_mask = "0000" then
        if data_valid = '0' then
           bus_busy <= '1';
        end if;
    end if;
end process;


process(clk) 
begin
    if rising_edge(clk) then
        -- Update the counters
        if divider = (clock_freq/1000000)-1 then
           divider <= (others => '0');
           counter <= counter + 1;
        else
           divider <= divider+1;
        end if;

        -- Process the bus request
        data_valid <= '0';
        bus_read_data <= x"00000000";
        if bus_enable = '1' then
            if bus_write_mask /= "0000"  then
                case bus_addr is
                    when "00" =>  
                        divider <= (others => '0');
                        if bus_write_mask(0) = '1' then
                            counter( 7 downto  0)  <= unsigned(bus_write_data( 7 downto  0));
                        end if;
                        if bus_write_mask(1) = '1' then
                            counter(15 downto  8)  <= unsigned(bus_write_data(15 downto  8));
                        end if;
                        if bus_write_mask(2) = '1' then
                            counter(23 downto 16)  <= unsigned(bus_write_data(23 downto 16));
                        end if;
                        if bus_write_mask(3) = '1' then
                            counter(31 downto 24)  <= unsigned(bus_write_data(31 downto 24));
                        end if;
                    when "01" =>  
                        if bus_write_mask(0) = '1' then
                            counter(39 downto 32)  <= unsigned(bus_write_data( 7 downto  0));
                        end if;
                        if bus_write_mask(1) = '1' then
                            counter(47 downto 40)  <= unsigned(bus_write_data(15 downto  8));
                        end if;
                        if bus_write_mask(2) = '1' then
                            counter(55 downto 48)  <= unsigned(bus_write_data(23 downto 16));
                        end if;
                        if bus_write_mask(3) = '1' then
                            counter(63 downto 56)  <= unsigned(bus_write_data(31 downto 24));
                        end if;
                    when "10" =>  
                        if bus_write_mask(0) = '1' then
                            counter_cmp(39 downto 32)  <= unsigned(bus_write_data( 7 downto  0));
                        end if;
                        if bus_write_mask(1) = '1' then
                            counter_cmp(47 downto 40)  <= unsigned(bus_write_data(15 downto  8));
                        end if;
                        if bus_write_mask(2) = '1' then
                            counter_cmp(55 downto 48)  <= unsigned(bus_write_data(23 downto 16));
                        end if;
                        if bus_write_mask(3) = '1' then
                            counter_cmp(63 downto 56)  <= unsigned(bus_write_data(31 downto 24));
                        end if;
                    when "11" =>  
                        if bus_write_mask(0) = '1' then
                            counter_cmp(39 downto 32)  <= unsigned(bus_write_data( 7 downto  0));
                        end if;
                        if bus_write_mask(1) = '1' then
                            counter_cmp(47 downto 40)  <= unsigned(bus_write_data(15 downto  8));
                        end if;
                        if bus_write_mask(2) = '1' then
                            counter_cmp(55 downto 48)  <= unsigned(bus_write_data(23 downto 16));
                        end if;
                        if bus_write_mask(3) = '1' then
                            counter_cmp(63 downto 56)  <= unsigned(bus_write_data(31 downto 24));
                        end if;
                    -- other registers are read only
                    when others =>
                end case;
            else
                if data_valid = '0' then
                   data_valid <= '1';
                end if;

                case bus_addr is
                    when "00"   => bus_read_data <= std_logic_vector(counter(31 downto  0));
                    when "01"   => bus_read_data <= std_logic_vector(counter(63 downto 32));
                    when "10"   => bus_read_data <= std_logic_vector(counter_cmp(31 downto  0));
                    when "11"   => bus_read_data <= std_logic_vector(counter_cmp(63 downto 32));
                    when others => bus_read_data <= (others => '0');
                end case;
            end if;           
        end if;
    end if;
end process;

end Behavioral;
