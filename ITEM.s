/*
brand new version of item.s
*/

.section .text

.globl	spawn

.equ	MAX_POS, 7
.equ	MAX_ITEMS, 7
.equ	MAX_OFFSET, 5
.equ	TYPE, 1
.equ	INITIAL_Y, 2

spawn:

	OUTPUT		.req	r0
	BASEADDRESS	.req	r4
	ITEMCOUNT	.req	r5
	XPOSITION	.req	r6
	SPAWNARRAY	.req	r7
	SPARE		.req	r8
	ITEMTYPE	.req	r9

	push	{r4-r10, lr}

	ldr	BASEADDRESS, =itemCount		//load item counter address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item counter

	cmp	ITEMCOUNT, #MAX_ITEMS		//compare item counter to maximum items
	bge	endSpn				//dont spawn if list is full

	bl	xorShift			//generate a random number
	and	OUTPUT, #255			//mask a number to a reasonable range
	cmp	OUTPUT, #128			//permit a spawn of 50% chance
	bge	endSpn				//dont spawn

spn:	bl	xorShift			//generate a random number
	and	XPOSITION, OUTPUT, #MAX_POS	//mask generated number to fit map
	add	XPOSITION, #MAP_OFFSET		//add the mask offset
	
	bl	xorShift			//generate a random number
	and	ITEMTYPE, OUTPUT, #TYPE		//mask the generate number to an item type

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	add	ITEMCOUNT, #1			//increment item count

	mov	SPARE, #12
	mul	OFFSET, ITEMCOUNT, SPARE	//multiply item count by 12
	str	ITEMCOUNT, [BASEADDRESS]	//store item count

	add	SPAWNARRAY, OFFSET		//add the offset
	str	XPOSITION, [SPAWNARRAY], #4	//store xposition

	mov	SPARE, #INITIAL_Y		//move default y into spare
	str	SPARE, [SPAWNARRAY], #4		//store default y position
	str	ITEMTYPE, [SPAWNARRAY]		//store item type into memory

	ldr	BASEADDRESS, =itemCount
	str	ITEMCOUNT, [BASEADDRESS]	//update the item count

endSpn:	.unreq	OUTPUT
	.unreq	BASEADDRESS
	.unreq	ITEMCOUNT
	.unreq	XPOSITION
	.unreq	SPAWNARRAY
	.unreq	SPARE
	.unreq	ITEMTYPE

	pop	{r4-r10, lr}
	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	rebirth

.equ	LAST_ROW, 21

rebirth:
	push	{r4-r10, lr}

	OUTPUT		.req	r0
	BASEADDRESS	.req	r3
	ITEMCOUNT	.req	r4
	ITEMY		.req	r5
	ITEMX		.req	r6
	COUNTER		.req	r7
	SPARE		.req	r8
	ITEMTYPE	.req	r9
	SPAWNARRAY	.req	r10

	ldr	SPAWNARRAY, =spawnArray		//load spawn array address
	ldr	BASEADDRESS, =itemCount		//load item count address
	ldr	ITEMCOUNT, [BASEADDRESS]	//load item count

	mov	COUNTER, #0			//initialize counter to zero

	cmp	ITEMCOUNT, #7			//check for items on list

	blt	gated				//end function if list not full

rep:	cmp	COUNTER, #7
	bge	gated

	ldr	ITEMY, [SPAWNARRAY, #4]		//load item y position
	cmp	ITEMY, #LAST_ROW		//compare item y position to last row
	blt	pass

	bl	xorShift			//generate a random number
	and	ITEMX, OUTPUT, #MAX_POS		//mask generated number to fit map
	add	ITEMX, #MAP_OFFSET		//add the mask offset
	
	bl	xorShift			//generate a random number
	and	ITEMTYPE, OUTPUT, #TYPE		//mask the generate number to an item type

	mov	SPARE, #INITIAL_Y		//move default y into spare

	str	ITEMX, [SPAWNARRAY], #4		//store x position
	str	SPARE, [SPAWNARRAY], #4		//store y position
	str	ITEMTYPE, [SPAWNARRAY], #4	//store item type

pass:	add	COUNTER, #1			//increment counter
	b	rep

gated:	.unreq	OUTPUT
	.unreq	BASEADDRESS
	.unreq	ITEMCOUNT
	.unreq	ITEMY
	.unreq	ITEMX
	.unreq	COUNTER
	.unreq	SPARE
	.unreq	ITEMTYPE
	.unreq	SPAWNARRAY

	pop	{r4-r10, lr}
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

	add	ITEMY, #MOVE			//move item down one tile
	str	ITEMY, [SPAWNARRAY], #8		//update yposition of item
	add	COUNTER, #1			//increment counter
	b	movAll

fin:	bl	rebirth				//remove items now off the map and spawn new ones

	.unreq	BASEADDRESS
	.unreq	SPAWNARRAY
	.unreq	ITEMY
	.unreq	ITEMCOUNT
	.unreq	COUNTER

	pop	{r4-r10,lr}
	bx	lr

.section .data
.globl	itemCount
itemCount:	.int	0		//number of items currently spawned

.globl	spawnArray
spawnArray:	.skip	7 * 3 * 4	//seven item max * three parameters per item * four bytes
