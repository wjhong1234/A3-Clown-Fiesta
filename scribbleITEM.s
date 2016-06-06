/*
---IMPORTANT---
About function "spawn":
	NO PARAMETER: A flag to determine whether the spawned item is an obstacle or fuel item.
	VOID: This function determines where the items spawn.
	OTHER: This file keeps track of each item in an array [NUMBER] + [XPos/YPos/Flag]*.

About function "move":
	NO PARAMETERS: ARE YOU DEAF I SAID IT TAKES NO PARAMETERS STOP READING THIS.
	VOID: This function moves every spawned item DOWN.
	OTHER: This function deletes all items that have reached the end of the line.

About function "obliterate":
	ONE PARAMETER: This function takes in an XPosition.
	VOID: Returns nothing, modifies spawn array.
	OTHER: This function uses the given XPosition to determine what item to destroy. Horrible idea, but all we got kids.

---MISSING---
	"spawn" function requires a way to count how many tiles has passed the player on the screen.
	Importantly, this function DOES NOT DRAW. Fucking hell this just does logic. Please draw somewhere else tyvm.

---NOTES---
take number from rng to place on the screen somewhere.

THIS FUNCTION LIMITS THE AMOUNT OF ITEMS SPAWNED TO 7. WE DON'T WANT FILTHY CLUTTER.

function for spawns:
	//get random number from rng to and with #7 so obstacles spawn pretty fast within 7 tiles
	//make obstacle spawn after going through that many tiles
	//obstacle position based on another random number within the road

moves down spawned items in list:
	gets first four bits to see how many times the loop is gonna be looped
	for each item we move them down a specific number of pixels each loop
	when an item reaches the end of the map, body that fool

THE FIRST FOUR BITS SHOW HOW MANY ITEMS HAVE BEEN SPAWNED ALREADY
AN ITEM IS DELETED WHEN IT'S OFF THE MAP this creates room for a new item if list is full

delete an item:
	removes item from list and moves the last item to the empty spot
	ONLY REMOVES ONE ITEM AT A TIME BECAUSE FUCK YOU

*/

.equ	SPEED, 3			//DEFAULT SPEED 

spawn:

	PASTILE		.req	r1
	CURRENTILE	.req	r0
	DIFFERENCE	.req	r2
	REQTILE		.req	r3

	push	{r4-r10}

	//***the following segment decides how many tiles in the obstacle will spawn.
	ldr	r0, =pasT		//load past tile counter
	ldr	PASTILE, [r0]		//load actual past tile number

	bl	countTiles		//currenTILE - pasTILE into DIFFERENCE

	sub	DIFFERENCE, CURRENTILE, PASTILE

	ldr	r0, =tiles		//load address of tile count
	ldr	REQTILE, [r0]		//load required tiles count

	cmp	REQTILE, #0		//compare tile count to zero
	bgt	cSpn			//generate new number if zero

	bl	xorShift		//generate a random number
	and	r1, r0, #7		//and with 7 to get number within 7
	cmp	r1, #0
	addeq	r1, #1			//if the generated number is zero, add one
	str	r1, =tiles
	b	spnEnd			//end function
	
	//only spawn new item if tilereq is met
cSpn:	cmp	REQTILE, DIFFERENCE	//compare tile difference to tile spawn number
	blt	spnEnd			//end function

	.unreq	PASTILE
	.unreq	CURRENTILE
	.unreq	DIFFERENCE
	.unreq	REQTILE

	//*** this is to generate a position to spawn in
	bl	xorShift		//generate another random number
	and	r0, #0b111111111	//and this to make it smaller

	//***crop guarantees that r0 will be a number within the size of the road.
crop:	cmp	r0, *ROADMAX		//compare randomly generated number to usable road size
	bgt	smalls
	cmp	r0, *ROADMIN		//compare randomly generated number to usable road rize
	blt	bigs
	b	itFits			//keep checking until number is within road

smalls:	sub	r0, *ROADMAX		//if it's bigger subtract the max from the number
	b	crop

