/*
---IMPORTANT---
About this file:
	LOOP: Limits FPS to approximately 5 frames per second.
	USAGE: Used in the main loop, controls timing of tick and render functions.

---NOTE---
a revised version of the loop for controlling FPS, with the addition of clear code and neat documentation.

THE LOOP CONTROLS THE FPS OF THE GAME LOOP, AND REQUIRES THE CLOCK TIME OF THE SYSTEM/PROGRAM.
	- Only calls tick and render as major function.
	- This should be the main game loop.
	- Tick contains all game logic and Render contains all the pixel drawing.
*/

.section .text

.equ	DEFAULTTIMEPERFRAME, 200000			//time per frame fixed at 200000 microseconds (5 FPS)
.equ	CLOCKADDRESS, 0x3f003004			//address of the clock

FPSLoop:

	CLOCK		.req	r3			//clock address
	CURRENTTIME	.req	r4			//time right now
	LASTFRAME	.req	r5			//time of the last frame
	DELTA		.req	r6			//total change in time 
	DIFFERENCE	.req	r7			//difference in time between current time and last frame time
	TIMEPERFRAME	.req	r8			//time per frame

	ldr	CLOCK, =CLOCKADDRESS			//load clock address
	ldr	TIMEPERFRAME, =DEFAULTTIMEPERFRAME	//load time per frame

	ldr	LASTFRAME, [CLOCK]			//initialize last frame to before loop start
	mov	DELTA, #0				//initialize delta to zero

loop:	ldr	CURRENTTIME, [CLOCK]			//get current system clock time

	sub	DIFFERENCE, CURRENTTIME, LASTFRAME	//difference = current time - last frame time
	add	DELTA, DIFFERENCE			//add difference to delta

	cmp	DELTA, TIMEPERFRAME			//compare total change to time per frame
	blt	skip					//tick if time since last tick doesnt match FPS

	bl	tick					//updates game state
	bl	render					//draws game onto screen

	mov	LASTFRAME, CURRENTTIME			//move current time into last frame time

skip:	sub	DELTA, TIMEPERFRAME			//subtract a frame time from total change
	b	loop					//return to loop start
	
