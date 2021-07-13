jmp start_boot
nop
resb 8 + 25

start_boot:
    mov ax, 0x07c0
    mov ds, ax

read_disk:
    mov ax, 0x0200
    mov es, ax
    xor bx, bx

    mov ch, 0
    mov cl, 2
    mov dh, 0

    mov al, 4
    mov ah, 0x02
    int 0x13

    jc read_error

    cmp ah, 0
    jne read_error

    cmp al, 4
    jne sectors_not_read_error

running_kernel:
    mov ax, 0x0200
    mov ds, ax
    mov es, ax

    mov ax, 0x0900
    mov ss, ax
    mov sp, 0xFFFF

    jmp 0x0200:0x0000

;; Prints a string
;; -------------------------------
print_string:
    pusha
    mov ah, 0x0e
print_string_loop:
    lodsb
    cmp al, 0
    je print_string_end
    int 0x10
    jmp print_string_loop
print_string_end:
    popa
    ret

;; Disk read error handlers
;; -------------------------------
read_error:
    mov si, readErr
    call print_string
    jmp $

sectors_not_read_error:
    mov si, sectorsCountNotMatchErr
    call print_string
    jmp $

readErr: db 'Kernel reading and loading failure!', 0
sectorsCountNotMatchErr: db 'Not all sectors was read from disk!', 0

times 510-($-$$) db 0
dw 0xAA55