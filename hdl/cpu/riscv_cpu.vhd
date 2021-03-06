--###############################################################################
--# ./hdl/cpu/riscv_cpu.vhd  - DESCRIPTION_NEEDED
--#
--# Part of the simple-riscv project. A simple three-stage RISC-V compatible CPU
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

entity riscv_cpu is
    Port( clk     : in  STD_LOGIC;
          progmem_addr       : out STD_LOGIC_VECTOR(31 downto 0);
          progmem_enable     : out STD_LOGIC;
          progmem_data_addr  : in  STD_LOGIC_VECTOR(31 downto 0);
          progmem_data       : in  STD_LOGIC_VECTOR(31 downto 0);
          progmem_data_valid : in  STD_LOGIC;

          reset              : in  STD_LOGIC;
          interrupt_timer    : in  STD_LOGIC;
          interrupt_external : in  STD_LOGIC;
          interrupt_software : in  STD_LOGIC;


          bus_busy           : in  STD_LOGIC;
          bus_addr           : out STD_LOGIC_VECTOR(31 downto 0);
          bus_width          : out STD_LOGIC_VECTOR(1 downto 0);  
          bus_dout           : out STD_LOGIC_VECTOR(31 downto 0);
          bus_write          : out STD_LOGIC;
          bus_enable         : out STD_LOGIC;
          bus_din            : in  STD_LOGIC_VECTOR(31 downto 0);

          debug_pc           : out STD_LOGIC_VECTOR(31 downto 0);
          debug_sel          : in  STD_LOGIC_VECTOR(4 downto 0);
          debug_data         : out STD_LOGIC_VECTOR(31 downto 0)
  );
end riscv_cpu;

