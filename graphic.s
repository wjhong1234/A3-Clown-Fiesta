.section .text
.globl	CreateImage
	// the offsets for the image structure
	.equ	x_start, 4		// the offset to retrieve initial x
	.equ	x_final, 8		// the offset to retrieve final x
	.equ	y_start, 12		// the offset to retrieve initial y
	.equ	y_final, 16		// the offset to retrieve final y

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
/*
	ldr	r0, =image		// load the base address of the image struct
	ldr	r1, =0xFD33		// color (or whatever)
	str	r1, [r0]		// store in the base address
	ldr	r1, =400		// initial x
	str	r1, [r0, x_start] 	// store in base + x_start_offset
	ldr	r1, =500		// final x
	str	r1, [r0, x_final]	// store in base + x_final_offset
	ldr	r1, =400		// initial y
	str	r1, [r0, y_start]	// store in base + y_start_offset
	ldr	r1, =500		// final y
	str	r1, [r0, y_final]	// store in base + y_final_offset
*/	
/*
	ldr	r0, =400
	ldr	r1, =400
	ldr	r2, =800
	ldr	r3, =500
	ldr	r4, =0xFD33
	bl	testDrawRectangle
*/	


/* Draw Rectangle
 * r0 - initial x
 * r1 - initial y
 * r2 - final x
 * r3 - final y
 * r4 - color/address (stack)
 */
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


/* Draw the character 'B' to (0,0)
 */
DrawCharB:
	push	{r4-r8, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8

	ldr		chAdr,	=font		// load the address of the font map
	mov		r0,		#'B'		// load the character into r0
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

	mov		py,		#0			// init the Y coordinate (pixel coordinate)

charLoop$:
	mov		px,		#0			// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov		r0,		px
	mov		r1,		py
	mov		r2,		#0xF800		// red
	bl		DrawPixel			// draw red pixel at (px, py)

noPixel$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py,		#1			// increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r8, pc}
 
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

