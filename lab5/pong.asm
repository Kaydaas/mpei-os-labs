[org 0x7E00]

jmp Start

; TITLE
Pong:
	db "  _______ _______ ______  _______ ", 0
	db " |   _   |   _   |   _  \|   _   |", 0
	db " |.  1   |.  |   |.  |   |.  |___|", 0
	db " |.  ____|.  |   |.  |   |.  |   |", 0
	db " |:  |   |:  1   |:  |   |:  1   |", 0
	db " |::.|   |::.. . |::.|   |::.. . |", 0
	db " `---'   `-------`--- ---`-------'", 0
	


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
	mov cx, 7
logo_print_loop:
	push cx
	cld
	call Print
	pop cx
	loop logo_print_loop


    jmp $           ; Infinite loop

times 1024 - ($ - $$) db 0    ; Pad the program to 1024 bytes