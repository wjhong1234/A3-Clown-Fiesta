.section    .init
.globl     _start

_start:
    b       main
    
.section .text
	.equ	START, #0
	.equ	QUIT, #1
	
	INPUT .req r4

main:
    	mov	sp, #0x8000	// Initializing the stack pointer
	bl	EnableJTAG

	bl	initi		// Initialize everything

mainmenu:
	bl	menu		// First bring up the menu
	mov	INPUT, r0	  
	cmp	INPUT, #QUIT	// if input is "loss" (or quit)
	bleq	drawLose	// the draw the losing screen
	blne	clearScreen	// otherwise, clear screen
	//blne	game
    
haltLoop$:
	b	haltLoop$
