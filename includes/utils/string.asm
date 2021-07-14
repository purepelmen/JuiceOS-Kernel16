;;
;; string.asm: functions for working with strings
;;

;; print_string: print a string
;; si - *string pointer
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

;; print_sybmol_times: print desired char 'CX' times
;; al - char, cx - count of iterations
print_symbol_times:
    mov ah, 0x0e
    int 0x10
    loop print_symbol_times
    ret

;; get_string_length: get string length
;; si - *string pointer | Return: cx - chars count
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

;; compare_string_length: compare two string lengths
;; si - *first string pointer, di - *second string pointer
;; Return: al - 0x01 = true (Length are equal) | al - 0x00 = false
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

;; compare_string: compare two strings
;; si - *first string pointer, di - *second string pointer
;; Return: al - 0x01 = true (strings are equal) | al - 0x00 = false
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
