# simple-riscv

A three-stage RISC-V CPU. 

- Fetch
- Decode
- Execute

Thsi is a follow on from Rudi-RV32I, a single-stage design. The more advanced design allows

- Higher performance (clock rate)
- Addtion of more functional units (eg CSR or multiplier)

## Target platform

This is currently targeted at Xilinx 7-series parts, but there is no part-specific code in the design.

## Building

- Make user your EDA tools are set up (Vivado)
- cd into the build directory for your target board
- run "build.sh" or "build.bat" depending on your OS

## Simulation
Currently you can run a a check of the basic functioning of the RV32I ISA:

- Make user your EDA tools are set up (Vivado)
- cd into the sim/scripts directory
- run "isa_check.sh" or "isa_check.bat" depending on your OS

## Project Status
- Currently in testing.
- Can run all RV32I instructions in a test program.
- Instruction fetch logic is very sub-optimal
- Implements at > 100MHz on Artix-7

## Current features
- RV32I instruction support
- Most instructions are single cycle (except jumps due to pipeline flush and load/store due to memory stalls)

## Known issues
- Unknown instructions will halt the CPU (as no functional unit is enabled, so no instruciton completes)
- Unaligned memory accesses are not yet supported
- An I-cache is required, but worked around using dual-port memory.
