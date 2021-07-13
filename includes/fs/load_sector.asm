;;
;; load_sector: load desired sector
;;
load_sector:
    mov ch, 0
    mov dh, 0

    mov ah, 0x02
    int 0x13

    jc read_error

    cmp ah, 0
    jne read_error
    
    ret

;; Disk read error handlers
;; -------------------------------
read_error:
    mov si, readErr
    call print_string

    jmp $

readErr: db 'Reading disk error', 0