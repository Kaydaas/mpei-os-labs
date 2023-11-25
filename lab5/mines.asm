[org 0x8200]

jmp Start

; ---INCLUDES---
%include "o.asm"
%include "disk.asm"

; ---STRINGS---
GameKeyboardLegend: db "MOVE CURSOR: W, A, S, D | DEFUSE: SPACE | RESTART: R | QUIT: ESC", 0
ResultKeyboardLegend: db "RESTART: R | QUIT: ESC", 0
WinMessage: db "YOU WON! :)", 0
LoseMessage: db "GAME OVER! :(", 0

; ---CONSTANTS---
MAX_BOARD_SIZE equ 20
MINE_PROBABILITY equ 15 ; 0-100, %
EMPTY equ ' '
MINE equ '*'

; ---VARIABLES---
CursorXTemp: db 0
CursorYTemp:
BoardSize: db 0
BoardLength: dw 0
Board times MAX_BOARD_SIZE * MAX_BOARD_SIZE db 0
MinesTotal: dw 0 ; Total number of mines on board
TilesLeft: dw 0 ; Number of undefused tiles

Counter: dw 0

; ---PROCEDURES---
; Next Cursor position
NextCursorPosition:
	inc byte [CursorX]
	mov al, byte [CursorX]
	cmp al, byte [BoardSize]
	jl NextCursorPositionEnd
	
	mov byte [CursorX], 0
	inc byte [CursorY]
	
NextCursorPositionEnd:
	ret

; Print board
PrintBoard:
	mov word [Counter], 0
	call ResetCursor

PrintBoardLoop:
	mov ax, word [Counter]
	mov cx, word [BoardLength]
	cmp ax, cx
	je PrintBoardEnd
	
	call SetCursor
	
	mov al, 176
	call PutChar
	
	inc word [Counter]
	call NextCursorPosition
	jmp PrintBoardLoop
	
PrintBoardEnd:
	ret

; Plant mines
PlantMines:
	mov word [Counter], 0
	mov word [MinesTotal], 0
	call ResetCursor
	
PlantMiesLoop:
	call SetCursor
	mov ax, word [Counter]
	mov cx, word [BoardLength]
	cmp ax, cx
	je PrintBoardEnd
	
	call CountOffset

	; Get random number from 1 to 100
	rdtsc
	xor edx, edx ; Required because there's no division of EAX solely
	mov ecx, 100 ; 100 possible values
	div ecx ; EDX:EAX / ECX --> EAX quotient, EDX remainder
	mov eax, edx ; -> EAX = [1,100]
	add eax, 1

	cmp al, MINE_PROBABILITY
	jl PlantMine

	mov al, EMPTY
	call PutTile
	jmp PlantMinesContinue

PlantMine:
	inc word [MinesTotal]
	mov al, MINE
	call PutTile

PlantMinesContinue:
	; DEBUG
	; call GetTile
	; call PutChar
	; DEBUG END

	inc word [Counter]
	call NextCursorPosition
	jmp PlantMiesLoop

PlantMinesEnd:
	ret


HandleGameInput:
	cmp al, 'w' ; Check if 'W' key is pressed
	je MoveCursorUp
	cmp al, 'a' ; Check if 'A' key is pressed
	je MoveCursorLeft
	cmp al, 's' ; Check if 'S' key is pressed
	je MoveCursorDown
	cmp al, 'd' ; Check if 'D' key is pressed
	je MoveCursorRight
	cmp al, 0x20 ; Check if 'SPACE' key is pressed
	je Defuse
	cmp al, 'r' ; Check if 'R' key is pressed
	je Restart
	cmp al, 0x1B ; Check if 'ESC' key is pressed
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
	mov al, byte [BoardSize]
	dec al
	cmp al, byte [CursorY]
	je GameLoop
	inc byte [CursorY]
	jmp GameLoop
	
MoveCursorRight:
	mov al, byte [BoardSize]
	dec al
	cmp al, byte [CursorX]
	je GameLoop
	inc byte [CursorX]
	jmp GameLoop

