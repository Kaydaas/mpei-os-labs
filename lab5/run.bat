@echo off

del *.obj
del *.bin
del *.img

nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin main.asm -o main.bin

qemu-img create -f raw disk.img 1M
copy /B bootloader.bin+main.bin disk.img

qemu-system-x86_64 -drive format=raw,file=disk.img

pause