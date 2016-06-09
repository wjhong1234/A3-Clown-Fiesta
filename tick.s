.section .text

	TEMP .req r4
	BUTTON .req r6

	// Buttons that will be accessed in the game
	.equ	SEL, 0b110111111111	// Select button
	.equ	START, 0b111011111111	// Start button
	.equ	LEFT, 0b111111011111	// Left button
	.equ	RIGHT, 0b111111101111	// Right button
	.equ	A, 0b111111110111	// A button

	// Flags for player state
	.equ	WIN, 2
	.equ	NONE, 1
	.equ	LOSE, 0

	// Flags for player action
	.equ	EXIT, 0
	.equ	RESTART, 1
	.equ	MOVE_LEFT, 2
	.equ	MOVE_RIGHT, 3

	// The outer edges of the map
	.equ	LEFT, 352
	.equ	RIGHT, 864
	.equ	END, 22 * 10


.globl	game
	ACTION .req r6
	PLAY .req r7
/*
game

Contains the skeleton loop.
Returns: Win (2) or Loss (0)
*/
game:
	push	{r4-r10, lr}

gameStart:
	mov	PLAY, #0	// set it so game has not started
	bl	initGame	// resets all aspects of game

gameLoop:
	bl	getInput	// get input of player
	mov	r1, PLAY	// check if game has started
	bl	readInput	// and read the input
			
	cmp	r0, #EXIT	// check if player is exiting
	beq	gameEnd
	cmp	r0, #RESTART	// check if player is restarting
	beq	gameStart

	cmp	PLAY, #1	// check if game started previously
	cmpne	r1, #1		// if not, check if that has changed
	bne	gameLoop	// if not changed, then loop back up
	moveq	PLAY, r1	// if changed, then record it

	// do something about this movement
	cmp	r0, #LEFT	// afterward check for movement
	cmp	r0, #RIGHT

	// will need to figure out what to do if
	// car hits the player before they can move?
/*	bl	updatePlayer	// update player based on the input
	bl	updateMap	// update map based on the input
	bl	updateState	// update the state based on the map

	subs	TEMP, r0, #1	// check the player status
	beq	gameLoop	// if status is 1 (not win or lose)
				// then keep looping
				// 0 - 1 = negative flag (mi)
				// 1 - 1 = zero flag (eq)
				// 2 - 1 = positive flag (ne)
*/

gameEnd:
	// we need to figure out how we're going to pass
	// all of this information into "render"
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
readInput:
	push	{r4-r10, lr}

	mov	BUTTON, r0	// preserve buttons

	cmp	r1, #1		// check if the game has started
	beq	checkMove	// if started, check left/right
				// if not, check if A pressed

	mov	r0, BUTTON	// A - start the game
	ldr	r1, =A
	bl	checkButton	
	cmp	r0, #1	
	moveq	PLAY, #1	// if A pressed,
	bne	checkButtons	// check for left/right	
checkMove:			// otherwise, don't check left/right	
	mov	r0, BUTTON	// LEFT - move left
	ldr	r1, =LEFT	
	bl	checkButton	
	cmp	r0, #1	
	moveq	ACTION, #MOVE_LEFT
	
	mov	r0, BUTTON	// RIGHT - move right
	ldr	r1, =RIGHT	
	bl	checkButton	
	cmp	r0, #1	
	moveq	ACTION, #MOVE_RIGHT
checkButtons:
	mov	r0, BUTTON	// START - restart game
	ldr	r1, =START	
	bl	checkButton	
	cmp	r0, #1
	moveq	ACTION, #RESTART

	mov	r0, BUTTON	// SELECT - exit to main
	ldr	r1, =SEL	
	bl	checkButton	
	cmp	r0, #1
	moveq	ACTION, #EXIT

	mov	r0, ACTION
	mov	r1, PLAY

	pop	{r4-r10, lr}
	bx	lr

	.unreq ACTION
	.unreq PLAY

updatePlayer:
	push	{r4-r10, lr}
	
	// will call the functions in player.s

	pop	{r4-r10, lr}
	bx	lr

updateMap:
	push	{r4-r10, lr}
	
	// will call the functions in map.s

	pop	{r4-r10, lr}
	bx	lr

/*
updateState

Depending on the state of the player, updates it.
// or we can place player information in a structure?
r0 - player x coordinate
r1 - player lives
r2 - fuel
r3 - map's y coordinate

return:	
r0 - player state (loss, win, or none of the above)
r1 - amount of lives (might be zero if loss)
r2 - amount of fuel (might be zero if loss)
*/
updateState:
	HIT_FLAG .req r5	// 0 if not hit, 1 if hit
	LIVES .req r6
	FUEL .req r7
	MAP_Y .req r8
	P_X .req r9

	push 	{r4-r10, lr}

	bl	getInput
	mov	BUTTON, r0
	

	mov	HIT_FLAG, #0

	mov	P_X, r0
	mov	LIVES, r1
	mov	FUEL, r2
	mov	MAP_Y, r3

	cmp	P_X, #LEFT	// if player hits leftmost edge
	movle	HIT_FLAG, #1	// trigger "lose life"
	cmp	P_X, #RIGHT	// if player hits rightmost edge
	movge	HIT_FLAG, #1	// trigger "lose life"
	/*
	// must check if player has hit a car
	bl	getNearestCar	// or some such function
				// if nearest car's coordinates are
				// overlapping with player
				// then the player has been hit

	// must check if player has hit a fuel object
	bl	getNearestFuel	// or some such function
				// if the nearest fuel's coordinates
				// are overlapping with player
				// then increase the fuel
	*/

	cmp	HIT_FLAG, #0	// if the player has been hit
	subne	LIVES, #1	// remove a life
	subne	FUEL, #10	// remove 10 fuel
	
	mov	r0, #0
	// here we check if the lose or win flags have been triggered
	cmp	LIVES, #0	// check how many lives left
	movle	r0, #LOSE	// if lives >= 0, trigger loss
	cmp	FUEL, #0	// check if fuel >= 0	
	movle	r0, #LOSE	// if so, then trigger loss
	cmp	MAP_Y, #END	// check if player reached end
	movge	r0, #WIN	// if so, trigger win
							
	pop	{r4-r10, lr}
	bx	lr

	.unreq	HIT_FLAG

