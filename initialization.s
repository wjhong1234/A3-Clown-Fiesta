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
	.equ	PAUSE, 0
initGame:
	push	{r4-r10, lr}
	
	bl	initMap			// initializes the map
	bl	resetPlayer		// resets the player
	bl	initState
	pop	{r4-r10, lr}
	bx	lr

/*
Initializes all states of the game.
*/
initState:
	mov	r1, #0
	ldr	r0, =itemCount	
	str	r1, [r0]
	ldr	r0, =status	
	str	r1, [r0]
	ldr	r0, =gameState		
	str	r1, [r0]
	ldr	r0, =faceState
	str	r1, [r0]
	bx	lr


/*
Initializes tile based on the row.
r0 - row
*/
initCenter:
	push	{lr}

initCenterLoop:
	cmp	r0, #2		// row mod 3		
	subgt	r0, #3
	bgt	initCenterLoop	// keep going until row <= 0

	cmp	r0, #0
	moveq	r0, #1		// row mod 3 = 0 -> lane tile
	movne	r0, #0		// otherwise, regular tile
	pop	{lr}
	bx	lr

.globl initMap
	.equ 	ROAD, 0
	.equ 	SIDE, 1
	.equ 	LEFT, 4
	.equ	CENTER, 12
	.equ 	RIGHT, 20
	.equ	X_OFF, 7 	// accounts for banner on the left
	.equ	Y_OFF, 2 	// accounts for scorecard at top
	
	COL .req r4
	ROW .req r5
	ADRS .req r6
initMap:
	push	{r4-r10, lr}
	
	mov	COL, #0
	mov	ROW, #0	

initMapLoop:
	mov	r0, COL
	mov	r1, ROW	
	bl	getTileRef	// get offset of the tile in array
	mov	ADRS, r0

	mov	r1, #SIDE	// first check if side or road tile
	cmp	COL, #LEFT	// if column <= left
	ble	strTile		// store grass
	cmp	COL, #RIGHT	// if column < right
	movlt	r1, #ROAD	// then it is on the road
				// else print grass
strTile:
	str	r1, [ADRS]	// store tile type

	cmp	COL, #CENTER	// if it is a center tile,
	moveq	r0, ROW		// check if it is a lane tile.
	bleq	initCenter
	mov	r2, #0
	mov	r3, #1
	cmp	r0, #1		// if it is a line tile,
	streq	r3, [ADRS, #12]	// store that it is a lane tile
	strne	r2, [ADRS, #12] // else store that it is a normal tile
			
	add	r0, COL, #X_OFF	// account for left image
	add	r1, ROW, #Y_OFF	// account for black box at top
	lsl	r0, #5		// column * 32 
	lsl	r1, #5		// row * 32
	str	r0, [ADRS, #4]	// store x
	str	r1, [ADRS, #8]	// store y

	add	COL, #1		// increase the column
	cmp	COL, #25	// check if reached rightmost column
	movge	COL, #0		// if so, return to beginning
	addge	ROW, #1		// and go to next row
	cmp	ROW, #21	// check if reached bottom-most row
	ble	initMapLoop	// if not, keep looping	

	pop	{r4-r10, lr}
	bx	lr
