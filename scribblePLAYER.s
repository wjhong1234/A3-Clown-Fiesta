/*

---IMPORTANT---
About the "playerMove" function:
	ONE PARAMETER: Takes in the button inputs to go either left or right.
	VOID: Moves player according to input, if move is valid.
	OTHER: Need better fence check for moving off map.

---NOTES---
player functions
*/

//.equ	PLAYERYPOS,  //the FIXED YPos of the player

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
	bx	lr
	
/* Don't forget to make a resetPlayer function for whenever the game restarts
.globl resetPlayer
	.equ	INIT_COL, 15
	.equ	INIT_ROW, 22
	.equ	INIT_LIFE, 3
	.equ	INIT_FUEL, 100
resetPlayer:
	// we do not need to push or pop because only
	// r0 and r1 are utilized as registers in this function
	ldr	r0, =player		// retrieve base reference of player struct
	mov	r1, #INIT_COL
	str	r1, [r0]		// store initial column
	mov	r1, #INIT_ROW
	str	r1, [r0, #4]		// store initial row
	mov	r1, #INIT_LIFE
	str	r1, [r0, #8]		// store initial life
	mov	r1, #INIT_FUEL
	str	r1, [r0, #12]		// store initial fuel
	bx	lr

*/

.section .data
.globl player	// needs to be retrieved in other files
player:	.skip	2 * 4			//Allocate memory for XPos/YPos of the player
					//should instead make it Col/Row of the player
	.skip	2 * 4			//Allocate memory for the lives & fuel of the player
	// instead should be initialized as the following:
	/*
	.int INIT_COL	// initial column
	.int INIT_ROW	// initial row
	.int INIT_LIFE	// initial life value
	.int INIT_FUEL	// initial fuel value
	*/
	.end