architecture Behavioral of riscv_cpu is
    component fetch_unit is
    Port ( clk                       : in  STD_LOGIC;
           -- from the exec unit
           exec_instr_completed      : in  STD_LOGIC;
           exec_flush_required       : in  STD_LOGIC;
           exec_current_pc           : in  STD_LOGIC_VECTOR (31 downto 0);

           -- to the decoder
           fetch_opcode              : out STD_LOGIC_VECTOR (31 downto 0);
           fetch_addr                : out STD_LOGIC_VECTOR (31 downto 0);
           fetch_instr_misaligned    : out std_logic := '0';
           fetch_except_instr_access : out std_logic := '0';


           -- to the memory
           progmem_enable            : out STD_LOGIC;
           progmem_addr              : out STD_LOGIC_VECTOR (31 downto 0);

           progmem_data_addr         : in  STD_LOGIC_VECTOR(31 downto 0);
           progmem_data              : in  STD_LOGIC_VECTOR (31 downto 0);
           progmem_data_valid        : in  STD_LOGIC
       
           );
    end component;

    signal fetch_opcode              : STD_LOGIC_VECTOR (31 downto 0);
    signal fetch_addr                : STD_LOGIC_VECTOR (31 downto 0);
    signal fetch_instr_misaligned    : std_logic;
    signal fetch_except_instr_access : std_logic;

    component decode_unit is
    Port (  clk                   : in  STD_LOGIC;
           -- from the exec unit
            exec_decode_next          : in  STD_LOGIC;
            exec_m_epc                : in  STD_LOGIC_VECTOR (31 downto 0);

            -- From the interrupt/exception unit
            intex_exception_raise     : in  STD_LOGIC;
            intex_exception_cause     : in  STD_LOGIC_VECTOR (31 downto 0);
            intex_exception_vector    : in  STD_LOGIC_VECTOR (31 downto 0);

            -- from the fetch unit
            fetch_opcode              : in  STD_LOGIC_VECTOR (31 downto 0);
            fetch_addr                : in  STD_LOGIC_VECTOR (31 downto 0);
            fetch_instr_misaligned    : in  std_logic := '0';
            fetch_except_instr_access : in  std_logic := '0';

            -- To the exec unit

            decode_addr               : out STD_LOGIC_VECTOR(31 downto 0);

            decode_immed              : out STD_LOGIC_VECTOR(31 downto 0);
            
            decode_reg_a              : out STD_LOGIC_VECTOR(4 downto 0);
            decode_select_a           : out STD_LOGIC_VECTOR(0 downto 0);
    
            decode_reg_b              : out STD_LOGIC_VECTOR(4 downto 0);
            decode_select_b           : out STD_LOGIC_VECTOR(0 downto 0);

            decode_jump_enable        : out STD_LOGIC;
            decode_pc_mode            : out STD_LOGIC_VECTOR(1 downto 0);
            decode_pc_jump_offset     : out STD_LOGIC_VECTOR(31 downto 0);
    
            decode_loadstore_enable   : out STD_LOGIC;
            decode_loadstore_offset   : out STD_LOGIC_VECTOR(31 downto 0);
            decode_loadstore_write    : out STD_LOGIC;
            decode_loadstore_width    : out STD_LOGIC_VECTOR(1 downto 0);
            decode_loadstore_ex_mode  : out STD_LOGIC_VECTOR(0 downto 0);
            decode_loadstore_ex_width : out STD_LOGIC_VECTOR(1 downto 0);
    
            decode_alu_enable         : out STD_LOGIC;
            decode_alu_mode           : out STD_LOGIC_VECTOR(2 downto 0);

            decode_csr_enable         : out STD_LOGIC;
            decode_csr_mode           : out STD_LOGIC_VECTOR(2 downto 0);
            decode_csr_reg            : out STD_LOGIC_VECTOR(11 downto 0);

            decode_branchtest_enable  : out STD_LOGIC;
            decode_branchtest_mode    : out STD_LOGIC_VECTOR(2 downto 0);

            decode_shift_enable       : out STD_LOGIC;
            decode_shift_mode         : out STD_LOGIC_VECTOR(1 downto 0);
    
    
            decode_result_src         : out STD_LOGIC_VECTOR(2 downto 0);
            decode_rdest              : out STD_LOGIC_VECTOR(4 downto 0);

            decode_instr_misaligned   : out std_logic;
            decode_instr_access       : out std_logic;
            decode_ecall              : out std_logic;
            decode_ebreak             : out std_logic;

            decode_force_complete     : out STD_LOGIC;
            decode_m_int_enter        : out STD_LOGIC;
            decode_m_int_return       : out STD_LOGIC;

            decode_mcause             : out STD_LOGIC_VECTOR(31 downto 0)
            );            
    end component;    
    
    signal decode_force_complete     : STD_LOGIC;
    signal decode_instr_misaligned   : std_logic;
    signal decode_instr_access       : std_logic;
    signal decode_ecall              : std_logic;
    signal decode_ebreak             : std_logic;

    signal decode_addr               : STD_LOGIC_VECTOR (31 downto 0);
    signal decode_immed              : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
    signal decode_reg_a              : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal decode_select_a           : STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
    signal decode_reg_b              : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal decode_select_b           : STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
    signal decode_jump_enable        : STD_LOGIC := '0';
    signal decode_pc_mode            : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal decode_pc_jump_offset     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal decode_loadstore_enable   : STD_LOGIC;
    signal decode_loadstore_offset   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');    
    signal decode_loadstore_write    : STD_LOGIC;
    signal decode_loadstore_width    : STD_LOGIC_VECTOR(1 downto 0);
    signal decode_loadstore_ex_mode  : STD_LOGIC_VECTOR(0 downto 0) := "0";
    signal decode_loadstore_ex_width : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    signal decode_alu_enable         : STD_LOGIC := '0';
    signal decode_alu_mode           : STD_LOGIC_VECTOR(2 downto 0) := "000";

    signal decode_csr_enable         : STD_LOGIC := '0';
    signal decode_csr_mode           : STD_LOGIC_VECTOR(2 downto 0)  := "000";
    signal decode_csr_reg            : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

    signal decode_branchtest_enable  : STD_LOGIC := '0';
    signal decode_branchtest_mode    : STD_LOGIC_VECTOR(2 downto 0) := "000";

    signal decode_shift_enable       : STD_LOGIC := '0';
    signal decode_shift_mode         : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    signal decode_result_src         : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');         
    signal decode_rdest              : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');            
    signal decode_m_int_enter        : STD_LOGIC := '0';
    signal decode_m_int_return       : STD_LOGIC := '0';
    signal decode_mcause             : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    component exec_unit is
    Port ( clk                 : in STD_LOGIC;

    
            decode_addr               : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            decode_immed              : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
            decode_reg_a              : in  STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_a           : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
        
            decode_reg_b              : in  STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_b           : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

            decode_jump_enable        : in STD_LOGIC := '0';        
            decode_pc_mode            : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
            decode_pc_jump_offset     : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        
            decode_loadstore_write    : in  STD_LOGIC;
            decode_loadstore_offset   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_loadstore_enable   : in  STD_LOGIC;
            decode_loadstore_width    : in  STD_LOGIC_VECTOR(1 downto 0);
            decode_loadstore_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0) := "0";
            decode_loadstore_ex_width : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
            decode_alu_enable         : in  STD_LOGIC := '0';
            decode_alu_mode           : in  STD_LOGIC_VECTOR(2 downto 0) := "000";
        
            decode_csr_enable         : in  STD_LOGIC := '0';
            decode_csr_mode           : in  STD_LOGIC_VECTOR(2 downto 0)  := "000";
            decode_csr_reg            : in  STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
        
            decode_branchtest_enable  : in  STD_LOGIC := '0';
            decode_branchtest_mode    : in  STD_LOGIC_VECTOR(2 downto 0) := "000";
        
            decode_shift_enable       : in  STD_LOGIC := '0';
            decode_shift_mode         : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
            decode_result_src         : in  STD_LOGIC_VECTOR(2 downto 0) := (others => '0');         
            decode_rdest              : in  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
                        
            decode_instr_misaligned   : in std_logic;
            decode_instr_access       : in std_logic;
            decode_ecall              : in std_logic;
            decode_ebreak             : in std_logic;

            decode_force_complete     : in  STD_LOGIC;
            decode_m_int_enter        : in  STD_LOGIC;
            decode_m_int_return       : in  STD_LOGIC;
            decode_mcause             : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
            exec_decode_next          : out STD_LOGIC;
            exec_instr_completed      : out STD_LOGIC;
            exec_instr_failed         : out STD_LOGIC;
            exec_flush_required       : out STD_LOGIC;
            exec_current_pc           : out STD_LOGIC_VECTOR (31 downto 0);

            bus_busy      : in  STD_LOGIC;
            bus_addr      : out STD_LOGIC_VECTOR(31 downto 0);
            bus_width     : out STD_LOGIC_VECTOR(1 downto 0);  
            bus_dout      : out STD_LOGIC_VECTOR(31 downto 0);
            bus_write     : out STD_LOGIC;
            bus_enable    : out STD_LOGIC;
            bus_din       : in  STD_LOGIC_VECTOR(31 downto 0);

            -- To the intex unit
            exec_except_instr_misaligned : out std_logic;
            exec_except_instr_access     : out std_logic;
            exec_except_illegal_instr    : out std_logic;
            exec_except_ecall            : out std_logic;
            exec_except_ebreak           : out std_logic;
            exec_except_load_misaligned  : out std_logic;
            exec_except_load_access      : out std_logic;
            exec_except_store_misaligned : out std_logic;
            exec_except_store_access     : out std_logic;

            exec_setting_mcause          : out std_logic;
            exec_setting_mcause_value    : out std_logic_vector(31 downto 0);

            -- From the internal CSR Unit to the outside world
            -- Interupt enable
            exec_m_ie          : out STD_LOGIC;

            -- Interrupt enable (external, timer, software)
            exec_m_eie         : out STD_LOGIC;
            exec_m_tie         : out STD_LOGIC;
            exec_m_sie         : out STD_LOGIC;
            m_eip         : in  STD_LOGIC;
            m_tip         : in  STD_LOGIC;
            m_sip         : in  STD_LOGIC;

            -- Return address for traps
            exec_m_epc         : out STD_LOGIC_VECTOR(31 downto 0);

            -- Trap vectoring
            exec_m_tvec_base   : out STD_LOGIC_VECTOR(31 downto 0);
            exec_m_tvec_flag   : out STD_LOGIC;


            debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
            debug_sel     : in  STD_LOGIC_VECTOR(4 downto 0);
            debug_data    : out STD_LOGIC_VECTOR(31 downto 0)
                
    );
    end component;

    signal exec_instr_completed      : STD_LOGIC;
    signal exec_instr_failed         : STD_LOGIC;
    signal exec_flush_required       : STD_LOGIC;
    signal exec_decode_next          : STD_LOGIC;
    signal exec_current_pc           : STD_LOGIC_VECTOR (31 downto 0);
    signal exec_m_epc                : STD_LOGIC_VECTOR (31 downto 0);
    signal exec_m_ie                 : STD_LOGIC;
    signal exec_m_eie                : STD_LOGIC;
    signal exec_m_tie                : STD_LOGIC;
    signal exec_m_sie                : STD_LOGIC;
    signal exec_m_tvec_base          : STD_LOGIC_VECTOR(31 downto 0);
    signal exec_m_tvec_flag          : STD_LOGIC;
    signal exec_setting_mcause       : STD_LOGIC;
    signal exec_setting_mcause_value : STD_LOGIC_VECTOR(31 downto 0);

    component intex_unit is
    Port (  clk                       : in  STD_LOGIC;
            reset                     : in  STD_LOGIC;
            interrupt_timer           : in  STD_LOGIC;
            interrupt_external        : in  STD_LOGIC;
            interrupt_software        : in  STD_LOGIC;

            intex_exception_raise     : out STD_LOGIC;
            intex_exception_cause     : out STD_LOGIC_VECTOR (31 downto 0);
            intex_exception_vector    : out STD_LOGIC_VECTOR (31 downto 0);

            intex_m_eip               : out STD_LOGIC;
            intex_m_tip               : out STD_LOGIC;
            intex_m_sip               : out STD_LOGIC;

            exec_setting_mcause          : in  std_logic;
            exec_setting_mcause_value    : in  std_logic_vector(31 downto 0);

            exec_except_instr_misaligned : in std_logic;
            exec_except_instr_access     : in std_logic;
            exec_except_illegal_instr    : in std_logic;
            exec_except_ecall            : in std_logic;
            exec_except_ebreak           : in std_logic;
            exec_except_load_misaligned  : in std_logic;
            exec_except_load_access      : in std_logic;
            exec_except_store_misaligned : in std_logic;
            exec_except_store_access     : in std_logic;

            -----------------------------
            -- From the CSR Unit
            -----------------------------
            exec_m_ie         : in  STD_LOGIC;

            -- Interrupt enable (external, timer, software)
            exec_m_eie        : in  STD_LOGIC;
            exec_m_tie        : in  STD_LOGIC;
            exec_m_sie        : in  STD_LOGIC;

            -- Trap vectoring
            exec_m_tvec_base  : in  STD_LOGIC_VECTOR(31 downto 0);
            exec_m_tvec_flag  : in  STD_LOGIC);
    end component;
    signal intex_exception_raise        : STD_LOGIC;
    signal intex_exception_cause        : STD_LOGIC_VECTOR (31 downto 0);
    signal intex_exception_vector       : STD_LOGIC_VECTOR (31 downto 0);
    signal intex_m_eip                  : STD_LOGIC;
    signal intex_m_tip                  : STD_LOGIC;
    signal intex_m_sip                  : STD_LOGIC;

    signal exec_except_instr_misaligned : std_logic := '0';
    signal exec_except_instr_access     : std_logic := '0';
    signal exec_except_illegal_instr    : std_logic := '0';
    signal exec_except_ecall            : std_logic := '0';
    signal exec_except_ebreak           : std_logic := '0';
    signal exec_except_load_misaligned  : std_logic := '0';
    signal exec_except_load_access      : std_logic := '0';
    signal exec_except_store_misaligned : std_logic := '0';
    signal exec_except_store_access     : std_logic := '0';

