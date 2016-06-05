/*

---IMPORTANT---
About the "playerMove" function:
	ONE PARAMETER: Takes in the button inputs to go either left or right.
	VOID: Moves player according to input, if move is valid.
	OTHER: Need better fence check for moving off map.

---NOTES---
player functions
*/

.equ	PLAYERYPOS, //the FIXED YPos of the player

playerMove:
	push	{r4-r10}

	//take button input, decide either single button inputs or parse entire buttons
	ldr	r3, =player		//load player address into r1
	ldr	r1, [r3]		//load XPos of player into r1

	cmp	r1, *MAPFENCELEFT	//Check if the current position is the border
	ble	endMv			//skip if it's going to move off map
	cmp	r1, *MAPFENCERIGHT	
	bge	endMv

	cmp	r0, *LEFTBUTTON		//Check if left move
	beq	left			//if left, branch to left
	bne	right			//else branch right

	//load player xpos and change based on button inputs
left:	sub	r1, #10			//change the move speed accordingly
	str	r1, [r3]		//store into XPos memory
	b	endMv

right:	add	r1, #10			//change the move speed accordingly
	str	r1, [r3]		//store into XPos memory

endMv:	pop	{r4-r10}

.section .data
player:	.skip	2 * 4			//Allocate memory for XPos/YPos of the player
	.skip	2 * 4			//Allocate memory for the lives & fuel of the player
	.end

