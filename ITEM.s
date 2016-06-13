/*
---IMPORTANT---
About the "spawn" function:
	NO PARAMETERS: Everything it needs is in memory.
	VOID: Spawns new items based on randomly generated numbers.
	USAGE: Called in the primary game loop, the function automatically times and generates non-playable items ie. fuel and Bernie Sanders.

About the "moveSpawn" function:
	NO PARAMETERS: Everything it needs is in memory.
	VOID: Moves all spawned items on the map down one tile.
	USAGE: This function should be called during the program tick, along with player movement, in order to move all spawned items.

About the "enforceFence" function:
	NO PARAMETERS: Everything it needs is in memory.
	VOID: Also non-global, as it is only used by the moveSpawn function.
	USAGE: Used at the end of "moveSpawn" to delete any spawned items that have moved off the map.

About the "obliterate" function:
	NO PARAMETERS: Everything it needs is in memory and is only called when needed.
	VOID: Removes items from game.
	USAGE: Called by game loop when a collision is detected, the function goes through all items and deletes the item overlapping the player.

---NOTES---
a revised version of item and the spawn functions, with the addition of clear code and neat documentation.

SPAWN LIMITS THE AMOUNT OF GENERATED ITEMS ON THE MAP TO 7.
	- Game map is fairly small, so anything larger would make it too difficult to play.
	- The number 7 is easy to mask things with in binary because it's 0b111.
	- 7 items are not a burden to load and store things in memory.

MOVESPAWN MOVES EVERYTHING DOWN AND IS CALLED IN THE GAME LOOP.
	- Literally all you need to know is that when you call it, spawned items go down (all fuels and obstacles).

ENFORCEFENCE IS ONLY USED BY MOVESPAWN.
	- So you can technically ignore it, unless a problem occurs and it's coming from this function.
	- Yes, this function name is a reference to Donald Trump.

OBLITERATE IS CALLED BY THE GAME WHEN A COLLISION IS DETECTED.
	- Only when the player rams into an item should this function be called.
	- Similar to enforceFence cause I copy pasta'd this code to it.
	- Removes the item (there is ever only ONE ITEM that can be on the player) that shares the tiles in the game logic as the player.
	- Spencer has great function name ideas.

SPAWNARRAY CONTAINS 7 GROUPS OF THREE GROUPS OF PARAMETERS: [XPOS/YPOS/ITEMTYPE].
*/

.section .text
.globl	spawn

.equ	SPEED, 3		//default speed
.equ	MAX_TILE_SKIP, 4	//maximum item spawn skip
.equ	MAX_ITEMS, 7		//maximum item count
.equ	MAX_POS, 15		//maximum item position
.equ	TYPE, 1			//item type mask
.equ	MAP_OFFSET, 5		//offset for map
.equ	INITIAL_Y, 2		//initial y position
.equ	BOTTOM_ROW, 24		//bottomost row number
.equ	MOVE, 1			//move distance

spawn:
	push	{r4-r10, lr}

	OUTPUT		.req	r0		//output of functions
	BASEADDRESS	.req	r1		//base address of a data item
	SPAWNARRAY	.req	r2		//spawn array *address
	ITEMCOUNT	.req	r3		//current spawned item count
	CURRENT		.req	r4		//current tile
	PAST		.req	r5		//last tile since spawn
	REQUIRED	.req	r6		//required amount of tiles for spawn
	DIFFERENCE	.req	r7		//difference between last and current tile count
	XPOSITION	.req	r8		//the generated xposition for a newly spawned item
	ITEMTYPE	.req	r9		//the type of the newly spawned item [fuel/obstacle]
	OFFSET		.req	r10		//offset of array address

	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count
	
	cmp	ITEMCOUNT, #MAX_ITEMS		//compare item count to maximum
	bge	endSpn				//dont spawn if maximum met

	ldr	BASEADDRESS, =tileReq		//load required tiles address
	ldr	REQUIRED, [BASEADDRESS]		//load required tiles

	cmp	REQUIRED, #0			//compare required tiles count to #0
	bgt	cont				//generate new number if tile count is zero

	bl	xorShift			//generate a random number
	and	OUTPUT, #MAX_TILE_SKIP		//mask the returned number with #7
	mov	REQUIRED, OUTPUT		//using output register as a spare register

	cmp	REQUIRED, #0			//compare item requirement to #1
	addeq	REQUIRED, #1			//this ensures no items spawn instantly
	ldr	BASEADDRESS, =tileReq		//load required tiles address
	str	REQUIRED, [BASEADDRESS]		//update required tiles
	b	endSpn				//end the function

//---------------------------------------------------------------------------------------------------//

