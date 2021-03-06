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

            -- From the exec unit
            exec_decode_next          : in  STD_LOGIC;
            exec_m_epc                : in  STD_LOGIC_VECTOR(31 downto 0);

            -- From the interrupt/exception unit
            intex_exception_raise     : in  STD_LOGIC;
            intex_exception_cause     : in  STD_LOGIC_VECTOR (31 downto 0);
            intex_exception_vector    : in  STD_LOGIC_VECTOR (31 downto 0);

            -- from the fetch unit
            fetch_opcode              : in STD_LOGIC_VECTOR (31 downto 0);
            fetch_addr                : in STD_LOGIC_VECTOR (31 downto 0);
            fetch_instr_misaligned    : in std_logic;
            fetch_except_instr_access : in std_logic;

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

            decode_csr_enable         : out STD_LOGIC := '0';
            decode_csr_mode           : out STD_LOGIC_VECTOR(2 downto 0)  := "000";
            decode_csr_reg            : out STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

            decode_branchtest_enable  : out STD_LOGIC := '0';
            decode_branchtest_mode    : out STD_LOGIC_VECTOR(2 downto 0) := "000";

            decode_shift_enable       : out STD_LOGIC := '0';
            decode_shift_mode         : out STD_LOGIC_VECTOR(1 downto 0) := "00";
    
            decode_result_src         : out STD_LOGIC_VECTOR(2 downto 0) := (others => '0');         
            decode_rdest              : out STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

            decode_m_int_enter        : out STD_LOGIC := '0';
            decode_m_int_return       : out STD_LOGIC := '0';
            decode_mcause             : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

            decode_instr_misaligned   : out std_logic := '0';
            decode_instr_access       : out std_logic := '0';

            decode_ecall              : out std_logic := '0';
            decode_ebreak             : out std_logic := '0';
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
    signal func12  : STD_LOGIC_VECTOR(11 downto 0);
    signal immed_I : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_S : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_B : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_U : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_J : STD_LOGIC_VECTOR(31 downto 0);
    signal immed_Z : STD_LOGIC_VECTOR(31 downto 0);
    signal instr31 : STD_LOGIC_VECTOR(31 downto 0);

    -- Exception handling/Interrupts
    signal launched_exception : std_logic := '0' ;
  
begin

   with fetch_opcode(31) select instr31 <= x"FFFFFFFF" when '1', x"00000000" when others;

   -- Break down the R, I, S, B, U. J-type instructions, as per ISA
   opcode  <= fetch_opcode( 6 downto 0);
   rd      <= fetch_opcode(11 downto 7);
   func3   <= fetch_opcode(14 downto 12);
   func7   <= fetch_opcode(31 downto 25);
   func12  <= fetch_opcode(31 downto 20);
   rs1     <= fetch_opcode(19 downto 15);
   rs2     <= fetch_opcode(24 downto 20);
   immed_I <= instr31(31 downto 12) & fetch_opcode(31 downto 20);
   immed_S <= instr31(31 downto 12) & fetch_opcode(31 downto 25) & fetch_opcode(11 downto 7);
   immed_B <= instr31(31 downto 12) & fetch_opcode(7) & fetch_opcode(30 downto 25) & fetch_opcode(11 downto 8) & "0";
   immed_U <= fetch_opcode(31 downto 12) & x"000";
   immed_J <= instr31(31 downto 20) & fetch_opcode(19 downto 12) & fetch_opcode(20) & fetch_opcode(30 downto 21) & "0" ;
   immed_Z <= "000000000000000000000000000" & rs1;

