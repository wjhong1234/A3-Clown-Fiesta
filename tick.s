.section .text
	// Buttons that will be accessed in the game
	.equ	SEL, 0b110111111111	// Select button
	.equ	START, 0b111011111111	// Start button
	.equ	LEFT, 0b111111011111	// Left button
	.equ	RIGHT, 0b111111101111	// Right button
	.equ	A, 0b111111110111	// A button

	// Flags for player state
	.equ	WIN, 2
	.equ	NONE, 0
	.equ	LOSE, 1

	// Flags if player has pressed A or not
	.equ	ON, #1
	.equ	OFF, #0

	// Flags for player action
	.equ	EXIT, 0
	.equ	RESTART, 1
	.equ	MOVE_LEFT, 2
	.equ	MOVE_RIGHT, 3

	// The outer edges of the map
	.equ	END, 22 * 10


.globl	game
	PLAY 		.req r7
	RESTART_FLAG	.req r8
	BUTTON 		.req r6
/*
game

Contains the skeleton loop.
Returns: Win (2) or Loss (0)
*/
game:
	push	{r4-r10, lr}
	ldr	r0, =gameState		// check if the player was already playing the game
	ldr	r1, [r0]
	cmp	r1, #1
	beq	game			// if so, then go immediately into game
					// if not, then assume new game
gameStart:
	ldr	r0, =play		// starts the game off
	mov	r1, #0
	str	r1, [r0]		// set it so game has not started
	bl	initGame		// resets all aspects of game
	
	cmp	RESTART_FLAG, #1	// check if the player has decided to restart the game
	beq	gameEnd			// if so, simply draw the map if necessary

game:
	bl	getInput		// get input of player
	bl	readInput		// read the input
	
	// checks for updates on player input
	mov	r1, #0			
	ldr	r2, =gameState
	cmp	r0, #EXIT		// check if player is exiting
	streq	r1, [r2]		// if the player is exiting, then store it and branch to end
	beq	gameEnd
	
	cmp	r0, #RESTART		// check if player is restarting
	moveq	RESTART_FLAG, #1	// Flag for restart if so
	beq	gameStart		
	
	ldr	r0, =play		// check if the player has ever pressed A
	ldr	r1, [r0]
	cmp	r1, #1
	bne	gameEnd			// if not, then don't update anything

gameMove:
	mov	r1, #2
	cmp	r0, #MOVE_LEFT		// check if moved left
	moveq	r1, #0		
	cmp	r0, #MOVE_RIGHT		// check if 
	moveq	r1, #1			// move right if right
	cmp	r1, #2			// if has moved
	movne	r0, r1			
	blne	movePlayer		// then update the position of player

	bl	updateRoad		// update map based on the input
//	bl	updateSpawn
	bl	updateState		// update the state based on the map

	ldr	r0, =status		// checks if the player has won or lost
	ldr	r1, [r0]
	subs	r1, #1		
	bmi	gameEnd			// if not, keep playing
	
	ldr	r2, =gameState		// if the player has won or lost, then end the game
	mov	r0, #0
	str	r0, [r2]
	
gameEnd:
	pop	{r4-r10, lr}
	bx	lr

/*
readInput
Reads the input and deciphers what will be done
r0 - buttons
r1 - if started the game

Returns:
r0 - what button has been pressed in order of importance
r1 - if A has been pressed
*/
	ACTION		.req	r6
	PLAY_ADRS	.req	r4
readInput:
	push	{r4-r10, lr}

	mov	BUTTON, r0		// preserve buttons
	ldr	PLAY_ADRS, =play
	mov	r5, #OFF

	ldr	r1, =play		// check if player previously pressed A
	ldr	r2, [r1]		
	cmp	r2, #1			// if player has pressed A, check for movement
	beq	checkMove

checkPlay:
	mov	r0, BUTTON		// Check if player has recently pressed A
	ldr	r1, =A		
	bl	checkButton	
	cmp	r0, #1	
	bne	checkButtons		// if not, do not check for movement
	streq	r0, [PLAY_ADRS]		// if so, then store it into memory
	
checkMove:			
	mov	r0, BUTTON		// Check if player pressed left
	ldr	r1, =LEFT	
	bl	checkButton	
	cmp	r0, #1	
	moveq	ACTION, #MOVE_LEFT
	
	mov	r0, BUTTON		// Check if the player pressed right
	ldr	r1, =RIGHT	
	bl	checkButton	
	cmp	r0, #1	
	moveq	ACTION, #MOVE_RIGHT
