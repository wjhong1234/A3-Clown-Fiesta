.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
	mov     sp, #0x8000
		
	bl	EnableJTAG
	bl	InitFrameBuffer	

	/* testing it */
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =459	// final x
	ldr	r3, =258	// final y
	ldr	r4, =dt1_pic
	bl	CreateImage	
    
haltLoop$:
	b		haltLoop$

