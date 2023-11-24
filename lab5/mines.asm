[org 0x8200]

jmp Start

; ---INCLUDES---
%include "o.asm"
%include "disk.asm"

; ---STRINGS---
; Logo
; Keyboard legend at the bottom of the screen
GameKeyboardLegend: db "MOVE CURSOR: W, A, S, D | DEFUSE: SPACE | RESTART: R | QUIT: ESC", 0
WinMessage: db "YOU WON! :)", 0
LoseMessage: db "GAME OVER! :(", 0
ResultKeyboardLegend: db "RESTART: R | QUIT: ESC", 0

; ---CONSTANTS---
MATRIX_SIZE equ 10 ; 10x10 matrix
MINE_PROBABILITY equ 15 ; 1-100 %

; ---VARIABLES---
Matrix times MATRIX_SIZE * MATRIX_SIZE db 0 ; 10x10 matrix
MinesTotal: db 0
TilesLeft: db 0
CursorX: db 0 ; Cursor X position
CursorY: db 0 ; Cursor Y position
RandomNumber: db 0
Counter: dd 0

; ---PROCEDURES---
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
	mov byte [MinesTotal], 0
	call ResetCursor
	
	mov     esi, Matrix

PrintMatrixLoop:
	cmp byte [Counter], MATRIX_SIZE * MATRIX_SIZE
	je MatrixPrintEnd   ; Exit the loop if they are equal

	call SetCursor
	
	mov al, 176
	
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
	;mov [esi], dword '*'
	mov byte [esi], '*'
	inc byte [MinesTotal]
	
Continue:
	inc esi
	
	inc byte [Counter]
	call IncIndex

	jmp PrintMatrixLoop
MatrixPrintEnd:
	ret

CountTotalMines:
	mov byte [Counter], 0
	mov byte [MinesTotal], 0
	call ResetCursor
	mov esi, Matrix
CountTotalMinesLoop:
	cmp byte [Counter], MATRIX_SIZE * MATRIX_SIZE
	je CountTotalMinesEnd   ; Exit the loop if they are equal
	call SetCursor
	call GetElement
	cmp al, '*'
	jne CountTotalMinesContinue
	inc byte [MinesTotal]
CountTotalMinesContinue:
	inc byte [Counter]
	call IncIndex
	jmp CountTotalMinesLoop
CountTotalMinesEnd:
	call ResetCursor
	ret



SetCursor:
	mov dh, byte [CursorY] ; Row
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
	cmp al, 0x1B ; Check if 'R' key is pressed
	je Quit
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
	
	mov cl, byte [CursorY]
	mov ch, byte [CursorX]

	; Top left
    dec byte [CursorY]
	dec byte [CursorX]
	
	cmp cl, 0
	je skip1
	
	cmp ch, 0
	je skip1
	
    call GetElement
    cmp al, '*'
    jne skip1
	inc byte [Counter]
skip1:
    ; Top
    inc byte [CursorX]
	
	cmp cl, 0
	je skip2
	
    call GetElement
    cmp al, '*'
    jne skip2
	inc byte [Counter]
skip2:
    ; Top right
    inc byte [CursorX]
	
	cmp cl, 0
	je skip3
	
	cmp ch, MATRIX_SIZE - 1
	je skip3
	
    call GetElement
    cmp al, '*'
    jne skip3
	inc byte [Counter]
skip3:
    ; Right
    inc byte [CursorY]
	
	cmp ch, MATRIX_SIZE - 1
	je skip4
	
    call GetElement
    cmp al, '*'
    jne skip4
	inc byte [Counter]
skip4:
    ; Bottom right
    inc byte [CursorY]
	
	cmp cl, MATRIX_SIZE - 1
	je skip5
	
	cmp ch, MATRIX_SIZE - 1
	je skip5
	
    call GetElement
    cmp al, '*'
    jne skip5
	inc byte [Counter]
skip5:
    ; Bottom
    dec byte [CursorX]
	
	cmp cl, MATRIX_SIZE - 1
	je skip6
	
    call GetElement
    cmp al, '*'
    jne skip6
	inc byte [Counter]
skip6:
    ; Bottom left
    dec byte [CursorX]
	
	cmp cl, MATRIX_SIZE - 1
	je skip7
	
	cmp ch, 0
	je skip8
	
    call GetElement
    cmp al, '*'
    jne skip7
	inc byte [Counter]
skip7:
    ; Left
    dec byte [CursorY]
	
	cmp ch, 0
	je skip8
	
    call GetElement
    cmp al, '*'
    jne skip8
	inc byte [Counter]
skip8:
	mov al, byte [Counter]
	add al, '0'

	ret

Defuse:
	mov ah, 0x08 ; BIOS function to read character from screen
	int 10h      ; Call BIOS interrupt
	cmp al, 176
	je DecTilesLeft


DefuseContinue:
    call GetElement
	cmp al, '*'
	je GameOver
	
	mov cl, byte [MinesTotal]
	mov bl, byte [TilesLeft]
	cmp cl, bl
	je Win
	
	mov dl, byte [CursorX]
	mov dh, byte [CursorY]
	call CountMinesAround
	mov byte [CursorX], dl
	mov byte [CursorY], dh
	cmp al, '0'
	jne DefuseEnd
	mov al, ' '
DefuseEnd:
	call PrintChar

	jmp GameLoop
DecTilesLeft:
	dec byte [TilesLeft]
	
	jmp DefuseContinue


Win:
	call ClearScreen
	call ResetCursor
	mov si, WinMessage
	call PrintStringL
	jmp Result
GameOver:
	call ClearScreen
	call ResetCursor
	mov si, LoseMessage
	call PrintStringL
Result:
	mov byte [CursorPosition], KeyboardLegendPosition
	call SetCursorRow
	mov si, ResultKeyboardLegend
	call PrintString
	call HideCursor
ResultLoop:
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16
	cmp al, 'r' ; Check if 'R' key is pressed
	je Restart
	cmp al, 0x1B ; Check if 'R' key is pressed
	je Quit
	jmp ResultLoop
	

Restart:
	jmp Start

Quit:
	jmp MENU_LOCATION

Start:
	call ClearScreen

	call SetCursor
	
	call PrintMatrix
	mov byte [CursorPosition], KeyboardLegendPosition
	call SetCursorRow
	mov si, GameKeyboardLegend
	call PrintString

	call ResetCursor
	mov byte [TilesLeft], MATRIX_SIZE * MATRIX_SIZE

	call CountTotalMines

GameLoop:
	call SetCursor
	; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleGameInput
	
	jmp GameLoop

times 2048-($-$$) db 0