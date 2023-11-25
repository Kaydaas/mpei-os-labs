; ---CONSTANTS---
; Row for keyboard legend
KEYBOARD_LEGEND_POSITION equ 24

; ---VARIABLES---
CursorPosition: db 0 ; Current cursor row
CursorX: db 0 ; Cursor X position
CursorY: db 0 ; Cursor Y position

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

GetChar:
	mov ah, 0x08 ; BIOS function to read character from screen
	int 10h ; Call BIOS interrupt

PutChar:
	mov ah, 0x0E ; Print character
	int 0x10 ; Call BIOS video services
	ret

PrintString:
	lodsb ; Load character from SI
	or al, al ; Check for string termination
	jz PrintStringEnd ; If zero, end of string
	call PutChar ; Print character
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

SetCursor:
	mov dh, byte [CursorY] ; Row
	mov dl, byte [CursorX] ; Column
	add dl, dl ; Multiply X coordinate by 2, just for better appearance
	mov bh, 0 ; Page number
	mov ah, 2
	int 10h
	ret

HideCursor:
	mov ch, 32 
	mov ah, 1 
	int 10h
	ret

ResetCursor:
	mov ch, 6 
	mov cl, 7 
	mov ah, 1 
	int 10h 
	mov byte [CursorX], 0
	mov byte [CursorY], 0
	call SetCursor
	ret