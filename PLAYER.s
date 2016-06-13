/*
---IMPORTANT---
About the "movePlayer" function:
	ONE PARAMETER: Takes in a flag that marks a direction to move in [Left/Right][0/1].
	VOID: Moves player without returning anything.
	USAGE: Used after taking in an input in the game loop in order to move the player in the specified direction.

About the "resetPlayer" function:
	NO PARAMETERS: Everything it needs is in memory.
	VOID: Resets all aspects of the player.
	USAGE: For starting a new game, resetPlayer is used to ensure all player attributes are reset.

About the "resetPlayerPosition" function:
	NO PARAMETERS: Everything it needs is in memory.
	VOID: Resets the position of the player.
	USAGE: Used when the player must be set back to the center of the map after an event ie. collision.

---NOTES---
a revised version of the player, with the addition of clear code and neat documentation.

MOVEPLAYER ALTERS THE PLAYER POSITIONS STORED IN MEMORY.
	- Takes in a Left/Right flag in r0.
	- I am aware I spelt "right" as "rite" in the "goRite" label.

RESETPLAYER RESETS ALL ATTRIBUTES ASSOCIATED WITH THE PLAYER.
	- This includes X Position, Y Position, Fuel and Lives.

RESETPLAYERPOSITION RESETS ONLY THE POSITIONS OF THE PLAYER.
	- X and Y positions of player set to default.
	- Y technically never changes, but we have it in our code for clarity.

PLAYER CONTAINS THE ATTRIBUTES OF A PLAYER: [0]XPOSITION [1]YPOSITION [2]FUEL [3]LIVES.
*/

.section .text

.globl	movePlayer

.equ	LEFT, 0				//flag value for left movement
.equ	RIGHT, 1			//flag value for right movement
.equ	MOVE, 1				//tile distance for a single move block
.equ	DEFAULT_X, 12			//default xposition
.equ	DEFAULT_Y, 21			//default yposition
.equ	DEFAULT_FUEL, 100		//default fuel amount
.equ	DEFAULT_LIVES, 3		//default lives

movePlayer:
	push	{r4-r10, lr}

	DIRECTION	.req	r0		//direction to move player
	BASEADDRESS	.req	r3		//base address of player attributes
	XPOSITION	.req	r4		//xposition of player

	ldr	BASEADDRESS, =oneDirection	//load player attributes address
	str	DIRECTION, [BASEADDRESS]	//store the direction

	ldr	BASEADDRESS, =player		//load player attributes address
	ldr	XPOSITION, [BASEADDRESS]	//load player xposition
	
	cmp	DIRECTION, #LEFT			//compare direction to LEFT
	beq	goLeft				//if equal branch to move left
	bne	goRite				//if not equal branch to move right

goLeft:	sub	XPOSITION, #MOVE			//decrement xposition value
	b	next

goRite:	add	XPOSITION, #MOVE			//increment xposition value

next:	str	XPOSITION, [BASEADDRESS]	//update xposition

	.unreq	DIRECTION
	.unreq	BASEADDRESS
	.unreq	XPOSITION
	
	pop	{r4-r10}
	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	resetPlayer

resetPlayer:
	
	BASEADDRESS	.req	r0			//base address of player attributes
	PARAMETER	.req	r1			//parameter register

	ldr	BASEADDRESS, =player			//load player attributes address
	mov	PARAMETER, #DEFAULT_X
	str	PARAMETER, [BASEADDRESS], #4		//store default player xposition
	mov	PARAMETER, #DEFAULT_Y
	str	PARAMETER, [BASEADDRESS], #4		//store default player yposition
	mov	PARAMETER, #DEFAULT_FUEL
	str	PARAMETER, [BASEADDRESS], #4		//store default player fuel amount
	mov	PARAMETER, #DEFAULT_LIVES
	str	PARAMETER, [BASEADDRESS]		//store default player lives	

	.unreq	BASEADDRESS
	.unreq	PARAMETER

	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	resetPlayerPosition

resetPlayerPosition:
	
	BASEADDRESS	.req	r0			//base address of player attributes
	PARAMETER	.req	r1			//parameter register

	ldr	BASEADDRESS, =player			//load player attributes address
	mov	PARAMETER, #DEFAULT_X
	str	PARAMETER, [BASEADDRESS]		//store default player xposition

	.unreq	BASEADDRESS
	.unreq	PARAMETER

	bx	lr

.section .data
.align
.globl	player
player:	.int	12		//x position of player
	.int	21		//y position of player
	.int	100		//player fuel
	.int	3		//player lives
.globl	oneDirection
oneDirection:
	.int	2		//which direction player moved