cont:	ldr	BASEADDRESS, =lastTile		//load last tile address
	ldr	PAST, [BASEADDRESS]		//load last tile

	ldr	BASEADDRESS, =tilePassed	//get current tile count
	ldr	OUTPUT, [BASEADDRESS]

	mov	CURRENT, OUTPUT			//move function output to CURRENT
	sub	DIFFERENCE, CURRENT, PAST	//difference = current tile - last tile

	cmp	REQUIRED, DIFFERENCE		//compare required tile count to the difference
	bgt	endSpn				//continue loop without spawning if difference > 0

//---------------------------------------------------------------------------------------------------//

	bl	xorShift			//generate a random number
	
	mov	XPOSITION, OUTPUT		//output is the new x position
	and	XPOSITION, #MAX_POS		//mask the generated number to the map size (15)
	add	XPOSITION, #MAP_OFFSET		//add the map offset (5)
	
	bl	xorShift			//generate a random number

	mov	ITEMTYPE, OUTPUT		//output is the new item type
	and	ITEMTYPE, #TYPE			//mask the generated number to an item type [0/1][fuel/obstacle]

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count

	add	ITEMCOUNT, #1			//increment spawn array
	mov	OUTPUT, #12
	mul	OFFSET, ITEMCOUNT, OUTPUT	//multiply item count by 12 (three items, four bytes each)
	str	ITEMCOUNT, [BASEADDRESS]	//store incremented item count

	add	SPAWNARRAY, OFFSET		//add the offset to the spawn array
	str	XPOSITION, [SPAWNARRAY], #4	//store x position of new item
	
	mov	r0, #INITIAL_Y			//move zero into r0
	str	r0, [SPAWNARRAY], #4		//store default y position of new item

	str	ITEMTYPE, [SPAWNARRAY]		//store item type of new item

	ldr	BASEADDRESS, =lastTile		//load last tile address
	str	CURRENT, [BASEADDRESS]		//update last tile

endSpn:	
	pop	{r4-r10, lr}
	bx	lr

	.unreq	OUTPUT
	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMCOUNT
	.unreq	CURRENT
	.unreq	PAST
	.unreq	REQUIRED
	.unreq	DIFFERENCE
	.unreq	XPOSITION
	.unreq	ITEMTYPE
	.unreq	OFFSET


//---------------------------------------------------------------------------------------------------//

.globl	moveSpawn

moveSpawn:
	push	{r4-r10, lr}

	BASEADDRESS	.req	r3		//base address
	SPAWNARRAY	.req	r4		//spawn array *address
	ITEMY		.req	r5		//yposition of an item
	ITEMCOUNT	.req	r6		//item count
	COUNTER		.req	r7		//loop counter

	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	mov	COUNTER, #0			//initialize counter to zero

