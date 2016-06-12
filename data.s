.section .data

.align 4

.globl FrameBufferInit
FrameBufferInit:
	.int 	22 * 4			//Buffer size in bytes
	.int	0			//Indicates a request to GPU
	.int	0x00048003		//Set Physical Display width and height
	.int	8			//size of buffer
	.int	8			//length of value
	.int	1024			//horizontal resolution
	.int	768			//vertical resolution

	.int	0x00048004		//Set Virtual Display width and height
	.int	8			//size of buffer
	.int	8			//length of value
	.int 	1024			//same as physical display width and height
	.int 	768

	.int	0x00048005		//Set bits per pixel
	.int 	4			//size of value buffer
	.int	4			//length of value
	.int	16			//bits per pixel value

	.int	0x00040001		//Allocate framebuffer
	.int	8			//size of value buffer
	.int	8			//length of value

.globl FrameBuffer
FrameBuffer:
	.int	0			//value will be set to framebuffer pointer
	.int	0			//value will be set to framebuffer size			

	.int	0			//end tag, indicates the end of the buffer

.globl FrameBufferPointer
FrameBufferPointer:
	.int	0

.globl itemCount
itemCount:	.int	0		//number of items currently spawned

.globl spawnArray
spawnArray:	.skip	7 * 3 * 4	//seven item max * three parameters per item * four bytes

.globl tileReq
tileReq:	.int	0		//tiles to count

.globl lastTile
lastTile:	.int	0		//tile since last spawn

.globl	tilePassed
tilePassed:
	.int 	0	// total 22 * 25 tiles

.globl	laneNum
laneNum:
	.int	0	// keeps track of how to update the map

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

.globl	player
player:	.int	12		//x position of player
	.int	21		//y position of player
	.int	100		//player fuel
	.int	3		//player lives

.globl	oneDirection
oneDirection:
	.int	2		//which direction player moved

.globl rngArr
rngArr:	.int	7001, 9001, 83, 666	//an array of numbers initialized to 1, 2, 3, 4

.globl font
font:		.incbin	"font.bin"

.globl fuel
fuel: .ascii "FUEL:"	// 5

.globl life
life: .ascii "LIVES:"	// 6

.globl tuto1
tuto1: .ascii "GET TRUMP TO THE WHITE HOUSE!"	// 29

.globl tuto2
tuto2: .ascii "AVOID BERNIE, COLLECT TOUPEES"	// 29

.globl instr1
instr1: .ascii "SELECT: MAIN MENU"	// 17

.globl instr2
instr2: .ascii "START: RESTART"	// 14

.globl pressA
pressA: .ascii "PRESS A TO START"	// 16

.globl dsclm
dsclm: .ascii "DISCLAIMER: We are not Trump supporters."	// 40

.globl prompt
prompt: .ascii "PRESS ANY BUTTON TO CONTINUE"	// 28

.globl	status
// Checks if the player lost or won
status:
	.int	0

.globl	gameState
// Checks if the player has chosen to quit
gameState:
	.int	0
	
.globl	faceState
// tracks which face Trump will make
faceState:				
	.int	0			// 0 - normal
					// 1 - collision
					// 2 - fuel
.globl	play
// Checks if the player has pressed A					
play:
	.int	0
	.end
