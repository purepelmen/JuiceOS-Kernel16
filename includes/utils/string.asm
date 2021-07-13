;; Print a string
;; -----------------------------------------------------
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

;; print_sybmol_times: print desired char (cx value) times
;; al - char, cx - count of iterations
print_symbol_times:
    mov ah, 0x0e
    int 0x10
    loop print_symbol_times
    ret

;; Get string length stored in SI. Result stores in CX.
;; -----------------------------------------------------
get_string_length:
    xor cx, cx
    push si
.loop:
    lodsb
    cmp al, 0
    je .end
    inc cx
    jmp .loop
.end:
    pop si
    ret

;; Compare lenth of two string. 01h = true, 00h = false
;; SI = 1 str, DI - 2 str
compare_string_length:
    push si
    call get_string_length
    mov dx, cx

    mov si, di
    call get_string_length
    pop si

    cmp cx, dx
    je .Equal
    jmp .NEqual

    .Equal:
    mov al, 0x01
    ret
    .NEqual:
    mov al, 0x00
    ret

;; Compare string in SI with DI. Al = 01 if equals, 00 = not equal.
;; -----------------------------------------------------
;; SI = 1 string, DI = 2 string
copmare_string:
    ;; Compare length
    call compare_string_length
    cmp al, 0x01
    jne .NEqual

    ;; Loop comparison
    cld
    rep cmpsb
    jne .NEqual
    jmp .Equal
    .NEqual:
    mov al, 0x00
    ret
    .Equal:
    mov al, 0x01
    ret
