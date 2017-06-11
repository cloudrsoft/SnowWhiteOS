bits 64

extern kernel_main
global start

section .text

start:
	call kernel_main
	cli
	hlt
