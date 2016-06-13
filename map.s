/*
Instance of game environment
	specifies fuel of player
	specifies number of lives left
	specifies what each cell of grid is (road/side tile)
	of width, there is at least 5 cells on either side
		that are side tiles

*/
	.equ	CENTER, 12
	.equ	ROAD, 0
	.equ	SIDE, 1
.section .text
	// adjust the latter number as necessary
	.equ	END, 22 * 5	// end of the map	

.globl updateRoad
/*
redraws the center tiles.
*/
	NEED	.req	r4
	COL	.req	r5
	ROW	.req	r6
	CHECK	.req	r7
	ZERO	.req	r8
	ONE	.req	r9
updateRoad:
	push	{r4-r10, lr}
	ldr	r0, =laneNum		// Retrieve address of the modulo
	ldr	NEED, [r0]		// Load the value of what we want
	add	NEED, #1		// Increment the value of what we want
	cmp	NEED, #3		// Check if it's reached the max
	moveq	NEED, #0		// If it has reached the max, set it back to 0
	str	NEED, [r0]		// Store the new value
	
	mov	COL, #12		// begins loop
	mov	ROW, #0

updateRoadLoop:
	mov	CHECK, ROW		
checkWhite:
	cmp	CHECK, #2		// row mod 3		
	subgt	CHECK, #3
	bgt	checkWhite		// keep going until row <= 0

	cmp	CHECK, NEED		// check for desired
	bne	checkWhiteEnd		// if not what we want, then go to the end of checkWhite
	
	mov	ONE, #1
	mov	ZERO, #0
	
	mov	r0, COL			// first get tile reference of previous tile
	sub	r1, ROW, #1			
	bl	getTileRef
	str	ONE, [r0, #16]		// flag that the tile has been changed
	str	ZERO, [r0, #12]		// white -> gray
	
	mov	r0, COL			// get tile reference of current tile			
	mov	r1, ROW
	bl	getTileRef
	str	ONE, [r0, #16]		// flag that this tile has been changed
	str	ONE, [r0, #12]		// gray -> white
	
checkWhiteEnd:
	add	ROW, #1
	cmp	ROW, #22	
	blt	updateRoadLoop
	
	pop	{r4-r10, lr}
	bx	lr

.globl	getTileRef
/*
getTileRef

Retrieves tile based on the row and the column.
r0 - column
r1 - row

Returns
r0 - address offset of the tile
*/
	.equ	PARAM, 5
	.equ	MAX_COL, 25
	.equ	MAX_ROW, 22
	OFFSET .req r2
getTileRef:
	push	{r4-r10, lr}
	
	ldr	r3, =gameMap		// retrieve map reference
	// X * 25 (32 (2^5) - 7 (2^3 - 2^0)) + Y
	// map[x][y] = [COL*MAX_COL*MAX_ITEM + ROW*MAX_ITEM] * 4
	
	mov	r4, #PARAM
	mov	r5, #MAX_COL
	mov	r6, #MAX_ROW
	
	// COL * MAX_COL [25] * MAX_ITEM [5]
	mul	r0, r5
	mul	r0, r4	
	
	// ROW * MAX_ITEM
	mul	r1, r4
	
	add	r0, r1		
	lsl	r0, #2
	
	pop	{r4-r10, lr}
	bx	lr
	.unreq	OFFSET

.globl	getOverlap
/*
getOverlap
Retrieves reference of possible overlapping item.
Returns 0 if none available.

Returns:
r0 - reference of item
*/
	COUNT .req r1
	S_ADRS .req r2
	BASE_ADRS .req r3
	P_ROW .req r4
	P_COL .req r5
getOverlap:
	push	{r4-r10, lr}

	ldr	r2, =player				// retrieve player reference
	ldr	P_COL, [r2]				// load column of player
	ldr	P_ROW, [r2, #4]				// load row of player
	ldr	BASE_ADRS, =spawnArray			// 
	mov	COUNT, #0				// the counter along the array
overlapLoop:
	add	S_ADRS, COUNT, COUNT, lsl #1		// counter * 3
	add	S_ADRS, BASE_ADRS, S_ADRS, lsl #2	// adrs = base + offset (count * 3 * 4)
	ldr	r6, [S_ADRS, #4]			// retrieve row
	cmp	r6, P_ROW				// compare spawn's row and player's row
	ldreq	r6, [S_ADRS]				// if the same, retrieve the column
	cmpeq	r6, P_COL				// and compare spawn's and player's column.
	moveq	r0, S_ADRS				// if the same, return the address of the spawn
	beq	overlapEnd				// and branch to end of function

	add	COUNT, #1				// if not the same, increment counter
	ldr	r6, =itemCount				// retrieve item count
	ldr	r0, [r6]
	cmp	COUNT, r0				// compare the count and the item count
	blt	overlapLoop				// if counter < item count, keep looping 
	mov	r0, #0					// return 0 if no overlap

overlapEnd:
	pop	{r4-r10, lr}
	bx	lr

.globl	hasCollide
/*
hasCollide
Checks if the player has collided with a wall.

Returns:
r0 - 0 if false, 1 if true
*/
hasCollide:
	push	{r4-r10, lr}
	ldr	r2, =player		// retrieve player reference
	ldr	r0, [r2]		// load column of player
	ldr	r1, [r2, #4]		// retrieve row of player
	bl	getTileRef		// retrieve tile reference
	ldr	r1, [r0]		// load tile type
	cmp	r1, #SIDE		// check if tile is side
	moveq	r0, #1			// return true if side
	movne	r0, #0			// return false if not
	pop	{r4-r10, lr}
	bx	lr

.globl	isEnd
/*
isEnd
Checks if the map has reached the end.

Returns:
r0 - 0 if false, 1 if true
*/
isEnd:
	push	{r4-r10, lr}

	ldr	r2, =tilePassed
	ldr	r0, [r2]
	ldr	r1, =END
	cmp	r0, r1
	movge	r0, #1
	movlt	r0, #0

	pop	{r4-r10, lr}
	bx	lr

.section .data
	// total 22 * 25 tiles

.globl	tilePassed
tilePassed:
	.int 0

.globl gameMap
gameMap:
	.skip 	22 * 25 * 5 * 4 // 22 * 25 tiles (5 variables)
	/*
	1. flag showing whether side/road (0/1)
	2. x coord
	3. y coord
	4. flag if there is something special drawn on it
	5. flag if it has changed in the last iteration
	*/

.globl	laneNum
laneNum:
	.int 	0	// how we update the center of the map
	.end
