/*
Instance of game environment
	specifies fuel of player
	specifies number of lives left
	specifies what each cell of grid is (road/side tile)
	of width, there is at least 5 cells on either side
		that are side tiles

*/
.section .text
	// adjust the latter number where necessary
	.equ	END, 24 * 8	// end of the map
	
	MAP_Y .req r4
	

initializeMap:
	push	{r4-r10, lr}

	//bl	drawMap
	

	pop	{r4-r10, lr}
	bx	lr

mapState:
	

updateMap:
	



.section .data
	// total 32 * 24 tiles
/*
leftSide:
	.skip 264 * 4	// 24 * 11 tiles
	.end
rightSide:
	.skip 120 * 4	// 24 * 5 tiles 
	.end
*/
road:
	.skip 384 * 4	// 24 * 16 tiles
	.end		


