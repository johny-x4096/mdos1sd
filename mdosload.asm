    DEVICE zxspectrum48
    org 32768
SPLASHSCR   equ 1
DIVPORT equ 227
CONMEM  equ 128
MAPRAM  equ 64
BANK_MDOS   equ 0
BANK_NMI    equ 1
BANK_SCR    equ 2
BANK_EEPROM equ 3
e_zxi_port  equ 0x783B

; e_zxi_020 - EXTRA button - short press
;   00 - none (only hold CPU)
;   01 - CPU speed
;   02 - Machine
;   03 - GigaScreen
;   04 - Warm reset
;   05 - Joystick/Gamepad interface mode
e_zxi_020   equ 0x20

start
    IF SPLASHSCR
    jp splashscreen
    ELSE
    jp init
    ENDIF
    db "build ",__DATE__," ",__TIME__,0

init
    ; set EXTRA button to Warm reset
    ld bc,e_zxi_port
    ld a,e_zxi_020
    out (c),a
    inc b
    ld a,4
    out (c),a

    di
    ld a,CONMEM+MAPRAM  ; reset MAPRAM (eZX/MB03)
    out (DIVPORT),a
    ld a,BANK_EEPROM|CONMEM
    out (DIVPORT),a
    ld hl,mdosrom
    ld de,8192
    ld bc,8192
    ldir
    ld a,BANK_MDOS|CONMEM
    out (DIVPORT),a
    ld de,8192
    ld bc,8192
    ldir
    ld a,BANK_NMI|CONMEM
    out (DIVPORT),a
    ld hl,mdosmenu
    ld de,8192
    ld bc,8192
    ldir
    ; call 8192
    ld a,MAPRAM
    out (DIVPORT),a
    rst 0

    IF SPLASHSCR
splashscreen
    ld a,7
    out (254),a
    ld hl,22528
    ld de,22529
    ld bc,767
    ld (hl),56
    ldir
    ld hl,logo
    ld de,16384
    ld bc,2048
    ldir

    ld a,2
    call 0x1601
    ld de,message
    ld bc,msg_len
    call 0x203c

waitkey
    halt
    ld a,(23556)
    cp 255
    jr z,waitkey
    jp init

message
    ; db 22,8,4,20,0,"build ",__DATE__," ",__TIME__
    db 22,7,0,20,1," SD version Johny-X & Flyyn '26 ",13
    db 22,1,28,20,0,19,1,"v0.6",19,0
    db 22,9,0,20,0,"       NMI menu controls:       ",20,0,13,13
    db 20,1,"CURSOR",20,0,"/",20,1,"ENTER",20,0,"/",20,1,"BREAK",20,0,13
    db 20,1,"W",20,0," on A/B toggle write protect",13
    db 20,1,"E",20,0," on A/B eject disc image",13
    db 20,1,"S",20,0," original MDOS SNAPSHOT",13
    db 20,1,"D",20,0," select drive in file browser",13
    db 20,1,"R",20,0," reinit drives in drive select",13,13
    db "On eLeMeNt ZX or MB03 use EXTRA button for reset",13
    db 22,21,16,20,0,"Press any key..."
msg_len equ $-message
    ENDIF
mdosrom
    incbin "mdos1sd.bin"
mdosmenu
    incbin "mdosmenu.nmi"
logo
    incbin "logo/logo.scr",2048,2048
end
    SAVETAP "mdosload.tap",start
    SAVEBIN "MDOSLOAD.BIN",start,end-start
    SAVE3DOS "MDOSLOAD.COD",start,end-start
    END
