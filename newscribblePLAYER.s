/*
a revised version of the player
*/

.section .text

.globl	movePlayer

.equ	LEFT, 0			//flag value for left movement
.equ	RIGHT, 1		//flag value for right movement
.equ	MOVE, 1			//tile distance for a single move block

movePlayer:
	push	{r4-r10, lr}

	DIRECTION	.req	r0		//direction to move player
	BASEADDRESS	.req	r3		//base address of player attributes
	XPOSITION	.req	r4		//xposition of player

	ldr	BASEADDRESS, =player		//load player attributes address
	ldr	XPOSITION, [BASEADDRESS]	//load player xposition
	
	cmp	DIRECTION, LEFT			//compare direction to LEFT
	beq	goLeft				//if equal branch to move left
	bne	goRite				//if not equal branch to move right

goLeft:	sub	XPOSITION, MOVE			//decrement xposition value
	b	next

goRite:	add	XPOSITION, MOVE			//increment xposition value

next:	str	XPOSITION, [BASEADDRESS]	//update xposition

	.unreq	DIRECTION
	.unreq	BASEADDRESS
	.unreq	XPOSITION
	
	pop	{r4-r10}
	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	resetPlayer

.equ	DEFAULT_X, 13		//default xposition
.equ	DEFAULT_Y, 22		//default yposition
.equ	DEFAULT_FUEL, 100	//default fuel amount
.equ	DEFAULT_LIVES, 3	//default lives

resetPlayer:
	
	BASEADDRESS	.req	r0	//base address of player attributes

	ldr	BASEADDRESS, =player			//load player attributes address
	str	DEFAULT_X, [BASEADDRESS], #4		//store default player xposition
	str	DEFAULT_Y, [BASEADDRESS], #4		//store default player yposition
	str	DEFAULT_FUEL, [BASEADDRESS], #4		//store default player fuel amount
	str	DEFAULT_LIVES, [BASEADDRESS]		//store default player lives	

	.unreq	BASEADDRESS

	bx	lr

//---------------------------------------------------------------------------------------------------//

.globl	resetPlayerPosition

resetPlayerPosition:
	
	BASEADDRESS	.req	r0	//base address of player attributes

	ldr	BASEADDRESS, =player		//load player attributes address
	str	DEFAULT_X, [BASEADDRESS]	//store default player xposition

	.unreq	BASEADDRESS
	
	bx	lr

.section .data
player:	.int	13		//x position of player
	.int	22		//y position of player
	.int	100		//player fuel
	.int	3		//player lives
