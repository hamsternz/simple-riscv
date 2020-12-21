--###############################################################################
--# ./hdl/cpu/decode/decode_unit.vhd  - Instruction decoder
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

use work.cpu_constants.ALL;

entity decode_unit is
    Port (  clk                       : in  STD_LOGIC;
            reset                     : in  STD_LOGIC;

            exec_instr_completed      : in  STD_LOGIC;
            exec_instr_failed         : in  STD_LOGIC;
            exec_flush_required       : in  STD_LOGIC;
            -- from the fetch unit
            fetch_opcode              : in  STD_LOGIC_VECTOR (31 downto 0);
            fetch_addr                : in  STD_LOGIC_VECTOR (31 downto 0);
            -- To the exec unit
            decode_addr               : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            decode_immed              : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
            decode_reg_a              : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_a           : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
            decode_reg_b              : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_b           : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
            decode_jump_enable        : out STD_LOGIC := '0';
            decode_pc_mode            : out STD_LOGIC_VECTOR(1 downto 0) := "00";
            decode_pc_jump_offset     : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_loadstore_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
            decode_loadstore_enable   : out STD_LOGIC := '0';
            decode_loadstore_write    : out STD_LOGIC := '0';
            decode_loadstore_width    : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
            decode_loadstore_ex_mode  : out STD_LOGIC_VECTOR(0 downto 0) := "0";
            decode_loadstore_ex_width : out STD_LOGIC_VECTOR(1 downto 0) := "00";
    
            decode_alu_enable         : out STD_LOGIC := '0';
            decode_alu_mode           : out STD_LOGIC_VECTOR(2 downto 0) := "000";

            decode_branchtest_enable  : out STD_LOGIC := '0';
            decode_branchtest_mode    : out STD_LOGIC_VECTOR(2 downto 0) := "000";

            decode_shift_enable       : out STD_LOGIC := '0';
            decode_shift_mode         : out STD_LOGIC_VECTOR(1 downto 0) := "00";
    
            decode_result_src         : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
            decode_rdest              : out STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

            -- To allow interrupts to be forced
            decode_force_complete     : out STD_LOGIC := '0');            
end decode_unit;

architecture Behavioral of decode_unit is
   -- decoding the instruction
    signal opcode  : STD_LOGIC_VECTOR( 6 downto 0);
    signal rd      : STD_LOGIC_VECTOR( 4 downto 0);
    signal rs1     : STD_LOGIC_VECTOR( 4 downto 0);
    signal rs2     : STD_LOGIC_VECTOR( 4 downto 0);
    signal func3   : STD_LOGIC_VECTOR( 2 downto 0);
    signal func7   : STD_LOGIC_VECTOR( 6 downto 0);
    signal immed_I : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_S : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_B : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_U : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_J : STD_LOGIC_VECTOR(31 downto 0);
    signal instr31 : STD_LOGIC_VECTOR(31 downto 0);

    -- Exception handling/Interrupts
    signal raise_exception : STD_LOGIC;    
    signal exception       : STD_LOGIC_VECTOR(2 downto 0);
begin
   raise_exception <= reset or exec_instr_failed;
   exception <= EXCEPTION_RESET         when reset = '1' else 
                EXCEPTION_UNKNOWN_INSTR when exec_instr_failed = '1' else 
                EXCEPTION_NONE;

   with fetch_opcode(31) select instr31 <= x"FFFFFFFF" when '1', x"00000000" when others;

   -- Break down the R, I, S, B, U. J-type instructions, as per ISA
   opcode  <= fetch_opcode( 6 downto 0);
   rd      <= fetch_opcode(11 downto 7);
   func3   <= fetch_opcode(14 downto 12);
   func7   <= fetch_opcode(31 downto 25);
   rs1     <= fetch_opcode(19 downto 15);
   rs2     <= fetch_opcode(24 downto 20);
   immed_I <= instr31(31 downto 12) & fetch_opcode(31 downto 20);
   immed_S <= instr31(31 downto 12) & fetch_opcode(31 downto 25) & fetch_opcode(11 downto 7);
   immed_B <= instr31(31 downto 12) & fetch_opcode(7) & fetch_opcode(30 downto 25) & fetch_opcode(11 downto 8) & "0";
   immed_U <= fetch_opcode(31 downto 12) & x"000";
   immed_J <= instr31(31 downto 20) & fetch_opcode(19 downto 12) & fetch_opcode(20) & fetch_opcode(30 downto 21) & "0" ;

