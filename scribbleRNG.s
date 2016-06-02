//random number generator for random cars and fuel placements

/*

--PSEUDO--

int x, y, z, w;		//initialized to NON-ZERO numbers bruh

as a function:
	int t = x;	//declare variable t == x
	t ^= t << 11	//t power of t shifted left 11 times (big number)
	t ^= t >> 8;	//t power of t shifted right 8 times (smaller number)
	x = y;		//conveyor belts the other variables for next time bruh
	y = z;
	z = w;
	w ^= w >> 19;	//makes the last variable equal to power of itself shifted 19 times right (smaller)
	w ^ = t		//make it big again by powering it to t
	return w	//send that bitch home

 not sure about the and	r1, #0xffffffff	but the goal was to keep the number within a registers size

*/

xorShift:
	push	{r4-r10}

	ldr	r0, =rngArr		//address of array
	ldr	r1, [r0]		//load x into r1

	mov	r2, r1			//dupe t
	mov	r3, r2 lsl #11		//shift t 11 times left

eleven:	cmp	r3, #0			//comparing counter to 0
	ble	next
	
	mul	r1, r2			//r1 *= r2
	and	r1, #0xffffffff		//keep the number within a register
	sub	r3, #1			//decrement r3
	b	eleven

next:	mov	r2, r1			//dupe t
	mov	r3, r2 lsr #8		//shift t 8 times right
	
eight:	cmp	r3, #0			//comparing counter to 0
	ble	cont

	mul	r1, r2			//r1 *= r2
	and	r1, #0xffffffff		//keep the number within a register
	sub	r3, #1			//decrement r3
	b	eight

cont:	ldr	r2, [r0, #4]		//load y into r2
	str	r2, [r0]		//move y into x
	ldr	r2, [r0, #8]		//load z into r2
	str	r2, [r0, #4]		//move z into y
	ldr	r2, [r0, #12]		//load w into r2
	str	r2, [r0, #8]		//move w into z

	mov	r0, r2			//dupe w
	mov	r3, r0 lsr #19		//shift w 19 times right

nein:	cmp	r3, #0			//comparing counter to 0
	ble	proc

	mul	r2, r0			//r2 *= r0
	and	r1, #0xffffffff		//keep the number within a register
	sub	r3, #1			//decrement r3
	b	nein

proc:	mov	r0, r2			//dupe w

tee:	cmp	r1, #0			//comparing counter(t) to 0
	ble	end

	mul	r2, r0			//r2 *= r0
	and	r1, #0xffffffff		//keep the number within a register
	sub	r3, #1			//decrement r3
	b	tee

end:	ldr	r0, =rngArr		//load array address again
	str	r2, [r0, #12]		//w ^= t

	mov	r0, r2			//returning in r0

	pop	{r4-r10}

section .data

rngArr:	.skip	4 * 4
	.end

