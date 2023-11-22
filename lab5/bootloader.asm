[org 0x7C00]

jmp Start

Start:
	; Reading the disk sector with the main program
	mov ah, 2
	mov al, 1
	mov ch, 0
	mov dh, 0
	mov cl, 2
	mov bx, 0x7E00 ; The main program is at 0x7E00
	int 0x13

	jnc Success
	jmp Loop ; If error

Success:
	jmp 0x7E00 ; Jumping to the main program

Loop:
	jmp Loop

times 510 - ($ - $$) db 0
dw 0xAA55