process(clk)
    begin
        if rising_edge(clk) then
            if exec_instr_completed = '1' OR exec_flush_required = '1' then
    
                 -- Set defaults for invalid instructions
                decode_addr              <= fetch_addr;
                decode_immed             <= immed_I;
                decode_force_complete    <= '0';
                decode_alu_enable        <= '0';
                decode_jump_enable       <= '0';
                decode_shift_enable      <= '0';
                decode_branchtest_enable <= '0';
        
                decode_reg_a            <= rs1; 
                decode_select_a         <= A_BUS_REGISTER;
        
                decode_reg_b            <= rs2;
                decode_select_b         <= B_BUS_REGISTER;
        
                decode_pc_mode          <= PC_JMP_RELATIVE_CONDITIONAL;
                decode_branchtest_mode <= func3;
                decode_branchtest_enable <= '0';
        
                decode_pc_jump_offset <= immed_B;
                if opcode(5) = '1' then
                   decode_loadstore_offset <= immed_S;
                else
                   decode_loadstore_offset <= immed_I;
                end if;      
        
                decode_alu_mode         <= ALU_ADD;  -- Adds are used for memory addressing when minimal size is built
                decode_shift_mode       <= SHIFTER_LEFT_LOGICAL;
                decode_result_src       <= RESULT_ALU;         
                decode_rdest            <= "00000";  -- By default write to register zero (which stays zero)
                
                decode_loadstore_width        <= func3(1 downto 0);
                decode_loadstore_write        <= '0';
                decode_loadstore_enable       <= '0';
                decode_loadstore_ex_width    <= SIGN_EX_WIDTH_W;
                decode_loadstore_ex_mode     <= SIGN_EX_UNSIGNED;
        
                case opcode is 
                   ----------------- LUI --------------------
                   when "0110111" =>    
                       decode_alu_enable       <= '1';
                       decode_immed            <= immed_U;
                       decode_reg_a            <= "00000"; 
                       decode_select_b         <= B_BUS_IMMEDIATE;
                       decode_alu_mode         <= ALU_OR; 
                       decode_rdest            <= rd;
                   ----------------- AUIPC-------------------
                   when "0010111" =>
                       decode_alu_enable       <= '1';
                       decode_immed            <= immed_U;
                       decode_select_a         <= A_BUS_PC;                
                       decode_select_b         <= B_BUS_IMMEDIATE;
                       decode_alu_mode         <= ALU_ADD;
                       decode_rdest            <= rd;
                   ----------------- JAL  -------------------
                   when "1101111" =>
                       decode_jump_enable      <= '1';
                       decode_pc_jump_offset   <= immed_J;
                       decode_result_src       <= RESULT_PC_PLUS_4;
                       decode_rdest            <= rd;
                       decode_pc_mode          <= PC_JMP_RELATIVE;
        
                   ----------------- JALR -------------------
                   when "1100111" =>
                       if func3 = "000" then
                          decode_jump_enable <= '1';
                          decode_pc_jump_offset   <= immed_I;
                          decode_select_b      <= B_BUS_IMMEDIATE;
                          decode_result_src    <= RESULT_PC_PLUS_4;
                          decode_rdest         <= rd;
                          decode_pc_mode       <= PC_JMP_REG_RELATIVE;
                       end if;
        
                   ----------------- BEQ, BNE, BLT, BGE, BLTU, BGEU  -------------------
                   when "1100011" =>
                       case func3 is
                          when "000"  =>
                             ----------------- BEQ  -------------------
                             -- offset and branch condition already set as defaults
                             decode_branchtest_enable  <= '1';
                             decode_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                          when "001"  =>
                             ----------------- BNE  ------------------
                             -- offsets already set as defaults
                             decode_branchtest_enable  <= '1';
                             decode_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                          when "100"  =>
                             ----------------- BLT -------------------
                             -- offsets already set as defaults
                             decode_branchtest_enable  <= '1';
                             decode_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                          when "101"  =>
                             ----------------- BGE  -------------------
                             -- offsets already set as defaults
                             decode_branchtest_enable  <= '1';
                             decode_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                          when "110"  =>
                             ----------------- BLTU  -------------------
                             -- offsets already set as defaults
                             decode_branchtest_enable  <= '1';
                             decode_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                          when "111"  =>
                             ----------------- BGEU  -------------------
                             -- offsets already set as defaults
                             decode_branchtest_enable  <= '1';
                             decode_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                          when others  =>  NULL;
                             -- Undecoded for opcode 1100011                      
                       end case;
                   when "0000011" =>
                       case func3 is 
                          when "000"  =>
                             ------------ LB ------------------
                             decode_loadstore_enable    <= '1';
                             decode_immed               <= immed_I;
                             decode_loadstore_width     <= "00";
                             decode_loadstore_ex_width  <= SIGN_EX_WIDTH_B;
                             decode_loadstore_ex_mode   <= SIGN_EX_SIGNED;
                             decode_rdest               <= rd;
                             decode_result_src          <= RESULT_MEMORY;
                          when "001"  =>
                             ------------ LH ------------------
                             decode_loadstore_enable    <= '1';
                             decode_immed               <= immed_I;
                             decode_loadstore_width     <= "01";
                             decode_loadstore_ex_width  <= SIGN_EX_WIDTH_H;
                             decode_loadstore_ex_mode   <= SIGN_EX_SIGNED;
                             decode_rdest               <= rd;
                             decode_result_src          <= RESULT_MEMORY;
                          when "010"  =>
                             ------------ LW ------------------
                             decode_loadstore_enable    <= '1';
                             decode_immed               <= immed_I;
                             decode_loadstore_width     <= "10";
                             decode_loadstore_ex_width  <= SIGN_EX_WIDTH_W;
                             decode_loadstore_ex_mode   <= SIGN_EX_SIGNED;
                             decode_rdest               <= rd;
                             decode_result_src          <= RESULT_MEMORY;
                          when "100"  =>
                             ------------ LBU ------------------
                             decode_immed               <= immed_I;
                             decode_loadstore_width     <= "00";
                             decode_loadstore_enable    <= '1';
                             decode_loadstore_ex_width  <= SIGN_EX_WIDTH_B;
                             decode_loadstore_ex_mode   <= SIGN_EX_UNSIGNED;
                             decode_rdest               <= rd;
                             decode_result_src          <= RESULT_MEMORY;
                          when "101"  =>
                             ------------ LHU ------------------
                             decode_immed               <= immed_I;
                             decode_loadstore_width     <= "01";
                             decode_loadstore_enable    <= '1';
                             decode_loadstore_ex_width  <= SIGN_EX_WIDTH_H;
                             decode_loadstore_ex_mode   <= SIGN_EX_UNSIGNED;
                             decode_rdest               <= rd;
                             decode_result_src          <= RESULT_MEMORY;
                          when others  =>  NULL;
                             -- Undecoded for opcode 0000011                      
                       end case;
                   when "0100011" =>
                       case func3 is 
                          when "000"  =>
                             ------------ SB ------------------
                             decode_loadstore_enable    <= '1';
                             decode_loadstore_width     <= "00";
                             decode_loadstore_write     <= '1';
                             decode_rdest               <= (others => '0');
                          when "001"  =>
                             ------------ SH ------------------
                             decode_loadstore_enable    <= '1';
                             decode_loadstore_width     <= "01";
                             decode_loadstore_write     <= '1';
                             decode_rdest               <= (others => '0');
                          when "010"  =>
                             ------------ SW ------------------
                             decode_loadstore_enable    <= '1';
                             decode_loadstore_width     <= "10";
                             decode_loadstore_write     <= '1';
                             decode_rdest               <= (others => '0');
                          when others  =>  NULL;
                             -- Undecoded for opcode 0100011                      
                       end case;
                   when "0010011" =>
                       decode_immed       <= immed_I;
                       case func3 is                 
                          when "000"  =>
                             ------------ ADDI ------------------
                             decode_alu_enable          <= '1';
                             decode_select_b            <= B_BUS_IMMEDIATE;
                             decode_alu_mode            <= ALU_ADD;
                             decode_rdest               <= rd;
                          when "001"  =>
                             case func7 is                 
                                when "0000000"  =>
                                   ------------ SLLI ------------------
                                   decode_shift_enable  <= '1';
                                   decode_select_b      <= B_BUS_IMMEDIATE;
                                   decode_result_src    <= RESULT_SHIFTER;
                                   decode_shift_mode    <= SHIFTER_LEFT_LOGICAL; 
                                   decode_rdest         <= rd;
                                when others =>
                             end case; 
                          when "010"  =>
                             ------------ SLTI ------------------
                             decode_alu_enable          <= '1';
                             decode_select_b           <= B_BUS_IMMEDIATE;
                             decode_alu_mode            <= ALU_LESS_THAN_SIGNED;
                             decode_rdest               <= rd;
                          when "011"  =>
                             ------------ SLTIU ------------------
                             decode_alu_enable          <= '1';
                             decode_select_b           <= B_BUS_IMMEDIATE;
                             decode_alu_mode            <= ALU_LESS_THAN_UNSIGNED;
                             decode_rdest               <= rd;
                          when "100"  =>
                             ------------ XORI ------------------
                             decode_alu_enable          <= '1';
                             decode_select_b           <= B_BUS_IMMEDIATE;
                             decode_alu_mode            <= ALU_XOR; 
                             decode_rdest               <= rd;
                          when "101"  =>
                             case func7 is                 
                                when "0000000"  =>
                                   ------------ SRLI ------------------
                                   decode_shift_enable  <= '1';
                                   decode_select_b      <= B_BUS_IMMEDIATE;
                                   decode_result_src    <= RESULT_SHIFTER;
                                   decode_shift_mode    <= SHIFTER_RIGHT_LOGICAL; 
                                   decode_rdest         <= rd;
                                when "0100000"  =>
                                   ------------ SRAI ------------------
                                   decode_shift_enable  <= '1';
                                   decode_select_b      <= B_BUS_IMMEDIATE;
                                   decode_result_src    <= RESULT_SHIFTER;
                                   decode_shift_mode    <= SHIFTER_RIGHT_ARITH; 
                                   decode_rdest         <= rd;
                                when others =>
                             end case; 
                          when "110"  =>
                             ------------ ORI ------------------
                             decode_alu_enable          <= '1';
                             decode_select_b           <= B_BUS_IMMEDIATE;
                             decode_alu_mode            <= ALU_OR; 
                             decode_rdest               <= rd;
                          when "111"  =>
                             ------------ ANDI ------------------
                             decode_alu_enable          <= '1';
                             decode_select_b           <= B_BUS_IMMEDIATE;
                             decode_alu_mode            <= ALU_AND; 
                             decode_rdest               <= rd;
                          when others  =>  NULL;
                             -- Undecoded for opcode 0100011                      
                       end case;
        
                   when "0110011" =>
                      case func7 is                 
                         when "0000000"  =>
                            case func3 is 
                                  when "000"  =>
                                     ------------ ADD ------------------
                                     decode_alu_enable  <= '1';
                                     decode_alu_mode    <= ALU_ADD; 
                                     decode_rdest       <= rd;
                                  when "001"  =>
                                     ------------ SLL ------------------
                                     decode_shift_enable <= '1';
                                     decode_result_src   <= RESULT_SHIFTER;
                                     decode_shift_mode   <= SHIFTER_LEFT_LOGICAL; 
                                     decode_rdest        <= rd;
                                  when "010"  =>
                                     ------------ SLT ------------------
                                     decode_alu_enable  <= '1';
                                     decode_alu_mode    <= ALU_LESS_THAN_SIGNED;
                                     decode_rdest       <= rd;
                                  when "011"  =>
                                     ------------ SLTU ------------------
                                     decode_alu_enable  <= '1';
                                     decode_alu_mode    <= ALU_LESS_THAN_UNSIGNED;
                                     decode_rdest       <= rd;
                                  when "100"  =>
                                     ------------ XOR ------------------
                                     decode_alu_enable  <= '1';
                                     decode_alu_mode    <= ALU_XOR; 
                                     decode_rdest       <= rd;
                                  when "101"  =>
                                     ------------ SRL ------------------
                                     decode_shift_enable <= '1';
                                     decode_result_src   <= RESULT_SHIFTER;
                                     decode_shift_mode   <= SHIFTER_RIGHT_LOGICAL; 
                                     decode_rdest        <= rd;
                                  when "110"  =>
                                     ------------ OR ------------------
                                     decode_alu_enable  <= '1';
                                     decode_alu_mode    <= ALU_OR; 
                                     decode_rdest       <= rd;
                                  when "111"  =>
                                     ------------ AND ------------------
                                     decode_alu_enable  <= '1';
                                     decode_alu_mode    <= ALU_AND; 
                                     decode_rdest       <= rd;
                              when others  =>  NULL;
                            end case;
                         when "0100000"  =>
                            case func3 is 
                               when "000"  =>
                                  ------------ SUB ------------------
                                  decode_alu_enable  <= '1';
                                  decode_alu_mode       <= ALU_SUB; 
                                  decode_rdest          <= rd;
                               when "101"  =>
                                  ------------ SRA ------------------
                                  decode_shift_enable   <= '1';
                                  decode_result_src     <= RESULT_SHIFTER;
                                  decode_shift_mode     <= SHIFTER_RIGHT_ARITH; 
                                  decode_rdest          <= rd;
                               when others  =>  NULL;
                            end case;
                         when "0001111"  =>
                            case func3 is 
                               when "000"  =>
                                  ------------ FENCE ------------------
                                  -- TODO
                               when others  =>  NULL;
                                 -- Undecoded for opcode 0001111                      
                            end case;
                         when "1110011"  =>
                            case fetch_opcode(31 downto 20) is
                               when "000000000000" =>
                                   if rs1 = "00000" and func3 = "000" and rd = "00000" then
                                     ------------ ECALL ------------------
                                     -- TODO
                                   end if; 
                               when "000000000001" =>
                                   if rs1 = "00000" and func3 = "000" and rd = "00000" then
                                     ------------ EBREAK ------------------
                                     -- TODO
                                   end if; 
                               when others  =>  NULL;
                            end case;
                         when others  =>  NULL;
                            -- Undecoded for opcode 1110011                      
                      end case;
                   when others =>
                     -- Undecoded for opcodes                      
                end case;
            end if;

            -- Other than reset, only raise an exception when an
            -- instruction completes or is stalled on fetch
            if exec_instr_completed = '1' OR exec_flush_required = '1' OR exec_instr_failed = '1' or reset = '1' then
                ---- Now override with exceptions, traps or interrupts
                if raise_exception = '1' then
                    decode_force_complete     <= '1';
                    decode_jump_enable        <= '1';
                    decode_alu_enable         <= '0';
                    decode_shift_enable       <= '0';
                    decode_branchtest_enable  <= '0';
                    decode_reg_a              <= "00000";
                    decode_reg_b              <= "00000";
                    decode_rdest              <= "00000";
                    decode_select_b           <= B_BUS_IMMEDIATE; -- Not sure if needed
                    decode_pc_mode            <= PC_JMP_REG_RELATIVE;
                    case exception is 
                        when EXCEPTION_RESET =>
                            decode_pc_jump_offset <= x"F0000000";
                        when EXCEPTION_UNKNOWN_INSTR =>
                            decode_pc_jump_offset <= x"F0000000";
                        when others =>
                            decode_pc_jump_offset <= x"F0000000";
                    end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
