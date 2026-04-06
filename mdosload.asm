    DEVICE zxspectrum48
    org 32768
SPLASHSCR   equ 1
DIVPORT equ 227
CONMEM  equ 128
MAPRAM  equ 64

    MACRO PADORG addr
         ; add padding
         IF $ < addr
         BLOCK addr-$
         ENDIF
         ORG addr
    ENDM

start
    IF SPLASHSCR
    ld a,7
    out (254),a
    ld hl,22528
    ld de,22529
    ld bc,767
    ld (hl),56
    ldir
    ld hl,logo
    ld de,18432
    ld bc,2048
    ldir

    ld a,2
    call 0x1601
    ld de,message
    ld bc,msg_len
    call 0x203c

    ld hl,18432
    ld de,logo
    ld bc,64
1
    push bc
    push hl
    ld bc,32
    ldir
    pop hl
    pop bc
    call downhl
    djnz 1b


    
    call waitkey
    ENDIF

    di
    ld a,CONMEM+MAPRAM  ; reset MAPRAM
    out (DIVPORT),a
    ld a,3|CONMEM
    out (DIVPORT),a
    ld hl,mdosrom
    ld de,8192
    ld bc,8192
    ldir
    ; ld a,MAPRAM
    ld a,0|CONMEM
    out (DIVPORT),a
    ; ld hl,mdosrom+8192
    ld de,8192
    ld bc,8192
    ldir
    ld a,1|CONMEM
    out (DIVPORT),a
    ld hl,mdosmenu
    ld de,8192
    ld bc,8192
    ldir
    ld a,MAPRAM
    out (DIVPORT),a
    ei
    ret
    rst 0

    IF SPLASHSCR
waitkey
    call fx
    ; call logocp

    halt
    ld a,(23556)
    cp 255
    jr z,waitkey
    ret

fx
    ld hl,(var2)
    inc hl
    ld (var2),hl
    push iy
    call fx0
    and 31
    ld d,a
    call fx0
    ld e,a
    push de
    pop iy
    ld ix,logo
    ld c,0
    ld hl,18432


    ld e,l
    ld d,h
1
    push hl
    ld b,32

2
    xor (iy+0)
    or (iy+1)
    and (hl)
    or (ix+0)
    ld (de),a
    inc l
    inc e
    inc iy
    inc ix
    djnz 2b
    pop hl
    ld e,l
    ld d,h
    call downhl
    inc c
    ld a,c
    cp 57

    jr nz,1b
    pop iy
    ret

fx0
    push de
    push hl
    ld a,r
    ld l,a
    ld a,(var1)
    add l
    xor 7
    rlca
    add a,31
    ld (var1),a
    ld hl,(var2)
    ld de,29711
    add hl,de
    rlc l
    ld (var2),hl
    xor l
    xor h
    pop hl
    pop de
    ret

fx1
var1
    db 0
var2
    dw 0

logocp
    ld de,logo
    ld hl,18432
    ld b,64
1
    push bc
    push hl
    ld b,32
2
    ld a,(de)
    or (hl)
    ld (hl),a
    inc hl
    inc de
    djnz 2b
    pop hl
    pop bc
    call downhl
    djnz 1b
    ret

downhl
    inc h
    ld a,h
    and 7
    ret nz
    ld a,l
    add a,32
    ld l,a
    ld a,h
    jr c,downhl2
    sub 8
    ld h,a
downhl2
    cp 88
    ret c
    ld h,64
    ret

message
    db 22,0,0,20,1,"      Vrbice 04/26 PreBeta      "
    db 22,1,4,20,0,"build ",__DATE__," ",__TIME__
    db 22,15,0,20,1," SD version Johny-X & Flyyn '26 "
    db 22,9,28,20,0,"v0.1"
    db 22,21,0,20,0,"Press any key..."
msg_len equ $-message
    ENDIF
mdosrom
    incbin "mdos1sd.bin"
mdosmenu
    incbin "mdosmenu.nmi"
    ALIGN 256
logo
    incbin "logo/logo.scr",2048,2048
    ; incbin "mdos3sd.bin"
    SAVETAP "mdosload.tap",start
    END
