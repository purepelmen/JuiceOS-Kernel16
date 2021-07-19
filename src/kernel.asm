;; check_running_type: check running type stored in 'al'
;; al - 0xBF = initial loading. Bootloader loads kernel with this code
;; al - 0xC0 = Returning. Uses in other software to return to kernel execution
;; al - 0xF0 = Returning from power saving (sleep). Used by kernel to return to execution.
check_running_type:
    cmp al, 0xBF
    je .BootSectorRunning
    cmp al, 0xC0
    je .ReturnRunning
    cmp al, 0xF0
    je .SleepReturnRunning

    ;; If code is incorrect - hang there
    mov si, runningTypeDeterminationFailure
    call print_string
    call get_keystroke
    jmp cmd_reboot

.BootSectorRunning:
    xor ax, ax
    mov [bootDrive], dl
    mov byte [runType], 0xBF
    call reset_screen
    jmp get_input_nbl

.ReturnRunning: 
    xor ax, ax
    mov byte [runType], 0xC0
    jmp get_input

.SleepReturnRunning:
    xor ax, ax
    mov byte [runType], 0xF0
    jmp get_input_nbl

;; Start new input
get_input:
    mov si, newLine
    call print_string
get_input_nbl:
    mov si, prompt
    call print_string

    call start_getting_input

;; Command handler
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

    mov si, inputBuffer
    mov di, cmdPowerSave
    call copmare_string
    cmp al, 0x01
    je cmd_powersave

    mov si, inputBuffer
    mov di, cmdRunType
    call copmare_string
    cmp al, 0x01
    je cmd_runtype

    mov si, inputBuffer
    mov di, cmdPs2KeyboardTest
    call copmare_string
    cmp al, 0x01
    je cmd_ps2test

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

cmd_powersave:
    call reset_screen
    mov si, powerSaveMsg
    call print_string

    .PowerSaveLoop:
        hlt
        call get_keystroke
        cmp al, 0x20
        je .Exit
        jmp .PowerSaveLoop

    .Exit:
        call reset_screen
        mov al, 0xF0
        jmp 0x0

cmd_runtype:
    cmp byte [runType], 0xBF
    je .Bootloader
    cmp byte [runType], 0xC0
    je .Returned
    cmp byte [runType], 0xF0
    je .WokeUp

.Bootloader:
    mov si, runnedTypeBootloader
    call print_string
    jmp get_input

.Returned:
    mov si, runnedTypeReturned
    call print_string
    jmp get_input

.WokeUp:
    mov si, runnedTypeWokeUp
    call print_string
    jmp get_input

cmd_ps2test:
    xor ax, ax
    mov al, 0xEE
    out 0x60, al
    xor ax, ax
    in al, 0x60
    cmp al, 0xEE
    je .TestComplete

    mov si, keyboardPs2TestFailure
    call print_string
    jmp get_input
.TestComplete:
    mov si, keyboardPs2TestSuccess
    call print_string
    jmp get_input

%include "includes/fs/load_sector.asm"
%include "includes/utils/screen.asm"
%include "includes/utils/string.asm"
%include "includes/utils/input.asm"
%include "includes/utils/hex.asm"
%include "includes/fs/sfts.asm"

inputBuffer: resb 60
bootDrive: db 0x00
runType: db 0x00

prompt: db 'PC>', 0
cmdHello: db 'hello', 0
cmdReboot: db 'reboot', 0
cmdSystem: db 'system', 0
cmdTest: db 'test', 0
cmdAscii: db 'ascii', 0
cmdCls: db 'cls', 0
cmdDir: db 'dir', 0
cmdHelp: db 'help', 0
cmdPowerSave: db 'powersave', 0
cmdRunType: db 'runtype', 0
cmdPs2KeyboardTest: db 'ps2test', 0

hex_prefix: db '0x', 0
newLine: db 0xA, 0xD, 0
entered_cmd_hello: db 0xA, 0xD, 'Helloooo :)', 0xA, 0xD, 0
enter_char_str: db 0xA, 0xD, 'Please type the char on your keyboard: ', 0
keyboardPs2TestSuccess: db 0xA, 0xD, 'Keyboard responded to echo-command. PS/2 Keyboard - PASS', 0xA, 0xD, 0
keyboardPs2TestFailure: db 0xA, 0xD, 'Keyboard not responded properly to echo-command. PS/2 Keyboard - FAIL', 0xA, 0xD, 0
runnedTypeBootloader: db 0xA, 0xD, 'Last kernel run was from bootloader.', 0xA, 0xD, 0
powerSaveMsg: db 'You are in power saving mode now. To exit from here - press SPACE.', 0
cmd_not_found: db 0xA, 0xD, 'Oh, it is like your command/file is not exist. :(', 0xA, 0xD, 0
systemInfoStr: db 0xA, 0xD, 'JuiceOS v1.0 (Working in Kernel16).', 0xA, 0xD, 'Booted from: ', 0
runnedTypeWokeUp: db 0xA, 0xD, 'Last kernel run was returned from power save mode.', 0xA, 0xD, 0
runnedTypeReturned: db 0xA, 0xD, 'Last kernel run was returned from other software.', 0xA, 0xD, 0
runningTypeDeterminationFailure: db 0xA, 0xD, 'The kernel was runned unsupported way.',\
                        0xA, 0xD, 'Kernel will not be running. Press any key to restart system.', 0

fileTableHeader: db 'File Name - Location Sector - Size', 0xA, 0xD,\
                    '----------------------------------------------------------------', 0xA, 0xD, 0

helpHeader: db 0xA, 0xD, 'HELLO - Test command that say hello to you', 0xA, 0xD,\
                         'REBOOT - Reboot your computer', 0xA, 0xD,\
                         'SYSTEM - Print system information', 0xA, 0xD,\
                         'TEST - Developer command that help us test current features', 0xA, 0xD,\
                         'ASCII - Prints hex representation of typed char', 0xA, 0xD,\
                         'CLS - Clear the console', 0xA, 0xD,\
                         'DIR - Print file list', 0xA, 0xD,\
                         'POWERSAVE - Enter power saving mode', 0xA, 0xD,\
                         'RUNTYPE - Print last kernel run type', 0xA, 0xD,\
                         'PS2TEST - Send to PS/2 Keyboard echo-command. It is used to test PS/2 keyboards.', 0

floppy_a: db ' (Floppy Drive A)', 0
floppy_b: db ' (Floppy Drive B)', 0
floppy_c: db ' (Floppy Drive C)', 0
harddrive_a db ' (First HDD)', 0
harddrive_b db ' (Second HDD)', 0
harddrive_c db ' (Third HDD)', 0

times 4096-($-$$) db 0