CountOffset:
	push eax
	push ebx
	push edx
	
	movzx eax, byte [CursorY]
	movzx ebx, byte [BoardSize]
	mul ebx
	movzx ebx, byte [CursorX]
	add eax, ebx

    mov esi, Board
    add esi, eax
	
	pop edx
	pop ebx
	pop eax
	
	ret

PutTile:
	call CountOffset
	
	mov byte [esi], al
	ret

GetTile:
    call CountOffset

    mov al, byte [esi]
    ret

CountMinesAround:
	pusha
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
	
    call GetTile
    cmp al, '*'
    jne skip1
	inc byte [Counter]
skip1:
    ; Top
    inc byte [CursorX]
	
	cmp cl, 0
	je skip2
	
    call GetTile
    cmp al, '*'
    jne skip2
	inc byte [Counter]
skip2:
    ; Top right
    inc byte [CursorX]
	
	cmp cl, 0
	je skip3
	
	mov al, byte [BoardSize]
	dec al
	cmp ch, al
	je skip3
	
    call GetTile
    cmp al, '*'
    jne skip3
	inc byte [Counter]
skip3:
    ; Right
    inc byte [CursorY]
	
	mov al, byte [BoardSize]
	dec al
	cmp ch, al
	je skip4
	
    call GetTile
    cmp al, '*'
    jne skip4
	inc byte [Counter]
skip4:
    ; Bottom right
    inc byte [CursorY]
	
	mov al, byte [BoardSize]
	dec al
	cmp cl, al
	je skip5
	
	mov al, byte [BoardSize]
	dec al
	cmp ch, al
	je skip5
	
    call GetTile
    cmp al, '*'
    jne skip5
	inc byte [Counter]
skip5:
    ; Bottom
    dec byte [CursorX]
	
	mov al, byte [BoardSize]
	dec al
	cmp cl, al
	je skip6
	
    call GetTile
    cmp al, '*'
    jne skip6
	inc byte [Counter]
skip6:
    ; Bottom left
    dec byte [CursorX]
	
	mov al, byte [BoardSize]
	dec al
	cmp cl, al
	je skip7
	
	cmp ch, 0
	je skip8
	
    call GetTile
    cmp al, '*'
    jne skip7
	inc byte [Counter]
skip7:
    ; Left
    dec byte [CursorY]
	
	cmp ch, 0
	je skip8
	
    call GetTile
    cmp al, '*'
    jne skip8
	inc byte [Counter]
skip8:
	popa
	mov al, byte [Counter]
	add al, '0'
	ret
	
	

Defuse:
	mov ah, 0x08 ; BIOS function to read character from screen
	int 10h      ; Call BIOS interrupt
	cmp al, 176
	je DecTilesLeft

DefuseContinue:

    call GetTile
	cmp al, '*'
	je GameOver
	
	mov cx, word [MinesTotal]
	mov bx, word [TilesLeft]
	cmp cx, bx
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
	call PutChar
	jmp GameLoop

DecTilesLeft:
	dec word [TilesLeft]
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
	mov byte [CursorPosition], KEYBOARD_LEGEND_POSITION
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

Quit:
	jmp MENU_LOCATION


; Set difficulty using the symbol on the screen printed in menu
SetDifficulty:
	call ResetCursor
	call GetChar
	cmp al, 0
	je EasyDifficulty
	cmp al, 1
	je MediumDifficulty
	cmp al, 2
	je HardDifficulty
	
EasyDifficulty:
	mov byte [BoardSize], 5
	jmp SetDifficultyEnd
	
MediumDifficulty:
	mov byte [BoardSize], 10
	jmp SetDifficultyEnd
	
HardDifficulty:
	mov byte [BoardSize], 20
	
SetDifficultyEnd:
	movzx ax, byte [BoardSize]
	mul ax
	mov word [BoardLength], ax
	ret

Start:
	call SetDifficulty

Restart:
	call ClearScreen
	
	mov byte [CursorPosition], KEYBOARD_LEGEND_POSITION
	call SetCursorRow
	mov si, GameKeyboardLegend
	call PrintString

	call PrintBoard
	call PlantMines
	
	call ResetCursor
	
	mov ax, word [BoardLength]
	mov word [TilesLeft], ax
	
GameLoop:
	call SetCursor
	; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleGameInput
	
	jmp GameLoop

times 2048-($-$$) db 0