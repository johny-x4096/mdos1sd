    DEVICE zxspectrum48
    org 32768
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

mdosrom
    incbin "mdos1sd.bin"
mdosmenu
    incbin "mdosmenu.nmi"
    ; incbin "mdos3sd.bin"
    SAVETAP "mdosload.tap",start
    END
