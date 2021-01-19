###########################################################################
		.set gpio_value,     0xE0000010;
		.set gpio_direction, 0xE0000014;
		.set timerbase,      0xE0000020
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
		
		li	t0, gpio_direction
		li	t1, gpio_value
		la	a0, counter	
 		li	a1, 0xFFFF
		sw	a1, 0(t0)
		sw	a1, 0(t1)

forever:	lw	a1, 0(a0)
		sw	a1, 0(t1)
		j	forever

###########################################################################
############# Interrupt handler ###########################################
###########################################################################
i_vector:	# Save registers  that will be touched
                csrrw	zero, mscratch, t0	# Bounce t0 via mscratch
                la	t0, save_t0		# use t0 as the base address
		sw	t1, 0x04(t0)
		sw	a0, 0x08(t0)
		sw	a1, 0x0C(t0)
                csrrw   t1, mscratch, zero
		sw	t1, 0x00(t0)

                ###########################################################
		# Setup for timer update, using registers t0, t1, a0 and a1
                ###########################################################
		la	t0, timerbase

i_rollover:	# copy timer count to a1:a0, allowing for rollover
	 	lw 	t1, timerh(t0)
		lw 	a0, timerl(t0)
		lw	a1, timerh(t0)
		bne 	a1, t1, i_rollover

		# add 5 to the current timer value - 500 microseconds
  		addi	a0, a0, 500
		bgtu	a0, a2, i_nocarry
		addi    a1, a1, 1

i_nocarry: 	# store the new value in the timer compare register,
                # avoiding supurious interrupt
                li      t1, 0xFFFFFFFF
		sw	t1, timercmph(t0)
		sw	a0, timercmpl(t0)
		# copy timerh to timercmpl
		sw	a1, timercmph(t0)

		# Increment counter
		la	a0, counter	
		lw	a1, 0(a0)
		addi	a1, a1, 1
		sw	a1, 0(a0)	

		# Restore registers
                la	t0, save_t0		# use t0 as the base address
		lw	a1, 0x0C(t0)
		lw	a0, 0x08(t0)
		lw	t1, 0x04(t0)
		lw	t0, 0x00(t0)
		mret

		.data
save_t0:	.word 	0
save_t1:	.word 	0
save_a0:	.word 	0
save_a1:	.word 	0
counter:	.word	0xFF
		.end