begin



    
fetch: fetch_unit port map (
        clk                       => clk,
        exec_instr_completed      => exec_instr_completed,
        exec_flush_required       => exec_flush_required,
        exec_current_pc           => exec_current_pc,
        fetch_opcode              => fetch_opcode,
        fetch_addr                => fetch_addr,
        fetch_instr_misaligned    => fetch_instr_misaligned,
        fetch_except_instr_access => fetch_except_instr_access,

        progmem_enable            => progmem_enable,
        progmem_addr              => progmem_addr,
        progmem_data_addr         => progmem_data_addr,
        progmem_data              => progmem_data,
        progmem_data_valid        => progmem_data_valid
    );
    
decode: decode_unit port map (
        clk                       => clk,

        intex_exception_raise     => intex_exception_raise,
        intex_exception_cause     => intex_exception_cause,
        intex_exception_vector    => intex_exception_vector,

        exec_decode_next          => exec_decode_next,
        exec_m_epc                => exec_m_epc,

        -- From the fetch unit
        fetch_opcode              => fetch_opcode,
        fetch_addr                => fetch_addr,
        fetch_instr_misaligned    => fetch_instr_misaligned,
        fetch_except_instr_access => fetch_except_instr_access,

        -- To the exec unit
        decode_addr               => decode_addr,
        decode_immed              => decode_immed,         
        
        decode_reg_a              => decode_reg_a,
        decode_select_a           => decode_select_a,

        decode_reg_b              => decode_reg_b, 
        decode_select_b           => decode_select_b,

        decode_jump_enable        => decode_jump_enable,
        decode_pc_mode            => decode_pc_mode,
        decode_pc_jump_offset     => decode_pc_jump_offset,
        decode_loadstore_offset   => decode_loadstore_offset,

        decode_loadstore_enable   => decode_loadstore_enable,
        decode_loadstore_write    => decode_loadstore_write,
        decode_loadstore_width    => decode_loadstore_width,
        decode_loadstore_ex_mode  => decode_loadstore_ex_mode,
        decode_loadstore_ex_width => decode_loadstore_ex_width,

        decode_alu_enable         => decode_alu_enable,
        decode_alu_mode           => decode_alu_mode,

        decode_csr_enable         => decode_csr_enable,
        decode_csr_mode           => decode_csr_mode,
        decode_csr_reg            => decode_csr_reg,

        decode_branchtest_enable  => decode_branchtest_enable,
        decode_branchtest_mode    => decode_branchtest_mode,

        decode_shift_enable       => decode_shift_enable,
        decode_shift_mode         => decode_shift_mode,

        decode_result_src         => decode_result_src,          
        decode_rdest              => decode_rdest,

        decode_instr_misaligned   => decode_instr_misaligned,
        decode_instr_access       => decode_instr_access,
        decode_ecall              => decode_ecall,
        decode_ebreak             => decode_ebreak,

        decode_force_complete     => decode_force_complete,
        decode_m_int_enter        => decode_m_int_enter,
        decode_m_int_return       => decode_m_int_return,
        decode_mcause             => decode_mcause
    );

