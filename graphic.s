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

	mov		py,	r3		// init the Y coordinate (pixel coordinate)
	mov		r9,	r2		// save X coordinate at register 9
	mov		r10, 	r1		// save colour at register 10
	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

charLoop$:
	mov		px,	r9			// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov		r0,		px
	mov		r1,		py
	mov		r2,		r10		// red
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

	pop		{r4-r10, pc}

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

	mov		r9,	r0
	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r9, lsl #4	// char address = font base + (char * 16)
	mov		py,	r3		// init the Y coordinate (pixel coordinate)
	mov		r9,	r2		// save X coordinate at register 9
	mov		r10, 	r1		// save colour at register 10

charLoop$:
	mov		px,	r9			// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov		r0,		px
	mov		r1,		py
	mov		r2,		r10		// red
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

	pop		{r4-r10, pc}


.globl	writeLife
	.equ	LIFE_X, 0
	.equ	LIFE_Y, 0
	INPUT .req r4
	LIFE .req r5
writeLife:
	push	{r4-r10, lr}

	mov	ONE, #48	// initialize one's place to decimal number of '0'
	
getLife:
	cmp	INPUT, #1	
	subge	INPUT, #1		// if the number >= 0, then		
	addge	LIFE, #1		// add 1 to ones
	bge	getLife		// keep looping until number < 1

	mov	r0, LIFE
	ldr	r1, =0xFFFF	// arg 2: colour of string
	mov	r2, =LIFE_X	// arg 3: x-coord
	ldr	r3, =LIFE_Y	// arg 4: y-coord
	
	bl	DrawChar	// prints one char

	pop	{r4-r10, lr}
	bx	lr

.globl	writeFuel
/*
writeFuel
Writes numbers on screen
r0 - number
*/
	.equ	FUEL_X, 0
	.equ	FUEL_Y, 0
	NUM .req r4
	HUND .req r5
	TEN .req r6
	ONE .req r7
	
writeFuel:
	push	{r4-r10, lr}
	
	mov	NUM, r0

	mov	HUND, #48	// initialize hundred's place to decimal number of '0'
	mov	TEN, #48	// initialize ten's place to decimal number of '0'
	mov	ONE, #48	// initialize one's place to decimal number of '0'
	
	ldr	r0, =1000
	cmp	NUM, r0		// if the number is more than 999 (x >= 1000) 
	addge	HUND, #9	// then set the hundreds, tens, and ones
	addge	TEN, #9		// to nine, and branch to print
	addge	ONE, #9
	bge	printNum

getHundred:
	cmp	NUM, #100	
	subge	NUM, #100	// if the number >= 100, then		
	addge	HUND, #1	// add 1 to hundreds
	bge	getHundred	// keep looping until number < 100

getTen:
	cmp	NUM, #10	
	subge	NUM, #10	// if the number >= 10, then		
	addge	TEN, #1		// add 1 to tens
	bge	getTen		// keep looping until number < 10

getOne:
	cmp	NUM, #1	
	subge	NUM, #1		// if the number >= 0, then		
	addge	ONE, #1		// add 1 to ones
	bge	getOne		// keep looping until number < 1
	
printNum:
	mov	r8, #2		// if looking for fuel numbers
	ldr	r9, =FUEL_X	// initialize x-coordinate

printNumLoop:
	ldr	r1, =0xFFFF	// arg 2: colour of string
	mov	r2, r9		// arg 3: x-coord
	ldr	r3, =FUEL_Y	// arg 4: y-coord

	subs	r8, #1		// flag
	movne	r0, HUND	// 2 - 1 = positive flag (ne)
	moveq	r0, TEN		// 1 - 1 = zero flag (eq)
	movmi	r0, ONE		// 0 - 1 = negative flag (mi)
	
	bl	DrawChar	// prints one char
				
	add	r9, #8		// move to next one or something

	cmp	r8, #-1
	beq	printNumEnd
	b	printNumLoop

printNumEnd:
	pop	{r4-r10, lr}
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
fuel: .ascii "FUEL:"	// 5
life: .ascii "LIVES:"	// 6
tuto1: .ascii "GET TRUMP TO WHITE HOUSE"	// 24
tuto2: .ascii "AVOID BERNIE, COLLECT TOUPEES"	// 29
pressA: .ascii "PRESS A TO START"	// 16
dsclm: .ascii "We are not Trump supporters."	// 28
contPrompt: .ascii "PRESS ANY BUTTON TO CONTINUE"	// 28
instr1: .ascii "SELECT: MAIN MENU"	// 17
instr2: .ascii "START: RESTART"	// 14
