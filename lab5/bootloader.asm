[org 0x7C00]

jmp Start

; ---INCLUDES---
%include "video.asm"
%include "disk.asm"

; ---STRINGS---
ErrorMessage: db "Error while reading the disk.", 0
SuccessMessage: db "Reading successful.", 0

Start:
    call SetVideoMode

    mov bx, GAME_LOCATION
    call DiskRead

    jnc Success

    ; If error
    mov si, ErrorMessage
    call PrintStringL
    jmp Loop

Success:
    mov si, SuccessMessage
    call PrintStringL
    jmp GAME_LOCATION ; Jump to the game code

Loop:
    jmp Loop

times 510-($-$$) db 0
dw 0xAA55