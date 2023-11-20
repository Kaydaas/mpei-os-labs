@echo off

del *.obj
del *.bin
del *.img
del *.exe

nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin minefield.asm -o minefield.bin

qemu-img create -f raw disk.img 1M
copy /B bootloader.bin+minefield.bin disk.img

qemu-system-x86_64 -drive format=raw,file=disk.img

pause