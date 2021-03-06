--###############################################################################
--# ./sim/tb_isa_check.vhd  - Smoketest the standard instructions
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

entity tb_isa_check is
end tb_isa_check;

architecture Behavioral of tb_isa_check is

    procedure print(str : in string) is
       variable oline : line;
    begin
       write(oline, str);
       writeline(output, oline);
    end procedure;

    component top_level is
    generic ( clock_freq    : natural   := 50000000);
    port ( clk          : in  STD_LOGIC;
             uart_rxd_out : out STD_LOGIC := '1';
             uart_txd_in  : in  STD_LOGIC;
             debug_sel    : in  STD_LOGIC_VECTOR(4 downto 0);
             debug_data   : out STD_LOGIC_VECTOR(31 downto 0);
             debug_pc     : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    signal clk          : STD_LOGIC;
    signal uart_rxd_out : STD_LOGIC := '1';
    signal uart_txd_in  : STD_LOGIC;
    signal debug_sel    : STD_LOGIC_VECTOR(4 downto 0) := "00001";
    signal debug_data   : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_pc     : STD_LOGIC_VECTOR(31 downto 0);
begin

process 
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
uut: top_level 
    generic map (clock_freq => 50000000)
    port map ( clk => clk,
             uart_rxd_out => uart_rxd_out,
             uart_txd_in  => uart_txd_in,
             debug_sel    => debug_sel,
             debug_data   => debug_data,
             debug_pc     => debug_pc);
             
process
    begin
        wait until rising_edge(clk);
        wait for 0.5 ns;
        case debug_pc is
            when x"F0000000" =>             
                debug_sel  <= "00000";
                wait for 0.5 ns;
                print("Check R0 is zero");
                assert debug_data = x"00000000" report "register r00 not 0x0" severity FAILURE;
            when x"F0000004" =>             
                debug_sel  <= "00001";
                wait for 0.5 ns;
                print("0: XOR r01 r01 => r01");
                assert debug_data = x"00000000" report "register r01 not 0x0" severity FAILURE;
            when x"F0000008" =>                                  
                debug_sel  <= "00010";
                wait for 0.5 ns;
                print("1: XOR r02 r02 => r02");
                assert debug_data = x"00000000" report "register r02 not 0x0" severity FAILURE;
                    
            when x"F000000C" =>                                  
                debug_sel  <= "00001";
                wait for 0.5 ns;
                print("2: ADDI r01 1 => r01");
                assert debug_data = x"00000001" report "register r01 not 0x1" severity FAILURE;
             
            when x"F0000010" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("3: ADD r01 r01 => r02");
                assert debug_data = x"00000002" report "FAIL: register r02 not 0x2" severity FAILURE;
                   
            when x"F0000014" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("4: ADD r01 r02 => r02");
                assert debug_data = x"00000003" report "FAIL: register r02 not 0x3" severity FAILURE;
               
            when x"F0000018" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("5: ADDI r02 r01 => r02");
                assert debug_data = x"00000004" report "FAIL: register r02 not 0x4" severity FAILURE;
               
            when x"F000001C" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("6: LUI FFFFF000 => r02");
                assert debug_data = x"FFFFF000" report "FAIL: register r02 not 0xFFFFF000" severity FAILURE;
         
            when x"F0000020" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("7: SRAI r02, 2 => r02");
                assert debug_data = x"FFFFFC00" report "FAIL: register r02 not 0xFFFFFC00" severity FAILURE;
         
            when x"F0000024" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("8: SRLI r02, 4 => r02");
                assert debug_data = x"0FFFFFC0" report "FAIL: register r02 not 0x0FFFFFC0" severity FAILURE;
             
            when x"F0000028" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print(" 9: SLLI r02, 2 => r02");
                assert debug_data = x"3FFFFF00" report "FAIL: register r02 not 0x3FFFFF00" severity FAILURE;
             
-- MEMORY ACCESS INSTRUCTIONS
                   
            when x"F000002C" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("10: AUPCI 0x12345000 => r02");
                assert debug_data = x"02345028" report "FAIL: register r02 not 0x02345028" severity FAILURE;
             
            when x"F0000030" =>                                  
                debug_sel   <= "00111";
                wait for 0.5 ns;
                print("11: LUI   0x10000000 => r07");
                assert debug_data = x"10000000" report "FAIL: register r02 not 0x10000000" severity FAILURE;
             
            when x"F0000034" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("12: SB r02, 0 - not checked yet");
             
            when x"F0000038" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("13: SB r02, 1 - not checked yet");
             
            when x"F000003C" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("14: SB r02, 2 - not checked yet");
             
            when x"F0000040" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("15: SB r02, 3 - not checked yet");
                  
            when x"F0000044" =>                                  
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("16: LW 0, r03");
                assert debug_data = x"28282828" report "FAIL: register r03 not 0x28282828" severity FAILURE;
             
            when x"F0000048" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("17: SH r02, 0 - not checked yet");
             
            when x"F000004C" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("18: SH r02, 2 - not checked yet");
             
            when x"F0000050" =>                                  
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("19: LW 0, r03");
                assert debug_data = x"50285028" report "FAIL: register r03 not 0x50285028" severity FAILURE;
             
            when x"F0000054" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("20: LUI 0x89ABD000 => r02");
                assert debug_data = x"89ABD000" report "FAIL: register r02 not 0x89ABD000" severity FAILURE;
             
            when x"F0000058" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("21: ADDI r02, 0xFFFFFDEF => r02");
                assert debug_data = x"89ABCDEF" report "FAIL: register r02 not 0x89ABCDEF" severity FAILURE;
             
            when x"F000005C" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("22: SW r02, 0 - not checked yet");
             
            when x"F0000060" =>                                  
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("23: LW 0, r03");
                assert debug_data = x"89ABCDEF" report "FAIL: register r03 not 0x89ABCDEF" severity FAILURE;
             
            when x"F0000064" =>                                  
 -- SIGNED lOADS
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("24: LH 0, r02");
                assert debug_data = x"FFFFCDEF" report "FAIL: register r02 not 0xFFFFCDEF" severity FAILURE;
             
            when x"F0000068" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("25: LH 2, r02");
                assert debug_data = x"FFFF89AB" report "FAIL: register r02 not 0xFFFF89AB" severity FAILURE;
             
            when x"F000006C" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("26: LB 0, r02");
                assert debug_data = x"FFFFFFEF" report "FAIL: register r02 not 0xFFFFFFEF" severity FAILURE;
             
            when x"F0000070" =>                                  
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("27: LB 1, r02");
                assert debug_data = x"FFFFFFCD" report "FAIL: register r02 not 0xFFFFFFCD" severity FAILURE;
             
            when x"F0000074" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("28: LB 2, r02");
                assert debug_data = x"FFFFFFAB" report "FAIL: register r02 not 0xFFFFFFAB" severity FAILURE;
             
            when x"F0000078" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("29: LB 3, r02");
                assert debug_data = x"FFFFFF89" report "FAIL: register r02 not 0xFFFFFF89" severity FAILURE;
             
 -- UNSIGNED lOADS
            when x"F000007C" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("30: LHU 0, r02");
                assert debug_data = x"0000CDEF" report "FAIL: register r02 not 0x0000CDEF" severity FAILURE;
             
            when x"F0000080" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("31: LHU 2, r02");
                assert debug_data = x"000089AB" report "FAIL: register r02 not 0x000089AB" severity FAILURE;
             
            when x"F0000084" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("32: LBU 0, r02");
                assert debug_data = x"000000EF" report "FAIL: register r02 not 0x000000EF" severity FAILURE;
             
            when x"F0000088" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("33: LBU 1, r02");
                assert debug_data = x"000000CD" report "FAIL: register r02 not 0x000000CD" severity FAILURE;
             
            when x"F000008C" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("34: LBU 2, r02");
                assert debug_data = x"000000AB" report "FAIL: register r02 not 0x000000AB" severity FAILURE;
             
            when x"F0000090" =>
                debug_sel   <= "00010";
                print("35: LBU 3, r02");
                assert debug_data = x"00000089" report "FAIL: register r02 not 0x00000089" severity FAILURE;

---- ALU OPERATIONS 
            when x"F0000094" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("36: LUI r02, 0x66666000");
                assert debug_data = x"66666000" report "FAIL: register r02 not 0x66666000" severity FAILURE;
             
            when x"F0000098" =>
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("37: ADDI r02, 0x666, r02");
                assert debug_data = x"66666666" report "FAIL: register r02 not 0x66666666" severity FAILURE;
             
            when x"F000009C" =>
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("38: LUI r03, 0xCCCCD000");
                assert debug_data = x"CCCCD000" report "FAIL: register r03 not 0xCCCCD000" severity FAILURE;
             
            when x"F00000A0" =>
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("39: ADDI r03, 0xCCC, r02");
                assert debug_data = x"CCCCCCCC" report "FAIL: register r03 not 0xCCCCCCCC" severity FAILURE;
             
            when x"F00000A4" =>
                -- r02 set to 66666666, r03 set to CCCCCCCCC
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("40: ADD  r02, r03, r04");
                assert debug_data = x"33333332" report "FAIL: register r04 not 0x33333332" severity FAILURE;
             
            when x"F00000A8" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("41: ADD  r03, r02, r04");
                assert debug_data = x"33333332" report "FAIL: register r04 not 0x33333332" severity FAILURE;
             
            when x"F00000AC" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("42: SUB  r02, r03, r04");
                assert debug_data = x"9999999A" report "FAIL: register r04 not 0x9999999A" severity FAILURE;
             
            when x"F00000B0" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("43: SUB  r03, r02, r04");
                assert debug_data = x"66666666" report "FAIL: register r04 not 0x66666666" severity FAILURE;
             
            when x"F00000B4" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("44: SLL  r02, r03, r04");
                assert debug_data = x"66666000" report "FAIL: register r04 not 0x66666000" severity FAILURE;
             
            when x"F00000B8" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("45: SLL  r03, r02, r04");
                assert debug_data = x"33333300" report "FAIL: register r04 not 0x33333300" severity FAILURE;
             
            when x"F00000BC" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("46: SLT  r02, r03, r04");
                assert debug_data = x"00000000" report "FAIL: register r04 not 0x00000000" severity FAILURE;
             
            when x"F00000C0" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("47: SLT  r03, r02, r04");
                assert debug_data = x"00000001" report "FAIL: register r04 not 0x00000001" severity FAILURE;
             
            when x"F00000C4" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("48: SLTU r02, r03, r04");
                assert debug_data = x"00000001" report "FAIL: register r04 not 0x00000001" severity FAILURE;
             
            when x"F00000C8" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("49: SLTU r03, r02, r04");
                assert debug_data = x"00000000" report "FAIL: register r04 not 0x00000000" severity FAILURE;
             
            when x"F00000CC" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("50: XOR  r02, r03, r04");
                assert debug_data = x"AAAAAAAA" report "FAIL: register r04 not 0xAAAAAAAA" severity FAILURE;
             
            when x"F00000D0" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("51: XOR  r03, r02, r04");
                assert debug_data = x"AAAAAAAA" report "FAIL: register r04 not 0xAAAAAAAA" severity FAILURE;
             
            when x"F00000D4" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("52: SRL  r02, r03, r04");
                assert debug_data = x"00066666" report "FAIL: register r04 not 0x00066666" severity FAILURE;
             
            when x"F00000D8" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("53: SRL  r03, r02, r04");
                assert debug_data = x"03333333" report "FAIL: register r04 not 0x03333333" severity FAILURE;
             
            when x"F00000DC" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("54: SRA  r02, r03, r04");
                assert debug_data = x"00066666" report "FAIL: register r04 not 0x00066666" severity FAILURE;
             
            when x"F00000E0" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("55: SRA  r03, r02, r04");
                assert debug_data = x"FF333333" report "FAIL: register r04 not 0xFF333333" severity FAILURE;
             
            when x"F00000E4" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("56: OR   r02, r03, r04");
                assert debug_data = x"EEEEEEEE" report "FAIL: register r04 not 0xEEEEEEEE" severity FAILURE;
             
            when x"F00000E8" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("57: OR   r03, r02, r04");
                assert debug_data = x"EEEEEEEE" report "FAIL: register r04 not 0xEEEEEEEE" severity FAILURE;
             
            when x"F00000EC" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("58: AND  r02, r03, r04");
                assert debug_data = x"44444444" report "FAIL: register r04 not 0x44444444" severity FAILURE;
             
            when x"F00000F0" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("59: AND  r03, r02, r04");
                assert debug_data = x"44444444" report "FAIL: register r04 not 0x44444444" severity FAILURE;
             
 ---- Immediate ALU ops
             
            when x"F00000F4" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("60: ADDI  r03, 0x666, r04");
                assert debug_data = x"CCCCD332" report "FAIL: register r04 not 0xCCCCD332" severity FAILURE;
             
            when x"F00000F8" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("61: SLTI  r03, 0x666, r04");
                assert debug_data = x"00000001" report "FAIL: register r04 not 0x00000001" severity FAILURE;
             
            when x"F00000FC" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("62: SLTUI r03, 0x666, r04");
                assert debug_data = x"00000000" report "FAIL: register r04 not 0x00000000" severity FAILURE;
             
            when x"F0000100" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("63: XORI  r03, 0x666, r04");
                assert debug_data = x"CCCCCAAA" report "FAIL: register r04 not 0xCCCCCAAA" severity FAILURE;
             
            when x"F0000104" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("64: ORI   r03, 0x666, r04");
                assert debug_data = x"CCCCCEEE" report "FAIL: register r04 not 0xCCCCCEEE" severity FAILURE;
             
            when x"F0000108" =>
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("65: ANDI  r03, 0x666, r04");
                assert debug_data = x"00000444" report "FAIL: register r04 not 0x00000444" severity FAILURE;
             
            when x"F000010C" =>             
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("66: SLLI  r03, 0x6, r04");
                assert debug_data = x"33333300" report "FAIL: register r04 not 0x33333300" severity FAILURE;
             
            when x"F0000110" =>             
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("67: SRLI  r03, 0x6, r04");
                assert debug_data = x"03333333" report "FAIL: register r04 not 0x03333333" severity FAILURE;
             
            when x"F0000114" =>             
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("68: SRAI  r03, 0x6, r04");
                assert debug_data = x"FF333333" report "FAIL: register r04 not 0xFF333333" severity FAILURE;
             
            when x"F0000118" =>                          
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("69: ADDI  r03 <= r00 + 0x000");
                assert debug_data = x"00000000" report "FAIL: register r03 not 0x00000000" severity FAILURE;
             
            when x"F000011C" =>
-- Relative jumps
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("70: JAL   +8, r04");
                assert debug_data = x"F000011C" report "FAIL: register r04 not 0xF000011C" severity FAILURE;
             
            when x"F0000120" =>                          
                debug_sel   <= "00011";
                print("71: ORI   r03 <= r03 | 0x001"); 
--               assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
         
            when x"F0000124" =>                          
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("72: ORI   r03 <= r03 | 0x002");
                assert debug_data = x"00000002" report "FAIL: register r03 not 0x00000002" severity FAILURE;

            when x"F0000128" =>             
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("73: ORI   r03 <= r03 | 0x004");
                assert debug_data = x"00000006" report "FAIL: register r03 not 0x00000006" severity FAILURE;
             
            when x"F000012C" =>             
                -----------------------------------------------------------------
                ------ Testing conditional branches with r03 = 8 and r04 = 8
                -----------------------------------------------------------------
                -- XOR  r02 <= r02 ^ r02
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("74: XOR   r02 <= r02 ^ r02");
                assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;
         
            when x"F0000130" =>             
                -- ADDI r03 <= r02 + 0x008
                debug_sel   <= "00011";
                wait for 0.5 ns;
                print("75: ADDI   r03 <= r02 + 0x8");
                assert debug_data = x"00000008" report "FAIL: register r03 not 0x00000008" severity FAILURE;
         
            when x"F0000134" =>             
                -- ADDI r04 <= r02 + 0x008
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("76: ADDI   r04 <= r02 + 0x8");
                assert debug_data = x"00000008" report "FAIL: register r04 not 0x00000008" severity FAILURE;
         
            when x"F0000138" =>             
                -- ORI  r02 <= r02 | 0x001
                print("78: ORI r02 <= r02 | 0x1  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
         
            when x"F000013C" =>             
                    -- BEQ  r03, r04, +8
                    debug_sel   <= "00010";
                    wait for 0.5 ns;
                    print("77: BEQ r03,r04,+8");
                    assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;
             
            when x"F0000140" =>             
                -- BNE  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("79: BNE r03,r04,+8");
                assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;
         
            when x"F0000144" =>             
                -- ORI  r02 <= r02 | 0x002
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("80: ORI r02 <= r02 | 0x2");
                assert debug_data = x"00000002" report "FAIL: register r02 not 0x00000002" severity FAILURE;
         
            when x"F0000148" =>             
                -- BLT  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("81: BLT r03,r04,+8");
         
            when x"F000014C" =>             
                -- ORI  r02 <= r02 | 0x004
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("82: ORI r02 <= r02 | 0x4");
                assert debug_data = x"00000006" report "FAIL: register r02 not 0x00000006" severity FAILURE;
         
            when x"F0000150" =>             
                    -- ORI  r02 <= r02 | 0x008
                    print("84: ORI r02 <= r02 | 0x8  -  should be skipped");
                    assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
             
            when x"F0000154" =>             
                -- BGE  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("83: BGE r03,r04,+8");
         
            when x"F0000158" =>             
                -- BLTU r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("85: BLTU r03,r04,+8");
         
            when x"F000015C" =>             
                -- ORI  r02 <= r02 | 0x010
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("86: ORI r02 <= r02 | 0x10");
                assert debug_data = x"00000016" report "FAIL: register r02 not 0x00000016" severity FAILURE;
         
            when x"F0000160" =>             
                -- ORI  r02 <= r02 | 0x020
                print("88: ORI r02 <= r02 | 0x20  -  should be skipped");
         
            when x"F0000164" =>             
                -- BGEU r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("87: BGEU r03,r04,+8");
         
            when x"F0000168" =>             
                -----------------------------------------------------------------
                ------ Testing conditional branches with r03 = 8 and r04 = 16
                -----------------------------------------------------------------
                -- XOR  r02 <= r02 ^ r02
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("89: XOR   r02 <= r02 ^ r02");
                assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;
         
            when x"F000016C" =>             
                -- ADDI r04 <= r03 + 0x008
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("90: ADDI   r04 <= r03 + 0x8");
                assert debug_data = x"00000010" report "FAIL: register r04 not 0x00000010" severity FAILURE;
         
            when x"F0000170" =>
                -- BEQ  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("91: BEQ  r03, r04,+8");
         
            when x"F0000174" =>
                -- ORI  r02 <= r02 | 0x001
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("92: ORI r02 <= r02 | 0x01");
                assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;
         
            when x"F0000178" =>
                -- ORI  r02 <= r02 | 0x002
                print("94: ORI r02 <= r02 | 0x2  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
         
            when x"F000017C" =>
                -- BNE  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("93: BNE  r03, r04,+8");
                assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;
         
            when x"F0000180" =>
                -- ORI  r02 <= r02 | 0x004
                print("96: ORI r02 <= r02 | 0x4  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
         
            when x"F0000184" =>
                -- BLT  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("95: BLT  r03, r04,+8");
                assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;
         
            when x"F0000188" =>
                -- BGE  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("97: BGE  r03, r04,+8");
                assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;
         
            when x"F000018C" =>
                -- ORI  r02 <= r02 | 0x008
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("98: ORI r02 <= r02 | 0x08");
                assert debug_data = x"00000009" report "FAIL: register r02 not 0x00000009" severity FAILURE;
         
            when x"F0000190" =>
                -- ORI  r02 <= r02 | 0x010
                print("100: ORI r02 <= r02 | 0x10  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
         
            when x"F0000194" =>
                -- BLTU r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("99: BLTU r03, r04,+8");
         
            when x"F0000198" =>
                -- BGEU r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("101: BGEU r03, r04,+8");
         
            when x"F000019C" =>
                -- ORI  r02 <= r02 | 0x020
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("102: ORI r02 <= r02 | 0x08");
                assert debug_data = x"00000029" report "FAIL: register r02 not 0x00000029" severity FAILURE;
         
            when x"F00001A0" =>
                -----------------------------------------------------------------
                ------ Testing conditional branches with r03 = 8 and r04 = -16
                -----------------------------------------------------------------
                -- XOR  r02 <= r02 ^ r02
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("103: XOR   r02 <= r02 ^ r02");
                assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;
         
            when x"F00001A4" =>
                -- ADDI r04 <= r02 + 0xFFFFFFE0  (-32)
                debug_sel   <= "00100";
                wait for 0.5 ns;
                print("104: ADDI   r04 <= r02 + 0xFE0");
                assert debug_data = x"FFFFFFE0" report "FAIL: register r04 not 0xFFFFFFE0" severity FAILURE;

            when x"F00001A8" =>
                -- BEQ  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("105: BEQ  r03, r04,+8");
         
            when x"F00001AC" =>
                -- ORI  r02 <= r02 | 0x001
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("106: ORI r02 <= r02 | 0x01");
                assert debug_data = x"00000001" report "FAIL: register r02 not 0x00000001" severity FAILURE;
         
            when x"F00001B0" =>
                -- ORI  r02 <= r02 | 0x002
                print("108: ORI r02 <= r02 | 0x02  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
         
            when x"F00001B4" =>
                -- BNE  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("107: BNE  r03, r04,+8");
         
            when x"F00001B8" =>
                -- BLT  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("109: BLT  r03, r04,+8");
         
            when x"F00001BC" =>
                -- ORI  r02 <= r02 | 0x004
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("110: ORI r02 <= r02 | 0x04");
                assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;
         
            when x"F00001C0" =>         
                -- ORI  r02 <= r02 | 0x008
                print("112: ORI r02 <= r02 | 0x08  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;

            when x"F00001C4" =>         
                -- BGE  r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("111: BGE  r03, r04,+8");
                assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;
         
            when x"F00001C8" =>         
                -- ORI  r02 <= r02 | 0x010
                print("114: ORI r02 <= r02 | 0x10  -  should be skipped");
                assert debug_pc = x"00000000" report "This should never be run" severity FAILURE;
     
         
            when x"F00001CC" =>         
                -- BLTU r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("113: BLTU r03, r04,+8");
                assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;
                
            when x"F00001D0" =>         
                -- BGEU r03, r04, +8
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("115: BGEU r03, r04,+8");
                assert debug_data = x"00000005" report "FAIL: register r02 not 0x00000005" severity FAILURE;
         
            when x"F00001D4" =>                  
                -- ORI  r02 <= r02 | 0x020
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("116: ORI r02 <= r02 | 0x20");
                assert debug_data = x"00000025" report "FAIL: register r02 not 0x00000025" severity FAILURE;

            when x"F00001D8" =>                  
                -- CSRRW r05, 0xF11, r00
                debug_sel   <= "00101";
                wait for 0.5 ns;
                print("117: CSRRW r05, 0xF11, r00");
                assert debug_data = x"F00DF00D" report "FAIL: register r05 not 0xF00DF00D" severity FAILURE;

            when x"F00001DC" =>                  
                -- CSRRW r05, 0xF12, r00
                debug_sel   <= "00101";
                wait for 0.5 ns;
                print("118: CSRRW r05, 0xF12, r00");
                assert debug_data = x"FEEDFEED" report "FAIL: register r05 not 0xFEEDFEED" severity FAILURE;

            when x"F00001E0" =>                  
                -- CSRRW r05, 0xF13, r00
                debug_sel   <= "00101";
                wait for 0.5 ns;
                print("119: CSRRW r05, 0xF13, r00");
                assert debug_data = x"DEADBEEF" report "FAIL: register r05 not 0xDEADBEEF" severity FAILURE;

            when x"F00001E4" =>                  
                -- CSRRW r05, 0xF14, r00
                debug_sel   <= "00101";
                wait for 0.5 ns;
                print("120: CSRRW r05, 0xF14, r00");
                assert debug_data = x"00000000" report "FAIL: register r05 not 0x00000000" severity FAILURE;

            when x"F00001E8" =>                  
                -- LUI r02, 0xF0000
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("119: LUI r02, 0xF0000");
                assert debug_data = x"F0000000" report "FAIL: register r02 not 0xF0000000" severity FAILURE;

            when x"F00001EC" =>                  
                -- ORI r02, 0x200
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("119: ORI r02, 0x200");
                assert debug_data = x"F0000200" report "FAIL: register r02 not 0xF0000200" severity FAILURE;
            when x"F00001F0" =>                  
                -- CSRRW r02, 0x305, r02
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("120: CSRRW r02, 0x305, r02");
                assert debug_data = x"00000000" report "FAIL: register r02 not 0x00000000" severity FAILURE;
            when x"F00001F4" =>                  
                -- ORI r02, 0x200
                debug_sel   <= "00010";
                wait for 0.5 ns;
                print("121: ORI r02, 0x200");
                assert debug_data = x"00000200" report "FAIL: register r02 not 0x00000200" severity FAILURE;
            when x"F00001F8" =>                  
                assert debug_pc /= x"F00001F8" report "FAIL: pc should not get to 0xF00001F8" severity FAILURE;
            when x"F00001FC" =>                  
                assert debug_pc /= x"F00001FC" report "FAIL: pc should not get to 0xF00001FC" severity FAILURE;

            when x"F0000200" =>                  
                -- Target of exception

            when x"F0000204" =>                  
                -- CSRRS r05 <= CSR[0x342] (mcause), should be 02
                debug_sel   <= "00101";
                wait for 0.5 ns;
                print("128: CSRRW r05, 0x342, r00");
                assert debug_data = x"00000002" report "FAIL: register r05 not 0x00000002" severity FAILURE;

            when x"F0000208" =>
                -- CSRRS r05 <= CSR[0x341] (mepc) should be 0xF00001F4
                debug_sel   <= "00101";
                wait for 0.5 ns;
                print("129: CSRRW r05, 0x341, r00");
                assert debug_data = x"F00001F4" report "FAIL: register r05 not 0xF00001F4" severity FAILURE;

            when x"F000020C" =>
                print("All tests complete");
                wait;

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
