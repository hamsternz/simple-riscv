CC=/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc
AS=/opt/riscv/bin/riscv32-unknown-linux-gnu-as
LD=/opt/riscv/bin/riscv32-unknown-linux-gnu-ld
OBJDUMP=/opt/riscv/bin/riscv32-unknown-linux-gnu-objdump

all : serial_test
	../image_to_mem/image_to_mem.sh serial_test
	###############################################
	# VHDL files should now be in ../../hdl/memory
	###############################################
	ls -l  ../../hdl/memory/*serial_test.vhd

dump : serial_test
	$(OBJDUMP) -d serial_test

serial_test : crt0.o serial_test.o script.ld
	$(LD) -T script.ld -o serial_test crt0.o serial_test.o --no-relax

crt0.o : crt0.S
	$(AS) -o crt0.o --march=rv32i crt0.S

serial_test.o : serial_test.c
	$(CC) -c serial_test.c -Wall -pedantic 

clean :
	rm -f crt0.o main.o serial_test.o serial_test
