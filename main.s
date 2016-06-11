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
	bl	clearScreen
	cmp	r4, #1
	
	bleq	drawMap
	blne	clearScreen
    
haltLoop$:
	b		haltLoop$
