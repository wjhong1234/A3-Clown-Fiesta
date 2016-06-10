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
 * stack? - the ascii representation of the image's colors
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
	ldrh	r2, [color], #2	// load the color of the image
				// and increment the address to be loaded
	bl	DrawPixel
	
	cmp	x, x_final	// once reached desired x coordinate
	addeq	y, #1		// move downward
	moveq	x, x_start	// and restart at the beginning	
	addne	x, #1		// otherwise, continue rightward
	cmp	y, y_final	// check if reached the desired y coordinate
	blt	DrawLoop	// if not, keep looping

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

	pop		{r4-r10, pc}


/* 
	After this point, these functions will draw specific
	parts of the game.
*/

.globl	initDraw
initDraw:
	push	{r4-r10, lr}
	bl	drawBanner
	bl	drawMap
	bl	initPrint
	pop	{r4-r10, lr}
	bx	lr


.globl	render
render:
	push	{r4-r10, lr}
	bl	drawFace
	bl	writeFuel
	bl	writeLife

	bl	drawCentre
//	bl	drawPainfulToImplementFlags
	bl	drawSpawn
	bl	drawPlayer

	pop	{r4-r10, lr}
	bx	lr

.globl	drawMap
	ROW .req r4
	COL .req r5
	ADRS .req r6
	.equ	ROAD, 0
	.equ	CENTER, 13
drawMap:
	push	{r4-r10, lr}
	mov	ROW, #0
	mov	COL, #0

drawMapLoop:
	mov	r0, COL
	mov	r1, ROW
	bl	getTileRef	// check if tile is a side or a road
	ldr	r1, [r0]	// load tile type	
	cmp	r1, #ROAD
	ldreq	r3, =road_tile	// draw road if road
	ldrne	r3, =grass_tile	// draw grass if grass

	cmp	COL, #CENTRE	// check if at centre
	lsleq	r1, ROW, #2	// offset of laneArray
	ldreq	r4, =laneArray	// retrieve lane array
	ldreq	r5, [r4, r1]	
	cmpeq	r5, #1		// check if it has a white flag
	ldreq	r3, =lane_tile	// if so, mark it as lane

	mov	ADRS, r0	// move address
	ldr	r0, [ADRS, #4]	// retrieve x
	ldr	r1, [ADRS, #8]	// retrieve y
	mov	r2, r3		// move address of image
	bl	drawTile
			
	add	COL, #1		// increase the column
	cmp	COL, #24	// check if reached rightmost column
	movge	COL, #0		// if so, return to beginning
	addge	ROW, #1		// and go to next row
	cmp	ROW, #21	// check if reached bottom-most row
	ble	drawMapLoop	// if not, keep looping
	
	pop	{r4-r10, lr}
	bx	lr

.globl	drawFace
/*
drawFace
Draws faces of DT.
r0 - state of Donald Trump
0 - normal, 1 - collision, 2 - fuel
*/
drawFace:
	push	{r4, lr}	
	
	subs	r0, #1		// check the status of face
	ldreq	r4, =face_c	// collision (1) - 1 = zero flag (eq)
	ldrne	r4, =face_f	// fuel (2) - 1 = positive flag (ne)
	ldrmi	r4, =face_n	// normal (0) - 1 = negative flag (mi)
	
	mov	r0, #47		// initial x
	ldr	r1, =568	// initial y
	ldr	r2, =167	// final x
	ldr	r3, =755	// final y
	bl	CreateImage
	
	pop	{r4, lr}
	bx	lr

drawBanner:
	push	{r4, lr}	
	mov	r0, #7		// initial x
	mov	r1, #64		// initial y
	ldr	r2, =223	// final x
	ldr	r3, =767	// final y
	ldr	r4, =banner
	bleq	CreateImage
	pop	{r4, lr}
	bx	lr

.globl	drawTiles
/*
drawTile
Draws specific tiles (32 x 32)

r0 - x coordinate
r1 - y coordinate
r2 - tile address
*/
	
drawTile:
	push	{r4, lr}
	mov	r4, r2		// move address (r0) to arg 4
	add	r2, r0, #32	// x + 32 = x final
	add	r3, r1, #32	// y + 32 = y final
	bl	CreateImage

	pop	{r4, lr}
	bx	lr

.globl	drawFlags
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

.globl	clearScreen

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
	blt	clearLoop	// if not, keep looping

	pop 	{r4-r10, lr}
	bx	lr

.section .data

.align 4
font:		.incbin	"font.bin"

// data structure of image
image:
	.int 0	// color/address of image
	.int 0	// initial x
	.int 0	// final x
	.int 0	// initial y
	.int 0	// final y


