;; start_getting_input: takes input from user and stops when ENTER is pressed
;; * process_input - point where code jumps to after taking the input
;; * inputBuffer: reference to input buffer is located
;; ---------------------------------------------------------------------------
start_getting_input:
    call reset_cmd
    mov di, inputBuffer
.input:
    call get_keystroke

    cmp al, 0xD
    je .End

    cmp al, 0x08
    je .HandleBackSpace

    cmp di, inputBuffer + 58
    jge .input

    mov ah, 0x0e
    int 0x10
    stosb

    jmp .input

.HandleBackSpace:
    ;; If we at start of input, we shouldn't handle backspace
    cmp di, inputBuffer
    je .input

    mov ah, 0x0e
    int 0x10
    dec di
    call clear_current_char
    mov byte [di], 0
    jmp .input

.End:
    ret

;; Clear the input buffer
;; ----------------------
reset_cmd:
    pusha
    mov cx, 60
    mov di, inputBuffer
reset_cmd_loop:
    mov al, 0
    stosb
    loop reset_cmd_loop
    popa
    ret

;; Clear current char at cursor position
;; -------------------------------------
clear_current_char:
    pusha
    mov bh, 0
    mov bl, 0x07
    mov cx, 1
    mov al, ' '
    mov ah, 0x09
    int 0x10
    popa
    ret

;; Get keystroke
;; Return: %AL = Keystroke
;; -------------------------------------
get_keystroke:
    xor ax, ax
    int 0x16
    ret