; ---VARIABLES---
; Current cursor position
CursorPosition: db 0

; ---CONSTANTS---
; Row for keyboard legend Line
KeyboardLegendPosition equ 24

SetVideoMode:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	ret

ClearScreen:
	mov eax, 0x02 ; Function number: clear screen
	xor ebx, ebx ; Page number: 0 (default)
	xor edx, edx ; Upper left corner: 0,0
	xor esi, esi ; Lower right corner: 0,0
	int 0x10 ; Call BIOS video services
	ret

PrintChar:
    mov ah, 0x0e ; Print character
    int 0x10 ; Call BIOS video services
    ret

PrintString:
	lodsb ; Load character from SI
	or al, al ; Check for string termination
	jz PrintStringEnd ; If zero, end of string
	mov ah, 0x0e ; Print character
	int 0x10 ; Call BIOS video services
	jmp PrintString ; Print next character
PrintStringEnd:
	ret

PrintNewLine:
	mov al, 0x0D ; Carriage return
	mov ah, 0x0E ; Print character
	int 0x10 ; Call BIOS video services
	mov al, 0x0A ; Line feed
	mov ah, 0x0E ; Print character
	int 0x10 ; Call BIOS video services
	ret

; Print string with new line
PrintStringL:
	call PrintString
	call PrintNewLine
	ret
	
SetCursor:
	mov dh, byte [CursorPosition] ; Row
	mov dl, 0 ; Column
	mov bh, 0 ; Page number
	mov ah, 2
	int 10h
	ret
	
HideCursor:
	mov ah, 0x01 ; Set cursor function
	mov cx, 0x2000 ; Define cursor shape (all pixels off)
	int 0x10 ; Call BIOS video services
	ret

ShowCursor:
	mov ah, 0x01 ; Set cursor function
	mov cx, 0x0607 ; Define cursor shape (underline, normal size)
	int 0x10 ; Call BIOS video services
	ret