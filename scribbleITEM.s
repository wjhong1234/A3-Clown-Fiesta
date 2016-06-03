/*
---IMPORTANT---
About this function:
	ONE PARAMETER: A flag to determine whether the spawned item is an obstacle or fuel item.
	VOID: This function determines where the items spawn, and draws them.
	OTHER: This file keeps track of each item in an array [XPos/YPos/Flag].

---MISSING---
	This function requires a way to count how many tiles has passed the player on the screen.
	Importantly, this function needs the draw functions to do what it does.

---NOTES---
take number from rng to place on the screen somewhere.

THIS FUNCTION LIMITS THE AMOUNT OF ITEMS SPAWNED TO 7. WE DON'T WANT FILTHY CLUTTER.

function for cars:
	//get random number from rng to and with #7 so obstacles spawn pretty fast within 7 tiles
	//make obstacle spawn after going through that many tiles
	//obstacle position based on another random number within the road
*/

spawn:
	push	{r4-r10}

	//***the following segment decides how many tiles in the obstacle will spawn.
	//***if we do this once every second, then the maximum amount of objects ever will be 7

	bl	xorShift		//generate a random number
	and	r0, #7			//and with 7 to get number within 7
	
	//COUNT tiles to generated number in order to spawn obstacle

	bl	xorShift		//generate another random number
	and	r0, #0x111111111	//and this to make it smaller

	//***crop guarantees that r0 will be a number within the size of the road.

crop:	cmp	r0, *ROADMAX		//compare randomly generated number to usable road size
	bgt	smalls
	cmp	r0, *ROADMIN		//compare randomly generated number to usable road rize
	blt	bigs
	b	next			//keep checking until number is within road

smalls:	sub	r0, *ROADMAX		//if it's bigger subtract the max from the number
	b	crop

bigs:	add	r0, *ROADMIN		//if it's smaller add the min to the number
	b	crop
	
	pop	{r4-r10}

.section .data
spnArr:	.skip	7 * 3 * 4		//Allocate memory for 7 items
	.end
