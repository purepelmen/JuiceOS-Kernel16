build:
	@nasm -f bin -o bin/boot.bin src/boot.asm
	@nasm -f bin -o bin/kernel.bin src/kernel.asm
	@nasm -f bin -o bin/fs.bin src/fs.asm
	@nasm -f bin -o bin/dumper.bin src/dumper.asm
	@cat bin/boot.bin bin/kernel.bin bin/fs.bin bin/dumper.bin > bin/os.bin 
