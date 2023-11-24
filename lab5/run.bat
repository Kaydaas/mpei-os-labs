@echo off

del *.bin
del *.img

nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin menu.asm -o menu.bin
nasm -f bin mines.asm -o mines.bin

qemu-img create -f raw disk.img 1M
copy /B bootloader.bin+menu.bin+mines.bin disk.img

qemu-system-x86_64 -drive format=raw,file=disk.img

pause