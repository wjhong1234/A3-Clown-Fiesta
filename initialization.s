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

	bl	initGame

	pop	{r4-r10, lr}
	bx	lr

.globl	initGame
initGame:
	push	{r4-r10, lr}

	bl	initMap
	//bl	drawMap

	pop	{r4-r10, lr}
	bx	lr

/*
Initializes tile based on the row.
r0 - row
*/
.globl initCenter
initCenter:
	push	{lr}

initCenterLoop:
	cmp	r0, #0		// row mod 3		
	subne	r0, #3
	bgt	initCenterLoop	// keep going until row <= 0

	moveq	r0, #1		// row mod 3 = 0 -> lane tile
	movne	r0, #0		// otherwise, regular tile
	pop	{lr}
	bx	lr

.globl initMap
	.equ 	ROAD, 0
	.equ 	SIDE, 1
	.equ 	LEFT, 4
	.equ	CENTER, 13
	.equ 	RIGHT, 19
	.equ	X_OFF, 7 	// accounts for trump on the left
	.equ	Y_OFF, 2 	// accounts for black spot at top
	
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

	// FIX THIS
	mov	r1, #SIDE	// first check if side or road tile
	cmp	COL, #LEFT	// if column > left
	cmpgt	COL, #RIGHT	// if column < right
	movlt	r1, #ROAD	// then it is on the road
	str	r1, [ADRS]	// store tile type

	cmp	COL, #13	// if it is a center tile,
	moveq	r0, ROW		// check if it is a lane tile.
	bleq	initCenter	
			
	add	r0, COL, #X_OFF	// account for left image
	add	r1, ROW, #Y_OFF	// account for black box at top
	lsl	r0, #5		// column * 32 
	lsl	r1, #5		// row * 32
	str	r0, [ADRS, #4]	// store x
	str	r1, [ADRS, #8]	// store y

	add	COL, #1		// increase the column
	cmp	COL, #24	// check if reached rightmost column
	movge	COL, #0		// if so, return to beginning
	addge	ROW, #1		// and go to next row
	cmp	ROW, #21	// check if reached bottom-most row
	ble	initMapLoop	// if not, keep looping	

	pop	{r4-r10, lr}
	bx	lr

.section .data
.align
.globl player
player:
	.int	22 	// row
	.int	13 	// column
	.int	100 	// fuel
	.int	3 	// life
