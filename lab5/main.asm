[org 0x7E00]

jmp Start

; ---INCLUDES---
%include "video.asm"
%include "menu.asm"
%include "pong.asm"

Start:
	call Menu
	call Game
	jmp Start

times 1024-($-$$) db 0