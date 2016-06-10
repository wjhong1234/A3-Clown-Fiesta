/*
---IMPORTANT---
About the "spawn" function:
	NO PARAMETERS: Everything it needs is in memory.
	VOID: Spawns new items based on randomly generated numbers.
	USAGE: Called in the primary game loop, the function automatically times and generates non-playable items ie. fuel and Bernie Sanders.

---NOTES---
a revised version of item and the spawn functions

THIS FUNCTION LIMITS THE AMOUNT OF GENERATED ITEMS ON THE MAP TO 7.
	- Game map is fairly small, so anything larger would make it too difficult to play.
	- The number 7 is easy to mask things with in binary because it's 0b111.
	- 7 items are not a burden to load and store things in memory.

SPAWNARRAY CONTAINS 7 GROUPS OF THREE GROUPS OF PARAMETERS: [XPOS/YPOS/ITEMTYPE].
*/

.section .text
.globl	spawn

.equ	SPEED, 3		//default speed
.equ	MAX_ITEMS, 7		//maximum item count
.equ	MAX_POS, 15		//maximum item position
.equ	TYPE, 1			//item type mask
.equ	MAP_OFFSET, 5		//offset for map
.equ	INITIAL_Y, 0		//initial y position
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

	ldr	BASEADDRESS, =tileReq		//load required tiles address
	ldr	REQUIRED, [BASEADDRESS]		//load required tiles

	cmp	REQUIRED, #0			//compare required tiles count to #0
	bgt	cont				//generate new number if tile count is zero

	bl	xorShift			//generate a random number
	and	REQUIRED, OUTPUT, MAX_ITEMS	//mask the returned number with #7

	cmp	REQUIRED, #0			//compare item requirement to #1
	addeq	REQUIRED, #1			//this ensures no items spawn instantly
	str	REQUIRED, [BASEADDRESS]		//update required tiles
	b	endSpn				//end the function

//---------------------------------------------------------------------------------------------------//

cont:	ldr	BASEADDRESS, =lastTile		//load last tile address
	ldr	PAST, [BASEADDRESS]		//load last tile

	bl	countTiles			//get current tile count

	mov	CURRENT, OUTPUT			//move function output to CURRENT
	sub	DIFFERENCE, CURRENT, PAST	//difference = current tile - last tile

	cmp	REQUIRED, DIFFERENCE		//compare required tile count to the difference
	bgt	endSpn				//continue loop without spawning if difference > 0

//---------------------------------------------------------------------------------------------------//

	bl	xorShift			//generate a random number
	
	mov	XPOSITION, OUTPUT		//output is the new x position
	and	XPOSITION, MAX_POS		//mask the generated number to the map size (15)
	add	XPOSITION, MAP_OFFSET		//add the map offset (5)
	
	bl	xorShift			//generate a random number

	mov	ITEMTYPE, OUTPUT		//output is the new item type
	and	ITEMTYPE, TYPE			//mask the generated number to an item type [0/1][fuel/obstacle]

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count

	add	ITEMCOUNT, #1			//increment spawn array
	mul	OFFSET, ITEMCOUNT, #12		//multiply item count by 12 (three items, four bytes each)
	str	ITEMCOUNT, [BASEADDRESS]	//store incremented item count

	add	SPAWNARRAY, OFFSET		//add the offset to the spawn array
	str	XPOSITION, [SPAWNARRAY], #4	//store x position of new item
	
	mov	r0, INITIAL_Y			//move zero into r0
	str	r0, [SPAWNARRAY], #4		//store default y position of new item

	str	ITEMTYPE, [SPAWNARRAY]		//store item type of new item

	ldr	BASEADDRESS, =lastTile		//load last tile address
	str	CURRENT, [BASEADDRESS]		//update last tile

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

endSpn:	pop	{r4-r10}
	bx	lr

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
	add	ITEMY, MOVE			//move item down one tile
	str	ITEMY, [SPAWNARRAY], #8		//update yposition of item
	add	COUNTER, #1			//increment counter
	b	movAll

fin:	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMY
	.unreq	ITEMCOUNT
	.unreq	COUNTER

	pop	{r4-r10}
	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	obliterate

.equ	YPOSITION, 22		//fixed yposition of player

obliterate:
	push	{r4-r10, lr}

	ITEMX		.req	r0	//xposition of an item
	ITEMY		.req	r1	//yposition of an item
	XPOSITION	.req	r2	//xposition of player
	BASEADDRESS	.req	r3	//base address
	SPAWNARRAY	.req	r4	//spawn array *address
	ITEMCOUNT	.req	r5	//item count
	COUNTER		.req	r6	//loop counter
	OFFSET		.req	r7	//memory offset
	ITEMTYPE	.req	r8	//type of item

	ldr	BASEADDRESS, =player		//load player attribute address
	ldr	XPOSITION, [BASEADDRESS]	//load player xposition

	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, =[BASEADDRESS]	//load item count

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	mov	COUNTER, #0			//move zero into loop counter

	cmp	ITEMCOUNT, #1			//check for items on list
	beq	end				//branch to end if there's only one item

loop:	cmp	COUNTER, ITEMCOUNT		//compare item count to loop counter
	bge	end				//end function if no matches

	ldr	ITEMX, [SPAWNARRAY], #4		//load item xposition
	ldr	ITEMY, [SPAWNARRAY], #4		//load item yposition

	cmp	ITEMY, YPOSITION		//compare ypositions of player and item
	bne	cont				//continue loop if not equal

	cmp	ITEMX, XPOSITION		//compare xpositions of player and item
	beq	delete				//delete item from list if a match is found

cont:	add	COUNTER, #1			//increment loop counter
	add	SPAWNARRAY, #4			//skip item type in memory
	b	loop

delete:	sub	SPAWNARRAY, #8			//address correction for matching item
	ldr	BASEADDRESS, =spawnArray	//load spawn array address

	sub	OFFSET, ITEMCOUNT, #1		//decrement itemcount to calculate offset
	mul	OFFSET, #12			//calculate offset for last item

	add	BASEADDRESS, OFFSET		//add offset to base address
	ldr	ITEMX, [BASEADDRESS], #4	//load last item xposition
	ldr	ITEMY, [BASEADDRESS], #4	//load last item yposition
	ldr	ITEMTYPE, [BASEADDRESS]		//load last item type

	str	ITEMX, [SPAWNARRAY], #4		//replace deleted item xposition with last item xposition
	str	ITEMY, [SPAWNARRAY], #4		//replace deleted item yposition with last item yposition
	str	ITEMTYPE, [BASEADDRESS]		//replace deleted item type with last item type

end:	ldr	BASEADDRESS, =itemCount		//load item count address
	sub	ITEMCOUNT, #1			//decrement item count
	str	ITEMCOUNT, [BASEADDRESS]	//update item count

	.unreq	ITEMX
	.unreq	ITEMY
	.unreq	XPOSITION
	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMCOUNT
	.unreq	COUNTER
	.unreq	OFFSET
	.unreq	ITEMTYPE

	pop	{r4-r10}
	bx	lr

.section .data
itemCount:	.int	0		//number of items currently spawned

spawnArray:	.skip	7 * 3 * 4	//seven item max * three parameters per item * four bytes

tileReq:	.int	0		//tiles to count

lastTile:	.int	0		//tile since last spawn
