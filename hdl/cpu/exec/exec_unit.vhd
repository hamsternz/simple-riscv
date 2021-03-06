--###############################################################################
--# ./hdl/cpu/exec/exec_unit.vhd  - DESCRIPTION_NEEDED
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

entity exec_unit is
    Port ( clk                       : in STD_LOGIC;

           decode_force_complete     : in  STD_LOGIC;
           decode_m_int_enter        : in  STD_LOGIC;
           decode_m_int_return       : in  std_logic := '0';
           decode_mcause             : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
           
           decode_instr_misaligned   : in  std_logic := '0';
           decode_instr_access       : in  std_logic := '0';
           decode_ecall              : in  std_logic := '0';
           decode_ebreak             : in  std_logic := '0';


           decode_addr               : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
           decode_immed              : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
           decode_reg_a              : in  STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
           decode_select_a           : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
        
           decode_reg_b              : in  STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
           decode_select_b           : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
        
           decode_jump_enable        : in  STD_LOGIC;
           decode_pc_mode            : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
           decode_pc_jump_offset     : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        
           decode_loadstore_enable   : in  STD_LOGIC;
           decode_loadstore_offset   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
           decode_loadstore_write    : in  STD_LOGIC;
           decode_loadstore_width    : in  STD_LOGIC_VECTOR(1 downto 0);
           decode_loadstore_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0) := "0";
           decode_loadstore_ex_width : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
           decode_alu_enable         : in  STD_LOGIC := '0';
           decode_alu_mode           : in  STD_LOGIC_VECTOR(2 downto 0) := "000";
        
           decode_csr_enable         : in  STD_LOGIC := '0';
           decode_csr_mode           : in  STD_LOGIC_VECTOR(2 downto 0)  := "000";
           decode_csr_reg            : in  STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
        
           decode_branchtest_enable : in  STD_LOGIC := '0';
           decode_branchtest_mode   : in  STD_LOGIC_VECTOR(2 downto 0) := "000";
        
           decode_shift_enable       : in  STD_LOGIC := '0';
           decode_shift_mode         : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
        
           decode_result_src         : in  STD_LOGIC_VECTOR(2 downto 0) := (others => '0');         
           decode_rdest              : in  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');            
          
           exec_instr_completed      : out STD_LOGIC                      := '0';
           exec_instr_failed         : out STD_LOGIC                      := '0';
           exec_flush_required       : out STD_LOGIC                      := '0';
           exec_decode_next          : out STD_LOGIC                      := '0';
           exec_current_pc           : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

           -- For signalling exceptions
           exec_except_instr_misaligned : out std_logic := '0';
           exec_except_instr_access     : out std_logic := '0';
           exec_except_illegal_instr    : out std_logic := '0';
           exec_except_ecall            : out std_logic := '0';
           exec_except_ebreak           : out std_logic := '0';
           exec_except_load_misaligned  : out std_logic := '0';
           exec_except_load_access      : out std_logic := '0';
           exec_except_store_misaligned : out std_logic := '0';
           exec_except_store_access     : out std_logic := '0';

           exec_setting_mcause          : out std_logic;
           exec_setting_mcause_value    : out std_logic_vector(31 downto 0);

           -- Signals in / out of the CSR unit
           exec_m_ie         : out STD_LOGIC;
           exec_m_eie        : out STD_LOGIC;
           exec_m_tie        : out STD_LOGIC;
           exec_m_sie        : out STD_LOGIC;
           m_eip             : in  STD_LOGIC;
           m_tip             : in  STD_LOGIC;
           m_sip             : in  STD_LOGIC;
           exec_m_tvec_base  : out STD_LOGIC_VECTOR(31 downto 0);
           exec_m_tvec_flag  : out STD_LOGIC;
           exec_m_epc        : out STD_LOGIC_VECTOR(31 downto 0);

           bus_busy      : in  STD_LOGIC;
           bus_addr      : out STD_LOGIC_VECTOR(31 downto 0);
           bus_width     : out STD_LOGIC_VECTOR(1 downto 0);  
           bus_dout      : out STD_LOGIC_VECTOR(31 downto 0);
           bus_write     : out STD_LOGIC;
           bus_enable    : out STD_LOGIC;
           bus_din       : in  STD_LOGIC_VECTOR(31 downto 0);
                    
           debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
           debug_sel     : in  STD_LOGIC_VECTOR(4 downto 0);
           debug_data    : out STD_LOGIC_VECTOR(31 downto 0)               
    );
