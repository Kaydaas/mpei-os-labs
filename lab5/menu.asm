; ---STRINGS---
; Title
Logo:
	db "  _______ _______ ______  _______ ", 0
	db " |   _   |   _   |   _  \|   _   |", 0
	db " |.  1   |.  |   |.  |   |.  |___|", 0
	db " |.  ____|.  |   |.  |   |.  |   |", 0
	db " |:  |   |:  1   |:  |   |:  1   |", 0
	db " |::.|   |::.. . |::.|   |::.. . |", 0
	db " `---'   `-------`--- ---`-------'", 0
; Menu
StartGameOption: dw "START GAME", 0
QuitOption: dw "QUIT", 0
MenuKeyboardLegend: dw "SWITCH OPTION: W, S | CHOOSE OPTION: ENTER", 0

; ---VARIABLES---
; Current cursor option
CursorOption: db 0

; ---CONSTANTS---
; Number of lines in logo, used for printing
LogoLength equ 7
; Row number for 'START GAME' option
StartGameCursorPosition equ 8
; Row number for 'QUIT' option
QuitCursorPosition equ 9

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






; ---MENU HANDLE---
HandleMenuInput:
	cmp al, 'w' ; Check if 'w' key is pressed
	je SwitchOption
	cmp al, 's' ; Check if 's' key is pressed
	je SwitchOption
	cmp al, 0x0D ; Check if 'Enter' key is pressed
	je SelectOption
	jmp MenuLoop ; Continue waiting for input if no valid key is pressed

SwitchOption:
	xor byte [CursorOption], 1 ; Toggle the value in CursorOption
	cmp byte [CursorOption], 0
	je SwitchToStartGameOption
	jmp SwitchToQuitOption

SwitchToStartGameOption:
	mov byte [CursorPosition], StartGameCursorPosition
	call SetCursor
	jmp MenuLoop

SwitchToQuitOption:
	mov byte [CursorPosition], QuitCursorPosition
	call SetCursor
	jmp MenuLoop
	
SelectOption:
	cmp byte [CursorOption], 0
	je StartGame
	jmp Quit
StartGame:
	ret
Quit:
	; Shut down the system
    int 0x19

; Set current cursor position to a 'CursorPosition'

; ---MENU HANDLE END---

Menu:
	call ClearScreen
	call PrintLogo
	call ShowCursor

	; Print options
	call PrintNewLine
	mov si, StartGameOption
	call PrintStringL
	mov si, QuitOption
	call PrintStringL

	; Print keyboard legend at the bottom of the screen
	mov byte [CursorPosition], KeyboardLegendPosition
	call SetCursor
	mov si, MenuKeyboardLegend
	call PrintString

	; Set cursor position to 'START GAME' option
	mov byte [CursorPosition], StartGameCursorPosition
	call SetCursor

MenuLoop:
	; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleMenuInput
	jmp MenuLoop