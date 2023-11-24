[org 0x7E00]

jmp Start

; ---INCLUDES---
%include "visual.asm"

; ---STRINGS---
; Logo
Logo:
	db "{__       {__ {__ {___     {__ {________   {__ __  ", 0
	db "{_ {__   {___ {__ {_ {__   {__ {__       {__    {__", 0
	db "{__ {__ { {__ {__ {__ {__  {__ {__        {__      ", 0
	db "{__  {__  {__ {__ {__  {__ {__ {______      {__    ", 0
	db "{__   {_  {__ {__ {__   {_ {__ {__             {__ ", 0
	db "{__       {__ {__ {__    {_ __ {__       {__    {__", 0
	db "{__       {__ {__ {__      {__ {________   {__ __  ", 0
; Keyboard legend at the bottom of the screen
GameKeyboardLegend: db "MOVE CURSOR: W, A, S, D | DEFUSE: SPACE | RESTART: R", 0

; ---CONSTANTS---
; Number of lines in logo, used for printing
LogoLength equ 7
MATRIX_SIZE equ 10 ; 10x10 matrix
MINE_PROBABILITY equ 15 ; 1-100 %

; ---VARIABLES---
Matrix times MATRIX_SIZE * MATRIX_SIZE db 0 ; 10x10 matrix
MinesTotal: db 0
MinesDefused: db 0
CursorX: db 0 ; Cursor X position
CursorY: db 0 ; Cursor Y position
RandomNumber: db 0
Counter: dd 0

; ---PROCEDURES---
PrintLogo:
	mov si, Logo
	mov cx, LogoLength
PrintLogoLoop:
	push cx
	cld
	call PrintStringL
	pop cx
	loop PrintLogoLoop
	ret
	
IncIndex:
	inc byte [CursorX]
	cmp byte [CursorX], MATRIX_SIZE
	jl IncIndexEnd
	mov byte [CursorX], 0
	inc byte [CursorY]
IncIndexEnd:
	ret

PrintMatrix:
	; Counter to get the current 
	mov byte [Counter], 0

	mov byte [CursorX], 0
	mov byte [CursorY], 0
	
	mov     esi, Matrix

PrintMatrixLoop:
	cmp byte [Counter], MATRIX_SIZE * MATRIX_SIZE
	je MatrixPrintEnd   ; Exit the loop if they are equal

	call SetCursor
	
	mov al, 'X'
	
	call PrintChar
	
	rdtsc
	xor     edx, edx             ; Required because there's no division of EAX solely
	mov     ecx, 99   ; 99 possible values
	div     ecx                  ; EDX:EAX / ECX --> EAX quotient, EDX remainder
	mov     eax, edx             ; -> EAX = [1,100]
	add     eax, 1

	
	cmp al, MINE_PROBABILITY
	jl PlantMine

	mov [esi], dword ' '
	jmp Continue
PlantMine:
	mov [esi], dword '*'

	
Continue:
	inc esi
	
	inc byte [Counter]
	call IncIndex

	jmp PrintMatrixLoop
MatrixPrintEnd:
	ret

SetCursor:
	mov dh, byte [CursorY] ; Row
	add dh, LogoLength + 1
	mov dl, byte [CursorX] ; Column
	add dl, dl ; Multiply X coordinate by 2, just for better appearance
	mov bh, 0 ; Page number
	mov ah, 2
	int 10h
	ret

HandleGameInput:
	cmp al, 'w' ; Check if 'W' key is pressed
	je MoveCursorUp
	cmp al, 'a' ; Check if 'W' key is pressed
	je MoveCursorLeft
	cmp al, 's' ; Check if 'W' key is pressed
	je MoveCursorDown
	cmp al, 'd' ; Check if 'W' key is pressed
	je MoveCursorRight
	cmp al, 0x20 ; Check if 'R' key is pressed
	je Defuse
	cmp al, 'r' ; Check if 'R' key is pressed
	je Restart
	jmp GameLoop ; Continue waiting for input if no valid key is pressed
	
MoveCursorUp:
	cmp byte [CursorY], 0
	je GameLoop
	dec byte [CursorY]
	jmp GameLoop
MoveCursorLeft:
	cmp byte [CursorX], 0
	je GameLoop
	dec byte [CursorX]
	jmp GameLoop
MoveCursorDown:
	cmp byte [CursorY], MATRIX_SIZE - 1
	je GameLoop
	inc byte [CursorY]
	jmp GameLoop
MoveCursorRight:
	cmp byte [CursorX], MATRIX_SIZE - 1
	je GameLoop
	inc byte [CursorX]
	jmp GameLoop

GetElement:
	mov al, byte [CursorY]
	mov bl, MATRIX_SIZE
	mul bl
	add al, byte [CursorX]

	; Add the offset to esi
	mov esi, Matrix
	add esi, eax

	mov al, [esi]
	ret

CountMinesAround:
	mov byte [Counter], 0

	; Check element above
    dec byte [CursorY]
	dec byte [CursorX]
    call GetElement
    cmp al, '*'
    jne skip1
	inc byte [Counter]
skip1:
    ; Check element below
    inc byte [CursorX]
    call GetElement
    cmp al, '*'
    jne skip2
	inc byte [Counter]
skip2:
    ; Check element to the left
    inc byte [CursorX]
    call GetElement
    cmp al, '*'
    jne skip3
	inc byte [Counter]
skip3:
    ; Check element to the right
    inc byte [CursorY]
    call GetElement
    cmp al, '*'
    jne skip4
	inc byte [Counter]
skip4:
    ; Check element to the top-left
    inc byte [CursorY]
    call GetElement
    cmp al, '*'
    jne skip5
	inc byte [Counter]
skip5:
    ; Check element to the top-right
    dec byte [CursorX]
    call GetElement
    cmp al, '*'
    jne skip6
	inc byte [Counter]
skip6:
    ; Check element to the bottom-right
    dec byte [CursorX]
    call GetElement
    cmp al, '*'
    jne skip7
	inc byte [Counter]
skip7:
    ; Check element to the bottom-left
    dec byte [CursorY]
    call GetElement
    cmp al, '*'
    jne skip8
	inc byte [Counter]
skip8:
	mov al, byte [Counter]
	add al, '0'

	ret

Defuse:
    call GetElement
	
	cmp al, '*'
	je Restart
	mov cl, byte [CursorX]
	mov ch, byte [CursorY]
	call CountMinesAround
	mov byte [CursorX], cl
	mov byte [CursorY], ch
	cmp al, '0'
	jne DefuseEnd
	mov al, ' '
DefuseEnd:
	call PrintChar
	jmp GameLoop

Restart:
	jmp Start

Start:
	call ClearScreen
	call PrintLogo

	call SetCursor
	
	call PrintMatrix
	; Print keyboard legend at the bottom of the screen
	mov byte [CursorPosition], KeyboardLegendPosition
	call SetCursorRow
	mov si, GameKeyboardLegend
	call PrintString

	mov byte [CursorX], 0
	mov byte [CursorY], 0

GameLoop:
	call SetCursor
	; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleGameInput
	
	jmp GameLoop

times 2048-($-$$) db 0