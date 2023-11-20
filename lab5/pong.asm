	org 0x2000
	
	jmp Start

; TITLE
Pong:
	db "      ___         ___           ___           ___      ", 0
	db "     /  /\       /  /\         /__/\         /  /\     ", 0
	db "    /  /::\     /  /::\        \  \:\       /  /:/_    ", 0
	db "   /  /:/\:\   /  /:/\:\        \  \:\     /  /:/ /\   ", 0
	db "  /  /:/~/:/  /  /:/  \:\   _____\__\:\   /  /:/_/::\  ", 0
	db " /__/:/ /:/  /__/:/ \__\:\ /__/::::::::\ /__/:/__\/\:\ ", 0
	db " \  \:\/:/   \  \:\ /  /:/ \  \:\~~\~~\/ \  \:\ /~~/:/ ", 0
	db "  \  \::/     \  \:\  /:/   \  \:\  ~~~   \  \:\  /:/  ", 0
	db "   \  \:\      \  \:\/:/     \  \:\        \  \:\/:/   ", 0
	db "    \  \:\      \  \::/       \  \:\        \  \::/    ", 0
	db "     \__\/       \__\/         \__\/         \__\/     ", 0
	


Print:
    lodsb ; Load character from SI
    or al, al ; Check for string termination
    jz PrintNewLine ; If zero, end of string
    mov ah, 0x0e ; Print character
    int 0x10
    jmp Print ; Print next character
PrintNewLine:
    mov al, 0x0D ; Carriage return
    mov ah, 0x0E ; Print character
    int 0x10
    mov al, 0x0A ; Line feed
    mov ah, 0x0E ; Print character
    int 0x10
PrintDone:
    ret

Start:

   ; Clear screen
	mov eax, 0x02     ; Function number: clear screen
	xor ebx, ebx      ; Page number: 0 (default)
	xor edx, edx      ; Upper left corner: 0,0
	xor esi, esi      ; Lower right corner: 0,0
	int 0x10          ; Call BIOS video services

    mov si, Pong
	call Print
	call Print
	call Print
	call Print
	call Print
	call Print
	call Print
	call Print
	call Print
	call Print
	call Print

    jmp $           ; Infinite loop

times 1024 - ($ - $$) db 0    ; Pad the program to 1024 bytes