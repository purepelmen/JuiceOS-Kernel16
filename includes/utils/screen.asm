;;
;; screen.asm: functions for working with screen

;; reset_screen: reset to standart video mode (0x03, 80x25, 16 colors)
reset_screen:
    mov ax, 0x0003
    int 0x10
    ret