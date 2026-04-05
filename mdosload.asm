    DEVICE zxspectrum48
    org 32768
SPLASHSCR   equ 0
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
    halt
    ld a,(23556)
    cp 255
    jr z,waitkey
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
logo
    incbin "logo/logo.scr",2048,2048
    ; incbin "mdos3sd.bin"
    SAVETAP "mdosload.tap",start
    END