exec: exec_unit port map (
        clk                       => clk,

        exec_setting_mcause       => exec_setting_mcause,
        exec_setting_mcause_value => exec_setting_mcause_value,

        exec_m_ie                 => exec_m_ie,
        exec_m_eie                => exec_m_eie,
        exec_m_tie                => exec_m_tie,
        exec_m_sie                => exec_m_sie,
        exec_m_epc                => exec_m_epc,
        m_eip                     => intex_m_eip,
        m_tip                     => intex_m_tip,
        m_sip                     => intex_m_sip,
        exec_m_tvec_base          => exec_m_tvec_base,
        exec_m_tvec_flag          => exec_m_tvec_flag,


        decode_force_complete     => decode_force_complete,
        decode_m_int_enter        => decode_m_int_enter,
        decode_m_int_return       => decode_m_int_return,
        decode_mcause             => decode_mcause,

        decode_instr_misaligned   => decode_instr_misaligned,
        decode_instr_access       => decode_instr_access,
        decode_ecall              => decode_ecall,
        decode_ebreak             => decode_ebreak,

        decode_addr               => decode_addr,
        decode_immed              => decode_immed,         
        
        decode_reg_a              => decode_reg_a,
        decode_select_a           => decode_select_a,

        decode_reg_b              => decode_reg_b, 
        decode_select_b           => decode_select_b,

        decode_jump_enable        => decode_jump_enable,
        decode_pc_mode            => decode_pc_mode,
        decode_pc_jump_offset     => decode_pc_jump_offset,
        
        decode_loadstore_offset   => decode_loadstore_offset,
        decode_loadstore_write    => decode_loadstore_write,
        decode_loadstore_enable   => decode_loadstore_enable,
        decode_loadstore_width    => decode_loadstore_width,
        decode_loadstore_ex_mode  => decode_loadstore_ex_mode,
        decode_loadstore_ex_width => decode_loadstore_ex_width,

        decode_alu_enable         => decode_alu_enable,
        decode_alu_mode           => decode_alu_mode,

        decode_csr_enable         => decode_csr_enable,
        decode_csr_mode           => decode_csr_mode,
        decode_csr_reg            => decode_csr_reg,

        decode_branchtest_enable  => decode_branchtest_enable,
        decode_branchtest_mode    => decode_branchtest_mode,

        decode_shift_enable       => decode_shift_enable,
        decode_shift_mode         => decode_shift_mode,

        decode_result_src         => decode_result_src,          
        decode_rdest              => decode_rdest,
        --===============================================    
        exec_instr_completed      => exec_instr_completed,
        exec_instr_failed         => exec_instr_failed,
        exec_flush_required       => exec_flush_required,
        exec_decode_next          => exec_decode_next,
        exec_current_pc           => exec_current_pc,

        exec_except_instr_misaligned => exec_except_instr_misaligned,
        exec_except_instr_access     => exec_except_instr_access,
        exec_except_illegal_instr    => exec_except_illegal_instr,
        exec_except_ecall            => exec_except_ecall,
        exec_except_ebreak           => exec_except_ebreak,
        exec_except_load_misaligned  => exec_except_load_misaligned,
        exec_except_load_access      => exec_except_load_access,
        exec_except_store_misaligned => exec_except_store_misaligned,
        exec_except_store_access     => exec_except_store_access,

        --===============================================    
        bus_busy                  => bus_busy,
        bus_addr                  => bus_addr,
        bus_width                 => bus_width,  
        bus_dout                  => bus_dout,
        bus_write                 => bus_write,
        bus_enable                => bus_enable,
        bus_din                   => bus_din,
        --===============================================    
        debug_pc                  => debug_pc,
        debug_sel                 => debug_sel,
        debug_data                => debug_data               
    );

