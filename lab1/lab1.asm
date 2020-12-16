%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;------------------------------------------------------------------------
org 100h

  %macro pranesimas 1
      push ax
      push dx
      mov ah, 09h
      mov dx,%1
      int 21h
      pop dx
      pop ax
  %endmacro

section .text                   

    startas:
    call pradine_eilute
    pranesimas pirmas_pranesimas
    mov ah,0ah
    mov dx, ivestis
    int 21h
    pranesimas nauja_eilute
    ; --------------------------------------------- Ivestis -------------
    macPutString 'Ivesk pirma skaiciu', crlf, '$'
    call procGetUInt16
    mov [sk1], ax
    macNewLine 

    macPutString 'Ivesk antra skaiciu', crlf, '$'
    call procGetUInt16
    mov [sk2], ax
    macNewLine 
    
    macPutString 'Ivesk trecia skaiciu', crlf, '$'
    call procGetUInt16
    mov [sk3], ax
    macNewLine 
    call uzd1
    call uzd2                 
    call uzd3
    
    ;funkcijos prasideda cia
    pradine_eilute:
        pranesimas prisistatymas
        pranesimas nauja_eilute
        ret
    uzd1:
        pranesimas pranesimas2
        ;SUKEICIAM 4 ir 8 simbolius +1 masyvo indeksas
        mov ah,[ivestis+5]
        mov al,[ivestis+9]
        mov [ivestis+5],al
        mov [ivestis+9],ah
        mov cl,[ivestis+3]
        mov ah,37;% zenklas desimtainis pavidalas
        mov [ivestis+3],ah; antras elementas tampa %

        mov bx,0
        mov bl, [ivestis+1]           ; bx <- kiek įvedėme baitų
        mov byte [ivestis+bx+3], 0ah ; pridedame gale LF (CR jau ten yra) 
        mov byte [ivestis+bx+4], '$'  ; pridedame gale '$' tam, kad 9-ą funkcija galėtų atspausdinti  
        pranesimas ivestis+2
        int 21h
        ;grazinam kokia buvo eilute
        mov ah,[ivestis+5]
        mov al,[ivestis+9]
        mov [ivestis+5],al
        mov [ivestis+9],ah
        mov [ivestis+3],cl
        ret
    uzd2:
        xor cx,cx
        mov [suma],cx
        pranesimas nauja_eilute
        pranesimas pranesimas3
        ;skaiciuojam
        mov bx,0;paziurim kokio dydzio yra ivestis
        mov bl, [ivestis+1]
        mov cx,bx; prisikiriam ciklo sukimo registrui bx reiksme t.y. kiek kartu suks
        mov bx,0002h; taip reikia
        call ciklas
        pranesimas bendra_suma
        mov ax,[suma]
        call procPutUInt16
        pranesimas nauja_eilute
        ret
    konvertavimas:; kaip viskas vyksta tai dl reiksme atspausdina kaip ascii simboli (4 reiksmes: 30,31,32,33- [0,1,2,3])
        push ax
        mov ah,02h;spausdinimas
        int 21h
        pranesimas nauja_eilute
        pop ax
        ret
    skaitomo_simbolio_spausdinimas:
        push ax
        push dx
        mov ah,02h
        mov dl,[ivestis+bx] ;isveda
        int 21h
        pranesimas tarpas
        pop dx
        pop ax
        ret
    ciklas:
        mov ax,0000h;nunulinam bitu sumos reiksme
        call skaitomo_simbolio_spausdinimas
        mov dh, [ivestis+bx];dh registrui priskiriam simbolio reiksme (a-61) etc.
        rcr dh,3h; pasukam i desine bitus per 2
        adc al, 00; pridedam cy registro reiksme jei ji yra
        rcr dh,1h; pasukam 1 bita i desine
        adc al, 00
        mov dh,[ivestis+bx+1]
        rcr dh,1h;pasukam 1 bita kad gauti 8 bita, t.y. kito simbolio 1 bita
        adc al, 00
        add al,30h;
        mov dl, al
        add [suma],ax
        push ax
        mov ax,30h
        sub [suma],ax
        pop ax
        call konvertavimas; kvieciam konvertavimo funkcija
        inc bx;padidinam registro bx reiksme, t.y. imsim masyvo kita elementa
        loop ciklas; sukam cikla
        ret
    uzd3:
        mov cx,0
        mov dx,0
        mov bx,0
        mov ax,0
        ; -------------------------------- skaiciavimai cia
        mov ax,[sk1];cia modulio funkcija veikia
        mov bx,0fh;15 atimam ir ziurim moduli
        cmp ax,bx
        sub ax,bx
        ja testi
        neg ax
        testi:
        mov [sk1],ax;issaugojam ax'o reiksme pirmam skaiciuje nes daugiau nebenaudosim 
        mov ax,[sk2];antras modulis
        mov bl,0fh;15
        div bx; dalinam is bx
        mov ax,dx
        xor dx,dx
        mov bx,0Ah
        cmp ax,bx
        sub ax,bx
        ja testi1
        neg ax
        testi1:
        add [sk1],ax;issaugojam i pirma skaiciu antro modulio reiksme(pridedam ja)
        mov ax,[sk2];maxi dalykas
        div bx;suskaiciuojama 1 liekana su b%10, tai issaugojama is dx i cx
        mov cx,dx
        xor dx,dx
        mov ax,[sk3]
        div bx
        mov bx,dx;is dx i bx
        mov ax,cx;is cx i ax
        cmp ax,bx;ieskome maxi
        jg testi2
        mov ax,bx
        testi2:  
        add [sk1],ax;viska sudedam i sk1
        mov ax,[sk1]
       ; macPutString crlf, ' Rezultatas yra: $';isvedam   
        pranesimas reiskinys 
        call procPutUInt16
        macNewLine    
        exit
        ret
%include 'yasmlib.asm'

section .data                 ; duomenys
    ;----------Pradiniai-duomenys----------
    prisistatymas:
        db 'Pijus Petkevicius Programu sistemos 1 kursas 1 grupe$'
    pranesimas2:
        db 'Gavome tokia eilute: ', 0x0D, 0x0A, '$'
    pirmas_pranesimas:
        db 'iveskite eilute', 0dh, 0ah, '$'
    ivestis:
        db 50h, 00h, '************************************************' 
    pranesimas3:
        db 'Antro, trecio ir astunto bitu suma yra: ', 0x0D, 0x0A, '$'
    nauja_eilute:
        db 0dh,0ah,'$'
    bendra_suma:
        db 'bendra bitu suma: $'
    tarpas:
        db ' $'
    reiskinys:
        db 'reiskinio |a-15| + |b%15-10| + max(c%10,b%10) rezultatas yra: $'
    sk1:
      dw 00
    sk2:
      dw 00
    sk3:
      dw 00
    suma:
      dw 00
section .bss                    ; neinicializuoti duomenys  