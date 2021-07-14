;;
;; dumper.bin: Dumper program by JuiceOS software
;;

get_input:
    mov si, newLine
    call print_string
get_input_nbl:
    mov si, prompt
    call print_string

    mov ax, 0x07e0
    mov es, ax

    call start_getting_input

;; Handle entered starting position
;; --------------------------------
process_input:
    ;; If nothing was printed, jump to input (with other message)
    cmp di, inputBuffer
    je get_input

    mov si, inputBuffer
    mov di, cmdDumpStart
    call copmare_string
    cmp al, 0x01
    je dump_start

    mov si, inputBuffer
    mov di, cmdSetAsciiFlag
    call copmare_string
    cmp al, 0x01
    je cmd_saf

    mov si, inputBuffer
    mov di, cmdClearAsciiFlag
    call copmare_string
    cmp al, 0x01
    je cmd_caf

    mov si, inputBuffer
    mov di, cmdHelp
    call copmare_string
    cmp al, 0x01
    je cmd_help

    mov si, inputBuffer
    mov di, cmdEnd
    call copmare_string
    cmp al, 0x01
    je cmd_end

    mov si, unrecognizedCmd
    call print_string
    jmp get_input

dump_start:
    xor ax, ax
    mov es, ax

    mov si, newLine
    call print_string

    xor si, si
.StartLoop:
    push si
    mov si, newLine
    call print_string

    mov si, memoryLabel
    call print_string

    mov si, preHex
    call print_string

    mov ax, es
    call print_hexw

    mov ah, 0x0e
    mov al, ':'
    int 0x10

    mov si, preHex
    call print_string

    pop si
    mov ax, si
    push si
    call print_hexw

    mov si, newLine
    call print_string
    mov si, newLine
    call print_string
    mov cx, 512
    pop si
.Loop:
    cmp si, 0xFFFF
    je .IncrementEs

.LoopReturn:
    mov byte al, [ES:SI]
    inc si

    cmp byte [asciiFlag], 0x01
    je .LoopAscii

    call print_hexb
    mov ax, 0x0e20
    int 0x10
    loop .Loop

    push si
    mov si, newLine
    call print_string

    mov si, continueStartMsg
    call print_string

    call get_keystroke

    pop si
    cmp al, 0x20
    je .StartLoop
    cmp al, 0xD
    je .StartNewSegment
    jmp get_input

.StartNewSegment:
    mov ax, es
    add ax, 1000h
    mov es, ax
    sub si, 512
    jmp .StartLoop

.LoopAscii:
    mov ah, 0x0e
    int 0x10
    mov ax, 0x0e20
    int 0x10
    loop .Loop

    push si
    mov si, newLine
    call print_string

    mov si, continueStartMsg
    call print_string

    call get_keystroke

    pop si
    cmp al, 0x20
    je .StartLoop
    cmp al, 0xD
    je .StartNewSegment
    jmp get_input

.IncrementEs:
    mov ax, es
    add ax, 1000h
    mov es, ax
    jmp .LoopReturn

cmd_saf:
    mov byte [asciiFlag], 0x01
    mov si, asciiFlagSetup
    call print_string
    jmp get_input

cmd_caf:
    mov byte [asciiFlag], 0x00
    mov si, asciiFlagCleared
    call print_string
    jmp get_input

cmd_help:
    mov si, helpMsg
    call print_string
    jmp get_input

cmd_end:
    mov ax, 0x0200
    mov es, ax
    mov ds, ax
    
    mov al, 0xC0
    jmp 0x0200:0x0000

%include "includes/utils/screen.asm"
%include "includes/utils/string.asm"
%include "includes/utils/input.asm"
%include "includes/utils/hex.asm"

asciiFlag: db 0x0
inputBuffer: resb 60

preHex: db '0x', 0
newLine: db 0xA, 0xD, 0
memoryLabel: db 'Memory: ', 0
prompt: db 'PC/dumper.bin>', 0
asciiFlagSetup: db 0xA, 0xD, 'ASCII flag is set up!', 0xA, 0xD, 0
asciiFlagCleared: db 0xA, 0xD, 'ASCII flag is clear!', 0xA, 0xD, 0
unrecognizedCmd: db 0xA, 0xD, 'Oh, it is like your command is not exist. :(', 0xA, 0xD, 0

continueMsg: db 0xA, 0xD, 'Space = Next Mem Sector || Other = End', 0xA, 0xD, 0
continueStartMsg: db 0xA, 0xD, 'Space = Next Mem Sector || Enter = Next segment offset || Other = End', 0xA, 0xD, 0
helpMsg: db 0xA, 0xD, 'START - Dumps all memory from the 0x0',\
            0xA, 0xD, 'SAF - Set ASCII flag',\
            0xA, 0xD, 'CAF - Clear ASCII flag',\
            0xA, 0xD, 'HELP - Print help',\
            0xA, 0xD, 'END - Exit from program', 0xA, 0xD, 0

cmdClearAsciiFlag: db 'caf', 0
cmdSetAsciiFlag: db 'saf', 0
cmdDumpStart: db 'start', 0
cmdHelp: db 'help', 0
cmdEnd: db 'end', 0

times 2048-($-$$) db 0