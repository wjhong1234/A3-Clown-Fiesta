.section .text
.globl	CreateImage

/* Create Image
 * provided the size of the image and the
 * address of the image, it will draw the image.
 *
 * r0 - beginning of image on x axis
 * r1 - beginning of image on y axis
 * r2 - end of image on x axis
 * r3 - end of image on y axis
 */

CreateImage:
	push	{r4-r10, lr}

	x_start .req r4
	y_start .req r5
	x_final .req r6
	y_final .req r7
	x .req r8
	y .req r9
	color .req r10
	
	mov	color,	r4
	mov	x_start, r0
	mov	y_start, r1
	mov	x_final, r2
	mov	y_final, r3
	mov	x, x_start
	mov	y, y_start	

DrawLoop:
	mov	r0, x 
	mov	r1, y
	ldrh	r2, [color], #2		// load the color of the image and increment the address to be loaded
	bl	DrawPixel
	
	cmp	x, x_final		// once reached desired x coordinate
	addeq	y, #1			// move downward
	moveq	x, x_start		// and restart at the beginning	
	addne	x, #1			// otherwise, continue rightward
	cmp	y, y_final		// check if reached the desired y coordinate
	ble	DrawLoop		// if not, keep looping

	pop 	{r4-r10, lr}
	bx	lr

/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr
	.unreq	offset
/* Draw a character to (x,y)
character: r0
colour: r1
x-coord: r2
y-coord: r3
 */
