	.section .init, "ax"
.global _start
_start:	
	la gp, __global_pointer$
	la sp, __stack_top
	add s0, sp, zero
	jal zero, main

	.text
.global main

	.set timerbase, 0xE0000020
        .set timerl,    0x00
        .set timerh,	0x04
        .set timercmpl,	0x08
        .set timercmph,	0x0C


main: 		# Load the base of the timer peripheral
		la	t0, timerbase

		# copy timer count to a1:a0, allowing for rollover
rollover: 	lw 	a0, timerl(t0)
		lw 	a1, timerh(t0)
		lw	a2, timerl(t0)
		bne 	a1, a0, rollover

		# add 1000 to the current timer value
		ori	a2, a0, 0
  		addi	a0, a0, 1000
		bgt	a0, a2, nocarry
		addi    a1, a1, 1
nocarry: 	# store the new value in the timer compare register
		sw	a0, timercmpl(t0)
		# copy timerh to timercmpl
		sw	a1, timercmph(t0)

forever:	j	forever
	.data
	.word 0

stat:        
	.end

