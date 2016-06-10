/*
---IMPORTANT---
About this file:
	LOOP: Limits FPS to approximately 5 frames per second.
	USAGE: Used in the main game loop, controls timing of tick and render functions.

---NOTE---
a revised version of the loop for controlling FPS
*/

.section .text

.equ	TIMEPERFRAME, 200000				//time per frame fixed at 200000 microseconds

FPSLoop:

	CURRENTTIME	.req	r4	
	LASTFRAME	.req	r5			//time of the last frame
	DELTA		.req	r6			//total change in time 
	DIFFERENCE	.req	r7			//difference in time between current time and last frame time

	bl	*getTime				//get current system clock time

	mov	LASTFRAME, r0				//initialize last frame to before loop start
	mov	DELTA, #0				//initialize delta to zero

loop:	bl	*getTime				//get current system clock time

	mov	CURRENTTIME, r0				//move output into register
	sub	DIFFERENCE, CURRENTTIME, LASTFRAME	//difference = current time - last frame time

	add	DELTA, DIFFERENCE			//add difference to delta

	cmp	DELTA, TIMEPERFRAME			//compare total change to time per frame
	blt	skip					//tick if time since last tick doesnt match FPS

	bl	tick					//updates game state
	bl	render					//draws game onto screen

	mov	LASTFRAME, CURRENTTIME			//move current time into last frame time

skip:	sub	DELTA, TIMEPERFRAME			//subtract a frame time from total change
	b	loop					//return to loop start
	
