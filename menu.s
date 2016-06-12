.section .text
.globl menu

	// The binary numbers that will be used
	// to determine which buttons have been pressed
	.equ	UP, 0b111101111111	// Up button
	.equ	DOWN, 0b111110111111	// Down button
	.equ	A, 0b111111110111	// A button
	.equ	NONE, 0b111111111111	// None have been pressed

	// Flags	
	.equ	TRUE, 1
	.equ	START, 1
	.equ	QUIT, 0

menu:
	BUTTON .req r6		// contains the button pressed
	FLAG .req r5		// if flag is set, then start game. Else, quit game
	push	{r4-r10, lr}

	ldr	r0, =status
	ldr	r1, [status]
	cmp	r1, #0		// check if the player has won or lost
	blne	keepPrompting	// if they have, the main menu won't print until they press something

	mov	FLAG, #1	// initialize main menu so that 
				// user is selecting start
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldr	r4, =menu_pic
	bl	CreateImage

menuLoop:
	bl	getInput	// Retrieve input of user
	mov	BUTTON, r0
	
	mov	r0, BUTTON	// before anything is checked,
	ldr	r1, =A		// we check if A has been pressed
	bl	checkButton	
	cmp	r0, #TRUE	// if they did, branch to selection
	beq	menuexit	

	mov	r0, BUTTON	// check if user pressed UP
	ldr	r1, =UP		
	bl	checkButton	
	cmp	r0, #TRUE
				// this prevents players from pressing UP at "start"
	cmpeq	FLAG, #QUIT	// First it checks if the flags are at "Quit"
	moveq	FLAG, #START	// If the flags are at "Quit", they are moved to "Start"

	mov	r0, BUTTON	// check if user pressed DOWN
	ldr	r1, =DOWN	
	bl	checkButton	
	cmp	r0, #1	
				// this prevents players from pressing DOWN at "quit"
	cmpeq	FLAG, #START	// checks if user is currently selecting 'start game'
	moveq	FLAG, #QUIT	// if so, selection is moved to 'quit game'

	mov	r0, FLAG	// the flags will be drawn
	bl	drawFlags	// depending on where the choice markers are

	b	menuLoop
menuexit:
	mov	r0, FLAG
	pop	{r4-r10, lr}
	bx	lr

	.unreq	BUTTON
	.unreq	FLAG
	
keepPrompting:
	push	{r4-r10, lr}
	ldr	r1, =NONE
	
promptLoop:
	bl	getInput
	cmp	r0, r1
	beq	promptLoop
	
	pop	{r4-r10, lr}
	bx	lr
