.global _start
	#.org	0xF0000000	


_start:	# Clear out two registers
 	xor	x1, x1, x1
	xor	x2, x2, x2
        # Set x1 to one
	addi	x1, x1, 1 
        # Test resgister+register adds.
	add 	x2, x1, x1
	add 	x2, x2, x1
	add 	x2, x1, x2

        # test LUI
        lui     x2, 0xFFFFF

	# test immediate shifts
        srai 	x2,x2,2
        srli 	x2,x2,4
        slli 	x2,x2,2
	
        # test AUIPC
	AUIPC   x2, 0x12345

        #######################################
        # Testing different size stores
        #######################################
        # Load the RAM address into x7
        lui     x7, 0x10000

        # Test four x byte stores
        sb      x2, 0(x7)
        sb      x2, 1(x7)
        sb      x2, 2(x7)
        sb      x2, 3(x7)

        # Load them back as a word
        lw	x3, 0(x7)

        # Test two x halfword stores
        sh      x2, 0(x7)
        sh      x2, 2(x7)

        # Load them back as a word
        lw	x3, 0(x7)
 
        #Create a new test value 0x89ABCDEF
        lui     x2, 0x89ABD
        addi    x2, x2, 0xFFFFFDEF

        # Store it into RAM  
        sw      x2, 0(x7)

        # Load them back as a word
        lw      x3, 0(x7)

        # Test signed halfword loads
        lh      x2, 0(x7)
        lh      x2, 2(x7)

        # Test signed byte loads
        lb      x2, 0(x7)
        lb      x2, 1(x7)
        lb      x2, 2(x7)
        lb      x2, 3(x7)

        # Test unsigned halfword loads
        lhu     x2, 0(x7)
        lhu     x2, 2(x7)

        # Test unsigned byte loads
        lbu     x2, 0(x7)
        lbu     x2, 1(x7)
        lbu     x2, 2(x7)
        lbu     x2, 3(x7)

        # Setup for reg <= reg op reg instructions
       	lui	x2, 0x66666
        addi	x2, x2, 0x666

       	lui	x3, 0xCCCCD
        addi	x3, x3, 0xFFFFFCCC

        # reg <= reg op reg instructions
        add	x4, x2, x3
        add	x4, x3, x2
        sub	x4, x2, x3
        sub	x4, x3, x2
        sll	x4, x2, x3
        sll	x4, x3, x2
        slt	x4, x2, x3
        slt	x4, x3, x2
        sltu	x4, x2, x3
        sltu	x4, x3, x2
        xor	x4, x2, x3
        xor	x4, x3, x2
        srl	x4, x2, x3
        srl	x4, x3, x2
        sra	x4, x2, x3
        sra	x4, x3, x2
        or	x4, x2, x3
        or	x4, x3, x2
        and	x4, x2, x3
        and	x4, x3, x2

        # reg <= reg op immediate instructions
        addi	x4, x3, 0x666
        slti	x4, x3, 0x666
        sltiu	x4, x3, 0x666
        xori 	x4, x3, 0x666
        ori 	x4, x3, 0x666
        andi 	x4, x3, 0x666
        slli 	x4, x3, 6
        srli 	x4, x3, 6
        srai 	x4, x3, 6
        # empty out x3 and test relative jump
        andi 	x3, x0, 0
        jal     x4, tmp0
	ori 	x3, x3, 1
tmp0:	ori 	x3, x3, 2
        ori 	x3, x3, 4
        # Testing conditional branckes
        xor 	x2, x2, x2
        addi    x3, x2, 0x8
        addi    x4, x2, 0x8
        # Test conditionals with rboth registers = 0x8
        beq     x3, x4, tmp1
        ori     x2, x2, 1
tmp1:	bne     x3, x4, tmp2        
        ori     x2, x2, 2
tmp2:	blt     x3, x4, tmp3        
        ori     x2, x2, 4
tmp3:	bge     x3, x4, tmp4        
        ori     x2, x2, 8
tmp4:	bltu 	x3, x4, tmp5        
        ori     x2, x2, 0x10
tmp5:	bgeu 	x3, x4, tmp6        
        ori     x2, x2, 0x20
tmp6:
        # Set up for next pass of conditionals 
 	xor     x2, x2, x2
        addi    x4, x3, 8
        beq	x3, x4, tmp11
        ori     x2, x2, 0x01
tmp11:	bne	x3, x4, tmp12
        ori     x2, x2, 0x02
tmp12:	blt	x3, x4, tmp13
        ori     x2, x2, 0x04
tmp13:	bge	x3, x4, tmp14
        ori     x2, x2, 0x08
tmp14: bltu	x3, x4, tmp15
        ori     x2, x2, 0x10 
tmp15: bgeu	x3, x4, tmp16
        ori     x2, x2, 0x20 
tmp16:
 
        # Set up for next pass of conditionals 
	xor	x2, x2, x2
        addi    x4, x2, 0xFFFFFFE0
	beq	x3, x4, tmp21
        ori     x2, x2, 0x01
tmp21:	bne	x3, x4, tmp22
        ori     x2, x2, 0x02
tmp22:	blt	x3, x4, tmp23
        ori     x2, x2, 0x04
tmp23:	bge	x3, x4, tmp24
        ori     x2, x2, 0x08
tmp24:	bltu	x3, x4, tmp25
        ori     x2, x2, 0x10
tmp25:	bgeu	x3, x4,	tmp26
        ori     x2, x2, 0x20
tmp26:
	# Now testing the CRS instructions
	csrrs	x5, mvendorid, x0
	csrrs	x5, marchid, x0
	csrrs	x5, mimpid, x0
	csrrs	x5, mhartid, x0

	# Set up the trap vector
	lui	x2, 0xF0000
        ori	x2, x2, 0x200
	csrrw	x2, mtvec, x2

        ori	x2, x2, 0x200   # Allow the testing of last instruction
        .word	0xFFF0007E	# An invalid instruction
        .word	0
        .word	0
traptarget:
        # Target for the "illegal opcode" vector
        csrrw	x5, mcause, x0
        csrrw	x5, mepc, x0
        # Padding
	addi	x1, x1, 1 
	addi	x1, x1, 1 
	addi	x1, x1, 1 
	addi	x1, x1, 1 
	addi	x1, x1, 1 
	addi	x1, x1, 1 
	addi	x1, x1, 1 
	.data
	.word 0
	.end

