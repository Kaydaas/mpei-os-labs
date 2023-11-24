[org 0x7E00]

jmp Start

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
	
; Menu
EasyOption: db "EASY", 0
MediumOption: db "MEDIUM", 0
HardOption: db "HARD", 0

MenuKeyboardLegend: db "SWITCH OPTION: W, S | CHOOSE OPTION: ENTER", 0

; ---VARIABLES---
; Current cursor option
Difficulty: db 0

; ---CONSTANTS---
; Number of lines in logo, used for printing
LogoLength equ 7
; Row number for 'START GAME' option
FirstOptionCursorPosition equ 8
; Row number for 'QUIT' option
NumberOfOptions equ 3

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
	je MoveOptionUp
	cmp al, 's' ; Check if 's' key is pressed
	je MoveOptionDowm
	cmp al, 0x0D ; Check if 'Enter' key is pressed
	je SelectOption
	jmp MenuLoop ; Continue waiting for input if no valid key is pressed

MoveOptionUp:
	cmp byte [CursorPosition], FirstOptionCursorPosition
	je MenuLoop
	dec byte [CursorPosition]
	call SetCursorRow
	jmp MenuLoop

MoveOptionDowm:
	cmp byte [CursorPosition], FirstOptionCursorPosition + NumberOfOptions - 1
	je MenuLoop
	inc byte [CursorPosition]
	call SetCursorRow
	jmp MenuLoop
	
SelectOption:
	jmp GAME_LOCATION
	ret

; Set current cursor position to a 'CursorPosition'

; ---MENU HANDLE END---

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

	; Print keyboard legend at the bottom of the screen
	mov byte [CursorPosition], KeyboardLegendPosition
	call SetCursorRow
	mov si, MenuKeyboardLegend
	call PrintString

	; Set cursor position to 'START GAME' option
	mov byte [CursorPosition], FirstOptionCursorPosition
	call SetCursorRow

MenuLoop:
	; Whait for input
	mov ah, 0 ; Reset AH to read keyboard input
	int 0x16 ; Wait for keypress
	jmp HandleMenuInput
	jmp MenuLoop
	
times 1024-($-$$) db 0