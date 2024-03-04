all:
	nasm -f elf64 -F dwarf -g as.asm
	gcc as.o -o as -fno-pie -no-pie -nostdlib
	

