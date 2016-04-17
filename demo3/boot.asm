; mini bootloader for educational purposes
;
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

;macros

%macro PRINT_STR 1 ;buffer
push si
mov si, %1
call puts
pop si
%endmacro

%macro GETC 0
 mov ah, 0
 int 0x16
%endmacro

%macro PUTC 0
  mov ah, 0x0E
  mov bx, 0x11
  int 0x10
%endmacro

%macro GET_STR 1 ;buffer
 mov di, %1
 call gets
%endmacro

%macro CHECK_DISK 1 ; drive
 mov dl, %1 ;drive
 call find_disk
%endmacro

%macro PRINT_BYTE 1 ; buffer
 mov si, %1
 mov al, BYTE[si]
 call print_byte
 PRINT_STR enter_key
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;code
main:
 xor ax,ax
 mov ds,ax
 mov es,ax
 PRINT_STR banner

 CHECK_DISK 0
 CHECK_DISK 1
 CHECK_DISK 0x80
 CHECK_DISK 0x81

 PRINT_STR disk_found
 xor cx,cx
 mov cl, BYTE [disknum]
 list_disks:
  test cx,cx
  jz list_end

   push cx
   mov si, disks_id
   add si, cx
   mov al, BYTE[si]
   cmp al, 0x80
   jnb _print_hd
   PRINT_STR floppy_label
   jmp label_printed
   _print_hd:
   PRINT_STR hd_label
   label_printed:
   PRINT_BYTE si
   pop cx

   dec cx
   jmp list_disks
 list_end:

 PRINT_STR total_found
 PRINT_BYTE disknum
 PRINT_STR bootable_found
 PRINT_BYTE bootablenum
 end:
 PRINT_STR banner_end
 GETC
 int 0x19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; SI - string
puts:
  lodsb
  cmp BYTE al, 0
  je puts_end
    PUTC
    jmp puts
  puts_end:
    ret

; AL - byte to be printed
print_byte:
 push ax
 and al, 0xF0
 sar al, 0x4
 call to_hex_ascii
 PUTC
 pop ax ;recover original value
 call to_hex_ascii
 PUTC
 ret

to_hex_ascii:
 and al, 0x0F
 cmp al, 0xA
 jb num
  sub al, 0xA
  add al, 'A'
 jmp end_to_hex_ascii
 num:
  add al, '0'
 end_to_hex_ascii:
 ret

; DL - drive
; buffer pointer: 0x8000
find_disk:
  mov BYTE [curr_disk], dl
  PRINT_BYTE curr_disk
  xor ah, ah ;reset
  int 0x13
  jc find_disk_end ;operation failed

  xor ax,ax
  mov al, BYTE [disknum]
  mov si, disks_id
  add si, ax
  mov dl, BYTE[curr_disk]
  mov BYTE[si], dl
  add BYTE [disknum], 1

  mov bx, 0x8000 ; buffer
  mov ah, 0x02 ; read
  mov al, 0x01 ; sector count
  mov dh, 0x00 ; head
  mov ch, 0x00 ; track
  mov cl, 0x01 ; sector number
  int 0x13
  jc find_disk_end ; carry bit is set on read error
   mov ax, WORD[0x8200 - 2]
   cmp ax, 0xAA55
   jne find_disk_end
    add BYTE [bootablenum], 1
  find_disk_end:
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;data
enter_key db 13, 10, 0
banner db 'Listing disks...', 13, 10, 0
banner_end db 'Finished! Press any key!', 13, 10, 0
disknum db 0
bootablenum db 0
hd_label db 'Hard disk: ', 0
floppy_label db 'Floppy: ', 0
disk_found db 'Found disks:', 13, 10, 0
total_found db 'Total: ', 0
bootable_found db 'Bootable: ', 0
curr_disk db 0
disks_id db 0, 0, 0, 0

times 510-($-$$) db 0	;padding
dw 0xAA55		;end signature
