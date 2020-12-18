library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity ram_memory is
  port ( clk            : in  STD_LOGIC;
         bus_busy       : out STD_LOGIC;
         bus_addr       : in  STD_LOGIC_VECTOR(11 downto 2);
         bus_enable     : in  STD_LOGIC;
         bus_write_mask : in  STD_LOGIC_VECTOR(3 downto 0);
         bus_write_data : in  STD_LOGIC_VECTOR(31 downto 0);
         bus_read_data  : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0'));
end entity;
 
architecture Behavioral of ram_memory is
    type a_memory is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : a_memory := (
         0 => x"6c6c6548",
         1 => x"6f77206f",
         2 => x"21646c72",
         3 => x"00000a0d",
         4 => x"61686320",
         5 => x"74636172",
         6 => x"20737265",
         7 => x"676e6f6c",
         8 => x"00000a0d",
         9 => x"74786554",
         10 => x"00000020",
         11 => x"e0000000",
         12 => x"e0000004",
         13 => x"e0000008",
         14 => x"e000000c",
         15 => x"e0000010",
         16 => x"e0000014",
       others => (others=>'0'));
    signal data_valid : STD_LOGIC := '1';
begin


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
        data_valid <= '0';
        if bus_enable = '1' then
            if bus_write_mask(0) = '1' then
                memory(to_integer(unsigned(bus_addr)))( 7 downto  0) <= bus_write_data( 7 downto  0);
            end if;
            if bus_write_mask(1) = '1' then
                memory(to_integer(unsigned(bus_addr)))(15 downto  8) <= bus_write_data(15 downto  8);
            end if;
            if bus_write_mask(2) = '1' then
                memory(to_integer(unsigned(bus_addr)))(23 downto 16) <= bus_write_data(23 downto 16);
            end if;
            if bus_write_mask(3) = '1' then
                memory(to_integer(unsigned(bus_addr)))(31 downto 24) <= bus_write_data(31 downto 24);
            end if;

            if bus_write_mask = "0000" and data_valid = '0' then
                data_valid <= '1';
            end if; 
            bus_read_data <= memory(to_integer(unsigned(bus_addr)));
        end if;
    end if;
end process;

end Behavioral;
