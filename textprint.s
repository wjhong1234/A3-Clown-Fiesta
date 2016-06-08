.section .text
.globl	tutorialPrint

tutorialPrint:
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
	ldr	r2, =0
	ldr	r3, =0
	ldr	r4, =0xFFFF
	bl	printText

	ldr	r0, =instr2
	mov	r1, #14
	ldr	r2, =0
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
	ldr	r2, =540
	ldr	r3, =384
	ldr	r4, =0xFFFF
	bl	printText

	pop 	{r4-r10, lr}
	bx	lr

.globl dsclmPrint

dsclmPrint:
	push	{r4-r10, lr}

	ldr	r0, =dsclm
	mov	r1, #28
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
