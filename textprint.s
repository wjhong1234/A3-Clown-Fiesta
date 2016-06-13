.section .text
.globl	initPrint

initPrint:
	push	{r4-r10, lr}

	ldr	r0, =fuel
	mov	r1, #5
	ldr	r2, =520
	ldr	r3, =40
	ldr	r4, =0xFFFF
	bl	printText

	ldr	r0, =life
	mov	r1, #6
	ldr	r2, =650
	ldr	r3, =40
	ldr	r4, =0xFFFF
	bl	printText

	ldr	r0, =tuto1
	mov	r1, #29
	ldr	r2, =475
	ldr	r3, =0
	ldr	r4, =0xFFFF
	bl	printText

	ldr	r0, =tuto2
	mov	r1, #29
	ldr	r2, =475
	ldr	r3, =15
	ldr	r4, =0xFFFF
	bl	printText

	ldr	r0, =instr1
	mov	r1, #17
	ldr	r2, =7
	ldr	r3, =0
	ldr	r4, =0xFFFF
	bl	printText

	ldr	r0, =instr2
	mov	r1, #14
	ldr	r2, =7
	ldr	r3, =15
	ldr	r4, =0xFFFF
	bl	printText

	pop 	{r4-r10, lr}
	bx	lr

.globl pressAPrint
pressAPrint:
	push	{r4-r10, lr}

	ldr	r0, =pressA
	mov	r1, #16
	ldr	r2, =550
	ldr	r3, =400
	ldr	r4, =0xFFFF
	bl	printText

	pop 	{r4-r10, lr}
	bx	lr

	.equ	ROW, 10
	COL	.req r4
	ADRS	.req r5

.globl pressAClear
pressAClear:
	push	{r4-r10, lr}

	mov	COL, #9
pressAClearLoop:
	mov	r0, COL
	mov	r1, #ROW
	bl	getTileRef
	mov	ADRS, r0
	ldr	r0, [ADRS, #4]
	ldr	r1, [ADRS, #8]
	ldr	r2, =road_tile
	bl	drawTile
	add	COL, #1
	cmp	COL, #15
	ble	pressAClearLoop

	pop 	{r4-r10, lr}
	bx	lr

.globl dsclmPrint
dsclmPrint:
	push	{r4-r10, lr}

	ldr	r0, =dsclm
	mov	r1, #40
	ldr	r2, =10
	ldr	r3, =750
	ldr	r4, =0xF9A9
	bl	printText

	pop 	{r4-r10, lr}
	bx	lr

.globl promptPrint
promptPrint:
	push	{r4-r10, lr}

	ldr	r0, =prompt
	mov	r1, #28
	ldr	r2, =372
	ldr	r3, =0
	ldr	r4, =0xF9A9
	bl	printText

	pop 	{r4-r10, lr}
	bx	lr

.globl	clearAllNums
clearAllNums:
	push	{r4-r10, lr}
	//clearsFuel
	ldr	r0, =570		// initialX
	ldr	r1, =40			// initialY
	add	r2, r0, #29		// finalX
	add	r3, r1, #11		// finalY
	ldr	r4, =clearNums_img
	bl	CreateImage
	
	//clearsLives
	ldr	r0, =710
	ldr	r1, =40
	add	r2, r0, #29
	add	r3, r1, #11
	ldr	r4, =clearNums_img
	bl CreateImage
	
	pop	{r4-r10, lr}
	bx	lr

.globl	writeLife
	.equ	LIFE_X, 710
	.equ	LIFE_Y, 40	
	LIFE .req r5
writeLife:
	push	{r4-r10, lr}

	ldr	r0, =player
	ldr	r1, [r0, #12]// retrieve life

	add	LIFE, r1, #48

	mov	r0, LIFE
	ldr	r1, =0xFFFF	// arg 2: colour of string
	ldr	r2, =LIFE_X	// arg 3: x-coord
	ldr	r3, =LIFE_Y	// arg 4: y-coord
	
	bl	DrawChar	// prints one char

	pop	{r4-r10, lr}
	bx	lr

.globl	writeFuel
/*
Writes the fuel.
*/
	.equ	FUEL_X, 570
	.equ	FUEL_Y, 40
	NUM .req r4
	HUND .req r5
	TEN .req r6
	ONE .req r7
writeFuel:
	push	{r4-r10, lr}
	
	ldr	r0, =player
	ldr	NUM, [r0, #8]// retrieve fuel

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

.globl	printText
/*
r0 - address
r1 - length
r2 - x coord
r3 - y coord
r4 - color
*/
	COLOR .req r8
	Y_COORD	.req r7
	X_COORD .req r6
	LENGTH .req r4
	ADRS .req r5
printText:
	push	{r4-r10, lr}
	mov	ADRS, r0
	mov	X_COORD, r2
	mov	Y_COORD, r3
	mov	COLOR, r4
	mov	LENGTH, r1
textLoop:
	ldrb	r0, [ADRS], #1
	mov	r1, COLOR
	mov	r2, X_COORD
	mov	r3, Y_COORD
	bl	DrawChar
	add	X_COORD, #10
	sub	LENGTH, #1
	cmp	LENGTH, #0
	bgt	textLoop

	pop	{r4-r10, lr}
	bx	lr
.section .data

.align 4

.globl fuel
fuel: .ascii "FUEL:"	// 5
.globl life
life: .ascii "LIVES:"	// 6
.globl tuto1
tuto1: .ascii "GET TRUMP TO THE WHITE HOUSE!"	// 29
.globl tuto2
tuto2: .ascii "AVOID BERNIE, COLLECT TOUPEES"	// 29
.globl instr1
instr1: .ascii "SELECT: MAIN MENU"	// 17
.globl instr2
instr2: .ascii "START: RESTART"	// 14
.globl pressA
pressA: .ascii "PRESS A TO START"	// 16
.globl dsclm
dsclm: .ascii "DISCLAIMER: WE ARE NOT TRUMP SUPPORTERS"	// 40
.globl prompt
prompt: .ascii "PRESS ANY BUTTON TO CONTINUE"	// 28
