.section .text

.globl	initi

	.equ	LATCH, 9
	.equ	DATA, 10
	.equ	CLOCK, 11

initi:
	push	{r4-r10, lr}
	bl	InitFrameBuffer
	
	// INITIALIZE THE SNES

	mov	r0, #LATCH	// Initialize Latch 
	mov	r1, #1		// which utilizes an output function
	bl	Init_GPIO	

	mov	r0, #DATA	// Initialize Data
	mov	r1, #0		// which utilizes an input function
	bl	Init_GPIO	

	mov	r0, #CLOCK	// Initialize Clock
	mov	r1, #1		// which utilizes an output function
	bl	Init_GPIO

	pop	{r4-r10, lr}
	bx	lr

.globl	initGame
initGame:
	push	{r4-r10, lr}

	bl	initMap
	bl	drawMap

	pop	{r4-r10, lr}
	bx	lr


.globl initMap
	.equ ROAD, 0
	.equ SIDE, 1
	.equ LEFT, 4
	.equ RIGHT, 19
	COL .req r3
	ROW .req r4
initMap:
	push	{r4-r10, lr}
	
	ldr	r0, =gameMap
	mov	COL, #0
	mov	ROW, #0	

initMapLoop:
	mov	r0, COL
	mov	r1, ROW	
	bl	getTileRef	// get offset of the tile in array
	mov	r1, #SIDE	// initialize it first to side
	cmp	COL, #LEFT	// if column > left
	cmpgt	COL, #RIGHT	// if column < right
	movlt	r1, #ROAD	// then it is on the road
	str	r1, [r0]	// store that

	add	COL, #1		// increase the column
	cmp	COL, #24	// check if reached rightmost column
	movge	COL, #0		// if so, return to beginning
	addge	ROW, #1		// and go to next row
	cmp	ROW, #21	// check if reached bottom-most row
	ble	initMapLoop	// if not, keep looping	

	pop	{r4-r10, lr}
	bx	lr


