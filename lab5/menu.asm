[org 0x7E00]

jmp Start

; ---INCLUDES---
%include "o.asm"
%include "disk.asm"

; ---STRINGS---
; Title
Logo:
	db "{__       {__ {__ {___     {__ {________   {__ __  ", 0
	db "{_ {__   {___ {__ {_ {__   {__ {__       {__    {__", 0
	db "{__ {__ { {__ {__ {__ {__  {__ {__        {__      ", 0
	db "{__  {__  {__ {__ {__  {__ {__ {______      {__    ", 0
	db "{__   {_  {__ {__ {__   {_ {__ {__             {__ ", 0
	db "{__       {__ {__ {__    {_ __ {__       {__    {__", 0
	db "{__       {__ {__ {__      {__ {________   {__ __  ", 0
; Menu options
EasyOption: db "EASY", 0
MediumOption: db "MEDIUM", 0
HardOption: db "HARD", 0
CurrentOption: db ">", 0
; Keyboard Legend at the bottom of the screen
MenuKeyboardLegend: db "SWITCH OPTION: W, S | CHOOSE OPTION: ENTER", 0

; ---CONSTANTS---
; Number of lines in logo, used for printing
LOGO_LENGTH equ 7
; Row number for 'START GAME' option
FIRST_OPTION_POSITION equ 8
; Row number for 'QUIT' option
NUMBER_OF_OPTIONS equ 3

; ---VARIABLES---
Difficulty: db 0

; ---PROCEDURES---
PrintLogo:
	mov si, Logo
	mov cx, LOGO_LENGTH
PrintLogoLoop:
	push cx
	cld
	call PrintStringL
	pop cx
	loop PrintLogoLoop
	ret

HandleMenuInput:
	cmp al, 'w' ; Check if 'W' key is pressed
	je MoveCursorUp
	cmp al, 's' ; Check if 'S' key is pressed
	je MoveCursorDown
	cmp al, 0x0D ; Check if 'ENTER' key is pressed
	je SelectOption
	jmp MenuLoop ; Continue waiting for input if no valid key is pressed

MoveCursorUp:
	cmp byte [CursorPosition], FIRST_OPTION_POSITION
	je MenuLoop
	dec byte [CursorPosition]
	call SetCursorRow
	jmp MenuLoop

MoveCursorDown:
	cmp byte [CursorPosition], FIRST_OPTION_POSITION + NUMBER_OF_OPTIONS - 1
	je MenuLoop
	inc byte [CursorPosition]
	call SetCursorRow
	jmp MenuLoop
	
SelectOption:
	call ClearScreen
	mov al, byte [CursorPosition]
	sub al, FIRST_OPTION_POSITION
	mov byte [Difficulty], al
	mov byte [CursorPosition], 0
	call SetCursorRow
	mov al, byte [Difficulty]
	call PutChar
	jmp GAME_LOCATION

Start:
	call ClearScreen
	call PrintLogo

	; Print options
	call PrintNewLine
	mov si, EasyOption
	call PrintStringL
	mov si, MediumOption
	call PrintStringL
	mov si, HardOption
	call PrintStringL

	; Print keyboard legend
	mov byte [CursorPosition], KEYBOARD_LEGEND_POSITION
	call SetCursorRow
	mov si, MenuKeyboardLegend
	call PrintString

	; Set cursor position to 'EASY' option
	mov byte [CursorPosition], FIRST_OPTION_POSITION
	call SetCursorRow

MenuLoop:
	; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleMenuInput
	jmp MenuLoop
	
times 1024-($-$$) db 0