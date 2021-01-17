###########################################################################
		.set timerbase, 0xE0000020
		.set timerl,    0x00
		.set timerh,	0x04
		.set timercmpl,	0x08
		.set timercmph,	0x0C

###########################################################################
		.section .init, "ax"
		.global _start

_start:		la gp, __global_pointer$
		la sp, __stack_top
		add s0, sp, zero
		jal zero, main

###########################################################################
		.text
		.global main

main: 		# Load the base of the timer peripheral
		la	t0, timerbase

		# copy timer count to a1:a0, allowing for rollover
rollover: 	lw 	t1, timerh(t0)
		lw 	a0, timerl(t0)
		lw	a1, timerh(t0)
		bne 	a1, t1, rollover

		# add 5 to the current timer value - 5 microseconds
  		addi	a0, a0, 5
		bgtu	a0, a2, nocarry
		addi    a1, a1, 1

nocarry: 	# store the new value in the timer compare register, avoiding supurious interrupt
                li      t1, 0xFFFFFFFF
		sw	t1, timercmph(t0)
		sw	a0, timercmpl(t0)
		# copy timerh to timercmpl
		sw	a1, timercmph(t0)

		# Now set up the interrupts
                # Set the vectors
 		la	t0, i_vector
		csrw	mtvec, t0

                # Enable the timer interrupt enable
		li	t0, 0x80
		csrrs	zero, mie, t0		# Endable mtie

                # Enable the global interrupt enable
		li	t0, 0x8
		csrrs	zero, mstatus, t0	# Enable mie
		
		
forever:	j	forever

###########################################################################
############# Interrupt handler ###########################################
###########################################################################
i_vector:	# Save registers on stack
		addi sp, sp, -4*4
		sw	t0, 0x04(sp)
		sw	t1, 0x04(sp)
		sw	a0, 0x08(sp)
		sw	a1, 0x0C(sp)

		# Setup for timer update
		la	t0, timerbase

i_rollover:	# copy timer count to a1:a0, allowing for rollover
	 	lw 	t1, timerh(t0)
		lw 	a0, timerl(t0)
		lw	a1, timerh(t0)
		bne 	a1, t1, i_rollover

		# add 5 to the current timer value - 5 microseconds
  		addi	a0, a0, 5
		bgtu	a0, a2, i_nocarry
		addi    a1, a1, 1

i_nocarry: 	# store the new value in the timer compare register,
                # avoiding supurious interrupt
                li      t1, 0xFFFFFFFF
		sw	t1, timercmph(t0)
		sw	a0, timercmpl(t0)
		# copy timerh to timercmpl
		sw	a1, timercmph(t0)

		# Restore registers and stack
		lw	t0, 0x04(sp)
		lw	t1, 0x04(sp)
		lw	a0, 0x08(sp)
		lw	a1, 0x0C(sp)
		addi 	sp, sp, 4*4
		mret

		.data
dummy:		.word 	0
		.end
