/*
---IMPORTANT---
About the "xorShift" function:
	NO PARAMETERS: Everything it needs is in memory.
	RETURNS IN R0: Produces a semi-randomly generated number.
	USAGE: Call it where you need it and you get a random number returned in r0.

---NOTES---
a revised version of rng

XORSHIFT PRODUCES A RANDOM NUMBER THAT IS HUGE.
	- Please mask it to a smaller number for use.
	- "LIMIT" register currently unused, but would be used to generally limit number size.
*/

.globl	xorShift

xorShift:
	push	{r4-r10, lr}

	T	.req	r4
	Y	.req	r5
	Z	.req	r6
	W	.req	r7

	BASEADDRESS	.req	r0	//base address for array of random numbers
	LIMIT		.req	r1	//to limit the maximum number

	ldr	BASEADDRESS, =rngArr	//load base address
	ldr	T, [BASEADDRESS]	//load x into t

	eor	T, T, lsl #11		//t ^= t << 11 (^ is exclusive or)
	eor	T, T, lsr #8		//t ^= t >> 8

	ldr	Y, [BASEADDRESS, #4]	//x = y
	str	Y, [BASEADDRESS], #4
	ldr	Z, [BASEADDRESS, #4]	//y = z
	str	Z, [BASEADDRESS], #4
	ldr	W, [BASEADDRESS, #4]	//z = w
	str	W, [BASEADDRESS], #4

	eor	W, W, lsr #19		//w ^= w >> 19
	eor	W, T			//w ^= t, returning W

	str	W, [BASEADDRESS, #4]	//store the w

	mov	r0, W			//return w

	.unreq	T
	.unreq	Y
	.unreq	Z
	.unreq	W

	.unreq	BASEADDRESS
	.unreq	LIMIT

	pop	{r4-r10}
	bx	lr

.section .data
rngArr:	.int	1, 2, 3, 4		//an array of numbers initialized to 1, 2, 3, 4