bigs:	add	r0, *ROADMIN		//if it's smaller add the min to the number
	b	crop
	
	NEWADDRESS	.req	r2
	BASEADDRESS	.req	r2
	OFFSET		.req	r1	
	COUNTER		.req	r1
	ITEMTYPE	.req	r0
	XPOS		.req	r0

itFits:	ldr	BASEADDRESS, =spnArr	//load address
	ldr	COUNTER, [BASEADDRESS]	//load counter

	add	COUNTER, #1		//increment counter
	str	COUNTER, [BASEADDRESS]

	lsl	COUNTER, #2		//multiply counter by 4
	add	NEWADDRESS, OFFSET	//address for xpos of new item (offset)
	str	XPOS, [NEWADDRESS], #4	//store xpos of new item into memory

	str	#0, [NEWADDRESS], #4	//store zero into ypos
	
	bl	xorShift		//generate new random number
	and	r0, #1			//make it either zero or one
	str	ITEMTYPE, [r2]		//store random item type into memory for item

	ldr	r0, =tiles		//load tile address
	str	#0, [r0]		//store zero into tilereq

	ldr	r1, =pasT		//load last time spawn was made
	bl	countTiles		//current tile
	str	r0, [r1]		//load current tile count into last spawn

	NEWADDRESS	.unreq
	BASEADDRESS	.unreq
	OFFSET		.unreq
	COUNTER		.unreq
	ITEMTYPE	.unreq
	XPOS		.unreq

spnEnd:	pop	{r4-r10}

spawnMove:
	push	{r4-r10}
	
	ldr	r1, =spnArr		//load spawn array address
	ldr	r3, [r1], #4		//load counter into r3

mDown:	cmp	r3, #0			//compare counter to 0
	ble	eDown			//if no more items, end function

	add	r1, #4			//skip the xpos of item
	ldr	r0, [r1, #4]!		//load ypos of item

	add	r0, SPEED		//add the pixels to the item pos (update item position)
	str	[r1], r0		//store the new ypos

	cmp	r0, *ROADEND		//checks if the item is exiting the map
	blge	obliterate		//if true, obliterate item from list and map

	add	r1, #4			//skip item type flag
	sub	r3, #1			//decrement counter
	b	mDown			//repeat loop 
	
eDown:	pop	{r4-r10}

obliterate:
	push	{r4-r10}

	ldr	r1, =spnArr		//load spawn array address
	ldr	r3, [r1], #4		//load counter in r2

remove:	cmp	r3, #0			//makes sure there is stuff in the array
	ble	bye			//if there isn't return from function

	add	r1, #4			//skip xpos
	ldr	r2, [r1], #4		//load ypos into r2, then skips the item type
	cmp	r2, r0			//compare given ypos to ypos of item
	beq	clear			//if equal, removes item

	sub	r3, #1			//decrement counter
	b	remove			//else, check another item

clear:	ldr	r1, =spnArr		//load spawn array address
	ldr	r0, [r1]		//load counter

	add	r3, r3, lsl #1		//multiply counter by 3
	lsl	r3, #2			//multiply by 4
	add	r2, r3, r1		//start address of item 

	add	r0, r0, lsl #1		//multiply last item by 3
	lsl	r0, #2			//multiply last item by 4
	add	r3, r0, r1		//address of last item

	ldr	r0, [r3], #4		//load xpos of last item
	str	r0, [r2], #4		//store last item xpos into deleted item xpos
	
	ldr	r0, [r3], #4		//load ypos of last item
	str	r0, [r2], #4		//store last item ypos into deleted item ypos
	
	ldr	r0, [r3]		//load item type of last item
	str	r0, [r2]		//store last item type into deleted item type

	ldr	r0, [r1]		//load counter
	sub	r0, #1			//decrement counter
	str	r0, [r1]		//store counter (update that bitch)

bye:	pop	{r4-r10}

.section .data
spnArr:	.skip	(7 * 3 * 4) + 4		//Allocate memory for 7 items and the item counter
	.end

pasT:	.int	0			//tile since last loop

tiles:	.int 	0			//tiles to count
