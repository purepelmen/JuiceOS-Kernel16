;;
;; sfts.asm: SFTS file system driver
;;

;; print_files: print all file table
print_files:
    call load_filetable

    mov si, newLine
    call print_string
    mov si, fileTableHeader
    call print_string

    ;; Re-update starting pointers
    mov ax, 0x0100
    mov ds, ax
    xor si, si

.print_filename:
    lodsb
    cmp al, 0
    je .print_start_sector
    mov ah, 0x0e
    int 0x10
    jmp .print_filename

.print_start_sector:
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov ah, 0x0e
    mov al, '-'
    int 0x10
    mov ah, 0x0e
    mov al, ' '
    int 0x10

    lodsb
    call print_hexb

.print_size:
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov ah, 0x0e
    mov al, '-'
    int 0x10
    mov ah, 0x0e
    mov al, ' '
    int 0x10

    lodsb
    call print_hexb
    
.NextEntry:
    mov ax, 0x0e0A
    int 0x10
    mov ax, 0x0e0D
    int 0x10

    lodsb
    cmp al, 0x0
    je .End
    dec si
    jmp .print_filename
.End:
    ;; Set up kernel segment
    mov ax, 0x0200
    mov ds, ax
    mov es, ax
    ret

check_file:
    call load_filetable

    ;; Set up segments
    mov ax, 0x0100
    mov ds, ax
    xor si, si
    mov ax, 0x0200
    mov es, ax
    mov di, inputBuffer

.check_filename:
    cmpsb
    jne .check_failed
    cmp byte [si], 0
    je .check_success
    jmp .check_filename

.check_success:
    cmpsb

.load_file:
    mov dl, [es:bootDrive] ; Drive

     ;; Mem location
    mov ax, 0x07e0
    mov es, ax
    xor bx, bx

    mov cl, [si]        ; Start sector
    inc si
    mov al, [si]        ; Sectors count

    call load_sector

.run_file:
    ;; Mem location
    mov ax, 0x07e0
    mov es, ax
    mov ds, ax

    jmp 0x07e0:0x0000

.check_failed:
    cmp byte [si], 0
    je .check_failed_cont
    inc si
    jmp .check_failed
.check_failed_cont:
    mov di, inputBuffer
    inc si
    inc si
    inc si
    cmp byte [si], 0
    je .file_not_found
    jmp .check_filename
    
.file_not_found:
    mov ax, 0x0200
    mov es, ax
    mov ds, ax
    ret

load_filetable:
    ;; Mem location
    mov ax, 0x0100
    mov es, ax
    xor bx, bx

    mov cl, 6           ; Start sector
    mov al, 2           ; Sectors count
    mov dl, [bootDrive] ; Drive

    call load_sector    ; Load file table
    ret