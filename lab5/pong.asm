; ---STRINGS---
GameKeyboardLegend: db "PLAYER1: W, S | PLAYER2: ARROWS UP, DOWN | QUIT: ESC", 0

; ---MENU HANDLE---
HandleGameInput:
	cmp al, 0x1B ; Check if 'Enter' key is pressed
	je QuitGame
	jmp GameLoop ; Continue waiting for input if no valid key is pressed
QuitGame:
	ret

Game:
	call ClearScreen
	call HideCursor
	
	; Print keyboard legend at the bottom of the screen
	mov byte [CursorPosition], KeyboardLegendPosition
	call SetCursor
	mov si, GameKeyboardLegend
	call PrintString
	
GameLoop:
		; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleGameInput
	
	jmp GameLoop
	