CC=/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc
AS=/opt/riscv/bin/riscv32-unknown-linux-gnu-as
COPTS= -Wall -pedantic 

all : timer_test
	../image_to_mem/image_to_mem.sh timer_test
	rm timer_test.o

timer_test : timer_test.o
	/opt/riscv/bin/riscv32-unknown-linux-gnu-ld -T script.ld timer_test.o -o timer_test --no-relax

dump: timer_test.o
	/opt/riscv/bin/riscv32-unknown-linux-gnu-objdump -d  timer_test 
	rm timer_test.o

timer_test.o : timer_test.S
	$(AS) -o timer_test.o -c timer_test.S

clean:
	rm -f timer_test.o timer_test
