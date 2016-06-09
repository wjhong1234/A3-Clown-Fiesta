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
	mov	r5, r0
	bl	clearScreen
	cmp	r5, #1
	bne	haltLoop$

	mov	r0, #7		// initial x
	mov	r1, #64		// initial y
	ldr	r2, =223	// final x
	ldr	r3, =767	// final y
	ldr	r4, =banner
	bleq	CreateImage
	bleq	tutorialPrint
	bleq	pressAPrint
    
haltLoop$:
	b		haltLoop$
