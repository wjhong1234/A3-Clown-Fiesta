.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
	mov     sp, #0x8000
	bl	EnableJTAG
	bl	InitFrameBuffer

	ldr	r0, =dsclm2
	ldr	r1, =0
	ldr	r3, =152
	bl	DrawString
    
haltLoop$:
	b	haltLoop$

/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */

DrawPixel:
	push	{r4}


	offset .req r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop	{r4}
	bx	lr


/* Draw the character 'B' to (0,0)
 */
DrawString:
	push	{r4-r12, lr}

	//r0 is the string
	//r1 is x coord
	//r2 is y coord
	//r3 is length of string
	//r4 is colour of string

	count .req r3
	chAdr .req r4
	px .req r5
	py .req r6
	row .req r7
	mask .req r8
	char .req r9

	mov	r10, r0
	mov	r11, r1
	mov	py, r2			// init the Y coordinate (pixel coordinate)
	mov	r12, r3

	mov	count, #0		// counter
	
stringLoop$:
	ldr	chAdr, =font		// load the address of the font map
	ldrb	char, [r0], #1		// load the first character and increment

	//ldrb	char, [r10], #1
	add	chAdr, char, lsl #4	// char address = font base + (char * 16)

charLoop$:
	mov	px, r1
	//mov	px, r11			// init the X coordinate

	mov	mask, #0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row, [chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst	row, mask		// test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	ldr	r2, =0x181F		// colour
	bl	DrawPixel		// draw coloured pixel at (px, py)

noPixel$:
	add	px, #1			// increment x coordinate by 1
	lsl	mask, #1		// shift bitmask left by 1

	tst	mask, #0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1			// increment y coordinate by 1

	tst	chAdr, #0xF
	bne	charLoop$		// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	add	r3, #1			// increment counter
	cmp	r3, r12			// compare counter to length of string
	add	r11, #8			// adds space between characters
	blt	stringLoop$

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop {r4-r8, pc}

.section .data

.align 4
font: .incbin "font.bin"
fuel: .ascii "FUEL: "
life: .ascii "LIVES: "
pressA: .ascii "Press A to Start"
tuto1: .ascii "Drive Trump's Limo to the White House!"
tuto2: .ascii "Avoid Bernies, Collect Toupees"
dsclm1: .ascii "We are not Trump supporters." 
dsclm2: .ascii "The views expressed in this game are intended to parody Trump's statements and political views, and do not reflect our own."
