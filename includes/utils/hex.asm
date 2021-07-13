;; print_hex_ascii - convert 4-bit number in al to ascii sybmol and prints it
;; #al - num, result - will be printed
print_hex_ascii:
    add al, 0x30
    cmp al, 0x39
    jle .End
    add al, 0x7
    .End:
    mov ah, 0x0e
    int 0x10
    ret

;; print_hexb - convert 8-bit number in al to ascii sybmol(will be up to 2 symbols) and prints it
;; #al - num, result - will be printed
print_hexb:
    push ax
    shr al, 4
    call print_hex_ascii
    pop ax
    push ax
    and al, 0x0F
    call print_hex_ascii
    pop ax
    ret

;; print_hexw - convert 16-bit number in ax to ascii sybmol(will be up to 4 symbols) and prints it
;; #ax - num, result - will be printed
print_hexw:
    push ax
    shr ax, 8
    call print_hexb
    pop ax
    push ax
    and ax, 0x00FF
    call print_hexb
    pop ax
    ret