checkButtons:
	mov	r0, BUTTON		// Check if the player pressed "start"
	ldr	r1, =START	
	bl	checkButton	
	cmp	r0, #1
	moveq	ACTION, #RESTART

	mov	r0, BUTTON		// Check if the player pressed "select"
	ldr	r1, =SEL	
	bl	checkButton	
	cmp	r0, #1
	moveq	ACTION, #EXIT

	mov	r0, ACTION

	pop	{r4-r10, lr}
	bx	lr

	.unreq ACTION
	.unreq PLAY

updateMap:
	push	{r4-r10, lr}
	
	bl	updateRoad

	pop	{r4-r10, lr}
	bx	lr

/*
updateState
Depending on the state of the player, updates it.
*/
	.equ	FUEL_LOSS, 5  
	.equ	NORMAL, 0	
	.equ	COLLISION, 1
	.equ	FUEL, 2
	.equ	HAIR_TYPE, 0
	.equ	BERNIE_TYPE, 1
updateState:
	HIT_FLAG 	.req r5		// [0/1]
	FUEL_FLAG	.req r6		// [0/1/2] - 0, no change; 1, addition; 2 - subtraction
	LIVES 		.req r7
	FUEL 		.req r8

	push 	{r4-r10, lr}
	
	mov	HIT_FLAG, #0

	// initializes the changes of the game state
	mov	LIVES, #0		
	mov	FUEL, #FUEL_LOSS

	// this section checks if there were changes to the player state
	bl	hasCollide		// check if player has hit the sides
	cmp	r0, #1		
	moveq	HIT_FLAG, #1		// Trigger hit flag if player collided with the side

	bl	getOverlap		// check if there is any overlap
	cmp	r0, #0
	beq	updateVar		// If there is no overlap, skip to updating variables
	ldrne	r1, [r0, #8]		// If there is an overlap, then load the offending obstacle type
	cmp	r1, #FUEL_TYPE		// Check if the item is fuel or otherwise
	moveq	FUEL_FLAG, #1
	movne	HIT_FLAG, #1	

	// here we update variables of the game
updateVar:
	cmp	FUEL_FLAG, #1		// checks if player has run into a fuel object
	addeq	FUEL, #10
	cmp	HIT_FLAG, #1		// checks if player has collided with something
	subeq	LIVES, #1
	subeq	FUEL, #10

	ldr	r0, =tilePassed		// increase the tile count
	ldr	r3, [r0]
	add	r3, #1
	str	r3, [r0]
	
	ldr	r1, [r0, #8]		// retrieve player's current life
	add	LIVES, r1		// adjust it according to the update
	str	LIVES, [r0, #8]		// Store updated life

	ldr	r1, [r0, #12]		// retrieve player's current fuel
	add	FUEL, r1		// adjust it according to the update
	str	FUEL, [r0, #12]		// Store new fuel
	
	mov	r1, #NORMAL		// initialize face state as normal
	cmp	HIT_FLAG, #1		// check if the player had a collision
	moveq	r1, #COLLISION
	cmp	FUEL_FLAG, #1		// check if the player ran into fuel
	moveq	r1, #FUEL
	ldr	r0, =faceState		// Store Trump's current state in order to redraw his face
	str	r1, [r0]
	
	cmp	HIT_FLAG, #1		// Reset player position if there was a collision
	bleq	resetPlayerPosition	
	
	// here we check if the lose or win flags have been triggered
updateGameState:
	mov	r0, #0
	cmp	LIVES, #0		// If lives <= 0, trigger loss
	movle	r0, #LOSE		
	cmp	FUEL, #0		// If fuel <= 0, trigger loss	
	movle	r0, #LOSE		
	bl	isEnd			// If player has reached end, trigger win
	cmp	r0, #1		
	moveq	r0, #WIN
	ldr	r1, =status		// Store whether or not the player won or lost
	str	r0, [r1]
					
	pop	{r4-r10, lr}		
	bx	lr			

	.unreq	HIT_FLAG

.section .data

.globl	status
// Checks if the player lost or won
status:
	.int	0

.globl	gameState
// Checks if the player has chosen to quit
gameState:
	.int	1	
	
.globl	faceState
// tracks which face Trump will make
faceState:				
	.int	0			// 0 - normal
					// 1 - collision
					// 2 - fuel

// Checks if the player has pressed A					
play:
	.int	0			
