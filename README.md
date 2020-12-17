# simple-riscv

A three-stage RISC-V CPU. 

- Fetch
- Decode
- Execute

Thsi is a follow on from Rudi-RV32I, a single-stage design. The more advanced design allows

- Higher performance (clock rate)
- Addtion of more functional units (eg CSR or multiplier)

## Current features
- RV32I instruction support
- Most instructions are single cycle (except jumps and load/store)

## Known issues
- Unknown instructions will halt the CPU (as no functional unit is enabled)
- Unaligned memory accesses are not yet supported
- An I-cache is required, but worked around using dual-port memory
