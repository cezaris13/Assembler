%include 'yasmmac.inc' 
org 100h  ;testas   

section .text
   startas:  
   macPutString 'Iveskite tekstine eilute iki 100 simboliu', crlf, '$'
   mov ah,0ah
   mov dx,reiksme
   int 21h
   macNewLine
   xor bx,bx
   mov bl,[reiksme+1];kiek simboliu 
   xor ax,ax
   call kiek_ab 
   call procPutUInt16
   int 20h
   kiek_ab:
      push cx
      mov cx,bx
      xor bx,bx
      inc cx;vienu daugiau prasukti reikia pabaigos kitaip netikrina pvz abbab
      ciklas:
         mov dl,[reiksme+bx]
         cmp dl, 'a'
         jne end
         mov dl,[reiksme+bx+1]
         cmp dl,'b'
         jne end
         mov dl,[reiksme+bx+2]
         cmp dl,'c'
         jne end
         inc al
         end:
         inc bx
      loop ciklas
      pop cx
   ret
%include 'yasmlib.asm'
section .data   
   reiksme:
        db 64h, 00h ,'*******************'
section .bss