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

;macros

%macro PRINT_STR 1 ;buffer
mov si, %1
call puts
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;code
main:
 xor ax,ax
 mov ds,ax
 mov es,ax
 PRINT_STR banner
 GET_STR 0x7e00
 PRINT_STR 0x7e00
 hlt

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

; DI - buffer
; max : 0x100
gets:
 xor cx, cx ; counter
 read_next:
  GETC
  cmp al, 0x8 ; is backspace pressed?
 je do_backspace
  cmp al, 0x20 ; check if end
 jl gets_end
  cmp cx, 0x100
  je read_next ;limit reached
  mov BYTE [di], al
  inc di
  inc cx
  PUTC
 jmp read_next
 do_backspace:
  test cx, cx
  jz read_next ;nothing to backspace
  PRINT_STR backsp_key
  mov BYTE [di], 0
  dec di
  dec cx
 jmp read_next
 gets_end:
  PRINT_STR enter_key
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;data
backsp_key db 8,' ',8, 0 ; emulated backspace
enter_key db 10, 13, 0
banner db 'Enter your text:', 13, 10, 0

times 510-($-$$) db 0	;padding
dw 0xAA55		;end signature
