%include 'yasmmac.inc' 
%define PERTRAUKIMAS 0x21
;------------------------------------------------------------------------
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 
; pridejau komentara
   startas:  
   jmp Nustatymas

   SenasPertraukimas:
      dw 0,0
   Keiciame:
      jmp .toliau
      .baitas:
         db 00
      .toliau:
         mov cx,2h 
         mov dx,.baitas
         pushf
         call far [cs:SenasPertraukimas]
         xor dx,dx
         mov dx,[.baitas]
         ret
   NaujasPertraukimas:
      push ax
      push bx
      push cx
      push ds
      push es
      push si
      push di
      push bp
      cmp ah,3fh
      jne .toliau
      call Keiciame
      pop bp
      pop di
      pop si 
      pop es
      pop ds
      pop cx
      pop bx
      pop ax
      iret
      .toliau
      pop bp
      pop di
      pop si 
      pop es
      pop ds
      pop cx
      pop bx
      pop ax
      pushf
      call far [cs:SenasPertraukimas]   
    
      iret 
  Nustatymas:
        ; Gauname sena  vektoriu
        push    cs
        pop     ds
        mov     ah, 0x35
        mov     al, PERTRAUKIMAS              ; gauname sena pertraukimo vektoriu
        int     21h

        
        ; Saugome sena vektoriu 
        mov     [cs:SenasPertraukimas], bx             ; issaugome seno doroklio poslinki    
        mov     [cs:SenasPertraukimas + 2], es         ; issaugome seno doroklio segmenta
        
        ; Nustatome nauja  vektoriu
        mov     dx, NaujasPertraukimas
        mov     ah, 0x25
        mov     al, PERTRAUKIMAS                       ; nustatome pertraukimo vektoriu
        int     21h
        
        macPutString "OK ...",  '$'
        
        mov dx, Nustatymas + 1
        int     27h                       ; Padarome rezidentu

%include 'yasmlib.asm'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


