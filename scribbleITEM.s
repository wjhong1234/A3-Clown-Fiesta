//just the obstacle and fuel part for transitions.s

/*

take number from rng to place on the screen somewhere.

function for cars:
	//get random number from rng to and with #7 so obstacles spawn pretty fast within 7 tiles
	//make obstacle spawn after going through that many tiles
	//obstacle position based on another random number within the road
*/

obstacleSpawn:
	push	{r4-r10}

	bl	xorShift		//generate a random number
	and	r0, #7			//and with 7 to get number within 7
	
	//COUNT tiles to generated number in order to spawn obstacle

	bl	xorShift		//generate another random number
	and	r0, #0x111111111	//and this to make it smaller

crop:	cmp	r0, *ROADMAX		//compare randomly generated number to usable road size
	bgt	smalls
	cmp	r0, *ROADMIN		//compare randomly generated number to usable road rize
	blt	bigs
	b	next			//keep checking until number is within road

smalls:	sub	r0, *ROADMAX		//if it's bigger subtract the max from the number
	b	crop

bigs:	add	r0, *ROADMIN		//if it's smaller add the min to the number
	b	crop

	//we have to account for size of the car, maybe just straight up on the min/max
	//DRAW obstacle to x position at top of road

	

	pop	{r4-r10}

