%include 'yasmmac.inc'  
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !
;Programa išveda tik tas eilutes, kuriose antras laukas neturi  raidžių ‘A’ ir ‘B’, o trečio, ketvirto ir penkto laukų sumos skaitmenų suma  yra 7.
  %macro skaitymas 3
     %%pradzia:
          call procFGetChar
          cmp ax,00
          je %%fpabaiga
          push bx
          mov bx,[%1]; pasiimam .size reiskme kuri yra musu masyvo elemento i reiskme
          mov [%2+bx],cl; mes i reiksme kintamaji issaugojam nuskaityta reiksme
          inc bx;padidinam size reiskme ir grazinam ja
          mov [%1],bx
          pop bx 
          cmp cl,%3
          je %%pabaiga
          jmp %%pradzia
     %%fpabaiga:
          push ax
          mov ax,105
          mov [f_pab],ax
          pop ax
     %%pabaiga:
  %endmacro

  %macro spausdinimas 2
     push cx
     push ax
     mov cx,%2
     mov dx,%1
     call procFWrite
     pop ax
     pop cx
  %endmacro

  %macro konvertavimas 2
     mov dx,%1
     call convert_to_digit
     add [%2], ax
  %endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
   startas:; cia nuskaitomi parametrai is mano komandines eilutes  
     xor bx, bx
     mov bl, [0x80];kiek simboliu
     cld
     mov cx,bx
     mov di,0x81
     mov al,20h;skippinam visus whitespace
     repe scasb
     inc cx
     dec di
     mov si,di
     mov di,skaitymoFailas;cia irasome failo pavadinima
     rep movsb

     mov dx,skaitymoFailas
     call procFOpenForReading ;
     jc error_r;error while trying to open file to read
     mov [ReadDescriptor],bx
     xor ax,ax
     xor bx,bx
     xor cx,cx
     xor dx,dx
     mov [f_pab],bx
     macPutString 'Pijus Petkevicius Programu sistemos 1 kursas 1 grupe',crlf,'$'
     macPutString 'Ivesk rasomo failo vardą', crlf, '$'
     mov al, 128                  ; ilgiausia eilutė
     mov dx, rasymoFailas      ; 
     call procGetStr 
     macNewLine

     mov dx,rasymoFailas
     call procFCreateOrTruncate
     jc error_w;error while trying to open or create file for writing into
     mov [WriteDescriptor],bx;close descriptor
     mov bx,[ReadDescriptor]
     skaitymas size, reiksme, 0ah
     WhileEOF:
          mov byte [pirmas_testas],0
          mov bx,[ReadDescriptor]; open descriptor
          push bx
          mov bx,0
          mov [size],bx
          mov [size2],bx
          mov [size3],bx
          mov [size4],bx
          mov [size5],bx
          pop bx
          skaitymas size, reiksme, ';' ; 0ah ; pozicija(dydis nuskaityto), kur saugojama reiksme, comparator
          skaitymas size2, reiksme2, ';' 
          skaitymas size3, reiksme3, ';' 
          skaitymas size4, reiksme4, ';' 
          skaitymas size5, reiksme5, 0ah

          push cx  
          mov cx,5h
          WhileAaBb:;pirma salyga neturi buti AaBb raidziu (veikia)
               push bx
               push cx
               push ax
               mov bx,5
               sub bx,cx
               mov al,[bx+raides]
               mov di,reiksme2
               mov cx,[size2]
               repne scasb
               cmp cx,00
               je contAaBb
               mov byte [pirmas_testas],1
               contAaBb:
               pop ax
               pop cx
               pop bx
          loop WhileAaBb
          pop cx

          push bx;tikrinam ar nera pirmas_testas 1(jei yra tai nebetinka else einam toliau)
          mov bx,[pirmas_testas]
          cmp bx,01
          pop bx
          je skipWritingToFile
          
          ;2 salyga 3 4 5 lauku sumos skaitmenu suma lygi 7
          push dx
          push ax
          push bx
          xor ax,ax
          mov [skaiciu_suma],ax
          mov [skaitmenu_suma],ax
          konvertavimas reiksme3, skaiciu_suma
          konvertavimas reiksme4, skaiciu_suma
          konvertavimas reiksme5, skaiciu_suma
          mov ax,[skaiciu_suma]
          mov dx,rezultatas
          call procInt16ToStr;iki cia kiekvienas stringas konvertuojamas i skaiciu ir pridedamas prie skaiciu_suma kintamojo ir jis konvertuojamas i stringa(patogiau dirbti)
          xor bx,bx  
          WhileDigits:
               mov ax,[rezultatas+bx]
               cmp al,'-'
               jne AddDigits
               inc bx
               jmp WhileDigits
          AddDigits:
               sub ax,30h
               cmp al,0ah
               ja end
               add [skaitmenu_suma], al
               inc bx
               jmp WhileDigits
          end:
          pop bx
          pop ax
          pop dx
          push ax
          mov ax,[skaitmenu_suma]
          cmp al,07
          pop ax
          jne skipWritingToFile

          mov bx,[WriteDescriptor]
          spausdinimas reiksme,[size]
          spausdinimas reiksme2,[size2]
          spausdinimas reiksme3,[size3]
          spausdinimas reiksme4,[size4]
          spausdinimas reiksme5,[size5]
          
          skipWritingToFile:
          push bx
          mov bx,[f_pab]
          cmp bx,105
          mov bx,00
          mov [pirmas_testas],bx
          mov [skaitmenu_suma],bx
          pop bx
          je skip
          cmp ax,00
          jne WhileEOF
          skip:
     mov bx,[WriteDescriptor]
     call procFClose;uzdarome rasymo faila
     mov bx,[ReadDescriptor]
     call procFClose;uzdarome skaitymo faila(prideti klaidos dalykus)
     End:
     int 20h
     error_r:
          macPutString 'klaida atidarant faila skaitymui',crlf,'$'
          jmp End
     error_w:
          macPutString 'klaida atidarant faila rasymui',crlf,'$'
          jmp End
     convert_to_digit:
   ; Išskiria iš buferio, kurio adresas DX'e sveiką skaičių int16 tipo
   ; Rezultatas patalpinamas AX'e. BX'e - adresas, kur buvo sustota (pvz. taepas)  
          push dx
          push cx
          mov bx, dx
          mov ax, 0
          mov cl, 0              ; 0 - if nonnegative, 1 - otherwise
          .next2:
               cmp [bx], byte '-'   ; the minus
               jne .digits
               mov cl, 1            ; negative number
               inc bx
          
          .digits:
               cmp [bx], byte '0'          
               jb  .lessThanNumeric
               cmp [bx], byte '9'          
               jbe  .updateAX
               .lessThanNumeric: 
               jmp .endParsing
               .updateAX:
               mov dx, 10
               mul dx
               mov dh, 0 
               mov dl, [bx]
               sub dl, '0'
               add ax, dx
               inc bx 
               jmp .digits
          .endParsing:
               cmp cl, 1
               jne .return
               neg ax
          .return:        
          pop cx
          pop dx
          ret
%include 'yasmlib.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data   
   skaitymoFailas:
        times 255 db 00
   rasymoFailas:
        times 255 db 00
   ReadDescriptor:
        dw 00
   WriteDescriptor:
        dw 00
   reiksme:
        db 50h, 00h, '************************************************' 
   size:
        dw 00
   reiksme2:
        db 50h, 00h, '************************************************' 
   size2:
        dw 00
   reiksme3:
        db 50h, 00h, '************************************************' 
   size3:
        dw 00
   reiksme4:
        db 50h, 00h, '************************************************' 
   size4:
        dw 00
   reiksme5:
        db 50h, 00h, '************************************************' 
   size5:
        dw 00
   f_pab:
        dw 00
   pirmas_testas:
        dw 00
   skaitmenu_suma:
        dw 00
   skaiciu_suma:
        dw 00
   rezultatas:
        db 50h, 00h, '***********************************************' 
   raides:
        db 'AaBb'
section .bss