.section .init
.global map


/*
Instance of game environment
	n x m grid
	n & m >= 20 tiles	
	specifies fuel of player
	specifies number of lives left
	specifies what each cell of grid is (road/side tile)
	of width, there is at least 5 cells on either side
		that are side tiles

*/
.section .text
map:
	




.section .data
	// total 32 * 24 tiles
leftSide:
	.skip 216 * 4	// 24 * 9 tiles
	.end
rightSide:
	.skip 120 * 4	// 24 * 5 tiles 
	.end
road:
	.skip 432 * 4	// 24 * 18 tiles
	.end		


