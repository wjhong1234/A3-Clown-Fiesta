
/*
---IMPORTANT---
About this file:
	NOT A FUNCTION: No
	WHAT?: Limits the FPS in the main loop.
	DESCRIPTION: This code segment ensures that the FPS of our delicious game is limited to 30 FPS.

--MISSING--
	This code requires floating points to use.

---NOTES---
 for limiting the FPS to 30

---PSEUDO---

 fps = 30			//set frames per second
 frametime = time rn pls	//the time of the last frame, init to before loop starts
 timeperframe = 1s / fps	//time for a single frame
 change = 0			//change to see if it's greater than 1s

 in main loop:
	 change += systemtime - frametime / timeperframe	//change is added incase there's extra time
	 if (change >= 1)					//if time between frames is greater than 1 fps
		update game 					//then we update that bitch
		change--					//then sub by 1 cause small time is scary

 anything starting with a * is wth is going on here pls help

*/

	FPS	.req	#30		//fps = 30
	FTIME	.req	r0
	TPF	.req	*1/fps		//timeperframe can probably be solid number or something
	CHG	.req	r1		//change = timebetweenframes
	TEMP	.req	r2		//temporary register

	mov	FTIME, *timernpls	//frametime = time rn pls
	mov	CHG, #0			//change = 0

loop:
	sub	TEMP, *systemtime, FTIME
	*div	TEMP, TPF
	add	CHG, TEMP
	cmp	CHG, #1
	blt	loop			//if change >= 1, backwards to save lines cause ima genius compliment me pls

	//DO UPDATING STUFF HERE
	sub	CHG, #1
	b	loop

//this seems pretty legit but theres a few things to figure out ofc.
