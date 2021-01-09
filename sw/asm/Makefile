CC=/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc
AS=/opt/riscv/bin/riscv32-unknown-linux-gnu-as
COPTS= -Wall -pedantic 

all : isa_test
	../image_to_mem/image_to_mem.sh isa_test
	rm isa_test.o

isa_test : isa_test.o
	echo "---------------------------------------------------------" >> /dev/null
	echo "-- Do not call anything main() - it will end up linked at" >> /dev/null
	echo "-- the start of the program, rather than the setup code"   >> /dev/null
	echo "---------------------------------------------------------" >> /dev/null
	/opt/riscv/bin/riscv32-unknown-linux-gnu-ld -T linker_script isa_test.o -o isa_test

dump: isa_test.o
	/opt/riscv/bin/riscv32-unknown-linux-gnu-objdump -d  isa_test.o 
	rm isa_test.o

isa_test.o : isa_test.S
	$(AS) -o isa_test.o -c isa_test.S

clean:
	rm -f isa_test.o isa_test
