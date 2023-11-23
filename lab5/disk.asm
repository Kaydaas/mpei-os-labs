; ---CONSTANTS---
GAME_LOCATION equ 0x7E00

DiskRead:
	; Read the stage 2 bootloader (2 sectors)
	mov al, 2 ; Read two sectors
	mov ch, 0 ; From cylinder 0
	mov cl, 2 ; From sector 2 (counting from 1)
	mov dh, 0 ; From head 0
	mov ah, 2
	int 0x13
	ret