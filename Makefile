# Type "make" in this folder to compile and run OS on Linux.

B_MAIN = bin/main
B_SOFT = bin/software
RAW_OS = bin/os.bin
FILES_TO_CAT = $(B_MAIN)/boot.bin $(B_MAIN)/kernel.bin $(B_MAIN)/fs.bin $(B_SOFT)/dumper.bin

build:
	@nasm -f bin -o $(B_MAIN)/boot.bin src/boot.asm
	@nasm -f bin -o $(B_MAIN)/kernel.bin src/kernel.asm
	@nasm -f bin -o $(B_MAIN)/fs.bin src/fs.asm
	@nasm -f bin -o $(B_SOFT)/dumper.bin src/dumper.asm
	@cat $(FILES_TO_CAT) > $(RAW_OS) 

	@rm $(B_MAIN)/*
	@rm $(B_SOFT)/*

run:
	@qemu-system-x86_64	$(RAW_OS)