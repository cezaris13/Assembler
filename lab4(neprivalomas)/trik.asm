%include 'yasmmac.inc'  
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !
  %macro viena_krastine 4;y1 y2 x1 x2
     push cx
     push di
     push ax
     push bx
        mov ax,[%3]
        mov bx,[%4]
        cmp ax,bx
        ja %%daugiau
        mov [min],ax
        mov [max],bx
        jmp %%done
        %%daugiau:
        mov [min],bx
        mov [max],ax
        %%done:
     pop bx
     pop ax
     finit
     fild word[%2]
     fild word[%1]
     fsubr st0,st1;y2-y1
     fild word[%4]
     fild word[%3]
     fsubr st0,st1;x2-x1
     fdivr st0,st2
     fstp dword [koef]
     mov ax,[%3]
     mov [x],ax
     finit
     fild word[x]
     fmul dword [koef]
     fistp dword [y]
     push ax
     mov ax,[%1]
     sub ax,[y]
     mov [b],ax
     pop ax
     mov ax,[min]
     push bx
     %%ciklas:
        mov [x],ax
        finit
        fild word[x]
        fmul dword [koef]
        fistp dword [y]
        
        mov si, [x]
        mov di, [y]
        mov cl, 5 
        ; cmp si,320
        ; jae %%end
        ; cmp di,200
        ; jae %%end
        add di,[b]
        call procPutPixel
        sub di,[b]
        inc ax
        mov bx,[max]
        cmp ax,bx
        %%end:
   jle %%ciklas
   pop bx
   pop di
   pop cx
  %endmacro
  ;trikampis pvz (0,50),(50,150),(100,0)
  ;kvadratas pvz (100,100),(150,100),(150,150),(100,150)
  ;penkiakampis pvz (0,50),(50,150),(150,100),(200,50),(100,0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 
startas:                     ; nuo cia vykdomas kodas
    macPutString "ivesk kokio n-kampio noresi", 0x0D, 0x0A, '$'
    call procGetUInt16
    mov [N],ax
    macNewLine
    mov cx,[N]
    xor di,di
    taskai:
        macPutString "ivesk tasko x koordinate", 0x0D, 0x0A, '$'
        call procGetUInt16
        mov [xtotal+di],ax
        macNewLine
        macPutString "ivesk tasko y koordinate", 0x0D, 0x0A, '$'
        call procGetUInt16
            mov [ytotal+di],ax
        macNewLine
        add di,2
        dec cx
        cmp cx,00
    jne taskai
    call procSetGraphicsMode
    mov cx,[N]
    dec cx
    xor di,di
    xor bx,bx
    add bx,2
    piesimas:
        mov ax,[xtotal+di]
        mov [x1],ax
        mov ax,[xtotal+di+bx]
        mov [x2],ax
        mov ax,[ytotal+di]
        mov [y1],ax
        mov ax,[ytotal+di+bx]
        mov [y2],ax
        viena_krastine y1,y2,x1,x2
        add di,2
        dec cx
        cmp cx,00
    jne piesimas

    mov bx,[N]
    add bx,bx
    sub bx,2
    mov ax,[xtotal]
    mov [x1],ax
    mov ax,[xtotal+bx]
    mov [x2],ax
    mov ax,[ytotal]
    mov [y1],ax
    mov ax,[ytotal+bx]
    mov [y2],ax
    viena_krastine y1,y2,x1,x2
    call spalvinimas

    mov cx,[N]
    xor bx,bx
    taskavimas:
        push cx
        mov si, [xtotal+bx]
        mov di, [ytotal+bx]
        mov cl, 15 
        call procPutPixel 
        pop cx
        add bx,2
        dec cx
        cmp cx,00
    jne taskavimas
    call procWaitForEsc 
    exit
    
    spalvinimas:
        xor di,di
        xor si,si
        pirmasc:
            xor bx,bx
            xor di,di
            dec di
            mov [pirmav],di
            mov [antrav],di
            inc di
            antrasc:
                mov cx,si
                mov dx,di
                mov ah,0dh
                int 10h 
                cmp al,00
                je baigiam
                cmp bx,0
                jne vienas
                mov bx,1
                mov [pirmav],di
                jmp baigiam
                vienas:
                mov [antrav],di
                baigiam:
                inc di
                cmp di,200
            jl antrasc
            mov bx,[pirmav]
            mov cx,[antrav]
            cmp bx,0ffffh
            je viskas
            cmp cx,0ffffh
            je viskas
            call spausdinimas
            viskas:
            inc si
            xor di,di
            cmp si,320
        jl pirmasc
    ret
    spausdinimas:
        mov ax,[pirmav]
        pradzia:
            mov di,ax
            mov cl,05
            call procPutPixel 
            inc ax
            mov bx,[antrav]
            cmp ax,bx
        jne pradzia
    ret
        
%include 'yasmlib.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data                   ; duomenys
    xtotal:
        dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;26 x
    ytotal:
        dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;26 y
    x1:
        dw 0
    y1:
        dw 0
    x2:
        dw 0
    y2:
        dw 0
    koef:
        dd 00.00
    b:
        dw 0
    x: 
        dw  0
    y:
        dw 0 
    pirmav:
        dw 00
    antrav:
        dw 00
    min:
        dw 00
    max:
        dw 00
    N:
      dw 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss  