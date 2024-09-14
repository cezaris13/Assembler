%include 'yasmmac.inc'
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !
;palei duotas koordinates nupaisoma tiese ekrane (apskaiciuojamas krypties koeficientas etc.)
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
    call procGetUInt16;ivedame kokio n-kampio noresime
    mov [N],ax
    macNewLine
    finit
     fldpi
     fadd st0, st0
     fild word [N]
     fdivr st0, st1
     fstp dword [dphi]
     xor ax,ax
     mov ax, [N]
     inc ax
    call procSetGraphicsMode
      .ciklas:; cia nupiesiamas n-kampis, nenuspalvintas
      finit ; veikimo principas: gaunama esamo tasko x ir y koordinates ir sekancio kuris bus apskritime delta phi=360/n pasislinkes toliau  kartojant n+1 kartu gaunamas nenuspalvintas n-kampis
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

    spalvinimas:;einama vertikaliai ir ieskoma ne juodu pixeliu jei 1 arba 0 nuspalvintas nieko nedarom jei 2 - tada pakeiciam pixeliu spalvas nuo pirmo ne juodo iki paskutinio(siuo budu galima spalvinti tik iskiluosius n-kampius )
        xor di,di
        xor si,si
        pirmasc:
            xor bx,bx
            xor di,di
            dec di
            mov [pirmav],di;pirmos ir antros sutiktos ne juodos spalvos koord. reiskmes i ffff( tokios i ekrana netelpa tai galima nesukti del to galvos)
            mov [antrav],di
            inc di
            antrasc:
            mov cx,si
            mov dx,di
            mov ah,0dh
            int 10h ; int 10h, ah=0dh- palei kokios reiksmes yra cx ir dx grazina i al kokia spalva( 00- juoda)
            cmp al,00
            je baigiam
            cmp bx,0; ar cia pirma sutikta ne juoda
            jne vienas
            mov bx,1
            mov [pirmav],di; jei taip tai i pirmav kintamaji issaugojam koordinate
            jmp baigiam
            vienas:
                mov [antrav],di; else i antra kintamaji
                baigiam:
                inc di
                cmp di,200
            jl antrasc
            mov bx,[pirmav]
            mov cx,[antrav]
            cmp bx,0ffffh;praejus pro viena linija pixeliu patikrinama kiek ne juodu buvo sutikta
            je viskas
            cmp cx,0ffffh
            je viskas
            call spausdinimas; jei 2 tai uzpildoma spalvomis
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
            mov cl,05; 05-violetine
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
        dw 0
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