# read all design files
read_vhdl ../../hdl/systems/top_level.vhd

# The CPU design
read_vhdl ../../hdl/cpu/cpu_constants.vhd
read_vhdl ../../hdl/cpu/fetch/fetch_unit.vhd
read_vhdl ../../hdl/cpu/riscv_cpu.vhd
read_vhdl ../../hdl/cpu/decode/decode_unit.vhd
read_vhdl ../../hdl/cpu/exec/program_counter.vhd
read_vhdl ../../hdl/cpu/exec/data_bus_mux_a.vhd
read_vhdl ../../hdl/cpu/exec/alu.vhd
read_vhdl ../../hdl/cpu/exec/csr_unit.vhd
read_vhdl ../../hdl/cpu/intex/intex_unit.vhd
read_vhdl ../../hdl/cpu/exec/exec_unit.vhd
read_vhdl ../../hdl/cpu/exec/loadstore_unit_pipelined.vhd
read_vhdl ../../hdl/cpu/exec/sign_extender.vhd
read_vhdl ../../hdl/cpu/exec/shifter.vhd
read_vhdl ../../hdl/cpu/exec/result_bus_mux.vhd
read_vhdl ../../hdl/cpu/exec/register_file.vhd
read_vhdl ../../hdl/cpu/exec/data_bus_mux_b.vhd
read_vhdl ../../hdl/cpu/exec/branch_test.vhd

read_vhdl ../../hdl/cpu/csr/csr_300_mstatus.vhd
read_vhdl ../../hdl/cpu/csr/csr_301_misa.vhd
read_vhdl ../../hdl/cpu/csr/csr_304_mie.vhd
read_vhdl ../../hdl/cpu/csr/csr_305_mtvec.vhd
read_vhdl ../../hdl/cpu/csr/csr_340_mscratch.vhd
read_vhdl ../../hdl/cpu/csr/csr_341_mepc.vhd
read_vhdl ../../hdl/cpu/csr/csr_342_mcause.vhd
read_vhdl ../../hdl/cpu/csr/csr_343_mtval.vhd
read_vhdl ../../hdl/cpu/csr/csr_344_mip.vhd
read_vhdl ../../hdl/cpu/csr/csr_C00_C80_cycle.vhd
read_vhdl ../../hdl/cpu/csr/csr_C01_C81_time.vhd
read_vhdl ../../hdl/cpu/csr/csr_C02_C82_retire.vhd
read_vhdl ../../hdl/cpu/csr/csr_F11_mvendorid.vhd
read_vhdl ../../hdl/cpu/csr/csr_F12_marchid.vhd
read_vhdl ../../hdl/cpu/csr/csr_F13_mimpid.vhd
read_vhdl ../../hdl/cpu/csr/csr_F14_mhartid.vhd
read_vhdl ../../hdl/cpu/csr/csr_readonly_zero.vhd
read_vhdl ../../hdl/cpu/csr/csr_other.vhd

# The Program ROM and RAM
read_vhdl ../../hdl/memory/program_memory_isa_test.vhd
read_vhdl ../../hdl/memory/ram_memory_isa_test.vhd

# The 'external' CPU bus - bridge, RAM and Serial peripherals
read_vhdl ../../hdl/bus/bus_bridge.vhd
read_vhdl ../../hdl/periph/peripheral_serial.vhd

# sim specific stuff
read_vhdl ../hdl/tb_top_level.vhd

save_project_as isa_check -force
set_property top tb_top_level [get_fileset sim_1]
launch_simulation -simset sim_1 -mode behavioral
run 6us
exit 0
