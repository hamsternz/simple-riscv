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

- Make sure your EDA tools are set up (Vivado)
- cd into the build directory for your target board
- run "build.sh" or "build.bat" depending on your OS

## Simulation
Currently you can run a a check of the basic functioning of the RV32I ISA:

- Make user your EDA tools are set up (Vivado)
- cd into the sim/scripts directory
- run "isa_check.sh" or "isa_check.bat" depending on your OS

## Project Status
- Can currently build and run C code (see sw/crt0/ for an example)
- Currently in testing.
- Can run all RV32I instructions, and a few protected ones.
- Instruction fetch logic is very sub-optimal, but works
- Implements at > 100MHz on Artix-7

## Current features
- RV32I instruction support.
- Most instructions are single cycle (except jumps due to pipeline flush and load/store due to memory stalls).
- Software exceptions are well on the way to completed.
- Only a limited subset of CSRs are supported - look in hdl/cpu/csr for details.

## Known issues
- Unaligned memory accesses are not yet supported, but do not cause an exception.
- An I-cache is required, but current workaround is using dual-port memory.