end exec_unit;

architecture Behavioral of exec_unit is
    signal pc                : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_four      : STD_LOGIC_VECTOR(31 downto 0);

    signal right_instr       : STD_LOGIC := '0';

    signal completed         : STD_LOGIC := '0';
    signal failed            : STD_LOGIC := '0';
    signal known_instr       : STD_LOGIC := '0';
    signal pc_completed      : STD_LOGIC := '0';
    
    component data_bus_mux_a is
    port ( bus_select     : in  STD_LOGIC_VECTOR( 0 downto 0);
           reg_read_port  : in  STD_LOGIC_VECTOR(31 downto 0);
           pc             : in  STD_LOGIC_VECTOR(31 downto 0);
           data_bus       : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;
  
    component data_bus_mux_b is
    port ( bus_select     : in  STD_LOGIC_VECTOR( 0 downto 0);
           reg_read_port  : in  STD_LOGIC_VECTOR(31 downto 0);
           immedediate    : in  STD_LOGIC_VECTOR(31 downto 0);
           data_bus       : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;
  
    component result_bus_mux is
        port ( res_src          : in  STD_LOGIC_VECTOR( 2 downto 0);
               res_alu          : in  STD_LOGIC_VECTOR(31 downto 0);
               res_csr          : in  STD_LOGIC_VECTOR(31 downto 0);
               res_shifter      : in  STD_LOGIC_VECTOR(31 downto 0);
               res_pc_plus_four : in  STD_LOGIC_VECTOR(31 downto 0);
               res_memory       : in  STD_LOGIC_VECTOR(31 downto 0);
               res_bus          : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;
          
    signal a_bus                 : STD_LOGIC_VECTOR(31 downto 0);
    signal b_bus                 : STD_LOGIC_VECTOR(31 downto 0);
    signal c_bus                 : STD_LOGIC_VECTOR(31 downto 0);

    component csr_unit is
      port ( clk          : in  STD_LOGIC;
             csr_mode     : in  STD_LOGIC_VECTOR(2 downto 0);
             csr_reg      : in  STD_LOGIC_VECTOR(11 downto 0);
             csr_active   : in  STD_LOGIC;  
             csr_complete : out STD_LOGIC;  
             csr_failed   : out STD_LOGIC;  
             a            : in  STD_LOGIC_VECTOR(31 downto 0);
             b            : in  STD_LOGIC_VECTOR(31 downto 0);
             c            : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

             -- Exception Program counter
             m_epc_set    : in  STD_LOGIC;
             m_epc_in     : in  STD_LOGIC_VECTOR(31 downto 0);
             m_epc_out    : out STD_LOGIC_VECTOR(31 downto 0);

             -- Trap Value
             m_tval_set   : in  STD_LOGIC;
             m_tval       : in  STD_LOGIC_VECTOR(31 downto 0);

             -- Exception cause
             m_cause_set  : in  STD_LOGIC;
             m_cause      : in  STD_LOGIC_VECTOR(31 downto 0);

             -- Interrupt enable
             m_ie         : out STD_LOGIC;

             -- Interrupt enter / exit 
             m_int_enter  : in  STD_LOGIC;
             m_int_return : in  STD_LOGIC;

    
             -- Interrupt enable (external, timer, software)
             m_eie        : out STD_LOGIC;
             m_tie        : out STD_LOGIC;
             m_sie        : out STD_LOGIC;

             -- Interrupt pending (external, timer, software)
             m_eip        : in  STD_LOGIC;
             m_tip        : in  STD_LOGIC;
             m_sip        : in  STD_LOGIC;

             inst_retired : in  STD_LOGIC;

             -- Trap vectors
             m_tvec_base  : out STD_LOGIC_VECTOR(31 downto 0);
             m_tvec_flag  : out STD_LOGIC
      ); 
    end component;
    signal csr_active   : std_logic;
    signal csr_complete : std_logic;
    signal csr_failed   : std_logic;
    signal c_csr        : STD_LOGIC_VECTOR(31 downto 0);
    signal m_tval_set   : STD_LOGIC := '0';
    signal m_tval       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    component alu is
      port ( clk             : in  STD_LOGIC;
             alu_mode        : in  STD_LOGIC_VECTOR(2 downto 0);
             alu_active      : in  STD_LOGIC;  
             alu_complete    : out STD_LOGIC;  
             alu_failed      : out STD_LOGIC;  
             a               : in  STD_LOGIC_VECTOR(31 downto 0);
             b               : in  STD_LOGIC_VECTOR(31 downto 0);
             c               : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
    end component;
    signal alu_active            : std_logic;
    signal alu_complete          : std_logic;
    signal alu_failed            : std_logic;
    signal c_alu               : STD_LOGIC_VECTOR(31 downto 0);
  
  
    component shifter is
        port ( clk            : in  STD_LOGIC; 
               shift_mode     : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
               shift_active   : in  STD_LOGIC;  
               shift_complete : out STD_LOGIC;  
               shift_failed   : out STD_LOGIC;  
               a              : in  STD_LOGIC_VECTOR(31 downto 0);
               b              : in  STD_LOGIC_VECTOR(31 downto 0);
               c              : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0')); 
    end component;
    signal c_shifter         : STD_LOGIC_VECTOR(31 downto 0);
    signal shift_active      : std_logic;
    signal shift_complete    : std_logic;
    signal shift_failed      : std_logic;
      
    component register_file is
        port ( clk              : in  STD_LOGIC;
               completed        : in  STD_LOGIC;
               read_port_1_addr : in  STD_LOGIC_VECTOR( 4 downto 0);
               read_data_1      : out STD_LOGIC_VECTOR(31 downto 0);       
               read_port_2_addr : in  STD_LOGIC_VECTOR( 4 downto 0);
               read_data_2      : out STD_LOGIC_VECTOR(31 downto 0);       
               write_port_addr  : in  STD_LOGIC_VECTOR( 4 downto 0);       
               write_data       : in  STD_LOGIC_VECTOR(31 downto 0); 
               debug_sel        : in  STD_LOGIC_VECTOR(4 downto 0);
               debug_data       : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    signal reg_read_data_a      : STD_LOGIC_VECTOR(31 downto 0);       
    signal reg_read_data_b      : STD_LOGIC_VECTOR(31 downto 0); 
  
    component branch_test is
    port ( clk                  : in  STD_LOGIC; 
           branchtest_mode      : in  STD_LOGIC_VECTOR(2 downto 0);
           branchtest_active    : in  STD_LOGIC;
           branchtest_complete  : out STD_LOGIC;
           branchtest_failed    : out STD_LOGIC;
           a                    : in  STD_LOGIC_VECTOR(31 downto 0);
           b                    : in  STD_LOGIC_VECTOR(31 downto 0);
           take_branch          : out STD_LOGIC);
    end component;
    signal branchtest_active   : std_logic;
    signal branchtest_complete : std_logic;
    signal branchtest_failed   : std_logic;
    signal take_branch          : std_logic;
      
    component program_counter is
    port ( clk              : in  STD_LOGIC; 
           completed        : in  STD_LOGIC; -- Has everything completed?

           jump_active      : in  STD_LOGIC;
           jump_complete    : out STD_LOGIC;
           jump_failed      : out STD_LOGIC;

           pc_mode          : in  STD_LOGIC_VECTOR(1 downto 0);
           take_branch      : in  STD_LOGIC;
           pc_jump_offset   : in  STD_LOGIC_VECTOR(31 downto 0);
           a                : in  STD_LOGIC_VECTOR(31 downto 0);
           pc               : out STD_LOGIC_VECTOR(31 downto 0);
           pc_plus_four     : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;    
    signal jump_active   : std_logic;
    signal jump_complete : std_logic;
    signal jump_failed   : std_logic;

    component loadstore_unit is
    Port (  clk                       : in STD_LOGIC;

        loadstore_active          : in  STD_LOGIC;
        loadstore_complete        : out STD_LOGIC;
        loadstore_failed          : out STD_LOGIC;

        loadstore_except_load_misaligned  : out std_logic := '0';
        loadstore_except_load_access      : out std_logic := '0';
        loadstore_except_store_misaligned : out std_logic := '0';
        loadstore_except_store_access     : out std_logic := '0';
        
        data_a                    : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        data_b                    : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        loadstore_data            : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        
        decode_loadstore_enable   : in  STD_LOGIC;
        decode_loadstore_write    : in  STD_LOGIC;
        decode_loadstore_offset   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        decode_loadstore_width    : in  STD_LOGIC_VECTOR(1 downto 0);
        decode_loadstore_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0) := "0";
        decode_loadstore_ex_width : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
        bus_busy                  : in  STD_LOGIC;
        bus_addr                  : out STD_LOGIC_VECTOR(31 downto 0);
        bus_width                 : out STD_LOGIC_VECTOR(1 downto 0);  
        bus_dout                  : out STD_LOGIC_VECTOR(31 downto 0);
        bus_write                 : out STD_LOGIC;
        bus_enable                : out STD_LOGIC;
        bus_din                   : in  STD_LOGIC_VECTOR(31 downto 0));
    end component;
    signal loadstore_active      : std_logic;
    signal loadstore_complete    : std_logic;
    signal loadstore_failed      : std_logic;
    signal loadstore_data        : STD_LOGIC_VECTOR(31 downto 0);

begin
    -- Mapping internal exceptions to external ones
    exec_except_illegal_instr    <= right_instr and not known_instr;
    exec_except_instr_misaligned <= right_instr and decode_instr_misaligned;
    exec_except_instr_access     <= right_instr and decode_instr_access;
    exec_except_ebreak           <= right_instr and decode_ebreak;
    exec_except_ecall            <= right_instr and decode_ecall;

    -- Managing the instrucion fetch misses
    right_instr               <= '1' when std_logic_vector(pc) = decode_addr else '0'; 

    alu_active                <= right_instr and decode_alu_enable;
    csr_active                <= right_instr and decode_csr_enable;
    shift_active              <= right_instr and decode_shift_enable;
    branchtest_active         <= right_instr and decode_branchtest_enable;
    loadstore_active          <= right_instr and decode_loadstore_enable;
    jump_active               <= right_instr and decode_jump_enable;

    known_instr               <= alu_active          or csr_active    or shift_active       or
                                 branchtest_active   or jump_active   or loadstore_active;

    completed                 <= alu_complete        or csr_complete  or shift_complete     or 
                                 branchtest_complete or jump_complete or loadstore_complete;

    failed                    <= (not known_instr)   or
                                 alu_failed          or csr_failed    or shift_failed       or
                                 branchtest_failed   or jump_failed   or loadstore_failed;

    exec_decode_next          <= completed or failed or (not known_instr) or (not right_instr);

    -- Used by the interrupt controller to detect when interrupts are taken
    exec_setting_mcause       <= decode_m_int_enter;
    exec_setting_mcause_value <= decode_mcause;
    
     -- Should the Program counter be advanced.
    pc_completed              <= completed or decode_force_complete;
   
    -- Outputs going to the outside world 
    exec_current_pc           <= pc;
    exec_instr_completed      <= completed;
    exec_instr_failed         <= failed;
    exec_flush_required       <= not right_instr;
    debug_pc                  <= pc;
    
i_alu: alu port map (
     clk              => clk,
     alu_mode         => decode_alu_mode,
     alu_active       => alu_active,
     alu_complete     => alu_complete,
     alu_failed       => alu_failed,  
     a                => a_bus,
     b                => b_bus,
     c                => c_alu); 

i_csr_unit: csr_unit port map (
     clk          => clk,
     csr_mode     => decode_csr_mode,
     csr_reg      => decode_csr_reg,
     csr_active   => csr_active,
     csr_complete => csr_complete,
     csr_failed   => csr_failed,  
     a            => a_bus,
     b            => b_bus,
     c            => c_csr,

     m_epc_set    => decode_m_int_enter,
     m_epc_in     => pc,
     m_epc_out    => exec_m_epc,

     m_tval_set   => m_tval_set,
     m_tval       => m_tval,

     -- For updating mstatus
     m_int_enter  => decode_m_int_enter,
     m_int_return => decode_m_int_return,

     m_cause_set  => decode_m_int_enter,
     m_cause      => decode_mcause,
 
     m_ie         => exec_m_ie,

     m_eie        => exec_m_eie,
     m_tie        => exec_m_tie,
     m_sie        => exec_m_sie,
     m_eip        => m_eip,
     m_tip        => m_tip,
     m_sip        => m_sip,
     inst_retired => completed,

     m_tvec_base  => exec_m_tvec_base,
     m_tvec_flag  => exec_m_tvec_flag
); 

i_shifter: shifter port map (
     clk              => clk,
     shift_mode       => decode_shift_mode,
     shift_active     => shift_active,
     shift_complete   => shift_complete,
     shift_failed     => shift_failed,
     a                => reg_read_data_a,
     b                => b_bus,
     c                => c_shifter); 

i_result_bus_mux: result_bus_mux port map (
     res_src          => decode_result_src,
     res_alu          => c_alu,
     res_csr          => c_csr,
     res_shifter      => c_shifter,
     res_pc_plus_four => pc_plus_four,
     res_memory       => loadstore_data,
     res_bus          => c_bus); 

i_register_file: register_file port map (
     clk              => clk,
     read_port_1_addr => decode_reg_a,
     read_data_1      => reg_read_data_a,
     read_port_2_addr => decode_reg_b,
     read_data_2      => reg_read_data_b,       

     write_port_addr  => decode_rdest,       
     write_data       => c_bus,
     completed        => completed,

     debug_sel        => debug_sel,
     debug_data       => debug_data);

i_data_bus_mux_a: data_bus_mux_a port map (
     bus_select               => decode_select_a,
     reg_read_port            => reg_read_data_a,
     pc                       => pc,
     data_bus                 => a_bus); 

i_data_bus_mux_b: data_bus_mux_b port map (
     bus_select                => decode_select_b,
     reg_read_port             => reg_read_data_b,
     immedediate               => decode_immed,
     data_bus                  => b_bus); 

i_branchtest: branch_test port map (
     clk                       => clk,

     branchtest_mode           => decode_branchtest_mode,
     branchtest_active         => branchtest_active,
     branchtest_complete       => branchtest_complete,
     branchtest_failed         => branchtest_failed,
     a                         => reg_read_data_a,
     b                         => reg_read_data_b,
     take_branch               => take_branch);

i_loadstore: loadstore_unit port map (
     clk                       => clk,

     loadstore_active          => loadstore_active,
     loadstore_complete        => loadstore_complete,
     loadstore_failed          => loadstore_failed,

     loadstore_except_load_misaligned  => exec_except_load_misaligned, 
     loadstore_except_load_access      => exec_except_load_access,
     loadstore_except_store_misaligned => exec_except_store_misaligned,
     loadstore_except_store_access     => exec_except_store_access,
        
     data_a                    => reg_read_data_a,
     data_b                    => reg_read_data_b,
     loadstore_data            => loadstore_data,
        
     decode_loadstore_enable   => decode_loadstore_enable,
     decode_loadstore_write    => decode_loadstore_write,
     decode_loadstore_offset   => decode_loadstore_offset,
     decode_loadstore_width    => decode_loadstore_width,
     decode_loadstore_ex_mode  => decode_loadstore_ex_mode,
     decode_loadstore_ex_width => decode_loadstore_ex_width,
        
     bus_busy                  => bus_busy,
     bus_addr                  => bus_addr,
     bus_width                 => bus_width,  
     bus_dout                  => bus_dout,
     bus_write                 => bus_write,
     bus_enable                => bus_enable,
     bus_din                   => bus_din);

i_program_counter: program_counter port map (
     clk                       => clk, 
     completed                 => pc_completed,
     
     jump_active               => jump_active,
     jump_complete             => jump_complete,
     jump_failed               => jump_failed,
       
     pc_mode                   => decode_pc_mode,
     take_branch               => take_branch,
     pc_jump_offset            => decode_pc_jump_offset,
     a                         => reg_read_data_a,
       -- outputs
     pc                        => pc,
     pc_plus_four              => pc_plus_four); 

end Behavioral;
