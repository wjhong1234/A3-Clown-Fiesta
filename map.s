/*
Instance of game environment
	specifies fuel of player
	specifies number of lives left
	specifies what each cell of grid is (road/side tile)
	of width, there is at least 5 cells on either side
		that are side tiles

*/
	.equ	CENTER, 15
	.equ 	LEFTMOST, 224
	.equ 	UPPERMOST, 64
	.equ	ROAD, 0
	.equ	SIDE, 1
.section .text
	// adjust the latter number where necessary
	.equ	END, 22 * 8	// end of the map	
/*

// Redraws center lane tile thing.


	ADRS .req r6
	ROW .req r5
	COL .req r4
updateRoad:
	push	{r4-r10, lr}
	
	ldr	ADRS, =laneArray// retrieve lane array
	mov	COL, #CENTER	// retrieve center tile
	mov	ROW, #0		// retrieve top
roadLoop:
	ldr	r0, [ADRS]	
	mov	r0, COL
	mov	r1, ROW
	bl	drawTile	

	ldr	r2,  =road
	mov	r0, COL		//
	mov	r1, ROW 	// 
	bl	getTileCoord	// retrieve coordinate
	ldr	r2, =LANE
	mov	r0, 
	bl	drawTile

	pop	{r4-r10, lr}
	bx	lr
	.unreq	ROW
	.unreq	COL
*/

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

/*
.globl	getOverlap

//getOverlap
//Retrieves reference of possible overlapping item.
//Returns 0 if none available.

//Returns:
//r0 - reference of item
	COUNT .req r1
	S_ADRS .req r2
	BASE_ADRS .req r3
	P_ROW .req r4
	P_COL .req r5
getOverlap:
	push	{r4-r10, lr}

	ldr	r2, =player		// retrieve player reference
	ldr	P_COL, [r2]		// load column of player
	ldr	P_ROW, [r2, #4]		// load row of player
	ldr	BASE_ADRS, =spawnArray	// 
	mov	COUNT, #0		// the counter along the array
overlapLoop:
	add	S_ADRS, COUNT, COUNT, lsl #1		// counter * 3
	add	S_ADRS, BASE_ADRS, S_ADRS, lsl #2	// adrs = base + offset (count * 3 * 4)
	ldr	r6, [S_ADRS, #4]			// retrieve row
	cmp	r6, P_ROW			// compare spawn's row and player's row
	ldreq	r6, [S_ADRS]		// if the same, retrieve the column
	cmpeq	r6, P_COL			// and compare spawn's and player's column.
	moveq	r0, S_ADRS		// if the same, return the address of the spawn
	beq	overlapEnd		// and branch to end of function

	add	COUNT, #1		// if not the same, increment counter
	ldr	r6, =itemCount		// retrieve item count
	ldr	r0, [r6]
	cmp	COUNT, r0		// compare the count and the item count
	blt	overlapLoop		// if counter < item count, keep looping 
	mov	r0, #0			// return 0 if no overlap

overlapEnd:
	
	pop	{r4-r10, lr}
	bx	lr
*/

.globl	hasCollide
/*
hasCollide
Checks if the player has collided with a wall.

Returns:
r0 - 0 if false, 1 if true
*/
hasCollide:
	push	{r4-r10, lr}
	ldr	r1, =player		// retrieve player reference
	ldr	r0, [r1, #4]	// load column of player
	mov	r1, #22			// retrieve row of player
	bl	getTileRef		// retrieve tile reference
	ldr	r1, [r0]		// load tile type
	cmp	r1, #0			// check if tile is side
	moveq	r0, #1		// return true if side
	movne	r0, #0		// return false if not
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

	ldr	r0, =tilePassed
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

	*/
	.end

.globl	laneArray
laneArray:
	.skip 22 * 4	// contains reference of lane or road
	.end
/*
tile struct
*/
/*
	.int	0		// side/road (0/1)
	.int	0		// x coord
	.int	0		// y coord
	.int	0		// if there is something special drawn on it
	.int	0		// if it has changed in the last iteration
