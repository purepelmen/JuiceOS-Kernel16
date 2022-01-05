jmp start_boot
nop
times 8 + 25 db 0

start_boot:
    mov ax, 0x07c0          ; Address to the bootsector
    mov ds, ax              ; Load data segment to bootsector location

;; Read the disk for kernel
;; -------------------------------
read_disk:
    mov bx, 0x2000          ; Where the kernel must be located

    mov ch, 0               ; Cylinder
    mov cl, 2               ; Sector (1-based)
    mov dh, 0               ; Track/Head

    mov al, 8               ; Sectors count to read
    mov ah, 0x02            ; Read disk operation
    int 0x13

    jc read_error           ; Carry is set if an error occured

    cmp ah, 0               ; If AH != 0, an error occured
    jne read_error          ; Handle read error

;; Run the loaded kernel
;; -------------------------------
running_kernel:
    mov ax, 0x0200          ; Kernel address
    mov ds, ax              ; Data segment <== Kernel address
    mov es, ax              ; Extra segment <== Kernel address

    mov sp, 0xFFFF          ; Stack pointer <== Max available stack pointer
    mov ax, 0x0900          ; Address for stack segment
    mov ss, ax              ; Stack segment <== 0x9000

    mov al, 0xBF            ; Bootloader running code
    jmp 0x0200:0x0000       ; Jump to kernel

;; Prints a string
;; -------------------------------
print_string:
    pusha
.loop:
    lodsb
    cmp al, 0
    je .end
    mov ah, 0x0e
    int 0x10
    jmp .loop
.end:
    popa
    ret

;; Disk read error handler
;; -------------------------------
read_error:
    mov si, readErrorStr
    call print_string
    jmp $

readErrorStr: db 'Kernel reading and loading failure!', 0

times 510-($-$$) db 0
dw 0xAA55