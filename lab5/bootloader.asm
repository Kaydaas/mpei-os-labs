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

	mov si, Loading
	call Print
	
	mov ah, 0x02      ; Function number: read sector
	mov al, 0x01      ; Number of sectors to read
	mov ch, 0x00      ; Track number (starting from 0)
	mov cl, 0x02      ; Sector number (starting from 1)
	mov dh, 0x00      ; Head number
	mov dl, 0x80      ; Drive number (0x80 for first hard drive)
	mov bx, 0x2000    ; Buffer address to load the sector
	int 0x13          ; Call BIOS disk services

	jnc LoadProgramSuccess ; Jump to success handling if disk read successful
	jmp LoadProgramError   ; Jump to error handling if disk read error

LoadProgramError:
	mov si, LoadingError
	call Print
	jmp Loop

LoadProgramSuccess:
	jmp 0x2000:0x0000  ; Jump to program entry point (assuming program is loaded at 0x2000)
	
	
	
	
Loop:
	jmp Loop

times 510 - ($ - $$) db 0

	dw 0xAA55