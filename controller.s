.section .text
.globl getInput
.globl Init_GPIO

	.equ	BASE_ADRS, 0x3f200000
	.equ	LATCH, 9
	.equ	DATA, 10
	.equ	CLOCK, 11
	.equ	UN_PRESS, 4095

	DONE_FLAG .req r10
	SAVED_BUTTONS .req r9	

getInput:
	push	{r4-r10, lr}
//	mov	SAVED_BUTTONS, r5	// save the current state of the buttons
pressLoop:	
	bl	Read_SNES		// Begin reading controller input

	mov	r5, r0			// Store 'buttons' array
	bl	Check_Buttons		// Check for flags
	mov	r8, r1			// sets flag for whether any buttons have been pressed
//	cmp	SAVED_BUTTONS, r5	// checks whether buttons have changed
//	beq	pressLoop		// if not, keep looping
	
	cmp	r8, #0			// checks whether anything has been pressed
//	moveq	SAVED_BUTTONS, r5	// if not, preserves unpressed state
	beq	pressLoop		// it also keeps looping

	lsr	r5, #5			// shift the unneeded four bits out (13-16)
	mov	r0, r5			// returns buttons pressed to main
	pop	{r4-r10, lr}
	bx 	lr

Check_Buttons:
	push	{r4-r10, lr}

	mov	r3, r0			// checks if no buttons have been pressed
	lsr	r3, #5			// remove unused right bits
	ldr	r2, =UN_PRESS		// loads 0b111111111111, 0b1^(12)
	cmp	r3, r2			// checks if any buttons have been pressed 
	moveq	r1, #0			// returns 0 if none have been pressed
	movne	r1, #1			// returns 1 otherwise

	pop	{r4-r10, lr}
	bx 	lr

Init_GPIO:
	push	{r4-r10, lr}
	
	PIN .req r4
	FUNC .req r1
	ADRS .req r3
	REG .req r5
	
	ldr	ADRS, =BASE_ADRS	// retrieve base address
	mov	PIN, r0
	mov	REG, #0			// the register number

setPin:
	cmp	PIN, #9			// check if pin number is isolated to one's column
	subgt	PIN, #10		// if not, subtract by 10
	addgt	REG, #1			// increase the register number
	bgt	setPin			// continue to loop until left with one's column

	add	ADRS, REG, lsl #2	// retrieve address (address + (register * 4))
	add	PIN, PIN, PIN, lsl #1	// PIN*3 = (PIN+(PINx2))
	lsl	FUNC, PIN		// align function to desired bits
	
	ldr	r6, [ADRS]		// retrieve value from address
	mov	r7, #7			// create the bit mask
	lsl	r7, PIN			// align the mask	
	bic	r6, r7			// clear the bits
	orr	r6, FUNC		// place the function
	str	r6, [ADRS]		// store changed value		
	
	.unreq PIN
	.unreq FUNC
	.unreq ADRS
	.unreq REG

	pop	{r4-r10, lr}
	bx	lr

// takes an integer parameter
// PARAM = 0, clear latch
// PARAM = 1, set latch
Write_Latch:
	PIN .req r0
	PARAM .req r1
	
	push	{r4-r10, lr}

	mov	PIN, #LATCH		// LATCH
	ldr	r2, =BASE_ADRS		// BASE GPIO REGISTER
	mov	r3, #1	
	lsl	r3, PIN			// ALIGN BIT FOR PIN 9
	teq	PARAM, #0
	streq	r3, [r2, #40]		// GPCLEAR0
	strne	r3, [r2, #28]		// GPSET0

	pop	{r4-r10, lr}
	bx	lr

Write_Clock:
	push	{r4-r10, lr}

	mov	PIN, #CLOCK		// CLOCK
	ldr	r2, =BASE_ADRS		// BASE GPIO REGISTER
	mov	r3, #1	
	lsl	r3, PIN			// ALIGN BIT FOR PIN 10
	teq	PARAM, #0
	streq	r3, [r2, #40]		// GPCLEAR0
	strne	r3, [r2, #28]		// GPSET0

	pop	{r4-r10, lr}
	bx	lr

// in this function, we are reading the line of data from SNES
// read in the form of a 16 bit binary number
// each bit gives information of whether or not a button is pressed
// last four bits are always 1
// the buttons are being read from left to right
	RETURN .req r2
Read_Data:
	push	{r4-r10, lr}

	mov	PIN, #DATA		// DATA
	ldr	r2, =BASE_ADRS		// BASE GPIO REGISTER
	ldr	r1, [r2, #52]		// GPLEV0

	// r3 in this case will hold the location of the bit we want to examine
	mov	r3, #1
	lsl	r3, PIN			// ALIGN PIN 10 BIT
	and	r1, r3			// MASK EVERYTHING ELSE
	teq	r1, #0
	moveq	RETURN, #0		// RETURN 0
	movne	RETURN, #1		// RETURN 1

	pop	{r4-r10, lr}
	bx	lr

	.unreq PIN
	.unreq PARAM

Wait:
	push	{r4-r10, lr}
	ldr 	r0, =0x3f003004 	// address of CLOCK
	ldr 	r2, [r0] 		// read CLOCK
	add	r1, r2 			// add desired wait time

waitLoop:
	ldr 	r2, [r0]
	cmp	r1, r2 			// stop when CLOCK = r1
	bhi 	waitLoop		// else keep waiting
	
	pop	{r4-r10, lr}
	bx	lr

Read_SNES:
	push	{r4-r10, lr}
	BUTTONS .req r4
	ARG	.req r1	
	COUNTER .req r5
	
	mov	BUTTONS, #0
	mov	ARG, #1
	bl	Write_Clock		// set clock
	mov	ARG, #1
	bl	Write_Latch		// set latch
	mov	ARG, #12
	bl	Wait			// wait for 12 microseconds
	mov	ARG, #0
	bl	Write_Latch		// clear latch
	mov	COUNTER, #0		// clear counter before pulseloop starts
	
pulseLoop:
	mov	ARG, #6
	bl	Wait			// wait for 6 microseconds
	mov	ARG, #0
	bl 	Write_Clock		// clear clock
	mov	ARG, #6
	bl	Wait			// wait for 6 microseconds
	bl	Read_Data		// read buttons[i] from SNES controller
	
	mov	r6, RETURN
	orr	BUTTONS, r6		// for each button that has been 'pressed'
	lsl	BUTTONS, #1		// we mark that it has been pressed (buttons[i] = b)
	
	mov	ARG, #1			// set clock
	bl	Write_Clock	
	add	COUNTER, #1		// increment counter
	cmp	COUNTER, #16		// if haven't read all buttons
	blt	pulseLoop		// keep going through the loop
	mov	r0, BUTTONS
	
	.unreq	ARG
	.unreq	COUNTER
	.unreq	RETURN

	pop	{r4-r10, lr}
	bx	lr

.globl checkButton
/*
Checks if button is being pressed
r0 - buttons pressed
r1 - button wanted
*/
checkButton:
	orr	r2, r0, r1	// let's test this
	cmp	r1, r2		// check to see if it matches the desired button
	moveq	r0, #1		// if it matches, return true
	movne	r0, #0		// if not, return false
	bx	lr

