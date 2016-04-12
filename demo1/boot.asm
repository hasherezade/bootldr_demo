; mini bootloader for educational purposes 
; CC-BY: hasherezade
;
; compile:
; nasm boot.asm -f bin -o boot.bin
; 
; Copy to flash disk (as root)
; example if the flash disk is /dev/sdb:
; dd if=boot.bin of=/dev/sdb bs=512 count=1
;

[bits 16]
[org 0x7C00]

;code
main:
 xor ax,ax
 mov ds,ax
 mov es,ax

 call set_page_1

 mov bp, banner
 mov cx, (banner_len - banner)
 mov dh, 0 ;row
 mov dl, 0 ;column

 call printstr
 hlt

set_page_1:
 mov ah, 0x5
 mov al, 1 ;page number
 int 0x10 ; BIOS video interrupt 
 ret

printstr:
 mov ah, 0x13 ; write string
 mov bh, 0x1 ; page number
 mov bl, 0x0A ; color

 int 0x10 ; BIOS video interrupt 
 ret

;data

banner db 'Matrix has you', 13, 10
banner_len db 0

times 510-($-$$) db 0	;padding
dw 0xAA55		;end signature