.globl DrawChar
DrawChar:
	push	{r4-r10, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	row	.req	r7
	mask	.req	r8

	mov	r9, r0
	ldr	chAdr, =font		// load the address of the font map
	add	chAdr, r9, lsl #4	// char address = font base + (char * 16)
	mov	py, r3			// init the Y coordinate (pixel coordinate)
	mov	r9, r2			// save X coordinate at register 9
	mov	r10, r1			// save colour at register 10

charLoop$:
	mov	px, r9			// init the X coordinate

	mov	mask, #0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row, [chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst	row, mask		// test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	mov	r2, r10			// red
	bl	DrawPixel		// draw red pixel at (px, py)

noPixel$:
	add	px, #1			// increment x coordinate by 1
	lsl	mask, #1		// shift bitmask left by 1

	tst	mask, #0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1			// increment y coordinate by 1

	tst	chAdr,	#0xF
	bne	charLoop$		// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop	{r4-r10, lr}
	bx	lr

.globl	drawTile
/*
drawTile
Draws specific tiles (32 x 32)

r0 - x coordinate
r1 - y coordinate
r2 - tile address
*/
	
drawTile:
	push	{r4, lr}
	mov	r4, r2			// move address (r0) to arg 4
	add	r2, r0, #31		// x + 32 = x final
	add	r3, r1, #31		// y + 32 = y final
	bl	CreateImage

	pop	{r4, lr}
	bx	lr

/* 
	After this point, these functions will draw specific
	parts of the game.
*/
.globl	initDraw
/*
Draws initial images of the game.
*/
initDraw:
	push	{r4-r10, lr}
	bl	drawMap
	bl	drawBanner
	bl	drawPlayer
	bl	initPrint
	bl	writeFuel
	bl	writeLife
	//bl	pressAPrint
	pop	{r4-r10, lr}
	bx	lr

.globl	render
/*
Redraws the game as the game updates.
*/
render:
	push	{r4-r10, lr}
	ldr	r0, =status		// check if the player has lost or won
	ldr	r1, [r0]
	subs	r1, #1	
	bmi	renderNormal		// If the player hasn't won or lost, render normally
	blne	drawWin			// otherwise draw the win or lose menu
	bleq	drawLose
	
	bl	promptPrint
	bl	keepPrompting
	b	renderEnd
	/*
	ne - one	(2 - 1) win
	eq - zero	(1 - 1) lose
	mi - negative	(0 - 1) normal state
	*/
renderNormal:
	bl	drawFace
	bl	clearAllNums
	bl	writeFuel
	bl	writeLife
	bl	drawNewMap
	bl	drawSpawn
	bl	drawPlayer

	ldr	r0, =play		// check if the player has pressed A
	ldr	r1, [r0]
	cmp	r1, #0			// if the player hasn't pressed A, prompt for it
	bleq	pressAPrint
renderEnd:
	pop	{r4-r10, lr}
	bx	lr
	
	
	COL	.req	r4
	ROW	.req	r5
	.equ	CENTER, 12
drawNewMap:
	push	{r4-r10, lr}
	
	mov	COL, #CENTER		// begins loop
	mov	ROW, #0
	
drawNewMapLoop:
	mov	r0, COL			// retrieve x and y coordinates of each tile
	mov	r1, ROW 			
	bl	getTileRef
	ldr	r1, [r0, #16]
	cmp	r1, #1			// if the tile has changed, then redraw it
	bne	drawNewMapInc
	mov	r1, #0
	str	r1, [r0, #16]		// remove flag for change
	
	mov	r3, r0
	ldr	r0, [r3, #4]		// x
	ldr	r1, [r3, #8]		// y
	ldr	r2, [r3, #12]
	cmp	r2, #1			// check if the tile is a special road tile
	ldreq	r2, =lane_tile
	ldrne	r2, =road_tile
	bl	drawTile
drawNewMapInc:
	add	ROW, #1			// continue down until reach the end
	cmp	ROW, #22
	blt	drawNewMapLoop
	
	pop	{r4-r10, lr}
	bx	lr
	.unreq	COL
	.unreq	ROW


	ROW .req r4
	COL .req r5
	ADRS .req r6
	.equ	ROAD, 0
	.equ	CENTER, 12
drawMap:
	push	{r4-r10, lr}
	mov	ROW, #0
	mov	COL, #0

drawMapLoop:
	mov	r0, COL
	mov	r1, ROW
	bl	getTileRef		// check if tile is a side or a road
	mov	ADRS, r0
	ldr	r2, [ADRS]		// load the tile type
	ldr	r1, [ADRS, #12]		// load to check if it's a lane tile
	cmp	r1, #0			// check if it's a lane tile
	ldrne	r3, =lane_tile		// if it is, branch away to draw lane tile
	bne	drawCont
	cmp	r2, #ROAD		// else, check if it's a road or side tile
	ldreq	r3, =road_tile
	ldrne	r3, =grass_tile

drawCont:
	ldr	r0, [ADRS, #4]		// retrieve x
	ldr	r1, [ADRS, #8]		// retrieve y
	mov	r2, r3			// move address of image
	bl	drawTile
			
	add	COL, #1			// increase the column
	cmp	COL, #25		// check if reached rightmost column
	movge	COL, #0			// if so, return to beginning
	addge	ROW, #1			// and go to next row
	cmp	ROW, #21		// check if reached bottom-most row
	ble	drawMapLoop		// if not, keep looping
	
	pop	{r4-r10, lr}
	bx	lr
	.unreq	ROW
	.unreq	COL
	.unreq	ADRS

	.equ	MAX_CYCLE, 5
	ADRS	.req	r0
	CYCLES	.req	r1
/*
drawFace
Draws Trump's faces.
0 - normal, 1 - collision, 2 - fuel
*/
drawFace:
	push	{r4-r10, lr}	
	
	ldr	ADRS, =faceState	// Retrieves the current state of Trump
	ldr	r1, [ADRS]	
	subs	r1, #1			// check the status of face
	bmi	revertFace		// normal (0) - 1 = negative flag (mi) -> then go back to normal face
	ldreq	r4, =face_c		// collision (1) - 1 = zero flag (eq)
	ldrne	r4, =face_f		// fuel (2) - 1 = positive flag (ne)
	b	createFace		// otherwise, change the face
	
revertFace:				// before reverting face to the regular one, we wait a set amount of cycles
	ldr	ADRS, =faceTimer	// load the faceTimer to retrieve the amount of cycles already passed
	ldr	CYCLES, [ADRS]	
	add	CYCLES, #1		// increment the amount of cycles
	str	CYCLES, [ADRS]		// Store the new value of cycles
	cmp	CYCLES, MAX_CYCLE	// Check if the amount of cycles passed equals the max amount of cycles wanted
	blt	drawFaceEnd		// If it is less than the max, then don't redraw the face
	movge	CYCLES, #0		// If they are equal, reset the timer
	ldrge	r4, =face_n		// If they are equal, revert face to normal
	
createFace:
	mov	r0, #54			// initial x
	ldr	r1, =568		// initial y
	ldr	r2, =174		// final x
	ldr	r3, =755		// final y
	bl	CreateImage
	
drawFaceEnd:
	pop	{r4-r10, lr}
	bx	lr
	.unreq	CYCLES
	.unreq	ADRS

/*
Draws the banner on the left side of the game screen.
*/
drawBanner:
	push	{r4-r10, lr}	
	mov	r0, #7			// initial x
	mov	r1, #64			// initial y
	ldr	r2, =223		// final x
	ldr	r3, =767		// final y
	ldr	r4, =banner
	bl	CreateImage
	pop	{r4-r10, lr}
	bx	lr
	
	.equ	BERNIE, 1
	
	SPAWNADRS	.req r4
	COUNT		.req r5
	OFFSET		.req r6
	TILEADRS	.req r7
drawSpawn:
	push	{r4-r10, lr}
	mov	COUNT, #0			// counter
	ldr	r8, =spawnArray			// loading base address
drawSpawnLoop:
	lsl	OFFSET, COUNT, #2		// X * 4
	sub	OFFSET, COUNT			// X * (4 - 1) = X * 3
	
	add	SPAWNADRS, r8, OFFSET, LSL#2	// retrieving address of SPAWN X
	
	ldr	r0, [SPAWNADRS]			// load X coord of spawn
	ldr	r1, [SPAWNADRS, #4]		// load Y coord of spawn
	sub	r1, #1				// ROW - 1 to get previous coord of spawn
	bl	getTileRef			// get reference for Tile(X,Y)
	mov	r3, r0
	ldr	r0, [r3, #12]			// checks whether the tile should be special or not
	cmp	r0, #1
	ldreq	r2, =lane_tile			// if it is, print the special tile
	ldrne	r2, =road_tile			// else, print the road tile
	ldr	r0, [r3, #4]			// load previous X pixel of spawn
	ldr	r1, [r3, #8]			// load previous Y pixel of spawn
	bl	drawTile			// clear previous location of spawn
	
	ldr	r0, [SPAWNADRS]			// load coords of spawn
	ldr	r1, [SPAWNADRS, #4]
	bl	getTileRef
	mov	TILEADRS, r0			
	ldr	r0, [SPAWNADRS, #8]
	cmp	r0, #BERNIE			// check if the item is bernie or toupee
	ldreq	r2, =bernie
	ldrne	r2, =toupee
	ldr	r0, [TILEADRS, #4]
	ldr	r1, [TILEADRS, #8]
	bl	drawTile			// draw new location of spawn

	add	COUNT, #1			// loops through for remaining spawn
	ldr	r3, =itemCount
	ldr	r2, [r3]
	cmp	COUNT, r2
	blt	drawSpawnLoop
	
	pop	{r4-r10, lr}
	bx	lr
	.unreq	SPAWNADRS
	.unreq	COUNT
	.unreq	OFFSET
	.unreq	TILEADRS

	DIFFERENCE	.req r6
	PLAYERADRS	.req r4
	TILEADRS	.req r5
	.equ	RIGHT, 19
	.equ	LEFT, 4
drawPlayer:
	push	{r4-r10, lr}
	ldr	PLAYERADRS, =player		// loading base address
	
	ldr	r1, =oneDirection		// get address of player movement
	ldr	r0, [r1]			// load player movement
	cmp	r0, #2				// check if player didn't move
	bne	getOldPos			// if the player moved, then erase the doppleganger

	ldr	r1, =faceState			// if the player didn't move, check if there was a collision
	ldr	r0, [r1]
	cmp	r0, #1				
	bne	drawPlayerCont			// if there was no collision, then do not redraw face

getOldPos:
	ldr	r2, =previousPos		// retrieve previous position
	ldr	r0, [r2]			// retrieve column
	ldr	r1, [r2, #4]			// retrieve row

	bl	getTileRef			// retrieve the tile reference
	ldr	r1, [r0]			// retrieve tile type
	cmp	r1, #0				// check if the tile is side or road
	ldrne	r2, =grass_tile			// if side, then draw a grass tile
	bne	eraseOld			
	ldr	r2, [r0, #12]			// if road, then check if this tile is special
	cmp	r2, #0				
	ldreq	r2, =road_tile			// if not special, draw a road tile
	ldrne	r2, =lane_tile			// if special, then draw a lane tile
eraseOld:
	mov	r7, r0				// move tile reference
	ldr	r0, [r7, #4]			// retrieve x coordinate
	ldr	r1, [r7, #8]			// retrieve y coordinate
	bl	drawTile

drawPlayerCont:
	ldr	r0, [PLAYERADRS]		// col
	ldr	r1, [PLAYERADRS, #4]		// row
	bl	getTileRef
	mov	TILEADRS, r0
	
	ldr	r0, [TILEADRS, #4]		// x
	ldr	r1, [TILEADRS, #8]		// y
	ldr	r2, =player_img
	bl	drawTile
	
	pop	{r4-r10, lr}
	bx	lr
	.unreq	PLAYERADRS
	.unreq	TILEADRS

.globl drawFlags
/*
Draws the flags on the main menu.
*/
	.equ	START, 1
drawFlags:
	push	{r4-r10, lr}
	
	cmp	r0, #START	
	
	ldr	r0, =327	// initial x
	ldr	r1, =478	// initial y
	ldr	r2, =367	// final x
	ldr	r3, =627	// final y
	ldreq	r4, =leftstart_pic
	ldreq	r5, =rightstart_pic
	ldrne	r4, =leftquit_pic
	ldrne	r5, =rightquit_pic
	bl	CreateImage
	ldr	r0, =671	// initial x
	ldr	r1, =480	// initial y
	ldr	r2, =711	// final x
	ldr	r3, =629	// final y
	mov	r4, r5
	bl	CreateImage

	pop	{r4-r10, lr}
	bx	lr

.globl drawLose
/*
Draws the lose screen.
*/
drawLose:
	push	{r4, lr}	
	
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldr	r4, =lose_pic
	bl	CreateImage
	
	pop	{r4, lr}
	bx	lr
	
.globl drawWin
/*
Draws the win screen.
*/
drawWin:
	push	{r4, lr}	
	
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldr	r4, =win_pic
	bl	CreateImage
	
	pop	{r4, lr}
	bx	lr

.globl	drawMenu
drawMenu:
	push	{r4, lr}
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =767	// final y
	ldr	r4, =menu_pic
	bl	CreateImage
	
	pop	{r4, lr}
	bx	lr

.globl	clearScreen
/*
Clears the screen using one pixel.
*/
clearScreen:
	push	{r4-r10, lr}
	
	ldr	r4, =1023
	ldr	r5, =767
	mov	x, #0
	mov	y, #0	

clearLoop:
	mov	r0, x
	mov	r1, y
	ldrh	r2, =0x0
	bl	DrawPixel

	cmp	x, r4		// once reached desired x coordinate
	addeq	y, #1		// move downward
	moveq	x, #0		// and restart at the beginning	
	addne	x, #1		// otherwise, continue rightward
	cmp	y, r5		// check if reached the desired y coordinate
	ble	clearLoop	// if not, keep looping

	pop 	{r4-r10, lr}
	bx	lr

.section .data
font:	.incbin "font.bin"
.align
faceTimer:
	.int	0		// counts the amount of cycles that the face is allowed to stay
