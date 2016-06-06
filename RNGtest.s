
.section .init
.globl	_start

_start:
	bl	main

.section .text

main:
	mov	sp, #0x8000

	bl	InitUART
	bl	EnableJTAG

	bl	xorShift
	//CHECK REGISTER IN GDB

