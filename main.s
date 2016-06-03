.section    .init
.globl     _start

_start:
    b       main
    
.section .text
	.equ	UNPRES, 0b111111111111
	.equ	SEL, 0b110111111111
	.equ	START, 0b111011111111
	.equ	UP, 0b111101111111
	.equ	DOWN, 0b111110111111
	.equ	LEFT, 0b111111011111
	.equ	RIGHT, 0b111111101111
	.equ	A, 0b111111101011
main:
    	mov	sp, #0x8000	// Initializing the stack pointer
	bl	EnableJTAG

	bl	initi

	bl	menu

	bl	clearScreen
    
haltLoop$:
	b		haltLoop$

menu:
	BUTTON .req r4		// contains the button pressed
	FLAG .req r5		// if flag is set, then start game. Else, quit game
	push	{r4-r10, lr}

	mov	FLAG, #1	// initialize main menu so that user is selecting start
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldr	r4, =menus_pic
	bl	CreateImage
menuloop:
	bl	getInput
	mov	BUTTON, r0
	
	mov	r0, BUTTON	// arg 1: the user input
	mov	r1, #A		// arg 2: desired button
	bl	checkButton	// check if user pressed A
	cmp	r0, #1		
	beq	menuexit

	mov	r0, BUTTON	// arg 1: the user input
	mov	r1, #UP		// arg 2: desired button
	bl	checkButton	// check if user pressed UP
	cmp	r0, #1		// check if the button matches		
	cmpeq	FLAG, #0	// checks if user is currently selecting 'quit game'
	moveq	FLAG, #1	// if so, selection is moved to 'start game'

	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldreq	r4, =menus_pic
	bleq	CreateImage

	mov	r0, BUTTON	// arg 1: the user input
	mov	r1, #DOWN	// arg 2: desired button
	bl	checkButton	// check if user pressed DOWN
	cmp	r0, #1		// if the button matches
	cmpeq	FLAG, #1	// checks if user is currenty selecting 'start game'
	moveq	FLAG, #0	// if so, selection is moved to 'quit game'

	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldreq	r4, =menuq_pic
	bleq	CreateImage

	b	menuloop
menuexit:
	pop	{r4-r10, lr}
	bx	lr

	.unreq	BUTTON
	.unreq	FLAG

/*
Checks if button is being pressed
r0 - buttons pressed
r1 - button wanted
*/
checkButton:
	or	r2, r0, r1	// mask the buttons the user pressed
	cmp	r2, r1		// check to see if it matches the desired button
	moveq	r0, #1		// if it matches, return true
	movne	r0, #0		// if not, return false
	bx	lr



