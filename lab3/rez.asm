%include 'yasmmac.inc' 
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 
   startas:                     ; nuo cia vykdomas kodas
     macPutString 'Ivesk rasomo failo vardą', crlf, '$'
     mov al, 128                  ; ilgiausia eilutė
     mov dx, skaitymoFailas      ; 
     call procGetStr 
     macNewLine
     call procFOpenForReading
     jc error_r
     mov cl,3h
     mov dx, pranesimas
     mov ah,3fh 
     int 21h
     mov [pranesimas],dx
     mov dx,pranesimas
     call procPutStr
     int 21h
     mov [pranesimas],dx
     mov dx,pranesimas
     call procPutStr
     int 21h
     mov [pranesimas],dx
     mov dx,pranesimas
     call procPutStr
     
      ; int 21h
      ; int 21h
      ; int 21h
      ; int 21h
     int 0x21
     int 3fh
     End:
     int 20h
     error_r:
         macPutString 'klaida atidarant faila skaitymui',crlf,'$'
         jmp End
%include 'yasmlib.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data                   ; duomenys
   skaitymoFailas:
        times 255 db 00
   pranesimas:
      db '***********'
   ReadDescriptor:
        dw 00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


