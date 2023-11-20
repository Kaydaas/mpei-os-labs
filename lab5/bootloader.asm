	org 0x7C00

	jmp Start

Loading:
	db "Loading game...", 0
LoadingError:
	db "Error while loading the game.", 0

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
	; Set video mode
	mov ah, 0x0e        
	mov al, 0x03
	int 0x10

	; Clear screen
	mov eax, 0x02     ; Function number: clear screen
	xor ebx, ebx      ; Page number: 0 (default)
	xor edx, edx      ; Upper left corner: 0,0
	xor esi, esi      ; Lower right corner: 0,0
	int 0x10          ; Call BIOS video services
	
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x80
    mov bx, 0x2000
    int 0x13

    jnc LoadProgramSuccess
    jmp LoadProgramError

LoadProgramError:
    mov si, LoadingError
    call Print
    jmp Loop

LoadProgramSuccess:
	mov si, Loading
	call Print
    jmp 0x0000:0x2000

Loop:
	jmp Loop

times 510 - ($ - $$) db 0

	dw 0xAA55