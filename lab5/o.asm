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
	mov ah, 0x0E ; Print character
	int 0x10 ; Call BIOS video services
	ret

PrintString:
	lodsb ; Load character from SI
	or al, al ; Check for string termination
	jz PrintStringEnd ; If zero, end of string
	call PrintChar ; Print character
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
	
SetCursorRow:
	mov dh, byte [CursorPosition] ; Row
	mov dl, 0 ; Column
	mov bh, 0 ; Page number
	mov ah, 2
	int 10h
	ret