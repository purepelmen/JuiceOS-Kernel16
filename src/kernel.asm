jmp start_kernel

back_from_program:
    jmp get_input

start_kernel:
    cmp byte [bootDrive], 0xFF
    je set_boot_drive
start_kernel_ret:
    call reset_screen
    jmp get_input_nbl

set_boot_drive:
    mov [bootDrive], dl
    jmp start_kernel_ret

; Start new input
get_input:
    mov ax, 0x0e0a
    int 0x10
    mov al, 0xD
    int 0x10
get_input_nbl:
    mov si, prompt
    call print_string

    call start_getting_input

;; Command handler
;; ----------------------
process_input:
    ;; If nothing was printed, skip it
    cmp di, inputBuffer
    je get_input

    mov si, inputBuffer
    mov di, cmdHello
    call copmare_string
    cmp al, 0x01
    je cmd_hello

    mov si, inputBuffer
    mov di, cmdReboot
    call copmare_string
    cmp al, 0x01
    je cmd_reboot

    mov si, inputBuffer
    mov di, cmdSystem
    call copmare_string
    cmp al, 0x01
    je cmd_getinfo

    mov si, inputBuffer
    mov di, cmdTest
    call copmare_string
    cmp al, 0x01
    je cmd_test

    mov si, inputBuffer
    mov di, cmdAscii
    call copmare_string
    cmp al, 0x01
    je cmd_ascii

    mov si, inputBuffer
    mov di, cmdCls
    call copmare_string
    cmp al, 0x01
    je cmd_cls

    mov si, inputBuffer
    mov di, cmdDir
    call copmare_string
    cmp al, 0x01
    je cmd_dir

    mov si, inputBuffer
    mov di, cmdHelp
    call copmare_string
    cmp al, 0x01
    je cmd_help

    call check_file

    mov si, cmd_not_found
    call print_string
    jmp get_input

cmd_hello:
    mov si, entered_cmd_hello
    call print_string
    jmp get_input

cmd_reboot:
    jmp 0xFFFF:0x0

cmd_getinfo:
    mov si, systemInfoStr
    call print_string

    mov si, hex_prefix
    call print_string
    mov al, [bootDrive]
    call print_hexb
    cmp byte [bootDrive], 0x00
    je cmd_getinfo_floppya
    cmp byte [bootDrive], 0x01
    je cmd_getinfo_floppyb
    cmp byte [bootDrive], 0x02
    je cmd_getinfo_floppyc
    cmp byte [bootDrive], 0x80
    je cmd_getinfo_hda
    cmp byte [bootDrive], 0x81
    je cmd_getinfo_hdb
    cmp byte [bootDrive], 0x82
    je cmd_getinfo_hdc
cmd_getinfo_return:
    jmp get_input

cmd_getinfo_floppya:
    mov si, floppy_a
    call print_string
    jmp cmd_getinfo_return
cmd_getinfo_floppyb:
    mov si, floppy_b
    call print_string
    jmp cmd_getinfo_return
cmd_getinfo_floppyc:
    mov si, floppy_c
    call print_string
    jmp cmd_getinfo_return
cmd_getinfo_hda:
    mov si, harddrive_a
    call print_string
    jmp cmd_getinfo_return
cmd_getinfo_hdb:
    mov si, harddrive_b
    call print_string
    jmp cmd_getinfo_return
cmd_getinfo_hdc:
    mov si, harddrive_c
    call print_string
    jmp cmd_getinfo_return

cmd_test:
    jmp get_input

cmd_ascii:
    mov si, enter_char_str
    call print_string

    call get_keystroke
    mov ah, 0x0e
    int 0x10

    mov si, newLine
    call print_string

    mov si, hex_prefix
    call print_string

    call print_hexb

    mov si, newLine
    call print_string

    jmp get_input

cmd_cls:
    call reset_screen
    jmp get_input_nbl

cmd_dir:
    mov si, newLine
    call print_string
    call print_files
    jmp get_input

cmd_help:
    mov si, helpHeader
    call print_string
    jmp get_input

%include "includes/fs/load_sector.asm"
%include "includes/utils/screen.asm"
%include "includes/utils/string.asm"
%include "includes/utils/input.asm"
%include "includes/utils/hex.asm"
%include "includes/fs/sfts.asm"

inputBuffer: resb 60
bootDrive: db 0xFF

prompt: db 'PC>', 0
cmdHello: db 'hello', 0
cmdReboot: db 'reboot', 0
cmdSystem: db 'system', 0
cmdTest: db 'test', 0
cmdAscii: db 'ascii', 0
cmdCls: db 'cls', 0
cmdDir: db 'dir', 0
cmdHelp: db 'help', 0

newLine: db 0xA, 0xD, 0
hex_prefix: db '0x', 0
cmd_not_found: db 0xA, 0xD, 'Oh, it is like your command/file is not exist. :(', 0xA, 0xD, 0
entered_cmd_hello: db 0xA, 0xD, 'Helloooo :)', 0xA, 0xD, 0
systemInfoStr: db 0xA, 0xD, 'JuiceOS v1.0 (Working in Kernel16).', 0xA, 0xD, 'Booted from: ', 0
enter_char_str: db 0xA, 0xD, 'Please type the char on your keyboard: ', 0

fileTableHeader: db 'File Name - Location Sector - Size', 0xA, 0xD,\
                    '----------------------------------------------------------------', 0xA, 0xD, 0

helpHeader: db 0xA, 0xD, 'HELLO - Test command that say hello to you', 0xA, 0xD,\
                         'REBOOT - Reboot your computer', 0xA, 0xD,\
                         'SYSTEM - Print system information', 0xA, 0xD,\
                         'TEST - Developer command that help us test current features', 0xA, 0xD,\
                         'ASCII - Prints hex representation of typed char', 0xA, 0xD,\
                         'CLS - Clear the console', 0xA, 0xD,\
                         'DIR - Print file list', 0xA, 0xD, 0

floppy_a: db ' (Floppy Drive A)', 0
floppy_b: db ' (Floppy Drive B)', 0
floppy_c: db ' (Floppy Drive C)', 0
harddrive_a db ' (First HDD)', 0
harddrive_b db ' (Second HDD)', 0
harddrive_c db ' (Third HDD)', 0

times 2048-($-$$) db 0