i_intex_unit: intex_unit port map (
        clk                          => clk,
        reset                        => reset,
        interrupt_timer              => interrupt_timer,
        interrupt_external           => interrupt_external,
        interrupt_software           => interrupt_software,

        exec_setting_mcause          => exec_setting_mcause,
        exec_setting_mcause_value    => exec_setting_mcause_value,

        intex_exception_raise        => intex_exception_raise,
        intex_exception_cause        => intex_exception_cause,
        intex_exception_vector       => intex_exception_vector,

        intex_m_eip                  => intex_m_eip,
        intex_m_tip                  => intex_m_tip,
        intex_m_sip                  => intex_m_sip,

        exec_except_instr_misaligned => exec_except_instr_misaligned,
        exec_except_instr_access     => exec_except_instr_access,
        exec_except_illegal_instr    => exec_except_illegal_instr,
        exec_except_ecall            => exec_except_ecall,
        exec_except_ebreak           => exec_except_ebreak,
        exec_except_load_misaligned  => exec_except_load_misaligned,
        exec_except_load_access      => exec_except_load_access,
        exec_except_store_misaligned => exec_except_store_misaligned,
        exec_except_store_access     => exec_except_store_access,

        exec_m_ie                    => exec_m_ie,
        exec_m_eie                   => exec_m_eie,
        exec_m_tie                   => exec_m_tie,
        exec_m_sie                   => exec_m_sie,
        exec_m_tvec_base             => exec_m_tvec_base,
        exec_m_tvec_flag             => exec_m_tvec_flag);

end Behavioral;
