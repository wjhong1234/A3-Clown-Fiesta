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
.section .text
	// adjust the latter number where necessary
	.equ	END, 24 * 8	// end of the map
	
	MAP_Y .req r4
	

/*
mapState:
	

updateMap:
*/	

/*
Redraws center lane tile thing.
*/
	r5 .req ROW
	r4 .req COL
updateRoad:
	push	{r4-r10, lr}
	
	mov	COL, #CENTER	// retrieve center tile
	mov	ROW, #0		// retrieve top
roadLoop:
	ldr	r2,  =road
	mov	r0, COL		//
	mov	r1, ROW 	// 
	bl	getTileCoord
	ldr	r2, =LANE
	mov	r0, 
	bl	drawTile
	

	pop	{r4-r10, lr}
	bx	lr

.globl	getTileRef
/*
getTileRef

Retrieves tile based on the row and the column.
r0 - row
r1 - column

Returns
r0 - address offset of the tile
*/
	OFFSET .req r2
getTileRef:
	push	{r4-r10, lr}
	
	ldr	r3, =gameMap			// retrieve map reference
	// X * 25 (32 (2^5) - 7 (2^3 - 2^0)) + Y
	// map[x][y] = MAX_COL*x + y	
	lsl	OFFSET, r0, #5		// X * 32
	sub	OFFSET, r0, lsl #3	// (X * 32) - (X * 8) = X * 24
	add	OFFSET, r0		// (X * 26) + (X * 1) = X * 25
	add	OFFSET, r1		// (X * 25) + Y 
	mov	r0, OFFSET, lsl #2	// OFFSET * 4
	
	pop	{r4-r10, lr}
	bx	lr

.globl	getTileCoord
/*
getTileCoord
Retrieves tile coordinates based on the row and column.
r0 - column
r1 - row

Returns:
r0 - x coordinate
r1 - y coordinate
*/
	.equ	X_OFF, 7 // accounts for trump on the left
getTileCoord:
	add	r0, #X_OFF
	add	r1, #X_OFF
	lsl	r0, #5		// 
	lsl	r1, #5		// 

	bx	lr

.section .data
	// total 22 * 25 tiles

.globl gameMap
gameMap:
	.skip 22 * 25 * 4 // 22 * 25

/*
.globl leftSide
.globl rightSide
.globl road

leftSide:
	.skip 264 * 4	// 5 * 22 tiles
	.end
rightSide:
	.skip 120 * 4	// 5 * 22 tiles 
	.end
road:
	.skip 384 * 4	// 15 * 22 tiles
	.end
*/		
laneArray:
	.skip 22 * 4	// contains reference of lane or road
	
/*
tile struct
*/
tile:
	.int	0		// side (0)/road (1)
	.int	0		// fuel(3)/bernie(2)/player/(1)/none(0)
	.int	0		// 
	.int	0		// 
