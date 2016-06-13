/*
---IMPORTANT---
About "main":
	MAIN: Initializes everything.

About "startGame":
	MENU: Contains the game menu.
	USAGE: Creates and controls all aspects of the main menu.

About "mainLoop":
	LOOP: Limits FPS to approximately 5 frames per second.
	USAGE: Used in the main loop, controls timing of tick and render functions.
	
About "mainEnd":
	END: Clears the screen to end the game.

---NOTE---
main.s is the initial file that starts the game.

a revised version of the loop for controlling FPS, with the addition of clear code and neat documentation.

MAIN AND ALL OF THE FOLLOWING CODE IS RESPONSIBLE FOR STARTING AND ENDING THE GAME.
	- Main loop o the entire program.
	- Starts the main menu, which starts the game.

THE LOOP CONTROLS THE FPS OF THE GAME LOOP, AND REQUIRES THE CLOCK TIME OF THE SYSTEM/PROGRAM.
	- Only calls tick and render as major function.
	- This should be the main game loop.
	- Tick contains all game logic and Render contains all the pixel drawing.
*/

.section    .init
.globl     _start

_start:
    b       main
    
.section .text

.equ	START, 1					//start flag
.equ	DEFAULTTIMEPERFRAME, 200000			//time per frame fixed at 200000 microseconds (5 FPS)
.equ	CLOCKADDRESS, 0x3f003004			//address of the clock
.equ	END, 0						//game end flag

	BASEADDRESS	.req	r2			//base address
	DIFFERENCE	.req	r3			//clock address
	CURRENTTIME	.req	r4			//time right now
	LASTFRAME	.req	r5			//time of the last frame
	DELTA		.req	r6			//total change in time 
	CLOCK		.req	r7			//difference in time between current time and last frame time
	TIMEPERFRAME	.req	r8			//time per frame
	RUNNINGFLAG	.req	r9			//flag to see if game running
	GAMEFLAG	.req	r10			//flag to see if player going to start or quit at menu
main:
    	mov	sp, #0x8000				// Initializing the stack pointer
	bl	EnableJTAG
	bl	initi

startGame:
	bl	menu					//main menu function
	mov	GAMEFLAG, r0
	bl	clearScreen				//clear screen to start game or end
	cmp	GAMEFLAG, #START			//compare gameflag to start

	bne	mainEnd
    
mainLoop:
	/*
	ldr	CLOCK, =CLOCKADDRESS			//load clock address
	ldr	TIMEPERFRAME, =DEFAULTTIMEPERFRAME	//load time per frame

	ldr	LASTFRAME, [CLOCK]			//initialize last frame to before loop start
	mov	DELTA, #0				//initialize delta to zero

loop:	ldr	CURRENTTIME, [CLOCK]			//get current system clock time

	sub	DIFFERENCE, CURRENTTIME, LASTFRAME	//difference = current time - last frame time
	add	DELTA, DIFFERENCE			//add difference to delta

	cmp	DELTA, TIMEPERFRAME			//compare total change to time per frame
	blt	skip					//tick if time since last tick doesnt match FPS
	*/
	bl	tick					//updates game state
	bl	render					//draws game onto screen
	
	ldr	BASEADDRESS, =gameState			//current state of the game (running / not running)
	ldr	RUNNINGFLAG, [BASEADDRESS]		//load current state
	
	cmp	RUNNINGFLAG, #END			//compare to see if game stopped
	beq	startGame				//return to main menu
	b	mainLoop
	/*
	mov	LASTFRAME, CURRENTTIME			//move current time into last frame time

skip:	sub	DELTA, TIMEPERFRAME			//subtract a frame time from total change
	b	loop					//return to loop start
   	*/
mainEnd:
	.unreq	BASEADDRESS
	.unreq	CLOCK
	.unreq	CURRENTTIME
	.unreq	LASTFRAME
	.unreq	DELTA
	.unreq	DIFFERENCE
	.unreq	TIMEPERFRAME
	.unreq	RUNNINGFLAG
	
	bl	clearScreen				//clear screen to end game
   
haltLoop$:
	b		haltLoop$