process(clk)
    begin
        if rising_edge(clk) then
            if exec_decode_next = '1' then
                launched_exception        <= '0';
    
                decode_instr_misaligned   <= fetch_instr_misaligned;
                decode_instr_access       <= fetch_except_instr_access;

                 -- Set defaults for invalid instructions
                decode_addr              <= fetch_addr;
                decode_immed             <= immed_I;
                decode_force_complete    <= '0';
                decode_csr_enable        <= '0';
                decode_alu_enable        <= '0';
                decode_jump_enable       <= '0';
                decode_shift_enable      <= '0';
                decode_branchtest_enable <= '0';
                decode_ecall             <= '0';
                decode_ebreak            <= '0';
        
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
                decode_csr_mode         <= CSR_NOACTION;
                decode_csr_reg          <= func12;
                decode_shift_mode       <= SHIFTER_LEFT_LOGICAL;
                decode_result_src       <= RESULT_ALU;         
                decode_rdest            <= "00000";  -- By default write to register zero (which stays zero)

                decode_m_int_enter      <= '0';
                decode_m_int_return     <= '0';
                decode_mcause           <= (others => '0');
                
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

                         when others =>

                      end case;
                   when "1110011"  =>
                       case func3 is 
                           when "000"  =>
                               if rs1 = "00000" and rd = "00000" then
                                   case fetch_opcode(31 downto 20) is
                                       when "000000000000" => 
                                            ------------- ECALL ---------------
                                            decode_ecall  <= '1';
                                       when "000000000001" =>
                                            ------------- EBREAK --------------
                                            decode_ebreak <= '1';
                                       when "001100000010" => 
                                            ------------- MRET --------------
                                            decode_m_int_return       <= '1';
                                            decode_jump_enable        <= '1';
                                            decode_alu_enable         <= '0';
                                            decode_shift_enable       <= '0';
                                            decode_branchtest_enable  <= '0';
                                            decode_reg_a              <= "00000";
                                            decode_reg_b              <= "00000";
                                            decode_rdest              <= "00000";
                                            decode_select_b           <= B_BUS_IMMEDIATE; -- Not sure if needed
                                            decode_pc_mode            <= PC_JMP_REG_RELATIVE;
                                            decode_mcause             <= intex_exception_cause;
                                            decode_pc_jump_offset     <= exec_m_epc;
                                       when others =>
                                   end case;
                               end if; 
                           when "001"  =>
                               ------------ CSRRW -------------------
                               decode_csr_enable <= '1';
                               decode_immed      <= immed_Z;
                               decode_result_src <= RESULT_CSR;
                               decode_rdest      <= rd;
                               if rd = "00000" then
                                   decode_csr_mode   <= CSR_WRITE;
                               else
                                   decode_csr_mode   <= CSR_READWRITE;
                               end if;

                           when "010"  =>
                               ------------ CSRRS -------------------
                               decode_csr_enable <= '1';
                               decode_immed      <= immed_Z;
                               decode_result_src <= RESULT_CSR;
                               decode_rdest      <= rd;
                               if rs1 = "00000" then
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_NOACTION;
                                   else
                                       decode_csr_mode   <= CSR_READ;
                                   end if;
                               else
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_WRITESET;
                                   else
                                       decode_csr_mode   <= CSR_READWRITESET;
                                   end if;
                               end if;

                           when "011"  =>
                               ------------ CSRRC -------------------
                               decode_csr_enable <= '1';
                               decode_immed      <= immed_Z;
                               decode_result_src <= RESULT_CSR;
                               decode_rdest      <= rd;
                               if rs1 = "00000" then
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_NOACTION;
                                   else
                                       decode_csr_mode   <= CSR_READ;
                                   end if;
                               else
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_WRITECLEAR;
                                   else
                                       decode_csr_mode   <= CSR_READWRITECLEAR;
                                   end if;
                               end if;

                           when "100"  =>
                               -- Added to reduce logic usage ---
                               decode_csr_enable <= '0';
                               decode_csr_mode   <= CSR_NOACTION;
                               decode_immed      <= immed_Z;
                               decode_select_b   <= B_BUS_IMMEDIATE;
                               decode_result_src <= RESULT_CSR;

                           when "101"  =>
                               ------------ CSRRWI -------------------
                               decode_csr_enable <= '1';
                               decode_immed      <= immed_Z;
                               decode_select_b   <= B_BUS_IMMEDIATE;
                               decode_result_src <= RESULT_CSR;
                               decode_rdest      <= rd;

                               if rd = "00000" then
                                   decode_csr_mode   <= CSR_WRITE;
                               else
                                   decode_csr_mode   <= CSR_READWRITE;
                               end if;

                           when "110"  =>
                               ------------ CSRRSI -------------------
                               decode_csr_enable <= '1';
                               decode_immed      <= immed_Z;
                               decode_select_b   <= B_BUS_IMMEDIATE;
                               decode_result_src <= RESULT_CSR;
                               decode_rdest      <= rd;
                               -- rs1 in this context is an immedaite value for the CSR update
                               if rs1 = "00000" then
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_NOACTION;
                                   else
                                       decode_csr_mode   <= CSR_READ;
                                   end if;
                               else
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_WRITESET;
                                   else
                                       decode_csr_mode   <= CSR_READWRITESET;
                                   end if;
                               end if;

                           when "111"  =>
                               ------------ CSRRCI -------------------
                               decode_csr_enable <= '1';
                               decode_immed      <= immed_Z;
                               decode_select_b   <= B_BUS_IMMEDIATE;
                               decode_result_src <= RESULT_CSR;
                               decode_rdest      <= rd;
                               -- rs1 in this context is an immedaite value for the CSR update
                               if rs1 = "00000" then
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_NOACTION;
                                   else
                                       decode_csr_mode   <= CSR_READ;
                                   end if;
                               else
                                   if rd = "00000" then
                                       decode_csr_mode   <= CSR_WRITECLEAR;
                                   else
                                       decode_csr_mode   <= CSR_READWRITECLEAR;
                                   end if;
                               end if;
                           when others =>
                               -- Undecoded for opcode 1110011                      
                       end case;
                   when others =>
                       -- Undecoded for opcodes                      
                end case;

                ---- Now override with exceptions, traps or interrupts
                if intex_exception_raise = '1' and launched_exception = '0' then
                    launched_exception        <= '1';
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
                    decode_mcause             <= intex_exception_cause;
                    decode_m_int_enter        <= '1';
                    decode_pc_jump_offset     <= intex_exception_vector;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
