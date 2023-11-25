; ---CONSTANTS---
MENU_LOCATION equ 0x7E00
GAME_LOCATION equ 0x8200

DiskRead:
	mov al, 6 ; Read 6 sectors
	mov ch, 0 ; From cylinder 0
	mov cl, 2 ; From sector 2 (counting from 1)
	mov dh, 0 ; From head 0
	mov ah, 2
	int 0x13
	ret