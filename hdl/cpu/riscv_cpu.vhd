--###############################################################################
--# ./hdl/cpu/riscv_cpu.vhd  - DESCRIPTION_NEEDED
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

entity riscv_cpu is
    Port( clk     : in  STD_LOGIC;
          progmem_addr       : out STD_LOGIC_VECTOR(31 downto 0);
          progmem_enable     : out STD_LOGIC;
          progmem_data_addr  : in  STD_LOGIC_VECTOR(31 downto 0);
          progmem_data       : in  STD_LOGIC_VECTOR(31 downto 0);
          progmem_data_valid : in  STD_LOGIC;

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
          debug_data    : out STD_LOGIC_VECTOR(31 downto 0)
  );
end riscv_cpu;

architecture Behavioral of riscv_cpu is
    component fetch_unit is
    Port ( clk                 : in  STD_LOGIC;
           -- from the exec unit
           exec_completed      : in  STD_LOGIC;
           exec_flush_required : in  STD_LOGIC;
           exec_current_pc     : in  STD_LOGIC_VECTOR (31 downto 0);

           -- to the decoder
           fetch_opcode        : out STD_LOGIC_VECTOR (31 downto 0);
           fetch_addr          : out STD_LOGIC_VECTOR (31 downto 0);

           -- to the memory
           progmem_enable      : out STD_LOGIC;
           progmem_addr        : out STD_LOGIC_VECTOR (31 downto 0);

           progmem_data_addr  : in  STD_LOGIC_VECTOR(31 downto 0);
           progmem_data        : in  STD_LOGIC_VECTOR (31 downto 0);
           progmem_data_valid  : in  STD_LOGIC
       
           );
    end component;

    signal fetch_opcode        : STD_LOGIC_VECTOR (31 downto 0);
    signal fetch_addr          : STD_LOGIC_VECTOR (31 downto 0);

    component decode_unit is
    Port (  clk                   : in  STD_LOGIC;
           -- from the exec unit
            exec_completed      : in  STD_LOGIC;
            exec_flush_required : in  STD_LOGIC;
            -- To the exec unit
            reset                     : in  STD_LOGIC;
            -- from the fetch unit
            fetch_opcode              : in  STD_LOGIC_VECTOR (31 downto 0);
            fetch_addr                : in  STD_LOGIC_VECTOR (31 downto 0);
            -- To the exec unit
            decode_reset              : out STD_LOGIC := '0';

            decode_addr               : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            decode_immed              : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
            decode_reg_a              : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_a           : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
            decode_zero_a             : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
            decode_reg_b              : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_b           : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
            decode_zero_b             : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

            decode_jump_enable        : out STD_LOGIC := '0';
            decode_pc_mode            : out STD_LOGIC_VECTOR(1 downto 0) := "00";
            decode_pc_jump_offset     : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_pc_branch_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
            decode_loadstore_enable   : out STD_LOGIC := '0';
            decode_loadstore_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_loadstore_write    : out STD_LOGIC;
            decode_loadstore_width    : out STD_LOGIC_VECTOR(1 downto 0);
            decode_loadstore_ex_mode  : out STD_LOGIC_VECTOR(0 downto 0) := "0";
            decode_loadstore_ex_width : out STD_LOGIC_VECTOR(1 downto 0) := "00";
    
            decode_alu_enable         : out STD_LOGIC := '0';
            decode_alu_mode           : out STD_LOGIC_VECTOR(2 downto 0) := "000";

            decode_branchtest_enable : out STD_LOGIC := '0';
            decode_branchtest_mode   : out STD_LOGIC_VECTOR(2 downto 0) := "000";

            decode_shift_enable         : out STD_LOGIC := '0';
            decode_shift_mode         : out STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    
            decode_result_src         : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
            decode_rdest              : out STD_LOGIC_VECTOR(4 downto 0) := (others => '0')
            
            );            
    end component;    
    
    signal decode_reset              : STD_LOGIC;

    signal decode_addr               : STD_LOGIC_VECTOR (31 downto 0);
    signal decode_immed              : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
    signal decode_reg_a              : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal decode_select_a           : STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    signal decode_zero_a             : STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
    signal decode_reg_b              : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
    signal decode_select_b           : STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    signal decode_zero_b             : STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
    
    signal decode_jump_enable        : STD_LOGIC := '0';
    signal decode_pc_mode            : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal decode_pc_jump_offset     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal decode_pc_branch_offset   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal decode_loadstore_enable   : STD_LOGIC;
    signal decode_loadstore_offset   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');    
    signal decode_loadstore_write    : STD_LOGIC;
    signal decode_loadstore_width    : STD_LOGIC_VECTOR(1 downto 0);
    signal decode_loadstore_ex_mode  : STD_LOGIC_VECTOR(0 downto 0) := "0";
    signal decode_loadstore_ex_width : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    signal decode_alu_enable         : STD_LOGIC := '0';
    signal decode_alu_mode           : STD_LOGIC_VECTOR(2 downto 0) := "000";

    signal decode_branchtest_enable  : STD_LOGIC := '0';
    signal decode_branchtest_mode    : STD_LOGIC_VECTOR(2 downto 0) := "000";

    signal decode_shift_enable       : STD_LOGIC := '0';
    signal decode_shift_mode         : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    signal decode_result_src         : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
    signal decode_rdest              : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');            

    component exec_unit is
    Port ( clk                 : in STD_LOGIC;

            decode_reset              : in  STD_LOGIC;
    
            decode_addr               : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            decode_immed              : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         
            
            decode_reg_a              : in  STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_a           : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
            decode_zero_a             : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
        
            decode_reg_b              : in  STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
            decode_select_b           : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
            decode_zero_b             : in  STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

            decode_jump_enable        : in STD_LOGIC := '0';        
            decode_pc_mode            : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
            decode_pc_jump_offset     : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_pc_branch_offset   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        
            decode_loadstore_write    : in  STD_LOGIC;
            decode_loadstore_offset   : in  STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
            decode_loadstore_enable   : in  STD_LOGIC;
            decode_loadstore_width    : in  STD_LOGIC_VECTOR(1 downto 0);
            decode_loadstore_ex_mode  : in  STD_LOGIC_VECTOR(0 downto 0) := "0";
            decode_loadstore_ex_width : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
            decode_alu_enable         : in  STD_LOGIC := '0';
            decode_alu_mode           : in  STD_LOGIC_VECTOR(2 downto 0) := "000";
        
            decode_branchtest_enable  : in  STD_LOGIC := '0';
            decode_branchtest_mode    : in  STD_LOGIC_VECTOR(2 downto 0) := "000";
        
            decode_shift_enable       : in  STD_LOGIC := '0';
            decode_shift_mode         : in  STD_LOGIC_VECTOR(1 downto 0) := "00";
        
        
            decode_result_src         : in  STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
            decode_rdest              : in  STD_LOGIC_VECTOR(4 downto 0) := (others => '0');            
    
            exec_completed        : out STD_LOGIC;
            exec_flush_required   : out STD_LOGIC;
            exec_current_pc       : out STD_LOGIC_VECTOR (31 downto 0);

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
    end component;

    signal exec_completed      : STD_LOGIC;
    signal exec_flush_required : STD_LOGIC;
    signal exec_current_pc     : STD_LOGIC_VECTOR (31 downto 0);

begin



    
fetch: fetch_unit port map (
        clk                   => clk,
        exec_completed        => exec_completed,
        exec_flush_required   => exec_flush_required,
        exec_current_pc       => exec_current_pc,
        fetch_opcode          => fetch_opcode,
        fetch_addr            => fetch_addr,

        progmem_enable        => progmem_enable,
        progmem_addr          => progmem_addr,
        progmem_data_addr     => progmem_data_addr,
        progmem_data          => progmem_data,
        progmem_data_valid    => progmem_data_valid
    );
    
decode: decode_unit port map (
        clk                   => clk,
        reset                 => reset,

        exec_completed        => exec_completed,
        exec_flush_required   => exec_flush_required,

        fetch_opcode          => fetch_opcode,
        fetch_addr            => fetch_addr,
        -- To the exec unit
        decode_reset          => decode_reset,
        decode_addr           => decode_addr,
        decode_immed          => decode_immed,         
        
        decode_reg_a          => decode_reg_a,
        decode_select_a       => decode_select_a,
        decode_zero_a         => decode_zero_a,

        decode_reg_b          => decode_reg_b, 
        decode_select_b       => decode_select_b,
        decode_zero_b         => decode_zero_b,

        decode_jump_enable        => decode_jump_enable,
        decode_pc_mode            => decode_pc_mode,
        decode_pc_jump_offset     => decode_pc_jump_offset,
        decode_pc_branch_offset   => decode_pc_branch_offset,
        decode_loadstore_offset   => decode_loadstore_offset,

        decode_loadstore_enable   => decode_loadstore_enable,
        decode_loadstore_write    => decode_loadstore_write,
        decode_loadstore_width    => decode_loadstore_width,
        decode_loadstore_ex_mode  => decode_loadstore_ex_mode,
        decode_loadstore_ex_width => decode_loadstore_ex_width,

        decode_alu_enable         => decode_alu_enable,
        decode_alu_mode           => decode_alu_mode,

        decode_branchtest_enable  => decode_branchtest_enable,
        decode_branchtest_mode    => decode_branchtest_mode,

        decode_shift_enable       => decode_shift_enable,
        decode_shift_mode         => decode_shift_mode,

        decode_result_src         => decode_result_src,          
        decode_rdest              => decode_rdest                                
    );

exec: exec_unit port map (
        clk                   => clk,
        -- To the exec unit
        decode_reset          => decode_reset,
        decode_addr           => decode_addr,
        decode_immed          => decode_immed,         
        
        decode_reg_a          => decode_reg_a,
        decode_select_a       => decode_select_a,
        decode_zero_a         => decode_zero_a,

        decode_reg_b          => decode_reg_b, 
        decode_select_b       => decode_select_b,
        decode_zero_b         => decode_zero_b,

        decode_jump_enable        => decode_jump_enable,
        decode_pc_mode            => decode_pc_mode,
        decode_pc_jump_offset     => decode_pc_jump_offset,
        decode_pc_branch_offset   => decode_pc_branch_offset,
        
        decode_loadstore_offset   => decode_loadstore_offset,
        decode_loadstore_write    => decode_loadstore_write,
        decode_loadstore_enable   => decode_loadstore_enable,
        decode_loadstore_width    => decode_loadstore_width,
        decode_loadstore_ex_mode  => decode_loadstore_ex_mode,
        decode_loadstore_ex_width => decode_loadstore_ex_width,

        decode_alu_enable         => decode_alu_enable,
        decode_alu_mode           => decode_alu_mode,

        decode_branchtest_enable  => decode_branchtest_enable,
        decode_branchtest_mode    => decode_branchtest_mode,

        decode_shift_enable       => decode_shift_enable,
        decode_shift_mode         => decode_shift_mode,

        decode_result_src         => decode_result_src,          
        decode_rdest              => decode_rdest,
        --===============================================    
        exec_completed        => exec_completed,
        exec_flush_required   => exec_flush_required,
        exec_current_pc       => exec_current_pc,
        
        bus_busy      => bus_busy,
        bus_addr      => bus_addr,
        bus_width     => bus_width,  
        bus_dout      => bus_dout,
        bus_write     => bus_write,
        bus_enable    => bus_enable,
        bus_din       => bus_din,
        
        debug_pc      => debug_pc,
        debug_sel     => debug_sel,
        debug_data    => debug_data               
    );

end Behavioral;
