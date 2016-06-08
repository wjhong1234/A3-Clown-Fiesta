.section .text
.globl	tutorialPrint

tutorialPrint:
	push	{r4-r10, lr}

	mov	r4, #5
	ldr	r5, =fuel
	ldr	r6, =520
fuelLoop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =50
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	fuelLoop

	mov	r4, #6
	ldr	r5, =life
	ldr	r6, =650
lifeLoop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =50
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	lifeLoop

	mov	r4, #29
	ldr	r5, =tuto1
	ldr	r6, =475
tuto1Loop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =0
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	tuto1Loop

	mov	r4, #29
	ldr	r5, =tuto2
	ldr	r6, =475
tuto2Loop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =15
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	tuto2Loop

	mov	r4, #17
	ldr	r5, =instr1
	ldr	r6, =680
instr1Loop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =35
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	instr1Loop

	mov	r4, #14
	ldr	r5, =instr2
	ldr	r6, =420
instr2Loop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =35
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	instr2Loop

	pop 	{r4-r10, lr}
	bx	lr

.globl pressAPrint

pressAPrint:
	push	{r4-r10, lr}

	mov	r4, #16
	ldr	r5, =pressA
	ldr	r6, =540
pressALoop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xFFFF
	mov	r2, r6
	ldr	r3, =384
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	pressALoop

	pop 	{r4-r10, lr}
	bx	lr

.globl dsclmPrint

dsclmPrint:
	push	{r4-r10, lr}

	mov	r4, #28
	ldr	r5, =dsclm
	ldr	r6, =10
dsclmLoop:
	ldrb	r0, [r5], #1
	ldr	r1, =0xF9A9
	mov	r2, r6
	ldr	r3, =750
	bl	DrawChar
	add	r6, #10
	sub	r4, #1
	cmp	r4, #0
	bgt	dsclmLoop

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
dsclm: .ascii "We are not Trump supporters."	// 28
.globl prompt
prompt: .ascii "PRESS ANY BUTTON TO CONTINUE"	// 28