movAll:	cmp	COUNTER, ITEMCOUNT		//compare item count to counter
	bge	fin				//finished moving everything

	ldr	ITEMY, [SPAWNARRAY, #4]!	//load item y position

	add	ITEMY, #MOVE			//move item down one tile
	str	ITEMY, [SPAWNARRAY], #8		//update yposition of item
	add	COUNTER, #1			//increment counter
	b	movAll

fin:	bl	enforceFence			//remove items now off the map

	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMY
	.unreq	ITEMCOUNT
	.unreq	COUNTER

	pop	{r4-r10,lr}
	bx	lr

//---------------------------------------------------------------------------------------------------//

enforceFence:
	push	{r4-r10, lr}

	SPARE		.req	r1		//spare register
	BASEADDRESS	.req	r2		//base address
	SPAWNARRAY	.req	r3		//spawn array *address
	ITEMX		.req	r4		//xposition of an itemi
	ITEMY		.req	r5		//yposition of an item
	ITEMTYPE	.req	r6		//type of item
	ITEMCOUNT	.req	r7		//item count
	COUNTER		.req	r8		//loop counter
	OFFSET		.req	r9		//address offset

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count

	mov	COUNTER, #0			//initialize loop counter
	
	cmp	ITEMCOUNT, #0			//check for items on list
	ble	gated				//end function if nothing there

//---------------------------------------------------------------------------------------------------//

fence:	cmp	COUNTER, ITEMCOUNT		//compare item count to counter
	bge	gated				//end loop

	ldr	ITEMY, [SPAWNARRAY, #4]!	//load item y position
	cmp	ITEMY, #BOTTOM_ROW		//compare item y position to bottom row
	bge	deport				//if item isn't in map boundaries, remove item

	add	SPAWNARRAY, #8			//add offset for next item search
	add	COUNTER, #1			//increment counter
	b	fence

//---------------------------------------------------------------------------------------------------//

deport:	sub	SPAWNARRAY, #4			//address correction
	ldr	BASEADDRESS, =spawnArray	//load spawn array address

	sub	OFFSET, ITEMCOUNT, #1		//decrement itemcount to calculate offset
	mov	SPARE, #12
	mul	OFFSET, SPARE			//calculate offset for last item

	add	BASEADDRESS, OFFSET		//add offset to base address
	ldr	ITEMX, [BASEADDRESS], #4	//load last item xposition
	ldr	ITEMY, [BASEADDRESS], #4	//load last item yposition
	ldr	ITEMTYPE, [BASEADDRESS]		//load last item type

	str	ITEMX, [SPAWNARRAY], #4		//replace deleted item xposition with last item xposition
	str	ITEMY, [SPAWNARRAY], #4		//replace deleted item yposition with last item yposition
	str	ITEMTYPE, [SPAWNARRAY]		//replace deleted item type with last item type

	ldr	BASEADDRESS, =itemCount		//load item count address
	sub	ITEMCOUNT, #1			//decrement item count since an item was removed
	str	ITEMCOUNT, [BASEADDRESS]	//update item count

gated:	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMX
	.unreq	ITEMY
	.unreq	ITEMTYPE
	.unreq	ITEMCOUNT
	.unreq	COUNTER
	.unreq	OFFSET
	.unreq	SPARE

	pop	{r4-r10,lr}
	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	obliterate

.equ	YPOSITION, 22		//fixed yposition of player

obliterate:
	push	{r4-r10, lr}

	ITEMX		.req	r0		//xposition of an item
	ITEMY		.req	r1		//yposition of an item
	XPOSITION	.req	r2		//xposition of player
	BASEADDRESS	.req	r3		//base address
	SPAWNARRAY	.req	r4		//spawn array *address
	ITEMCOUNT	.req	r5		//item count
	COUNTER		.req	r6		//loop counter
	OFFSET		.req	r7		//memory offset
	ITEMTYPE	.req	r8		//type of item
	SPARE		.req	r9		//spare register

	ldr	BASEADDRESS, =player		//load player attribute address
	ldr	XPOSITION, [BASEADDRESS]	//load player xposition

	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	mov	COUNTER, #0			//move zero into loop counter

	cmp	ITEMCOUNT, #1			//check for items on list
	beq	end				//branch to end if there's only one item
	
	cmp	ITEMCOUNT, #0			//check if nothing is on list
	ble	endZ				//branch to end if nothing

//---------------------------------------------------------------------------------------------------//

loop:	cmp	COUNTER, ITEMCOUNT		//compare item count to loop counter
	bge	end				//end function if no matches

	ldr	ITEMX, [SPAWNARRAY], #4		//load item xposition
	ldr	ITEMY, [SPAWNARRAY], #4		//load item yposition

	cmp	ITEMY, #YPOSITION		//compare ypositions of player and item
	bne	next				//continue loop if not equal

	cmp	ITEMX, XPOSITION		//compare xpositions of player and item
	beq	delete				//delete item from list if a match is found

next:	add	COUNTER, #1			//increment loop counter
	add	SPAWNARRAY, #4			//skip item type in memory
	b	loop

//---------------------------------------------------------------------------------------------------//

delete:	sub	SPAWNARRAY, #8			//address correction for matching item
	ldr	BASEADDRESS, =spawnArray	//load spawn array address

	sub	OFFSET, ITEMCOUNT, #1		//decrement itemcount to calculate offset
	mov	SPARE, #12
	mul	OFFSET, SPARE			//calculate offset for last item

	add	BASEADDRESS, OFFSET		//add offset to base address
	ldr	ITEMX, [BASEADDRESS], #4	//load last item xposition
	ldr	ITEMY, [BASEADDRESS], #4	//load last item yposition
	ldr	ITEMTYPE, [BASEADDRESS]		//load last item type

	str	ITEMX, [SPAWNARRAY], #4		//replace deleted item xposition with last item xposition
	str	ITEMY, [SPAWNARRAY], #4		//replace deleted item yposition with last item yposition
	str	ITEMTYPE, [SPAWNARRAY]		//replace deleted item type with last item type

end:	ldr	BASEADDRESS, =itemCount		//load item count address
	sub	ITEMCOUNT, #1			//decrement item count
	str	ITEMCOUNT, [BASEADDRESS]	//update item count

endZ:	.unreq	ITEMX
	.unreq	ITEMY
	.unreq	XPOSITION
	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMCOUNT
	.unreq	COUNTER
	.unreq	OFFSET
	.unreq	ITEMTYPE
	.unreq	SPARE

	pop	{r4-r10,lr}
	bx	lr

.section .data
tileReq:	.int	0		// tiles to count

lastTile:	.int	0		// tile since last spawn

.globl	itemCount
itemCount:	.int	0		//number of items currently spawned

.globl	spawnArray
spawnArray:	.skip	7 * 3 * 4	//seven item max * three parameters per item * four bytes
		.end
