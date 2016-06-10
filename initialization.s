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
	//bl	drawMap

	pop	{r4-r10, lr}
	bx	lr

.globl initCenter
	ADRS .req r3
	OFFSET .req r4
	.equ	DONE, 22
initCenter:
	push	{r4-r10, lr}

	ldr	ADRS, =laneArray	// retrieve array of middle lane
	mov	r0, #2		// refresh counter for deciding lane or road tile
	mov	r5, #0		// actual counter

initCenterLoop:
	mov	r1, #0		// road is regular

	lsl	OFFSET, r0, #2	// retrieve offset of array
	cmp	r0, #2
	moveq	r1, #1		// road has a lane tile
	streq	r1, [ADRS, OFFSET]

	subs	r0, #1
	movmi	r0, #2		// if r0 = -1, then bring it back to 2
	add	r5, #1		// increment the actual counter
	cmp	r5, #DONE	// keep looping until reach all the tiles
	blt	initCenterLoop

	pop	{r4-r10, lr}
	bx	lr
	

.globl initMap
	.equ 	ROAD, 0
	.equ 	SIDE, 1
	.equ 	LEFT, 4
	.equ 	RIGHT, 19
	.equ	X_OFF, 7 	// accounts for trump on the left
	.equ	Y_OFF, 2 	// accounts for black spot at top
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

	mov	r1, #SIDE	// first check if side or road tile
	cmp	COL, #LEFT	// if column > left
	cmpgt	COL, #RIGHT	// if column < right
	movlt	r1, #ROAD	// then it is on the road
	str	r1, [r0]	// store tile type
				
	add	r1, COL, #X_OFF	// account for left image
	add	r2, ROW, #Y_OFF	// account for black box at top
	lsl	r1, #5		// column * 32 
	lsl	r2, #5		// row * 32
	str	r1, [r0, #4]	// store x
	str	r2, [r0, #8]	// store y

	add	COL, #1		// increase the column
	cmp	COL, #24	// check if reached rightmost column
	movge	COL, #0		// if so, return to beginning
	addge	ROW, #1		// and go to next row
	cmp	ROW, #21	// check if reached bottom-most row
	ble	initMapLoop	// if not, keep looping	

	pop	{r4-r10, lr}
	bx	lr


