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


/* 
	After this point, these functions will draw specific
	parts of the game.
*/

/*
render

This draws everything based on the game's state
*/
render:
	push	{r4}
	pop		{r4}
	bx		lr



// work in progress
.globl	drawRoad
	.equ	RIGHT, 864	// rightmost edge of the road
	.equ	LEFT, 352	// leftmost edge of the road
	.equ	CENTRE, 512	// center of road
				
				
	.equ	SPACE, 6	// the space between the white road marks
drawRoad:
	push	{r4-r10, lr}
	
	ldr	r5, =CENTRE	
	sub	r0, r5, #16	// center - 16 = leftmost edge of road mark
	mov	r1, #4444
	add	r2, r5, #16	// center + 16 = rightmost edge of road mark
	add	r3, r1, #32	// the bottom-most edge of the tile
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


.globl	drawTiles
/*
drawTile
Draws specific tiles (32 x 32)

r0 - tile address
r1 - x coordinate
r2 - y coordinate
*/
drawTile:
	push	{r4, lr}
	mov	r4, r0		// move address (r0) to arg 4
	mov	r0, r1		// move	x coordinate (r1) to arg 0
	mov	r1, r2		// move y coordinate (r2) to arg 1
	add	r2, r0, #32	// x + 32 = x final
	add	r3, r1, #32	// y + 32 = y final
	bl	CreateImage

	pop	{r4, lr}
	bx	lr


.globl	drawFlags
	.equ	START, #1
drawFlags:
	push	{r4, lr}
	
	cmp	r0, #START	
	
	ldr	r0, =327	// initial x
	ldr	r1, =478	// initial y
	ldr	r2, =367	// final x
	ldr	r3, =627	// final y
	ldreq	r4, =leftstart_pic
	ldrne	r4, =leftquit_pic
	bl	CreateImage
	ldr	r0, =671	// initial x
	ldr	r1, =480	// initial y
	ldr	r2, =711	// final x
	ldr	r3, =629	// final y
	ldreq	r4, =rightstart_pic
	ldrne	r4, =rightquit_pic
	bl	CreateImage

	pop	{r4, lr}
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

