CC=/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc
AS=/opt/riscv/bin/riscv32-unknown-linux-gnu-as
LD=/opt/riscv/bin/riscv32-unknown-linux-gnu-ld
OBJDUMP=/opt/riscv/bin/riscv32-unknown-linux-gnu-objdump

all : basys3_serial
	../image_to_mem/image_to_mem.sh basys3_serial
	###############################################
	# VHDL files should now be in ../../hdl/memory
	###############################################
	ls -l  ../../hdl/memory/*basys3_serial.vhd

dump : basys3_serial
	$(OBJDUMP) -d basys3_serial

basys3_serial : crt0.o basys3_serial.o script.ld
	$(LD) -T script.ld -o basys3_serial crt0.o basys3_serial.o

crt0.o : crt0.S
	$(AS) -o crt0.o --march=rv32i crt0.S

basys3_serial.o : basys3_serial.c
	$(CC) -c basys3_serial.c -Wall -pedantic 

clean :
	rm -f crt0.o main.o basys3_serial.o basys3_serial
