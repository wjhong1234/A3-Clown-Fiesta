.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    	mov	sp, #0x8000	// Initializing the stack pointer
	bl	EnableJTAG

	bl	initi

mainmenu:
	bl	menu
	mov	r4, r0
	cmp	r4, #1

	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldr	r4, =lose_pic
	bleq	CreateImage
	blne	clearScreen
    
haltLoop$:
	b		haltLoop$
