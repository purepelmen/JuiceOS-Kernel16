FILES_TO_CAT = bin/main/boot.bin bin/main/kernel.bin bin/main/fs.bin bin/software/dumper.bin

build:
	@nasm -f bin -o bin/main/boot.bin src/boot.asm
	@nasm -f bin -o bin/main/kernel.bin src/kernel.asm
	@nasm -f bin -o bin/main/fs.bin src/fs.asm
	@nasm -f bin -o bin/software/dumper.bin src/dumper.asm
	@cat $(FILES_TO_CAT) > bin/os.bin 
