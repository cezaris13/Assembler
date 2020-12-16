%include 'yasmmac.inc'  
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !
  %macro viena_krastine 4;y1 y2 x1 x2
  push ax
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
     %%ciklas:
        mov [x],ax
        finit
        fild word[x]
        fmul dword [koef]
        fistp dword [y]
        mov si, [x]
        mov di, [y]
        mov cl, 5 
        add di,[b]
        call procPutPixel
        sub di,[b]
        inc ax
        mov bx,[max]
        cmp ax,bx
   jle %%ciklas
   pop ax

  %endmacro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 

   startas:                     ; nuo cia vykdomas kodas
    call procGetUInt16
    mov [N],ax
    macNewLine 
    finit 
     fldpi
     fadd st0, st0
     fild word [N]101
     fdivr st0, st1 
     fstp dword [dphi]
     xor ax,ax
     mov ax, [N]
     inc ax
    call procSetGraphicsMode
      .ciklas:
      finit
      fld dword [phi]
      fcos 
      fmul dword [R]
      fild word [xc]
      fadd st0, st1
      frndint
      fistp word [x1]
      fdecstp   
      finit   
      fld dword [phi]
      fadd dword [dphi]
      fcos 
      fmul dword [R]
      fild word [xc]
      fadd st0, st1
      frndint
      fistp word [x2]
      fdecstp 

      finit
      fld dword [phi]
      fsin 
      fmul dword [R]
      fild word [yc]
      fadd st0, st1
      frndint
      fistp word [y1]
      finit
      fld dword [phi]
      fadd dword [dphi]
      fsin 
      fmul dword [R]
      fild word [yc]
      fadd st0, st1
      frndint
      fistp word [y2]
      viena_krastine y1,y2,x1,x2
      fld dword [phi]
      fadd dword [dphi]
      fstp  dword [phi]

      dec ax  
      cmp ax,00
      jge .ciklas     
      call spalvinimas
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
section .data   
    N:
        dw 0                ; duomenys
    dphi:
        dd  0.0
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
    R:
     dd  50.0

    phi: 
     dd  0.0
    xc: 
     dw 160
    yc:
     dw 100
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss  