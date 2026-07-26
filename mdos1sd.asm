    DEVICE ZXSPECTRUM48
DIVPORT equ 227
CONMEM  equ 128
MAPRAM  equ 64
BANK128 equ 32765
BANK_MDOS   equ 0
BANK_NMI    equ 1
BANK_SCR    equ 2
    ORG 0
RST00
    nop
    jr START1
    db 0FFh
    db 0FFh
    db 0FFh
    db 0FFh
    db 0FFh
RST08
    ld          hl,(CH_ADD)
    jp          SYNTAX1
    db          0FFh
    db          0FFh
RST10
    RST         RST28
    dw          10h
    ret
    db          0FFh
    db          0FFh
    db          0FFh
    db          0FFh
RST18
    RST         RST28
    dw          18h
    ret
    db          0FFh
    db          0FFh
    db          0FFh
    db          0FFh
RST20
    RST         RST28
    dw          20h
    ret
    db          0FFh
    db          0FFh
    db          0FFh
    db          0FFh
RST28
    jp          CALLZX1
    db          0FFh
    db          0FFh
    db          0FFh
    db          0FFh
    db          0FFh
RST30
    bit         0x7,(iy+0x1)
    ret
    db          0FFh
    db          0FFh
    db          0FFh
MASK_INT
    ; jp          INTERRUPT
    ; ret
    db 0x18 ; jr 0x52
    jr JPINTERRUPT
CALLZX1
    push        af
    ld          a,(SNAPINF)
    and         a
    jp          nz,SNAPRET
    pop         af
    ex (sp),hl
    ld          (SAVE_DE),de
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    inc         hl
    jp CALLZX1off
    ORG 0x52
    ei  ; return from mdos im1
    reti
    ; ex (sp),hl
    ; push        hl
    ; ld hl,SYSFLAG   ; 0x52
    ; ld (hl),0x4f
    ; ld          hl,0x0
    ; ex (sp),hl
    ; push        de
    ; ld          de,(SAVE_DE)
    ; jp ZXROM
    ; ORG 0x38
JPINTERRUPT
    jp INTERRUPT
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    db          0FFh
    db          0FFh
    db          0FFh
    ORG 0x66
NMI
    ; jp          (ix)
    nop
    pop af
    rst 0
START1
    ex          (sp),hl
    push        bc
    push        af
    ld          a,I
    di
    push        af
    pop         bc
    ld          (IREG2),bc
    push        hl
    ld hl,SYSMRK
    ld          b,0x8
CHCOLD
    ld          a,h
    xor         l
    cp (hl)
    jr          nz,COLD
    inc         hl
    djnz        CHCOLD
    ld a,(hl)
    ld (hl),0x20
    cp          0x4f
    jp          z,ROMRET
    cp          0x45
    jp          z,ERRCOD
    pop         hl
    ld          a,(hl)
    cp          '*'
    jp          z,SPECCOMM
    push        de
    ld          b,h
    ld          c,l
    ld hl,IORTAB
TESTROUT
    ld e,(hl)
    inc         hl
    ld d,(hl)
    inc         hl
    ex          de,hl
    ld          a,h
    or          l
    jr          z,COLD
    sbc         hl,bc
    ex          de,hl
    ld e,(hl)
    inc         hl
    ld d,(hl)
    inc         hl
    jr          nz,TESTROUT
    ex          de,hl
    pop         de
    pop         af
    pop         bc
    ex          (sp),hl
    ret
COLD
    ; set divxxx bank to 0
    ld a,BANK_MDOS
    out (DIVPORT),a
    ; set 48k rom in 128k machine
    ld a,16
    ld bc,BANK128
    out (c),a
    ; out (BANK128),a
; d80 sram test
;     ld          hl,0x0
;     ld          de,0x3800
;     ld          bc,0x800
;     ldir
;     ld          hl,0x0
;     ld          de,0x3800
;     ld          bc,0x800
; RAMTEST
;     ld          a,(de)
;     inc         de
;     cpi
;     jr          nz,RAMERR
;     jp          pe,RAMTEST
;     ld          hl,0x3800
;     ld          d,h
;     ld          e,l
;     inc         de
;     ld          bc,0x800
;     ld          (hl),0x0
;     ldir

    ; ld          hl,0x3eef
    ld hl,SYSMRK
    ld          b,0x8
SETMRK
    ld          a,h
    xor         l
    ld          (hl),a
    inc         hl
    djnz        SETMRK
    ld          (hl),0x20
    ld          a,0x7f
    in          a,(0xfe)
    RRA
    jr          c,NODEB
    RRA
    jr          nc,NODEB
    RRA
    jr          c,NODEB
    RRA
    jr          nc,NODEB
    RRA
    jr          c,NODEB
    ld          (DEBUG),a
NODEB
    ld          de,0x3e00
    ld          hl,0xef8
    ld          bc,0x18
    ldir
    ld          a, 'A'
    ld          (ACDRIVE),a
    ld          hl,0x5800
    ld          de,0x5801
    ld          bc,0x300
    ; ld          (hl),0x12 red ink/paper
    ld (hl),0x9 ; blue ink/paper
    ldir
    ; ld          a,0x2 red border
    ld a,1
    out         (0xfe),a
    ld          sp,0x4000
    call        HWINIT
    di
    ; ld          sp,0x1019
    ld sp,FAKESP    ; DivMMC compatibility patch by u880d
    jp          ZXROM
    ORG 0x012F
RAMERR
    xor         a
CYCLE
    dec         a
    out         (0xfe),a
    ex          (sp),hl
    ex          (sp),hl
    jr          nz,CYCLE
    jp          RST00
ROMRET
    pop         hl
    pop         af
    pop         bc
    ex          (sp),hl
    ei
    ; nop
    ret
ERRCOD
    pop         hl
    pop         af
    pop         bc
    ex          (sp),hl
    ei
    halt
    res         0x5,(iy+0x1)
    bit         0x1,(iy+0x30)
    jr          z,NOCOPYBUF
    RST         RST28
    dw          0ECDh
NOCOPYBUF
    ld          a,(ERR_NR)
    inc         a
    push        af
    ld          hl,0x0
    ld          (iy+0x37),h
    ld          (iy+0x26),h
    ld          (DEFADD),hl
    inc         hl
    ld          (STRMS6),hl
    RST         RST28
    dw          16B0h
    res         0x5,(iy+0x37)
    RST         RST28
    dw          0D6Eh
    set         0x5,(iy+0x2)
    call        ERAVAR
    pop         af
    cp          0x1c
    jr          nc,ERRMDOS
    ld          hl,0x1335
HLROMRET
    push        hl
    jp          ZXROM
ERRMDOS
    ld          b,a
    add         a,0x7
    RST         RST28
    dw          15EFh
    ld          a,0x20
    RST         RST10
    ld          a,b
    ld          de,SYSMSG
    call        PRTMES
    ld          hl,0x1349
    jr          HLROMRET
IORTAB
    dw          022C3h
WORD_ram_019c
    dw          0DD9h
WORD_ram_019e
    dw          025ACh
WORD_ram_01a0
    dw          0E23h
    dw          027A6h
    dw          0DD9h
    dw          027ADh
    dw          0E1Eh
    ; dw          067h
    dw 0x69
    dw          02E7h   ; SNAPR
    dw          0h  ; end tab
SPECCOMM
    inc         hl
    ld          a,(hl)
    cp          '='
    jp          nz,COLD
    inc         hl
    ld          a,(hl)
    inc         hl
    pop         bc
    pop         bc
    ex          (sp),hl
    ei
    out         (0xfe),a
    ld          c,l
    ld          b,h
    call        BCPRT
    jp          ZXROM
PRTMES
    ex          de,hl
    inc         a
    inc         a
SETMESS
    dec         a
    jr          z,PMESSAGE
SETNMESS
    bit         0x7,(hl)
    inc         hl
    jr          z,SETNMESS
    jr          SETMESS
PMESSAGE
    ld          a,(hl)
    push        hl
    res         0x7,a
    cp          0x23
    ld hl,DNZONE1
    jr          z,PRNAME
    cp          0x40
    ld          hl,0x3e8a
    jr          z,PRNAME
    pop         hl
    RST         RST28
    dw          0C3Bh
    bit         0x7,(hl)
    ret         nz
PNEXTCH
    inc         hl
    jr          PMESSAGE
PRNAME
    push        bc
    ld          b,0xa
PRNAMEL
    ld a,(hl)
    and         a
    jr          z,STOPPRNM
    inc         hl
    push        bc
    RST         RST28
    dw          0C3Bh
    pop         bc
    djnz        PRNAMEL
STOPPRNM
    pop         bc
    pop         hl
    jr          PNEXTCH
ERRR
    push        af
    ld          a,(SNAPINF)
    and         a
    jp          nz,SNAPRET
    pop         af
    ld hl,ERR_NR
    ld (hl),a
    push        hl
    ld          hl,(CH_ADD)
SYNTAX1
    pop         bc
    ld          a,(SNAPINF)
    and         a
    jp          nz,SNAPRET
    ld          a,(DEBUG)
    and         a
    jr          z,COMMAND
    push        bc
    ld          hl,(STKEND)
    ld          de,0xa
    add         hl,de
    ld          (STKEND),hl
    ld          a,0x2
    RST         RST28
    dw          1601h
    pop         bc
    push        bc
    call        BCPRT
    ld          a,' '
LAB_ram_023a
    RST         RST10
LAB_ram_023b
    ld          bc,(T_ADDR)
    call        BCPRT
    ld          a,0x20
    RST         RST10
    ld          hl,0x0
    add         hl,sp
    ld          de,(ERR_SP)
    dec         de
    dec         de
    ex          de,hl
    and         a
    sbc         hl,de
    ld          b,h
    ld          c,l
    call        BCPRT
    ld          a,0xd
    RST         RST10
    ld          hl,(STKEND)
    ld          bc,0xfff6
    add         hl,bc
    ld          (STKEND),hl
    pop         bc
COMMAND
    ld ix,SYNTAB
SETCOMM
    ld l,(ix+0)
    ld h,(ix+1)
    ld          a,h
    or          l
    jr          z,NOCOM
    ld          de,(T_ADDR)
    sbc         hl,de
    jr          nz,NEXTCOM
    ld l,(ix+2)
    ld h,(ix+3)
    sbc         hl,bc
    jr          nz,NEXTCOM
    ld          hl,0x0
    add         hl,sp
    ld          de,(ERR_SP)
    ex          de,hl
    and         a
    sbc         hl,de
    ld e,(ix+4)
    ld d,(ix+5)
    sbc         hl,de
    jr          z,DOCOM
NEXTCOM
    ld          de,0x8
    add         ix,de
    jr          SETCOMM
NOCOM
    push        bc
    ld          hl,0xb
    push        hl
    ld          hl,(ERR_SP)
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    ex          de,hl
    ld          bc,0x1303
    and         a
    sbc         hl,bc
    jr          nz,ERROR
    ex          de,hl
    ld          (hl),0x0
    dec         hl
    ld          (hl),0x0
    ld hl,SYSFLAG
    ld (hl),0x45
ERROR
    call        DSKSTP
    ld          hl,(CH_ADD)
    jp          ZXROM
DOCOM
    ld          sp,(ERR_SP)
    ld          hl,0x1b76
    push        hl
    ld          hl,0x2e1
    push        hl
    ld          (T_ADDR),hl
    ld l,(ix+6)
    ld h,(ix+7)
    jp (hl)
RETURN
    call        DSKSTP
    jp          ZXROM
; 0x02E7
SNAPR
    ld          (SAVE_SP),sp
    ld sp,SNAP_SP
    push af
    push bc
    push de
    push hl
    exx
    ex af,af'
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ld          bc,(IREG2)
    push bc
    im          1
; NMIMENU
    ; store SCR into DIVxxx page 2
    ld a,BANK_SCR
    out (DIVPORT),a
    ld hl,16384
    ld de,8192
    ld bc,6912
    ldir

    ; call NMI menu from DIVxxx page 1
    ld a,BANK_NMI
    out (DIVPORT),a
    call 8192

    ex af,af'
    

    ld hl,8192+3
    ld de,DIMAGESTAT
    ld b,14
1
    ld c,(hl)
    ld a,BANK_MDOS
    out (DIVPORT),a
    ld a,c
    ld (de),a
    ld a,BANK_NMI
    out (DIVPORT),a
    inc hl
    inc de
    ; dec b
    ; jr nz,1b
    djnz 1b

    ld a,BANK_SCR
    out (DIVPORT),a
    ld hl,8192
    ld de,16384
    ld bc,6912
    ldir
    ld a,BANK_MDOS
    out (DIVPORT),a

    ex af,af'
    cp 's'
    jp nz,SNAPRET


    ld          a,0xff
    ld          (SNAPINF),a
    ld hl,ACDRIVE
    ld de,DNZONE1
    ld          bc,0xa
    ldir
    ; ld          hl,0x3a4
    ld hl,SNAPNM
    ; ld          de,0x3e8a
    ld de,FNZONE1
    ld          bc,0xb
    ldir
    ld          a,(SNPCOUNT)
    inc         a
    ld          (SNPCOUNT),a
    dec         a
    ld          b,0x0
DECLOP
    sub         0xa
    jr          c,DECOK
    inc         b
    jr          DECLOP
DECOK
    add         a,0x3a
    ld          (SNONMB2),a
    ld          a,b
    add         a,0x30
    ld          (SNONMB1),a
    ei
    ; nop
    ld          hl,0x3f80
    ld          (STARTADR),hl
    ld          de,0xc080
    call        SAVRUN
    call        DSKSTP
SNAPRET
    call        DSKSTP
    di
    ld          sp,0x3fe8
    xor         a
    ld          (SNAPINF),a
    pop af
    jp          pe,SNPRT1
    ld          I,a
    cp          0x3f
    jr          z,NOIM2
    im          2
NOIM2
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ex af,af'
    exx
    pop hl
    pop de
    pop bc
    pop af
    ld          sp,(SAVE_SP)
    jp          ZXROM
SNPRT1
    ld          i,a
    cp          0x3f
    jr          z,NOIM21
    im          2
NOIM21
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ex af,af'
    exx
    pop hl
    pop de
    pop bc
    pop af
    ld          sp,(SAVE_SP)
    ei
    jp          ZXROM
; 0x0394
    ; ORG 0x0394
SNPLOA
    ld          sp,0x3f80
    ld          ix,0x3f80
    ld          de,0xc080
    call        LOADBLOCK
    jp          SNAPRET
SNAPNM
    db          "SNAPSHOT00S"
; SYSMSG
;     ; 29 "*"+128
;     db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
;     db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
;     db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
;     db 0AAH,0AAH,0AAH,0AAH,0AAH
;     db          "File not foun",0E4h
;     db          "File exist",0F3h
;     db          "Disk ful",0ECh
;     db          "Directory ful",0ECh
;     db          "Advanced featur",0E5h
;     db          "Bad device typ",0E5h
;     db          "Device ident missin",0E7h
;     db          "Device unavailabl",0E5h
;     db          0A0h,0A0h,0A0h,0A0h,0A0h,0A0h
;     db          "Device I/O erro",0F2h
;     db          "Bad volume nam",0E5h
;     db          "Bad file typ",0E5h
;     db          "Volume not foun",0E4h
;     db          "File is read protecte",0E4h
;     db          "File is write protecte",0E4h
;     db          "File is not executabl",0E5h
;     db          "File is delete protecte",0E4h
;     db          "Bad record numbe",0F2h
;     db          "Impossible to RENAM",0C5h
;     db          "Impossible to COP",0D9h
;     db          "Corrupted FAT structur",0E5h
;     db          "Stream already ope",0EEh
;     db          "Drive is not read",0F9h
;     db          "Seek erro",0F2h
;     db          "Sector not foun",0E4h
;     db          "CRC erro",0F2h
;     db          "Disk is write protecte",0E4h
;     db          "Internal erro",0F2h
;     db          "Please insert volume #",08Dh
;     db          "Erase all files ",0BFh
;     db          "Rewrite old file ",0BFh
;     db          "All data will be discarded !  ",0A0h
;     db          "File too lon",0E7h





; 04c6h and 0562h
    ; ORG 0x4c6
; rom SAVE trap 0x4c6
    ORG 0x04C9
    push hl
    ld hl,0x4c9
    jp TRAPRET

; rom LOAD trap 0x562
    ORG 0x0564
    push hl
    ld hl,0x0564
    jp TRAPRET
    ORG 0x05FF
; TODO:
; tabulka error restart
SYNTAB
    dw          01B15h
WORD_ram_0601
    dw          01726h
WORD_ram_0603
    dw          02h
WORD_ram_0605
    dw          011DFh
WORD_ram_0607
    dw          01B15h
WORD_ram_0609
    dw          01C8Bh
    dw          0h
    dw          011DFh
    dw          01B12h
    dw          01726h
    dw          02h
    dw          012D3h
    dw          01AB2h
    dw          01C8Bh
    dw          0Ah
    dw          06C1h
    dw          01B0Eh
    dw          01726h
    dw          02h
    dw          01A54h
    dw          01B0Ch
    dw          01C8Bh
    dw          04h
    dw          01306h
    dw          01B08h
    dw          01726h
    dw          02h
    dw          01320h
    dw          01A00h
    dw          01C8Bh
    dw          08h
    dw          01701h
    dw          01A01h
    dw          01C8Bh
    dw          08h
    dw          01704h
    dw          01A03h
    dw          01C8Bh
    dw          08h
    dw          01707h
    dw          01A7Bh
    dw          01C8Bh
    dw          06h
    dw          06F0h
    dw          01AAFh
    dw          01C8Bh
    dw          08h
    dw          086Fh
    dw          01ADDh
    dw          01C8Bh
    dw          08h
    dw          086Fh
    dw          01ACAh
    dw          01C8Bh
    dw          06h
    dw          0A50h
    dw          01AD0h
    dw          01C8Bh
    dw          0Ah
    dw          0A4Bh
    dw          01B00h
    dw          01766h
    dw          06h
    dw          0AC9h
    dw          01B00h
    dw          01766h
    dw          08h
    dw          0AC9h
    dw          01B00h
    dw          01C8Bh
    dw          00h
    dw          0BDBh
    dw          01AFFh
    dw          01C8Bh
    dw          08h
    dw          0B7Bh
    dw          01B04h
    dw          01766h
    dw          06h
    dw          0C14h
    dw          01B03h
    dw          01C8Bh
    dw          08h
    dw          0C2Dh
    dw          01AACh
    dw          01BB1h
    dw          00h
    dw          01139h
    dw          01A9Dh
    dw          01C8Bh
    dw          0Ah
    dw          07E5h
    dw          01ADAh
    dw          01C8Bh
    dw          0Ah
    dw          07E5h
    dw          00h
POKE
    RST         RST18
    cp          '#'
    jr          z,HASHOK
REPORTC
    ld          a,0xb
    jp          ERRR
HASHOK
    RST         RST20
    RST         RST28
    dw          1C82h
    RST         RST18
    cp          ','
    jr          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C82h
    call        ISSYNCONTR
    RST         RST28
    dw          1E85h
    push        af
    ld          a,b
    cp          0x2
    jr          c,NOOUT
    ld          a,0xa
    jp          ERRR
NOOUT
    pop         af
    ld          hl,0x3e00
    add         hl,bc
    ld (hl),a
    ret
LETFNATTR
    RST         RST18
    cp          0xab
    ; ld          hl,0x723
    ld hl,LETATTR
    jr          z,SELLLET
    cp          0xa8
    ld          hl,0x778
    jr          z,SELLLET
GOREPC
    jp          REPORTC
SELLLET
    ld          (VALSYX),hl
    RST         RST20
    cp          0x28
    jr          nz,GOREPC
    RST         RST20
    RST         RST28
    dw          1C8Ch
    RST         RST18
    cp          ')'
    jr          nz,GOREPC
    RST         RST20
    cp          '='
    jr          nz,GOREPC
    RST         RST20
    RST         RST28
    dw          1C8Ch
    call        ISSYNCONTR
    ld          hl,(VALSYX)
    jp (hl)
LETATTR
    RST         RST28
    dw          2BF1h
    ld          a,b
    and         a
    jr          nz,REPORTA
    ld          b,c
    ld          c,0x0
    ld          a,b
    and         a
    jr          z,ATRNAME
ANALATR
    ld hl,DEFATTR
    ld          a,(de)
    and         0xdf
    inc         de
    push        de
    ld          e,0x80
RFINDATR
    cp (hl)
    inc         hl
    jr          z,SETATR
    RRC         e
    jr          nc,RFINDATR
REPORTA
    ld          a,0x9
    jp          ERRR
SETATR
    ld          a,c
    or          e
    ld          c,a
    pop         de
    djnz        ANALATR
ATRNAME
    ex af,af'
    call        DIVSTRING
    call        TESTNM
    call        ARRANGNM
    call        SETWDNM
    call        SETACT
    call        FIRSTMASK
    jp          nz,REPORTS
WATTR
    ex af,af'
    push        hl
    ex          (sp),ix
    ld (ix+0x14),a
    ex          (sp),ix
    pop         hl
    call        WSCADR
    ex af,af'
    call        NEXTMASK
    ret         nz
    jr          WATTR
LETFN
    call        ANSTRING
    call        SETACT
    call        FIRSTMASK
    jr          nz,NOEXIST
    ld          a,0x1c
    jp          ERRR
NOEXIST
    ld          hl,0x3e80
    ld          de,0x3e95
    ld          bc,0x15
    ldir
    call        ANSTRING
    ld hl,EXTE1
    ld          a,(EXTE2)
    cp (hl)
    jr          z,EXTISSOME
REPORTJ
    ld          a,0x32
    jp          ERRR
EXTISSOME
    ld          hl,0x3e80
    ld          de,0x3e95
    ld          bc,0xa
    call        VERIFY
    jr          nz,REPORTJ
    call        FIRSTMASK
    jp          nz,REPORTS
    inc         hl
    ld          de,0x3e9f
    ld          bc,0xa
    ex          de,hl
    ldir
    call        WSCADR
    call        ERAVAR
    ret
ANSTRING
    call        DIVSTRING
    call        SETWDNM
    call        ANALWDNM
    inc         a
    jp          z,REPORTX
    call        ARRANGNM
    jp          c,REPORTF
    ld          a,(EXTE1)
    cp          '?'
    jp          z,REPORTF
    ret
L_PRINT
    RST         RST18
    cp          0x2a
    jp          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C8Ch
    call        ISSYNCONTR
    call        DIVSTRING
    call        SETWDNM
    call        ANALWDNM
    inc         a
    jp          z,REPORTX
    call        ARRANGNM
    jp          c,REPORTF
    jr          z,LPSETEXT
    ld          a,(EXTE1)
    cp          'Q'
    jp          nz,REPORTF
LPSETEXT
    ld          a,'Q'
    ld          (EXTE1),a
    call        SETACT
    call        FIRSTMASK
    jp          nz,REPORTS
    call        GETATR
    bit         0x3,a
    jp          z,REPORTE
    ld          a,0x11
    call        ADDHLA
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    ex          de,hl
PRINTSEC
    call        GETWTEST
    ld          a,d
    cp          0xc
    ret         Z
    ld          (VALSYX),de
    call        LOGFYZ
    ld          de,0x101
    ld          hl,0x3a00
    call        BREADA
    ld          de,(VALSYX)
    ld          a,d
    cp          0xe
    jr          c,PRINTALL
    and         0x1
    ld          d,a
    or          e
    jr          nz,PRINTBUFF
PRINTALL
    ld          de,0x200
PRINTBUFF
    ld hl,AUXBUF
PRNTLOOP
    push        de
    push        hl
    ld a,(hl)
    RST         RST10
    pop         hl
    pop         de
    inc         hl
    dec         de
    ld          a,d
    or          e
    jr          nz,PRNTLOOP
    ld          hl,(VALSYX)
    ld          a,h
    cp          0xe
    ret         nc
    jr          PRINTSEC
L_LIST
    RST         RST18
    cp          0x2a
    jp          nz,REPORTC
    RST         RST20
    call        ISSYNCONTR
    ld          a,0xd
    RST         RST10
    xor         a
    ld          de,0x971
    call        PRTMES
    ld          a,0x1
    ld          de,0x971
    call        PRTMES
    ld          a,0x41
    ld ix,DRPARZN
RINFO2
    push        ix
    push        af
    ld a,(ix+2)
    and         a
    jr          z,RINFO1
    pop         af
    push        af
    RST         RST10
    ld          a,0x2
    ld          de,0x971
    call        PRTMES
RINFO1
    pop         af
    pop         ix
    ld          de,0xc
    add         ix,de
    inc         a
    cp          0x45
    jr          c,RINFO2
    ld          a,0x3
    ld          de,0x971
    call        PRTMES
    ld          a,0x41
    ld ix,DRPARZN
RINFO4
    push        ix
    push        af
    bit 0,(ix+0)
    jr          z,RINFO3
    pop         af
    push        af
    RST         RST10
    ld          a,0x2
    ld          de,0x971
    call        PRTMES
RINFO3
    pop         af
    pop         ix
    ld          de,0xc
    add         ix,de
    inc         a
    cp          0x45
    jr          c,RINFO4
    ld          a,0x4
    ld          de,0x971
    call        PRTMES
    ld          hl,0x3eaa
    call        PTRSTR
    ld          a,0x5
    ld          de,0x971
    call        PRTMES
    call        INITALLDR
    ld          b,0x4
    ld hl,DRNAMES
RINFO5
    push        bc
    push        hl
    ld a,(hl)
    and         a
    jr          z,RINFO6
    ld          a,0x20
    RST         RST10
    ld          a,0x20
    RST         RST10
    pop         hl
    push        hl
    call        PTRSTR
    ld          a,0xd
    RST         RST10
RINFO6
    pop         hl
    pop         bc
    ld          a,0xc
    call        ADDHLA
    djnz        RINFO5
    ld          a,0x6
    ld          de,0x971
    call        PRTMES
    ld          hl,(VARS)
    push        hl
    ld          de,(PROG)
    and         a
    sbc         hl,de
    ld          c,l
    ld          b,h
    call        BCPRT
    ld          a,0x7
    ld          de,0x971
    call        PRTMES
    ld          hl,(E_LINE)
    pop         de
    and         a
    sbc         hl,de
    ld          c,l
    ld          b,h
    call        BCPRT
    ld          a,0x8
    ld          de,INFMES
    call        PRTMES
    ld          bc,(RAMTOP)
    call        BCPRT
    ld          a,0x9
    ld          de,0x971
    call        PRTMES
    RST         RST28
    dw          1F1Ah
    ld          hl,0xffff
    and         a
    sbc         hl,bc
    ld          c,l
    ld          b,h
    call        BCPRT
    ld          a,0xd
    RST         RST10
    ret
; 0x971
INFMES
    db 80h
    db "MDOS Release: 1.0 (01-Sep-92)\r"
    db "(C) Didaktik Skalica 1992",0Dh,08Dh
    db "Drives Defined  :"," "+080h
    db ":,"," "+80h
    db 8,8,32,0Dh
    db "Drives Installed:",0A0h
    db 8,8,32,0Dh
    db "Current Device  :",0A0h
    db ":",0Dh,0Dh
    db "Volumes Available:",08Dh
    db 0Dh
    db "Length of Program  :",0A0h
    db 0Dh
    db "Length of Variables:",0A0h
    db 0Dh,0Dh
    db "Top of RAM :",0A0h
    db 0Dh
    db          "Free memory:",0A0h
RESTORE
    ; ld          hl,0x2296
    ld hl,BWRITE
    jr          RRPRG
READ
    ; ld          hl,0x22a5
    ld hl,BREAD
RRPRG
    ld          (VALSYX),hl
    RST         RST18
    cp          0x2a
JMPREPC
    jp          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C8Ch
    ld          b,0x2
RRPRGPAR
    push        bc
    RST         RST18
    cp          0x2c
    jr          nz,JMPREPC
    RST         RST20
    RST         RST28
    dw          1C82h
    pop         bc
    djnz        RRPRGPAR
    call        ISSYNCONTR
    RST         RST28
    dw          1E99h
    ld          (VALSYY),bc
    RST         RST28
    dw          1E99h
    push        bc
    call        DIVSTRING
    call        SETWDNM
    call        SETACT
    ld          a,(FNZONE1)
    and         a
    jr          z,RRINDISK
    call        ARRANGNM
    jp          c,REPORTF
    call        FIRSTMASK
    jp          nz,REPORTS
    ld          a,0x11
    call        ADDHLA
    ld a,(hl)
    inc         hl
    ld h,(hl)
    ld          l,a
    pop         bc
RRFINDSC
    ld          a,b
    or          c
    jr          z,RRFINDOK
    dec         bc
    call        GETWTEST
    ex          de,hl
    bit         0x3,h
    jr          z,RRFINDSC
    ld          a,0x31
    jp          ERRR
RRINDISK
    pop         hl
RRFINDOK
    call        LOGFYZ
    ld          de,0x100
    call        ERAVAR
    ld          a,(WORKDR)
    ld          hl,(VALSYX)
    push        hl
    ld          hl,(VALSYY)
    ret
OPENINPUT
    ld          hl,(STKEND)
    ld          de,0xa
    add         hl,de
    ld          (STKEND),hl
    RST         RST28
    dw          171Eh
    ld          (VALSYX),hl
    ld          a,b
    or          c
    jr          z,STRNOOPEN
    ld          a,b
    and         a
    jr          nz,REPORTM
    ld          a,c
    cp          0x11
    jr          c,STRNOOPEN
REPORTM
    ld          a,0x35
    jp          ERRR
STRNOOPEN
    call        ANAOPENNM
    push        ix
    call        SETSTRNM
    call        SETACT
    call        FIRSTMASK
    jp          nz,REPORTS
    call        GETATR
    bit         0x3,a
    jp          z,REPORTE
    push        hl
    call        MAKE544B
    push        hl
    call        SETSTRBUF
    pop         hl
    ld          (VALSYY),hl
    ld          de,0x15c4
    call        LD_HL_DE
    ld          de,0x22c2
    call        LD_HL_DE
    ld          a,0xeb
    call        LD_HL_A
MAKEHBUF
    ld          a,(WORKDR)
    call        LD_HL_A
    ex          de,hl
    push        ix
    pop         hl
    ld          a,0x30
    call        ADDHLA
    ld          bc,0xc
    ldir
    ex          de,hl
    ld          de,(ADRSCTR)
    call        LD_HL_DE
    pop         de
    push        de
    call        LD_HL_DE
    ex          (sp),ix
    ld          a,(ix+0xb)
    call        LD_HL_A
    ld          a,(ix+0xc)
    call        LD_HL_A
    ld          a,(ix+0x15)
    call        LD_HL_A
    ld          e,(ix+0x11)
    ld          d,(ix+0x12)
    call        LD_HL_DE
    pop         ix
    ld          de,0x0
    call        LD_HL_DE
    ld          e,l
    ld          d,h
    inc         de
    inc         de
    inc         de
    call        LD_HL_DE
    call        ERAVAR
    pop         ix
    ld          hl,0x1b00
    ld          (T_ADDR),hl
    ret
ONLYOUT
    RST         RST30
    jr          z,NOOPEN1
    RST         RST28
    dw          171Eh
    ld          (VALSYX),hl
    ld          a,b
    or          c
    jr          z,NOOPEN1
    ld          a,b
    and         a
    jp          nz,REPORTM
    ld          a,c
    cp          0x11
    jp          nc,REPORTM
NOOPEN1
    RST         RST18
    cp          0x2c
    jp          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C8Ch
    call        ISSYNCONTR
    call        DIVSTRING
OPENOUTF
    push        ix
    call        SETSTRNM
    call        SETACT
    call        FIRSTMASK
    jr          nz,OPENNULF
    call        GETATR
    bit         0x2,a
    jp z,WPRTER
    call        DFILER
OPENNULF
    call        SETEMPTYF
    push        hl
    call        MAKE544B
    push        hl
    call        SETSTRBUF
    pop         hl
    ld          de,0x25ab
    call        LD_HL_DE
    ld          de,0x15c4
    call        LD_HL_DE
    ld          a,0xeb
    call        LD_HL_A
    jp          MAKEHBUF
OPENIO
    RST         RST18
    cp          0x2c
    jp          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C8Ch
    call        ISSYNCONTR
    call        DIVSTRING
    call        OPENOUTF
    ld          hl,(VALSYY)
    ld          de,0x27ac
    call        LD_HL_DE
    ld          de,0x27a5
    call        LD_HL_DE
    ld          a,0xeb
    call        LD_HL_A
    ld          hl,(VALSYX)
    call        LD_DE_HL
    ld          bc,0xfde0
    ex          de,hl
    add         hl,bc
    ex          de,hl
    dec         hl
    dec         hl
    call        LD_HL_DE
    ret
CLOSESTR
    ld          hl,(STKEND)
    ld          de,0x5
    add         hl,de
    ld          (STKEND),hl
    RST         RST28
    dw          1E94h
    RST         RST28
    dw          1721h
CLOUTSTRF
    push        hl
    call        CLOPENF
    pop         hl
    RST         RST28
    dw          16EBh
    ret
CLOSEALL
    call        ISSYNCONTR
    xor         a
CLOSEALL1
    push        af
    RST         RST28
    dw          1721h
    push        hl
    ld          hl,(CHANS)
    add         hl,bc
    inc         hl
    inc         hl
    inc         hl
    ld          a,(hl)
    pop         hl
    cp          0xeb
    call        z,CLOUTSTRF
    pop         af
    inc         a
    cp          0x10
    jr          c,CLOSEALL1
    ret
CLOPENF
    ld          a,b
    or          c
    ret         Z
    ld          hl,(CHANS)
    add         hl,bc
    ld          d,(hl)
    dec         hl
    ld          e,(hl)
    ex          de,hl
    ld          bc,0x25ab
    sbc         hl,bc
    jr          z,CLOSEOUTF
    ld          bc,0x201
    and         a
    sbc         hl,bc
    jr          z,CLOSEOF1
CLOERROOM
    ex          de,hl
    ld          bc,0x220
    call        DESTRBYTE
    ret
CLOSEOF1
    push        de
    call        CLOERROOM
    pop         de
CLOSEOUTF
    push        ix
    ex          de,hl
    inc         hl
    inc         hl
    inc         hl
    inc         hl
    inc         hl
    inc         hl
    ld          de,0x3e80
    ld          bc,0xa
    ldir
    inc         hl
    inc         hl
    call        SETACT
    call        LD_DE_HL
    ld          c,e
    ld          b,d
    ld          (ADRSCTR),de
    ld          a,(WORKDR)
    ld          (ADRDR),a
    ld          de,0x101
    push        hl
    ld          hl,0x3800
    call        BREADA
    pop         hl
    call        LD_DE_HL
    push        de
    pop         ix
    call        LD_DE_HL
    push        de
    ld          c,(hl)
    inc         hl
    call        LD_DE_HL
    ex          de,hl
    ex          (sp),hl
    push        hl
    ex          de,hl
    call        LD_DE_HL
    ld          (ix+0xb),e
    pop         af
    add         a,d
    ld          (ix+0xc),a
    ld          a,c
    ADC         a,0x0
    ld          (ix+0x15),a
    call        WSCADR
    call        DRVSYS
    ld          a,d
    or          e
    ex          (sp),hl
    jr          z,CLOSEEND
    push        de
    call        GETWTEST
    ld          a,d
    cp          0xc
    jr          z,CLEMPTYF
    push        hl
    call        FIEMPTYFAT
    jp          nz,RETREP
    pop         de
    ex          de,hl
    call        WRTOFAT
    ex          de,hl
CLEMPTYF
    pop         de
    ld          a,d
    or          0xe
    ld          d,a
    call        WRTOFAT
    call        WFATIFCH
    call        LOGFYZ
    pop         hl
    push        hl
    inc         hl
    inc         hl
    inc         hl
    ld          de,0x100
    ld          a,(WORKDR)
    call        BWRITE
CLOSEEND
    pop         hl
    ld          de,0xffe3
    add         hl,de
    ld          bc,0x220
    call        DESTRBYTE
    call        ERAVAR
    pop         ix
    ret
ANAOPENNM
    RST         RST28
    dw          2BF1h
    ld          a,b
    or          c
    jp          z,REPORTF
    call        ANALSTE
    and         a
    ret
SETSTRBUF
    ld          de,(CHANS)
    and         a
    sbc         hl,de
    inc         hl
    ex          de,hl
    ld          hl,(VALSYX)
    ld          (hl),e
    inc         hl
    ld          (hl),d
    ret
SETEMPTYF
    call        FINDANDFILL
    ld          b,0x6
CLSHEADINF
    ld          (hl),0x0
    inc         hl
    djnz        CLSHEADINF
    push        hl
    ld          hl,0x0
    call        FIEMPTYFAT
    jp          nz,RETREP
    ex          de,hl
    pop         hl
    ld          (hl),e
    inc         hl
    ld          (hl),d
    inc         hl
    push        hl
    ex          de,hl
    ld          de,0xc00
    call        WRTOFAT
    pop         hl
    ld          (hl),0x0
    inc         hl
    ld          (hl),0xf
    inc         hl
    ld          (hl),0x0
    ld          de,0xffeb
    add         hl,de
    call        WSCADR
    call        WFATIFCH
    ret
LD_HL_DE
    ld          (hl),e
    inc         hl
    ld          (hl),d
    inc         hl
    ret
LD_HL_A
    ld          (hl),a
    inc         hl
    ret
MAKE544B
    ld          bc,0x220
    jr          MAKEROOM
MAKE1088B
    ld          bc,0x440
MAKEROOM
    ld          hl,(PROG)
    dec         hl
    RST         RST28
    dw          1655h
    inc         hl
    ret
DESTRBYTE
    push        hl
    push        bc
    RST         RST28
    dw          19E8h
    pop         bc
    pop         hl
    ld          de,(CHANS)
    and         a
    sbc         hl,de
    inc         hl
    push        hl
    ld          hl,0x5c10
    ld          a,0x13
CRECTADR
    call        LD_DE_HL
    ex          (sp),hl
    sbc         hl,de
    add         hl,de
    jr          nc,NOCRECT
    ex          de,hl
    and         a
    sbc         hl,bc
    ex          de,hl
    ex          (sp),hl
    dec         hl
    dec         hl
    call        LD_HL_DE
    ex          (sp),hl
NOCRECT
    ex          (sp),hl
    dec         a
    jr          nz,CRECTADR
    pop         hl
    ret
LD_DE_HL
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    inc         hl
    ret
SETSTRNM
    call        SETWDNM
    call        ANALWDNM
    inc         a
    jp          z,REPORTX
    call        ARRANGNM
    jp          c,REPORTF
    ld          a,(EXTE1)
    cp          'B'
    ret         Z
    cp          'Q'
    ret         Z
    cp          '?'
    jp          nz,REPORTF
    ld          a,'Q'
    ld          (EXTE1),a
    ret
RDFROMSTR
    ei
    res         0x3,(iy+0x2)
    ld          hl,(ERR_SP)
    dec         hl
    ld          b,(hl)
    dec         hl
    push        hl
    ld          c,(hl)
    ld          hl,0xf3b
    and         a
    sbc         hl,bc
    pop         hl
    jr          nz,NOINPUT
    ld          (hl),0x48
NOINPUT
    ld          hl,0x18
    add         hl,de
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    inc         hl
    ld          c,(hl)
    inc         hl
    ld          b,(hl)
    ld          a,d
    or          e
    jr          nz,NOEMPTBF
    push        hl
    call        STRRDNSEC
    pop         hl
    jr          c,STRNEXT
    or          0xff
    jp          ZXROM
STRNEXT
    ld          c,l
    ld          b,h
    inc         bc
    inc         bc
NOEMPTBF
    dec         de
    ld          a,(bc)
INCPOINTERS
    inc         bc
    ld          (hl),b
    dec         hl
    ld          (hl),c
    dec         hl
    ld (hl),d
    dec         hl
    ld (hl),e
    scf
    jp          ZXROM
WRTOSTR2
    ld          hl,0x23a
    jr          WRTOSTR
WRTOSTR1
    ld          hl,0x1a
WRTOSTR
    ei
    add         hl,de
    ld e,(hl)
    inc         hl
    ld d,(hl)
    inc         hl
    ld          c,(hl)
    inc         hl
    ld          b,(hl)
    ld          (bc),a
    inc         de
    bit         0x1,d
    jr          z,INCPOINTERS
    push        hl
    call        WFLSTRSC
    pop         hl
    ld          c,l
    ld          b,h
    inc         bc
    ld          de,0x0
    jr          INCPOINTERS
STRRDNSEC
    push        ix
    inc         hl
    inc         hl
    push        hl
    call        STRDRNMSC
    push        hl
    ex          de,hl
    bit         0x3,h
    jr          nz,ISLAST
    call        SETACT
    call        GETWTEST
    call        ERAVAR
    call        LOGFYZ
    pop         hl
    call        LD_HL_DE
    ld          a,d
    cp          0xc
    jr          z,ISEMPTY
    bit         0x3,d
    jr          z,IS512B
    ld          a,d
    and         0x1
    ld          d,a
    or          e
    jr          nz,NO512B
IS512B
    ld          de,0x200
NO512B
    pop         hl
    push        de
    ld          de,0x100
    call        BREADA
    pop         de
    pop         ix
    scf
    ret
ISLAST
    pop         hl
ISEMPTY
    pop         hl
    pop         ix
    and         a
    ret
STRDRNMSC
    ld          de,0xffe6
    add         hl,de
    ld          de,0x3e80
    ld          bc,0xa
    ldir
    ld          de,0x9
    add         hl,de
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    dec         hl
    ret
WFLSTRSC
    push        ix
    inc         hl
    inc         hl
    push        hl
    call        STRDRNMSC
    ld          (VALSYX),hl
    push        de
    call        SETACT
    pop         hl
    call        GETWTEST
    ld          a,d
    cp          0xc
    jr          z,NULENGTH
    push        hl
    call        FIEMPTYFAT
    jp          nz,RETREP
    pop         de
    ex          de,hl
    call        WRTOFAT
    ld          hl,(VALSYX)
    call        LD_HL_DE
    ex          de,hl
NULENGTH
    ld          de,0xe00
    call        WRTOFAT
    call        LOGFYZ
    pop         hl
    push        hl
    ld          de,0x100
    ld          a,(WORKDR)
    call        BWRITE
    pop         hl
    ld          de,0xfff7
    add         hl,de
    ld a,(hl)
    add         a,0x2
    ld (hl),a
    jr          nc,STRWOK
    inc         hl
    inc (hl)
    jr          nz,STRWOK
    inc         hl
    inc (hl)
STRWOK
    call        WFATIFCH
    call        ERAVAR
    pop         ix
    ret
CLOSE0STR
    xor         a
    jp          CLOUTSTRF
ROMDRPAR
    db          00h
    db          00h
    db          00h
    db          00h
    db          00h
    db          018h
    db          028h
    db          09h
    db          00h
    db          00h
    db          00h
    db          00h
DISK_B
    db          00h
    db          00h
    db          00h
    db          00h
    db          00h
    db          014h
    db          050h
    db          09h
    db          00h
    db          00h
    db          00h
    db          00h
TXTSDOS
    db          "SDOS"
NUM24B
    ld          c,0x8
    ld          hl,0x3eda
CALCDIV
    push        hl
    ld          (ix+0x3),0x1
    ld          (ix+0x4),0x0
    ld          (ix+0x5),0x0
    ld          a,c
    dec         a
    jr          z,SETNUM
    ld          b,a
    ld          a,(ix+0x3)
    ld          l,(ix+0x4)
    ld          h,(ix+0x5)
MULT10
    add         a,a
    ADC         hl,hl
    add         a,a
    ADC         hl,hl
    add         a,(ix+0x3)
    ld          e,(ix+0x4)
    ld          d,(ix+0x5)
    ADC         hl,de
    add         a,a
    ADC         hl,hl
    ld          (ix+0x3),a
    ld          (ix+0x4),l
    ld          (ix+0x5),h
    djnz        MULT10
SETNUM
    pop         hl
    ld (hl),0x30
    push        hl
SUBNUM
    ld          a,(ix+0x0)
    ld          l,(ix+0x1)
    ld          h,(ix+0x2)
    sub         (ix+0x3)
    ld          e,(ix+0x4)
    ld          d,(ix+0x5)
    sbc         hl,de
    jr          c,ISLOW
    ld          (ix+0x0),a
    ld          (ix+0x1),l
    ld          (ix+0x2),h
    pop         hl
    inc (hl)
    push        hl
    jr          SUBNUM
ISLOW
    pop         hl
    inc         hl
    dec         c
    jr          nz,CALCDIV
    ld hl,ASCIINM
    ld          b,0x7
CLSNUL
    ld a,(hl)
    cp          0x30
    jr          nz,PRNUM
    ld (hl),0x20
    inc         hl
    djnz        CLSNUL
PRNUM
    ld hl,ASCIINM
    ld          b,0x8
PRNUM1
    ld a,(hl)
    push        hl
    push        bc
    RST         RST10
    pop         bc
    pop         hl
    inc         hl
    djnz        PRNUM1
    ret
TESTNM
    ld          a,(FNZONE1)
    and         a
    jp          z,REPORTF
    ret
BCPRT
    RST         RST28
    dw          02D2Bh
    RST         RST28
    dw          02DE3h
    ret
ADDHLA
    add         a,l
    ld          l,a
    ret         nc
    inc         h
    ret
ANALSTE
    ld          hl,0x3e80
    push        bc
    push        de
    ld          b,0x15
    call        BNULHL
    pop         de
    pop         bc
    jr          DIVSTRING1
DIVSTRCAT
    RST         RST18
    cp          0xd
    jr          z,NOPARCAT
    cp          0x3a
    jr          z,NOPARCAT
    RST         RST28
    dw          1C8Ch
    call        TESTSYN1
DIVSTRING
    ld          hl,0x3e80
    ld          b,0x15
    call        BNULHL
    RST         RST28
    dw          2BF1h
DIVSTRING1
    ex          de,hl
    inc         b
    dec         b
    jp          nz,REPORTF
    ld          b,c
    inc         b
DIVLOOP
    dec         b
    ret         Z
    ld          de,0x3e80
    call        GETNAME
    jr          nz,MOVENAME
    jr          nc,NEXTANAL
    ld          a,(hl)
    ld          (EXTE1),a
    dec         b
    dec         b
    jr          nz,REPORTF
MOVENAME
    ld          hl,0x3e80
    ld          de,0x3e8a
    ld          bc,0xa
    ldir
    ld          hl,0x3e80
    ld          b,0xa
    call        BNULHL
    ret
NEXTANAL
    ld          a,c
    and         a
    jr          z,DIVLOOP
    dec         b
    ret         Z
    ld          de,0x3e8a
    call        GETNAME
    jr          c,ANALFNM
    ret         nz
REPORTF
    ld          a,0xe
    jp          ERRR
ANALFNM
    ld          a,(hl)
    ld          (EXTE1),a
    dec         b
    dec         b
    ret         Z
    jr          REPORTF
NOPARCAT
    call        TESTSYN1
    ld hl,FNZONE1
    ld          de,0x3e8b
    ld (hl),0x3f
    ld          bc,0xa
    ldir
MOVEWDNM
    ld          hl,0x3eaa
    ld          de,0x3e80
    ld          bc,0xa
    ldir
    ret
SETWDNM
    ld hl,DNZONE1
    ld a,(hl)
    and         a
    ret         nz
    jr          MOVEWDNM
BNULHL
    ld          (hl),0x0
    inc         hl
    djnz        BNULHL
    ret
TESTSYN1
    RST         RST30
    ret         nz
    pop         bc
    nop
    jr          SYNCRET
ISSYNCONTR
    RST         RST30
    ret         nz
SYNCRET
    pop         bc
    pop         bc
    pop         bc
    push        hl
    ld          hl,0x1bf4
    ex          (sp),hl
    jp          ZXROM
GETNAME
    ld          c,0x0
MAKENAME
    ld          a,(hl)
    inc         hl
    cp          ':'
    ret         Z
    cp          '.'
    scf
    ret         Z
    ld          (de),a
    inc         de
    inc         c
    ld          a,c
    cp          0xb
    jp          nc,REPORTF
    djnz        MAKENAME
    and         a
    ret
ARRANGNM
    ld hl,FNZONE1
    ld a,(hl)
    and         a
    jr          nz,ARNGNM1
    ld (hl),"*"
ARNGNM1
    ld          b,0xa
    ld          c,0x0
ARRLOPPLD
    ld a,(hl)
    and         a
    jr          z,ARRANGEXT
    cp          '*'
    jr          z,FILLMARK
    cp          '?'
    jr          nz,NOWILD
    set         0x0,c
NOWILD
    inc         hl
    djnz        ARRLOPPLD
ARRANGEXT
    call        SETEXT
    and         a
    RR          c
    ret
FILLMARK
    ld (hl),"?"
    inc         hl
    dec         b
FILLMARK1
    ld a,(hl)
    ld (hl),"?"
    inc         hl
    and         a
    jp          nz,REPORTF
    djnz        FILLMARK1
    set         0x0,c
    jr          ARRANGEXT
SETEXT
    set         0x1,c
    ld          a,(EXTE1)
    call        UPPER
    cp          '*'
    jr          z,SETMARK
    and         a
    jr          nz,EXTIS
    res         0x1,c
SETMARK
    ld          a,0x3f
EXTIS
    ld          (EXTE1),a
    push        hl
    push        bc
    ld          hl,0x10db
    ld          bc,0x7
    CPIR
    pop         bc
    pop         hl
    ret         Z
    ld          a,0x2b
    jp          ERRR
EXTTAB
    db          "PNCBQS?"
ANALWDNM
    ld hl,DNZONE1
ANALWNM
    ld          b,0xa
ANALWDCH
    ld a,(hl)
    and         a
    jr          z,ANALWDEN
    call        ISALFNUM
    jr          nc,REPORTB
    inc         hl
    djnz        ANALWDCH
ANALWDEN
    ld hl,DNZONE1
    ld a,(hl)
    and         a
    ret         Z
    inc         hl
    ld a,(hl)
ANALWDNM1
    and         a
    scf
    ret         nz
    dec         hl
    ld a,(hl)
    call        UPPER
    sub          'A'
    ret         c
    cp          0x5
    jr          z,ANALWDNM1
    ccf
    ret         c
    cp          0x4
    ccf
    ret         nz
    or          0xff
    ret
REPORTB
    ld          a,0x2a
    jp          ERRR
UPPER
    call        ISALFABET
    ret         nc
    and         0xdf
    ret
ISALFNUM
    call        ISNUM
    ccf
    ret         c
ISALFABET
    cp           'A'
    ccf
    ret         nc
    cp          '['
    ret         c
    cp           'a'
    ccf
    ret         nc
    cp          '{'
    ret
ISNUM
    cp          '0'
    ret         c
    cp          ':'
    ccf
    ret
RUN
    ld          bc,0x5
    RST         RST28
    dw          30h
    ld          hl,0x1157
    ld          bc,0x3
    push        de
    ldir
    ld          bc,0x3
    pop         de
    RST         RST28
    dw          2AB2h
    ld          a,0x1
    ld          (T_ADDR),a
    jp          SMLSTART
TXTRUN
    db          "run"
CATNOINF
    RST         RST20
    call        DIVSTRCAT
    call        SETWDNM
    call        ARRANGNM
    call        SETACT
    ld          a,0x2
    RST         RST28
    dw          1601h
    xor         a
    ld          de,0x12ad
    call        PRTMES
    call        NAMEDISK
    call        PTRSTR
    ld          a,0xd
    RST         RST10
    ld          a,0xd
    RST         RST10
    ld          a,0xff
    ld          c,0x0
CATNOLOOP
    call        NEXTMASK
    jr          nz,PRINTINF
    inc         c
    push        bc
    push        af
    call        GETATR
    bit         0x7,a
    jr          nz,ISHIDEEN
    ld          a,(hl)
    inc         hl
    RST         RST10
    ld          a,0x20
    RST         RST10
    call        PTRSTR
    ld          a,0x6
    RST         RST10
ISHIDEEN
    pop         af
    pop         bc
    jr          CATNOLOOP
PRINTINF
    push        bc
    ld          a,0xd
    RST         RST10
    ld          a,0xd
    RST         RST10
    pop         bc
    ld          b,0x0
    call        BCPRT
    ld          de,0x12ad
    ld          a,0x1
    call        PRTMES
    call        FREECOUNT
    push        ix
    ld ix,SV24NM
    sla         c
    rl          b
    ld (ix+0),0
    ld (ix+1),c
    ld (ix+2),b
    call        NUM24B
    pop         ix
    ld          a,0x2
    ld          de,0x12ad
    call        PRTMES
    call        ERAVAR
    ret
CATFN
    RST         RST18
    cp          '-'
    jp          z,CATNOINF
    call        DIVSTRCAT
    call        SETWDNM
    call        ARRANGNM
    call        SETACT
    ld          a,0x2
    RST         RST28
    dw          1601h
    xor         a
    ld          de,0x129e
    call        PRTMES
    call        NAMEDISK
    call        PTRSTR
    ld          a,0xd
    RST         RST10
    ld          a,0xd
    RST         RST10
    ld          a,0xff
    ld          c,0x0
CATFNLOOP
    call        NEXTMASK
    jr          nz,PRINTINF
    inc         c
    push        af
    call        GETATR
    bit         0x7,a
    ld          b,a
    push        bc
    jr          nz,FNISHID
    push        hl
    ld          a,(hl)
    inc         hl
    RST         RST10
    ld          a,0x20
    RST         RST10
    call        PTRSTR
    pop         hl
    ld          a,0xb
    call        ADDHLA
    push        ix
    ld ix,SV24NM
    ld          a,(hl)
    ld (ix+0),a
    inc         hl
    ld          a,(hl)
    ld (ix+1),a
    ld          a,0x9
    call        ADDHLA
    ld          a,(hl)
    ld (ix+2),a
    ld          a,0x17
    RST         RST10
    ld          a,0xe
    RST         RST10
    xor         a
    RST         RST10
    call        NUM24B
    pop         ix
    ld          a,0x17
    RST         RST10
    ld          a,0x17
    RST         RST10
    xor         a
    RST         RST10
    pop         bc
    push        bc
    ld hl,DEFATTR
    ld          e,0x8
CATFNATT
    rl          b
    ld a,(hl)
    inc         hl
    jr          c,CATFNAPR
    ld          a,'-'
CATFNAPR
    push        hl
    push        de
    push        bc
    RST         RST10
    pop         bc
    pop         de
    pop         hl
    dec         e
    jr          nz,CATFNATT
    ld          a,0xd
    RST         RST10
FNISHID
    pop         bc
    pop         af
    jp          CATFNLOOP
DEFATTR
    db          "HSPARWED"
GETATR
    push        hl
    ex          (sp),ix
    ld          a,(ix+0x14)
    ex          (sp),ix
    pop         hl
    ret
PTRSTR
    push        bc
    ld          b,0xa
PRTSTRLOOP
    ld          a,(hl)
LAB_ram_1291
    and         a
    jr          z,ENDPRTSTR
    push        hl
    push        bc
    RST         RST10
    pop         bc
    pop         hl
    inc         hl
    djnz        PRTSTRLOOP
ENDPRTSTR
    pop         bc
    ret
TXTCAT1
    db          0FFh
    db          "\rDirectory of",0A0h
TXTCAT2
    db          0FFh
    db          "\rCatalogue of",0A0h," "
    db          "File(s),",0A0h," "
    db          "Bytes free.",8Dh
ERASE
    call        DIVSTRING
    call        TESTNM
    call        SETWDNM
    call        ARRANGNM
    jp          z,REPORTF
    ld hl,FNZONE1
    ld          b,0xa
ERASEALL
    ld a,(hl)
    inc         hl
    cp          '?'
    jr          nz,ERANOALL
    djnz        ERASEALL
    ld          a,0xbd
    ld          de,SYSMSG
    call        KEYMSG
    ret         nc
ERANOALL
    call        DELALLFIL
    push        af
    call        ERAVAR
    pop         af
    ret         Z
    ld          a,0x1b
    jp          ERRR
MOVEACT
    call        ISSYNCONTR
    call        DIVSTRING
    call        ANALWDNM
    ld hl,DNZONE1
    ld a,(hl)
    and         a
    jp          z,REPORTB
    ld          de,0x3eaa
    ld          bc,0xa
    ldir
    ret
FORMAT
    call        DIVSTRING
    call        ANALWDNM
    jr          z,REPORTY
    jr          nc,FORDROK
REPORTY
    ld          a,0x21
    jp          ERRR
FORDROK
    inc         a
    jr          nz,FORDISK
    ld          a,0x20
    jp          ERRR
FORDISK
    dec         a
    ld          (WORKDR),a
    call        DRVCMP
    jr          nz,FORMAT1
    ld          a,0x22
    jp          ERRR
FORMAT1
    call        ARRANGNM
    ld          hl,0x3e8a
    call        ANALWNM
    jp          c,REPORTB
    ld          a,(ix+0x5)
    ld          (ix+0x1),a
    ld          a,(ix+0x6)
    ld          (ix+0x2),a
    ld          a,(ix+0x7)
    ld          (ix+0x3),a
    ; ignore SINGLE SIDED parameter
    ; ld          a,(EXTE1)
    ; cp          'S'
    ; jr          nz,RFO41
    ; res         0x4,(ix+0x1)
RFO41
    call        ERAVAR
    push        hl
    push        de
    ld          de,SYSMSG
    ld          a,0xbf
    call        KEYMSG
    pop         de
    pop         hl
    ret         nc
    ld          a,(WORKDR)
    call        DRVSEL
    ; call        HOME
    ; prepare sector content, fill 0xe5
    ld hl,VRAM
    ld a,0xe5
    ld b,0
    call FILLCONST
    call FILLCONST
    ; fill attrs with same border/paper, up to last line
    ld a,(ATTR_P)
    and 0x38
    ld b,a
    rrca
    rrca
    rrca
    or b
    ld hl,VRAM_ATTR
    ld de,VRAM_ATTR+1
    ld bc,735
    ld (hl),a
    ldir
    ; check if image len is 80 or 40 tracks
    ld a,(WORKDR)
    call SELIMGSTAT
    ld c,80
    bit 5,(hl)
    jr z,1f ; not 40 tracks
    ld c,40
1
    ld (ix+0x2),c
    ; ld          c,(ix+0x2)      ; c = tracks per side
    ; bit         0x4,(ix+0x1)    ; single sided?
    ; jr          z,RFORM5        
    RLC         c               ; no, double tracks
RFORM5
    ld          b,0x0           ; track counter
  
RFORM6
    push        bc
    ; ld          de,0x100
    ; ld          a,(WORKDR)
    ; call        BFORMA
    ld a,b
    and 7
    out (0xfe),a
    
    ld a,0  ; sector 0
1
    push af
    push bc
    ld c,a
    ld hl,VRAM
    call DWRITESD
;     ld a,c
;     or a
;     jr z,2f
;     ld a,2
;     out (254),a
;     ; jr z,FORMAT_EOF
; 2
    pop bc
    pop af
    inc a
    cp 9
    jr nz,1b


    pop         bc
    inc         b               ; inc track counter
    ld          a,b
    cp          c               ; all formated?
    jr          nz,RFORM6       ; no, continue
    dec         b

/*
FORMTEST
    ld          hl,0xffff
    push        hl
FORMTEST1
    ld          c,0x0
FORMTEST2
    push        bc
    ld          hl,0x4900
    ld          de,0x1
    ld          a,c
    out         (0xfe),a
    ld          a,(WORKDR)
    call        DREAD
    ld          a,0x2
    cp          b
    jr          z,FORMNTEST
    ld          a,0x29
    jp          ERRR
FORMNTEST
    ld          a,0x85
    and         c
    jr          z,FNOTECH
    ld          a,0x3b
    jp          ERRR
FNOTECH
    ld          a,0x18
    and         c
    pop         bc
    jr          z,FORMSOK
    push        bc
    call        FYZLOG
    pop         bc
    push        hl
FORMSOK
    inc         c
    ld          a,(ix+0x3)
    cp          c
    jr          nz,FORMTEST2
    djnz        FORMTEST1
*/
    ld hl,FATBUF
    ld          e,l
    ld          d,h
    inc         de
    ld (hl),0
    ld          bc,0x1ff
    ldir
    ld          de,0x3c80
    ld          hl,0x3e00
    ld          bc,0x30
    ldir
    push        ix
    pop         hl
    ld          bc,0xc
    ldir
    ld          de,0x3cc0
    ld          hl,0x3e8a
    ld          bc,0xa
    ldir
    ld          a,R
    ld          (de),a
    inc         de
    halt
    ld          a,R
    ld          (de),a
    inc         de
    ld          hl,0xf10
    ld          bc,0x4
    ldir
    ld          de,0x101
    ld          hl,0x3c00
    ld          bc,0x0
    ld          a,(WORKDR)
    call        BWRITE
    ld hl,FATBUF
    push        hl
    ld          de,0x3c01
    ld (hl),0xdd
    ld          bc,0x1ff
    ldir
    pop         hl
    ld          c,0x1
WEMPFAT
    push        hl
    ld          de,0x101
    ld          b,0x0
    push        bc
    ld          a,(WORKDR)
    call        BWRITE
    pop         bc
    pop         hl
    inc         c
    ld          a,0x6
    cp          c
    jr          nz,WEMPFAT
    call        SECPERDISK
    and         a
    ld          de,0xe
    sbc         hl,de
    ex          de,hl
    push        de
WTESTFAT
    push        de
    ld          de,0x0
    call        WRTOFAT
    pop         de
    inc         hl
    dec         de
    ld          a,d
    or          e
    jr          nz,WTESTFAT
    pop         bc
    ld          de,0x0
WFAILSEC
    ; pop         hl
    ; ld          a,h
    ; and         l
    ; inc         a
    ; jr          z,WFATEND
    ; push        de
    ; ld          de,0xdff
    ; call        WRTOFAT
    ; pop         de
    ; inc         de
    ; dec         bc
    ; jr          WFAILSEC
WFATEND
    call        WFATIFCH
    push        de
    push        bc
    RST         RST28
    dw          0D6Bh
    ld          a,0xfe
    RST         RST28
    dw          1601h
    xor         a
    ; ld          de,0x14e1
    ld de,TXTFORM
    call        PRTMES
    pop         bc
    push        bc
    call        BCPRT
    ld          a,0x1
    ; ld          de,0x14e1
    ld de,TXTFORM
    call        PRTMES
    pop         bc
    pop         de
    push        bc
    ld          b,d
    ld          c,e
    call        BCPRT
    ld          a,0x2
    ; ld          de,0x14e1
    ld de,TXTFORM
    call        PRTMES
    pop         bc
    sla         c
    rl          b
    ld ix,SV24NM
    ld (ix+0),0
    ld (ix+1),c
    ld (ix+2),b
    call        NUM24B
    ld          a,0x3
    ; ld          de,0x14e1
    ld de,TXTFORM
    call        PRTMES
    call        ERAVAR
    ld          a,(ATTR_P)
    rrca
    rrca
    rrca
    or          0xf8
    out         (0xfe),a
    ret
TXTFORM
    db          0FFh
    db          "Format complete.\r"
    db          "Formatted",0A0h
    db          " good blocks\rand",0A0h
    db          " bad blocks.\r"
    db          "Total capacity i",0F3h
    db          " Bytes.",08Dh
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ; db          0h
    ORG 0x1700
STANDROM
    ; ret
    db 0x18 ; = jr 0x1740
RSAVE
    ld          a,0x0
    db          21h
RLOAD
    ld          a,0x1
    db          21h
RMERGE
    ld          a,0x3
SLMSYNTAX
    ld          (T_ADDR),a
    RST         RST18
    cp          '*'
    jp          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C8Ch
SMLSTART
    RST         RST30
    jr          z,SAVEDATA
    ld          bc,0x11
    ld          a,(T_ADDR)
    and         a
    jr          z,SAVESPACE
    ld          c,0x22
SAVESPACE
    RST         RST28
    dw          30h
    push        de
    pop         ix
    ld          b,0xb
    ld          a,0x20
SAVEBLANK
    ld          (de),a
    inc         de
    djnz        SAVEBLANK
    ld          (ix+0x1),0xff
    call        SLMASTR
SAVEDATA
    RST         RST18
    cp          0xe4
    ; jr          nz,SAVESCRN   ; 0x173c
    ; ld          a,(T_ADDR)
    ; cp          0x3
    jp SAVEDATAoff
; return to rom from 0x1700 d40 trap
    nop
; 0x1740 from 0x1700
    jp ZXROM
SAVEDATAcont
    jp          z,REPORTC
    RST         RST20
    RST         RST28
    dw          28B2h
    set         0x7,c
    jr          nc,SAVEOLD
    ld          hl,0x0
    ld          a,(T_ADDR)
    dec         a
    jr          z,SAVENEW
    ld          a,0x1
    jp          ERRR
SAVEOLD
    jp          nz,REPORTC
    RST         RST30
    jr          z,SAVEDATA1
    inc         hl
    ld          a,(hl)
    ld          (ix+0xb),a
    inc         hl
    ld          a,(hl)
    ld          (ix+0xc),a
    inc         hl
SAVENEW
    ld          (ix+0xe),c
    ld          a,0x1
    bit         0x6,c
    jr          z,SAVETYPE
    inc         a
SAVETYPE
    ld          (ix+0x0),a
SAVEDATA1
    ex          de,hl
    RST         RST20
    cp          ')'
    jr          nz,SAVEOLD
    RST         RST20
    call        ISSYNCONTR
    ex          de,hl
    jp          SAVEALL
SAVESCRN
    cp          0xaa
    jr          nz,SAVECODE
    ld          a,(T_ADDR)
    cp          0x3
    jp          z,REPORTC
    RST         RST20
    call        ISSYNCONTR
    ld          (ix+0xb),0x0
    ld          (ix+0xc),0x1b
    ld          hl,0x4000
    ld          (ix+0xd),l
    ld          (ix+0xe),h
    jr          SAVETYPE3
SAVECODE
    cp          0xaf
    jr          nz,SAVELINE
    ld          a,(T_ADDR)
    cp          0x3
    jp          z,REPORTC
    RST         RST20
    RST         RST28
    dw          2048h
    jr          nz,SAVECODE1
    ld          a,(T_ADDR)
    and         a
    jp          z,REPORTC
    RST         RST28
    dw          1CE6h
    jr          SAVECODE2
SAVECODE1
    RST         RST28
    dw          1C82h
    RST         RST18
    cp          ','
    jr          z,SAVECODE3
    ld          a,(T_ADDR)
    and         a
    jp          z,REPORTC
SAVECODE2
    RST         RST28
    dw          1CE6h
    jr          SAVECODE4
SAVECODE3
    RST         RST20
    RST         RST28
    dw          1C82h
SAVECODE4
    call        ISSYNCONTR
    RST         RST28
    dw          1E99h
    ld          (ix+0xb),c
    ld          (ix+0xc),b
    RST         RST28
    dw          1E99h
    ld          (ix+0xd),c
    ld          (ix+0xe),b
    ld          h,b
    ld          l,c
SAVETYPE3
    ld          (ix+0x0),0x3
    jr          SAVEALL
SAVELINE
    cp          0xca
    jr          z,SAVELINE1
    call        ISSYNCONTR
    ld          (ix+0xe),0x80
    jr          SAVETYPE0
SAVELINE1
    ld          a,(T_ADDR)
    and         a
    jp          nz,REPORTC
    RST         RST20
    RST         RST28
    dw          1C82h
    call        ISSYNCONTR
    RST         RST28
    dw          1E99h
    ld          (ix+0xd),c
    ld          (ix+0xe),b
SAVETYPE0
    ld          (ix+0x0),0x0
    ld          hl,(E_LINE)
    ld          de,(PROG)
    scf
    sbc         hl,de
    ld          (ix+0xb),l
    ld          (ix+0xc),h
    ld          hl,(VARS)
    sbc         hl,de
    ld          (ix+0xf),l
    ld          (ix+0x10),h
    ex          de,hl
SAVEALL
    ld          a,(T_ADDR)
    and         a
    jp          z,SAVECONTR
    push        hl
    ld          bc,0x11
    add         ix,bc
    push        ix
    call        LOAR01
    pop         ix
    pop         hl
    ld          a,(ix+0x0)
    cp          0x3
    jr          z,VERIFYCONT
    ld          a,(T_ADDR)
    dec         a
    jp          z,LOADCONT
    cp          0x2
    jp          z,MERGECONT
VERIFYCONT
    push        hl
    ld          l,(ix-0x6)
    ld          h,(ix-0x5)
    ld          e,(ix+0xb)
    ld          d,(ix+0xc)
    ld          a,h
    or          l
    jr          z,VERCONT1
    sbc         hl,de
    jr c,VERIFIERR
    jr          z,VERCONT1
    ld          a,(ix+0x0)
    cp          0x3
    jr nz,VERIFIERR
VERCONT1
    pop         hl
    ld          a,h
    or          l
    jr          nz,VERCONT2
    ld          l,(ix+0xd)
    ld          h,(ix+0xe)
VERCONT2
    push        hl
    pop         ix
    jp          LOADBLOCK
; REPORTX
VERIFIERR
    ld          a,0x40
    jp          ERRR
LOADCONT
    ld          e,(ix+0xb)
    ld          d,(ix+0xc)
    push        hl
    ld          a,h
    or          l
    jr          nz,LOADCONT1
    inc         de
    inc         de
    inc         de
    ex          de,hl
    jr          LOADCONT2
LOADCONT1
    ld          l,(ix-0x6)
    ld          h,(ix-0x5)
    ex          de,hl
    scf
    sbc         hl,de
    jr          c,LOADDATA
LOADCONT2
    ld          de,0x5
    add         hl,de
    ld          b,h
    ld          c,l
    RST         RST28
    dw          1F05h
LOADDATA
    pop         hl
    ld          a,(ix+0x0)
    and         a
    jr          z,LOADPROG
    ld          a,h
    or          l
    jr          z,LOADDATA1
    dec         hl
    ld b,(hl)
    dec         hl
    ld c,(hl)
    dec         hl
    inc         bc
    inc         bc
    inc         bc
    ld          (X_PTR),ix
    RST         RST28
    dw          19E8h
    ld          ix,(X_PTR)
LOADDATA1
    ld          hl,(E_LINE)
    dec         hl
    ld          c,(ix+0xb)
    ld          b,(ix+0xc)
    push        bc
    inc         bc
    inc         bc
    inc         bc
    ld          a,(ix-0x3)
    push        af
    RST         RST28
    dw          1655h
    inc         hl
    pop         af
    ld          (hl),a
    pop         de
    inc         hl
    ld          (hl),e
    inc         hl
    ld          (hl),d
    inc         hl
    push        hl
    pop         ix
    scf
    ld          a,0xff
    jp          LOADBLOCK
LOADPROG
    ex          de,hl
    ld          hl,(E_LINE)
    dec         hl
    ld          (X_PTR),ix
    ld          c,(ix+0xb)
    ld          b,(ix+0xc)
    push        bc
    RST         RST28
    dw          19E5h
    pop         bc
    push        hl
    push        bc
    RST         RST28
    dw          1655h
    ld          ix,(X_PTR)
    inc         hl
    ld          c,(ix+0xf)
    ld          b,(ix+0x10)
    add         hl,bc
    ld          (VARS),hl
    ld          h,(ix+0xe)
    ld          a,h
    and         0xc0
    jr          nz,LOADPRG1
    ld          l,(ix+0xd)
    ld          (NEWPPC),hl
    ld          (iy+0xa),0x0
LOADPRG1
    pop         de
    pop         ix
    jp          LOADBLOCK
MERGECONT
    ld          c,(ix+0xb)
    ld          b,(ix+0xc)
    push        bc
    inc         bc
    RST         RST28
    dw          30h
    ld          (hl),0x80
    ex          de,hl
    pop         de
    push        hl
    push        hl
    pop         ix
    call        LOADBLOCK
    call        DSKSTP
    pop         hl
    push        hl
    ld          hl,0x8ce
    ex          (sp),hl
    jp          ZXROM
LOAR01
    push        hl
    push        ix
    ld a,(ix-0x11)
    ld          (ix+0x0),a
    call        FINTYP
    call        SETACT
    call        FIRSTMASK
    jr          nz,TSTSNP
    ld          (SVADRA),hl
    pop         ix
    push        ix
    pop         de
    ldir
    ; ld          l,(ix-0x11)=>DAT_ram_ffef
    ld l,(ix-0x11)
    ld          (ix+0x0),l
    xor         a
    ld          (VARIA3),a
    pop         hl
    ret
TSTSNP
    ld          a,(EXTE1)
    cp          'P'
    jp          nz,REPORTS
    ld          a,'S'
    ld          (EXTE1),a
    call        FIRSTMASK
    jp          nz,REPORTS
    ld          (SVADRA),hl
    jp          SNPLOA
LOADBLOCK
    ld          (STARTADR),ix
    ld          (LENDAT),de
    call        SETACT
    ld          hl,(STARTADR)
    ld          de,(LENDAT)
    call        LOAFND
LOADBEND
    ld          ix,(STARTADR)
    ld          de,(LENDAT)
    add         ix,de
    xor         a
    scf
    ret
FINTYP
    ld          a,(ix+0x0)
    ld          hl,0x10db
    call        ADDHLA
    ld a,(hl)
    ld          (EXTE1),a
    ret
SAVESETPAR
    call        FINTYP
    ld          l,(ix+0xd)
    ld          h,(ix+0xe)
    ld          (VALSYX),hl
    ld          l,(ix+0xf)
    ld          h,(ix+0x10)
    ld          (VALSYY),hl
    ld          e,(ix+0xb)
    ld          d,(ix+0xc)
    ret
SAVECONTR
    ld          (STARTADR),hl
    call        SAVESETPAR
SAVRUN
    push        de
    call        SETACT
    call        FIRSTMASK
    jr          nz,SAVNODEL
    call        GETATR
    bit         0x2,a
    jr          nz,SAVRUN1
WPRTER
    ld          a,0x2e
    jp          ERRR
SAVRUN1
    ld          a,(SNAPINF)
    and         a
    jr          nz,SAVNOASK
    ld          a,(AIFASK)
    and         a
    jr          nz,SAVNOASK
    push        hl
    push        de
    ld          de,SYSMSG
    ld          a,0xbe
    call        KEYMSG
    pop         de
    pop         hl
    jp          nc,REPORTF
SAVNOASK
    call        DFILER
SAVNODEL
    pop         de
    ld          hl,(STARTADR)
    call        SAVEFILE
    jp          LOADBEND
SLMASTR
    call        DIVSTRING
    call        SETWDNM
    call        ANALWDNM
    jr          z,SLMNODR
    inc         a
SLMNODR
    ex af,af'
    call        ARRANGNM
    jp          nz,REPORTF
    jp          c,REPORTF
    ret
COPYF
    call        SETCOPYNM
    push        af
    ld          hl,0x3e80
    ld          de,0x3e95
    ld          bc,0x15
    ldir
    call        SETCOPYNM
    push        af
    ld          hl,0x3e80
    ld          de,0x3e95
    ld          bc,0xa
    call        VERIFY
    jr          nz,COPYF2
    pop         af
    jp          c,REPORTF
    pop         af
    jp          c,REPORTF
    ld          hl,0x3e8a
    ld          de,0x3e9f
    ld          bc,0xa
    call        VERIFY
    jp          z,REPORTF
    ld          a,(EXTE1)
    ld hl,EXTE2
    cp (hl)
    jp          nz,REPORTF
    ld          b,0xff
    jr          COPYF4
COPYF2
    pop         af
    ld          b,0x0
    jr          c,COPYF3
    pop         af
    jr          c,COPYF4
    dec         b
    jr          COPYF4
COPYF3
    pop         af
    jp          nc,REPORTF
COPYF4
    ld          c,0x0
    nop
    nop
    nop
    nop
    push        bc
    ld          de,(STKEND)
    ld          hl,(RAMTOP)
    dec         h
    sbc         hl,de
    jr          nc,COPYF5
REPORT4
    ld          a,0x3
    jp          ERRR
COPYF5
    ld          a,h
    SRL         a
    jr          z,REPORT4
    ld          (VALSYX),a
    ld          (VALSYY),de
    ld          a,0xff
    ld          (VALSYX1),a
COPYLOOP
    call        SETACT
    ld          a,(VALSYX1)
    call        NEXTMASK
    ld          (VALSYX1),a
    jp          nz,ENDCOPY
    call        GETATR
    bit         0x3,a
    jp          z,REPORTE
    ld          de,0x3eb4
    ld          bc,0x20
    ldir
    ld hl,SVFSC
    ld e,(hl)
    inc         hl
    ld d,(hl)
    ld          (STARTADR),de
    call        CHNGDRNM
    pop         bc
    push        bc
    inc         b
    jr          z,COPYF6
    ld hl,SVHEAD
    ld a,(hl)
    ld          (EXTE1),a
    inc         hl
    ld          de,0x3e8a
    ld          bc,0xa
    ldir
COPYF6
    call        SETACT
    call        ERAVAR
    call        DELALLFIL
    call        FIRSTEMPTY
    jp          nz,REPORTV
    pop         bc
    push        bc
    push        hl
    ex          de,hl
    inc         b
    jr          z,COPYFONE
    ld          hl,0x3eb4
    ld          bc,0x20
    ldir
    jr          COPYFILE
COPYFONE
    ld          a,(EXTE1)
    ld (de),a
    inc         de
    ld          hl,0x3e8a
    ld          bc,0xa
    ldir
    ld          hl,0x3ebf
    ld          bc,0x15
    ldir
COPYFILE
    ld          hl,0x0
    call        FIEMPTYFAT
    jp          nz,RETREP
    ld          (LENDAT),hl
    ld          de,0xc00
    call        WRTOFAT
    ex          de,hl
    pop         hl
    ld          a,0x11
    call        ADDHLA
    ld          (hl),e
    inc         hl
    ld          (hl),d
    call        WSCADR
    call        WFATIFCH
COPYRD
    call        CHNGDRNM
    call        SETACT
    call        ERAVAR
    ld          de,(VALSYY)
    ld          hl,(STARTADR)
    ld          a,(VALSYX)
COPYRDSK
    push        af
    push        hl
    call        LOGFYZ
    ex          de,hl
    ld          de,0x100
    call        BREADA
    ex          (sp),hl
    call        GETWTEST
    bit         0x3,d
    jr          nz,CPYRDLST
    ex          de,hl
    pop         de
    pop         af
    dec         a
    jr          nz,COPYRDSK
    ld          (STARTADR),hl
    jr          CPYFULB
CPYRDLST
    push        de
    call        CHNGDRNM
    call        SETACT
    call        ERAVAR
    pop         de
    pop         af
    pop         af
    push        de
    ld          b,a
    ld          a,(VALSYX)
    sub         b
    inc         a
    jr          COPYBUF
CPYFULB
    call        CHNGDRNM
    call        SETACT
    call        ERAVAR
    ld          hl,0x8c00
    push        hl
    ld          a,(VALSYX)
COPYBUF
    ld          de,(VALSYY)
    ld          hl,(LENDAT)
    push        af
COPYWSC
    push        hl
    call        LOGFYZ
    ex          de,hl
    ld          de,0x100
    ld          a,(WORKDR)
    call        BWRITE
    pop         de
    pop         af
    dec         a
    jr          z,COPYIFALL
    push        af
    ex          de,hl
    push        de
    push        hl
    call        FIEMPTYFAT
    jr          nz,COPYNOEM
    pop         de
    ex          de,hl
    call        WRTOFAT
    ex          de,hl
    pop         de
    jr          COPYWSC
COPYIFALL
    ex          de,hl
    pop         de
    bit         0x7,d
    res         0x7,d
    jr          nz,CPYNOEND
    call        WRTOFAT
    call        WFATIFCH
    call        CHNGDRNM
    pop         bc
    inc         c
    push        bc
    jp          COPYLOOP
ENDCOPY
    ld          a,0xfe
    RST         RST28
    dw          1601h
    ld          a,0xd
    RST         RST10
    pop         bc
    ld          b,0x0
    call        BCPRT
    xor         a
    ld          de,0x1c44
    call        PRTMES
    ret
COPYNOEM
    pop         hl
    ld          de,0xc00
    call        WRTOFAT
    call        WFATIFCH
    jp          RETREP
CPYNOEND
    push        hl
    call        FIEMPTYFAT
    jr          nz,COPYNOEM
    pop         de
    ex          de,hl
    call        WRTOFAT
    ex          de,hl
    ld          de,0xc00
    call        WRTOFAT
    ld          (LENDAT),hl
    call        WFATIFCH
    jp          COPYRD
TXTMOVE
    db          0FFh
    db          " File(s) copied.",08Dh
CHNGDRNM
    ld          hl,0x3e80
    ld          de,0x3e95
    ld          bc,0x15
    push        af
CHANGDR1
    ld a,(de)
    LDI
    dec         hl
    ld (hl),a
    inc         hl
    jp          pe,CHANGDR1
    pop         af
    ret
SETCOPYNM
    call        DIVSTRING
    call        SETWDNM
    call        ANALWDNM
    jr          c,SETCOPYN1
    ld          a,0x2a
    jp          ERRR
SETCOPYN1
    inc         a
    jp          z,REPORTX
    call        ARRANGNM
    push        af
    ld          a,(EXTE1)
    cp          0x3f
    jr          nz,SETCOPYN2
    pop         af
    scf
    ret
SETCOPYN2
    pop         af
    ret
SETACT
    push        bc
    push        de
    push        hl
    push        af
    xor         a
    ld          (VARIA1),a
    ld          (VARIA2),a
    dec         a
    ld          (VARIA3),a
    call        ANALWDNM
    jr          nz,OKANALW
    ld          a,0x3b
    jp          ERRR
OKANALW
    jr          c,SETNAME
    inc         a
    jr          nz,SETDRIVE
    ld          a,0x20
    jp          ERRR
SETDRIVE
    dec         a
    ld          (WORKDR),a
    jp          GETPAR1
SETNAME
    call        SETDRV
    jr          z,SETRET
    call        INITALLDR
    call        SETDRV
    jr          z,SETRET
    ld          de,SYSMSG
    ld          a,0x3c
    call        KEYMSG
    jr          c,SETNAME
    ld          a,0x2c
    jp          ERRR
CMPDSK
    push        bc
    push        de
    push        hl
    push        af
    call        RDBOOT
    call        NAMEDISK
    ld          de,0x3ac0
    ld          bc,0xc
    call        VERIFY
    jp          nz,SETPARAM
SETRET
    pop         af
    pop         hl
    pop         de
    pop         bc
    cp          a
    ret
GETWTEST
    call        GETFAT
    push        af
    ld          a,d
    cp          0xd
    jr          z,REPORT1
    or          e
    jr          z,REPORT1
    pop         af
    ret
REPORT1
    ld          a,0x34
    jp          ERRR
GETFAT
    push        hl
    call        READFATSC
    jr          c,IFODD
    ld          e,(hl)
    inc         hl
    ld          a,(hl)
    and         0xf0
    rrca
    rrca
    rrca
    rrca
    ld          d,a
    pop         hl
    ret
IFODD
    ld          a,(hl)
    and         0xf
    ld          d,a
    inc         hl
    ld          e,(hl)
    pop         hl
    ret
WRTOFAT
    push        hl
    push        de
    call        READFATSC
    ld          a,0xff
    ld          (CHNGFLAG),a
    pop         de
    push        de
    jr          c,WISODD
    ld          (hl),e
    inc         hl
    ld          a,d
    rrca
    rrca
    rrca
    rrca
    ld          d,a
    ld          a,(hl)
    and         0xf
    or          d
    ld          (hl),a
    pop         de
    pop         hl
    ret
WISODD
    ld          a,(hl)
    and         0xf0
    or          d
    ld          (hl),a
    inc         hl
    ld          (hl),e
    pop         de
    pop         hl
    ret
READFATSC
    push        bc
    ld          bc,0x6a9
    and         a
    sbc         hl,bc
    jr          c,NOHIGHER
    ld          a,0x3b
    jp          ERRR
NOHIGHER
    add         hl,bc
    ld          c,0x0
    ld          de,0x155
    and         a
CALCSCFAT
    inc         c
    sbc         hl,de
    jr          nc,CALCSCFAT
    add         hl,de
    ld          d,h
    ld          e,l
    add         hl,hl
    add         hl,de
    SRL         h
    RR          l
    push        af
    ld          a,(FATDR)
    ld          b,a
    ld          a,(WORKDR)
    cp          b
    jr          nz,MUSTREAD
    ld          a,(FATSC)
    cp          c
    jr          z,RDFATPOL
MUSTREAD
    push        hl
    push        bc
    call        WFATIFCH
    pop         bc
    ld          a,c
    ld          (FATSC),a
    ld          b,0x0
    ld          de,0x101
    ld          hl,0x3c00
    call        BREADA
    pop         hl
    ld          a,(WORKDR)
    ld          (FATDR),a
RDFATPOL
    ld          de,0x3c00
    add         hl,de
    pop         af
    pop         bc
    ret
WFATIFCH
    push        bc
    push        de
    push        hl
    push        af
    ld          a,(CHNGFLAG)
    and         a
    jr          z,NOWFAT
    ld          a,(FATSC)
    ld          c,a
    ld          a,(FATDR)
    ld          de,0x101
    ld          hl,0x3c00
    ld          b,0x0
    call        BWRITE
    xor         a
    ld          (CHNGFLAG),a
NOWFAT
    pop         af
    pop         hl
    pop         de
    pop         bc
    ret
FREECOUNT
    ld          bc,0x0
    ld          hl,0xe
FRCOUNT1
    call        GETFAT
    inc         hl
    ld          a,d
    cp          0xd
    jr          nz,NOSYS
    ld          a,e
    cp          0xdd
    ret         Z
    or          d
NOSYS
    or          e
    jr          nz,FRCOUNT1
    inc         bc
    jr          FRCOUNT1
SECPERDISK
    ld          b,(ix+0x2)
    bit         0x4,(ix+0x1)
    jr          z,SECPD1
    RLC         b
SECPD1
    ld          c,0x0
FYZLOG
    push        de
    ld          e,(ix+0x3)
    ld          d,0x0
    ld          h,d
    ld          l,c
    inc         b
    jr          CALCLOG1
CALCLOG
    add         hl,de
CALCLOG1
    djnz        CALCLOG
    pop         de
    ret
LOGFYZ
    push        de
    ld          e,(ix+0x3)
    ld          d,0x0
    ld          b,0xff
    and         a
CALCLF
    inc         b
    sbc         hl,de
    jr          nc,CALCLF
    add         hl,de
    ld          c,l
    pop         de
    ret
READADR
    inc         a
    bit         0x7,a
    ret         nz
    push        af
    push        bc
    push        de
    ld          b,a
    and         0xf
    ld          c,a
    push        bc
    ld          a,b
    and         0x70
    rlca
    rla
    push        af
    rlca
    rlca
    ld          b,a
    pop         af
    ld          a,b
    rla
    ld          hl,0x6
    call        ADDHLA
    call        LOGFYZ
    ld          a,(WORKDR)
    ld          h,a
    ld          a,(ADRDR)
    cp          h
    jr          nz,RDSFDR
    ld          hl,(ADRSCTR)
    sbc         hl,bc
    jr          z,RDADRCALC
RDSFDR
    ld          a,(WORKDR)
    ld          (ADRDR),a
    ld          (ADRSCTR),bc
    ld          hl,0x3800
    ld          de,0x101
    call        BREADA
RDADRCALC
    pop         bc
    ld          a,c
    rlca
    rlca
    rlca
    rlca
    ld          d,0x0
    rla
    ld          e,a
    rl          d
    ld          hl,0x3800
    add         hl,de
    pop         de
    pop         bc
    pop         af
    cp          a
    ret
WSCADR
    push        af
    push        bc
    push        de
    push        hl
    ld          a,(ADRDR)
    ld          bc,(ADRSCTR)
    ld          de,0x101
    ld          hl,0x3800
    call        BWRITE
    pop         hl
    pop         de
    pop         bc
    pop         af
    ret
RDBOOT
    ld          hl,0x3a00
    ld          de,0x101
    ld          bc,0x0
    call        BREADA
    ld          hl,0x3acc
    ld          de,0xf10
    ld          bc,0x4
    call        VERIFY
    ret         Z
    ld          a,0xff
    ld          (FATDR),a
    ld          a,0x20
    jp          ERRR
GETPAR
    push        bc
    push        de
    push        hl
    push        af
GETPAR1
    call        DRVSYS
    call        RDBOOT
SETPARAM
    ld          a,(ix+0x5)
    ld          (ix+0x1),a
    bit         0x4,(ix+0x5)
    jr          nz,DSIDE
    ld          a,(DAT_ram_3ab1)
    bit         0x4,a
    ; jr          nz,REPORTX
    jr nz,SETDSE
DSIDE
    ld          a,(DAT_ram_3ab2)
    cp          (ix+0x6)
    jr          z,TRACKOK
    jr          c,TRACKOK
    sub         (ix+0x6)
    cp          0x8
    jr nc,SETDSE
    ld          a,(DAT_ram_3ab2)
TRACKOK
    ld          (ix+0x2),a
    add         a,a
    cp          (ix+0x6)
    jr          nz,NOLINH
    set         0x5,(ix+0x1)
NOLINH
    ld          a,(DAT_ram_3ab1)
    and         0x13
    ld          b,a
    ld          a,(ix+0x1)
    and         0xec
    or          b
    ld          (ix+0x1),a
    ld          a,(DAT_ram_3ab3)
    ld          (ix+0x3),a
    call        NAMEDISK
    ex          de,hl
    ld          hl,0x3ac0
    ld          bc,0xc
    ldir
    pop         af
    ld          l,a
    or          0xff
    ld          a,l
    pop         hl
    pop         de
    pop         bc
    ret
SETDSE  ; error Bad device type
    ld          a,0x20
    jp          ERRR
VERIFY
    ld          a,(de)
    inc         de
    cpi
    ret         nz
    ret         po
    jr          VERIFY
SETDRV
    xor         a
FINDNMDR
    push        af
    ld          (WORKDR),a
    call        DRVCMP
    jr          z,NEXTNM
    call        NAMEDISK
    ld          de,0x3e80
    ld          bc,0xa
    call        VERIFY
    jr          nz,NEXTNM
    ld          a,(WORKDR)
    call        TESTDR
    jr          z,NEXTNM
    call        CMPDSK
    jr          z,FINDNMOK
NEXTNM
    pop         af
    inc         a
    cp          0x4
    jr          c,FINDNMDR
    or          a
    ret
FINDNMOK
    pop         af
    ld          (WORKDR),a
    cp          a
    ret
INITALLDR
    xor         a
INITDR
    push        af
    call        DRVCMP
    jr          z,NOINITDR
    pop         af
    push        af
    call        TESTDR
    jr          z,NOINITDR
    pop         af
    push        af
    ld          (WORKDR),a
    call        GETPAR
NOINITDR
    pop         af
    inc         a
    cp          0x4
    jr          c,INITDR
    ret
DELALLFIL
    call        SETACT
    call        FIRSTMASK
    ret         nz
DELFIND
    push        af
    call        GETATR
    bit         0x0,a
    jr          nz,NODELPR
    ld          a,0x30
    jp          ERRR
NODELPR
    call        DFILER
    pop         af
    call        NEXTMASK
    jr          z,DELFIND
    call        WFATIFCH
    xor         a
    ret
DFILER
    ld          (hl),0xe5
    call        WSCADR
    ld          de,0x11
    add         hl,de
    ld          a,(hl)
    inc         hl
    ld          h,(hl)
    ld          l,a
DFILER1
    call        GETWTEST
    push        de
    ld          de,0x0
    call        WRTOFAT
    pop         hl
    bit         0x3,h
    ret         nz
    jr          DFILER1
    ORG 0x1fa5
LOAFND
    jp LOAFND_
    ORG 0x1fab
LOAWITHF
    jp LOAWITHF_
    ; ORG 0x1ffa
; ZXROM
; ZXROMEI
    ; ei
    ORG 0x1ffb
; ZXROMDI
ZXROM
    ret
/*
LOAFND      ; 0x1FA5
    push        hl
    ld          hl,(SVADRA)
    jr          LOADFND1
LOAWITHF    ; 0x1FAB
    push        hl
    call        FIRSTMASK
    jr          z,LOADFND1
REPORTS
    ld          a,0x1b
    jp          ERRR
LOADFND1
    call        GETATR
    bit         0x3,a
    jr          nz,LOAFND2
REPORTE
    ld          a,0x2d
    jp          ERRR
LOAFND2
    ld          a,0x11
    call        ADDHLA
    ld          a,(hl)
    inc         hl
    ld          h,(hl)
    ld          l,a
LOAFNDLP    ; 0x1fcb
    push        hl
    call        LOGFYZ
    pop         hl
    push        bc
    call        COUNTCSEC
    ex          de,hl
    bit         0x3,h
    ld          d,b
    ld          e,0x0
    pop         bc
    jr          nz,LOAFND4
    ex          (sp),hl
    call        BREADA
    ex          (sp),hl
    jr          LOAFNDLP
LOAFND4
    bit         0x1,h
    jr          z,LFNDNULL
    ld          a,h
    and         0x1
    ld          h,a
    ld          a,h
    or          l
    jr          nz,LOAFND3
    pop         hl
    call        BREADA
    call        ERAVAR
    ret
LOAFND3
    dec         d
    jr          z,LOAFNDLS
    ex          (sp),hl
    call        BREADA
    ex          (sp),hl
LOAFNDLS
    push        hl
    ld          hl,(SVFRSC)
    call        LOGFYZ
    ld          hl,0x3a00
    ld          de,0x101
    call        BREADA
    pop         bc
    pop         de
    ld          hl,0x3a00
    ldir
LOAFNDEND
    call        ERAVAR
    ret
LFNDNULL
    pop         hl
    jr          LOAFNDEND
*/
    ORG 0x201E
TRANSTOSEC
    ld          a,d
    and         0xfe
    rrca
    ld          b,a
    ld          a,d
    and         0x1
    ld          d,a
    ld          a,d
    or          e
    ret         Z
    inc         b
    ret
FINDANDFILL
    call        FIRSTEMPTY
    jr          z,IFFIND
REPORTV
    ld          a,0x1e
    jp          ERRR
IFFIND
    ld          a,(EXTE1)
    ld          (hl),a
    inc         hl
    ld          de,0x3e8a
    ld          bc,0xa
    ex          de,hl
    ldir
    ex          de,hl
    ret
SAVEFILE
    push        hl
    push        de
    call        FINDANDFILL
    pop         de
    ld          (hl),e
    inc         hl
    ld          (hl),d
    inc         hl
    ld          bc,(VALSYX)
    ld          (hl),c
    inc         hl
    ld          (hl),b
    inc         hl
    ld          bc,(VALSYY)
    ld          (hl),c
    inc         hl
    ld          (hl),b
    inc         hl
    push        hl
    inc         hl
    inc         hl
    ld          a,(HEAD20)
    ld          (hl),a
    inc         hl
    ld          (hl),0xf
    inc         hl
    ld          (hl),0x0
    call        TRANSTOSEC
    or          b
    ld          a,d
    jr          nz,SAVEFILE1
    ld          a,0xc
    inc         b
    jr          SAVEFILE2
SAVEFILE1
    or          0xe
SAVEFILE2
    ld          d,a
    call SEACHN
    jr          z,SAVEFILE3
    ld          hl,0x0
    call        FIEMPTYFAT
    jr          nz,RETREP
SAVEFILE3
    ex          de,hl
    ex          (sp),hl
    ld          (hl),e
    inc         hl
    ld          (hl),d
    call        WSCADR
    ex          de,hl
    pop         de
    push        hl
    call        SAVETOFAT
    inc         b
    dec         b
    jr          nz,RETREP
    pop         hl
SAVEFILE4
    push        hl
    call        LOGFYZ
    pop         hl
    push        bc
    call        COUNTCSEC
    push        de
    ld          d,b
    ld          e,0x0
    pop         hl
    pop         bc
    ex          (sp),hl
    ld          a,(WORKDR)
    call        BWRITE
    ex          (sp),hl
    bit         0x3,h
    jr          z,SAVEFILE4
    pop         hl
    call        ERAVAR
    ret
RETREP
    call        ERAVAR
    ld          a,0x1d
    jp          ERRR
COUNTCSEC
    ld          b,0x0
    push        hl
COUNTSEC1
    ld          (SVFRSC),hl
    call        GETWTEST
    dec         de
    and         a
    sbc         hl,de
    add         hl,de
    inc         de
    inc         hl
    push        af
    inc         b
    pop         af
    jr          z,COUNTSEC1
    pop         hl
    ret
SAVETOFAT
    push        de
SAVE2FLP
    push        hl
    dec         b
    jr          z,SAVETOF1
    call        FIEMPTYFAT
    jr          nz,SAVETOF1
    ex          de,hl
    pop         hl
    call        WRTOFAT
    ex          de,hl
    jr          SAVE2FLP
SAVETOF1
    pop         hl
    pop         de
    call        WRTOFAT
    call        WFATIFCH
    ret
FIEMPTYFAT
    push        de
FINDEFAT1
    inc         hl
    call        GETFAT
    ld          a,d
    or          e
    jr          z,IFFATEMPTY
    ld          de,0x6a8
    sbc         hl,de
    add         hl,de
    jr          c,FINDEFAT1
IFFATEMPTY
    and         a
    pop         de
    ret
; FIEMPTYFAT
;a try to find the contiguous FAT chain
SEACHN
    push        de
    push        bc
    ld          hl,0x0
FINDBE1
    call        FIEMPTYFAT
    jr          nz,FINDBERR
    push        hl
FINDBE2
    dec         b
    jr          z,FINDBEOK
    inc         hl
    call        GETFAT
    ld          a,d
    or          e
    jr          z,FINDBE2
    jr          FINDBNFL
FINDBEOK
    pop         hl
FINDBERR
    pop         bc
    pop         de
    ret
FINDBNFL
    pop         bc
    pop         bc
    push        bc
    jr          FINDBE1
FIRSTMASK
    ld          a,0xff
NEXTMASK
    call        RDNOEMPTY
    ret         nz
    call        TESTMSK
    jr          nz,NEXTMASK
    ret
TESTMSK
    push        hl
    push        bc
    push        de
    ld          c,a
    ld          a,(EXTE1)
    cp          '?'
    jr z,TESTMSK2
    cp          (hl)
    jr          nz,NONAME
TESTMSK2
    inc         hl
    ld          b,0xa
    ld de,FNZONE1
TSTNMLOOP
    ld a,(de)
    cp          0x3f
    jr          z,NEXTTEST
    cp          (hl)
    jr          nz,NONAME
NEXTTEST
    inc         de
    inc         hl
    djnz        TSTNMLOOP
NONAME
    ld          a,c
    pop         de
    pop         bc
    pop         hl
    ret
FIRSTEMPTY
    ld          a,0xff
NXTEMPT
    call        READADR
    ret         nz
    push        bc
    ld          b,a
    ld          a,(hl)
    cp          0xe5
    ld          a,b
    pop         bc
    jr          nz,NXTEMPT
    ret
RDNOEMPTY
    call        READADR
    ret         nz
    push        bc
    ld          b,a
    ld          a,(hl)
    cp          0xe5
    ld          a,b
    pop         bc
    jr          z,RDNOEMPTY
    cp          a
    ret
ERAVAR
    xor         a
    ld          (FATSC),a
    ld          (CHNGFLAG),a
    ld          (ADRSCTR),a
    ld          (ADRSCTR+1),a
    ld          (VARIA1),a
    ld          (VARIA2),a
    dec         a
    ld          (VARIA3),a
    ld          (FATDR),a
    ld          (ADRDR),a
    ret
NAMEDISK
    push        ix
    pop         hl
    ld          de,0x30
    add         hl,de
    ret
DRVSYS
    push        bc
    push        af
    ld          a,(WORKDR)
    call        DRVCMP
    pop         af
    pop         bc
    ret
DRVCMP
    rlca
    rlca
    ld          c,a
    rlca
    add         a,c
    ld          c,a
    ld          b,0x0
    ld ix,DRPARZN
    add         ix,bc
    bit 0,(ix+0)
    ret
KEYMSG
    push        hl
    push        bc
    ld          hl,(CURCHL)
    push        hl
    push        af
    push        de
    ld          a,0xfd
    RST         RST28
    dw          1601h
    pop         de
    pop         af
    push        af
    and         0x7f
    inc         a
    call        PRTMES
    pop         af
    and         0x80
    rlca
    ld          de,0x21fb
    call        PRTMES
    set         0x5,(iy+0x2)
    RST         RST28
    dw          15D4h
    pop         hl
    ld          (CURCHL),hl
    pop         bc
    pop         hl
    ld          a,(LAST_K)
    and         0xdf
    cp          'R'
    scf
    ret         Z
    cp          'P'
    scf
    ret         Z
    and         a
    ret
TXTQUE
    db          80h
    db          " (Retry = R",0A9h
    db          " (Proceed = P",0A9h
HWINIT
    ; ld          a,0xd0
    ; out         (DAT_io_0081),a
    xor         a
HWINI0
    push        af
    call        DRVCMP
    push        ix
    pop         hl
    inc         hl
    ld          e,l
    ld          d,h
    inc         hl
    inc         hl
    inc         hl
    inc         hl
    ld          bc,0x3
    ldir
    res         0x0,(ix+0x0)
    res         0x7,(ix+0x0)
    ld          a,(ix+0x2)
    and         a
    jr          z,HWINI1
    pop         af
    push        af
    call        DRVSEL
    call        HOME
    ; out         (0x87),a
    nop
    nop
    and         0x4
    ; jr          z,HWINI1
    nop
    nop
    ; tady se povoluje mechanika
    set         0x0,(ix+0x0)
    ld          (ix+0x4),0x0
    ld          a,0x36
    ld          d,0x10
    call        SEEK
    ld          a,0x2
    ld          d,0x10
    call        SEEK
    and         0x4
    ld          a,0x28
    jr          nz,TRK40
    ld          a,0x50
TRK40
    ld          (ix+0x6),a
    ld          (ix+0x3),a
    call        HOME
HWINI1
    pop         af
    inc         a
    cp          0x2
    jr          c,HWINI0
    ; call        DSKSTP
    ; ld          a,0xc7
    ; ld          (NMI),a
    ret
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; db          0FFh
    ; ret
    ORG 0x2296
BWRITE
    push        hl
; LAB_ram_2297
    ; ld          hl,0x23be
    ld hl,DWRITE    ; sem pak rovnou DWRITESD ne?
    jr          BRWR0
BFORMA
    push        hl
    ; ld          hl,0x23d8
    ld hl,DFORMA
    jr          BRWR0
BREADA
    ld          a,(WORKDR)
BREAD
    push        hl
    ; ld          hl,0x236a
    ld hl,DREAD ; sem dej pak rovnou DREADSD ne?
BRWR0
    ld          (MODJPA2),hl
    ld hl,MODJP1
    ld (hl),0xc3
    pop         hl
BRWL0
    push        bc
    push        af
    push        de
    push        hl
    call        MODJP1
    inc         c
    dec         c
    jr          z,BREAD1
    dec         b
    jr          nz,BREAD2
    bit         0x7,c
    jr          z,BREAD3
BREA71
    ld          a,0x36
BREA72
    ld          de,SYSMSG
BREAD6
    call        KEYMSG
    jr          c,BREAD4
    ld          a,0x29
    jp          ERRR
BREAD3
    ld          a,c
    and         0x18
    jr          nz,BREA31
ERR45
    ld          a,0x3b
    jp          ERRR
BREA31
    ld          a,0x37
    jr          BREA72
BREAD4
    pop         hl
    pop         de
    pop         af
    pop         bc
    jr          BRWL0
BREAD1
    pop         hl
    pop         de
    pop         af
    ld          bc,0x200
    add         hl,bc
    pop         bc
    push        af
    inc         c
    ld          a,(ix+0x3)
    cp          c
    jr          nz,BREA11
    ld          c,0x0
    inc         b
BREA11
    pop         af
    dec         d
    jp          nz,BRWL0
    ret
BREAD2
    dec         b
    jr          nz,BREAD7
    ld          a,c
    and         0x9d
    jr          z,BREAD1
BREA81
    bit         0x7,c
    jr          nz,BREA71
    bit         0x4,c
    jr          z,BREAD8
    ld          a,0x38
    jr          BREA72
BREAD8
    bit         0x3,c
    jr          z,ERR45
    ld          a,0x39
    jr          BREA72
BREAD7
    dec         b
    jr          nz,BREAD9
    ld          a,c
    and         0xdd
    bit         0x6,c
    jr          z,BREA81
    ld          a,0x3a
    jr          BREA72
BREAD9
    bit         0x0,c
    jr          z,BREA91
    ld          a,0x22
    jp          ERRR
BREA91
    bit         0x1,c
    jr          z,ERR45
REPORTX
    ld          a,0x20
    jp          ERRR
    or          0x1
    ei
    ret
    ORG 0x2340
SEEK
    ret
    ; out         (DAT_io_0087),a
    ; and         a
    ; jr          z,HOME
    ; call        DELAY
    ; ld          a,d
    ; jr          TRACKSEEK
    ORG 0x234B
HOME
    ret
    ; ld          a,0x8
; TRACKSEEK
;     ld          b,a
;     ld          a,(ix+0x1)
;     and         0xc0
;     rlca
;     rlca
;     or          b
;     out         (DAT_io_0081),a
;     call        DELAY
; WAITBUSY
;     in          a,(DAT_io_0081)
;     bit         0x0,a
;     jr          nz,WAITBUSY
;     ld          bc,0xf
; WAITHOME
;     djnz        WAITHOME
;     dec         c
;     jr          nz,WAITHOME
;     ret
    ORG 0x236A
DREAD
    jp DREADSD
;     call        FINDTRACK
;     jr          nc,DOOPRET
;     ld          a,0x88
;     ld          b,0x2
;     ld          ix,0x25ea
; DOWDCOM
;     push        af
;     ld          a,(SELSTA1)
;     set         0x6,a
;     call        OUTTODR
;     pop         af
;     push        hl
;     ld hl,SVSIDE
;     or (hl)
;     pop         hl
; DOWDCREP
;     push        af
;     push        hl
;     push        de
;     push        bc
;     ld          c,0x87
;     ld          d,0x1
;     ld          b,c
;     out         (DAT_io_0081),a
; DOWDL1
;     in          a,(DAT_io_0081)
;     ld          b,c
;     and         d
;     jr          z,DOWDL1
; DOWDL2
;     in          a,(DAT_io_0081)
;     ld          b,c
;     and         d
;     jr          nz,DOWDL2
;     ld          a,(SELSTA1)
;     res         0x6,a
;     call        OUTTODR
;     in          a,(DAT_io_0081)
;     pop         bc
;     pop         de
;     pop         hl
;     ld          d,a
;     in          a,(DAT_io_0085)
;     dec         a
;     out         (DAT_io_0085),a
;     pop         af
;     bit         0x3,d
;     jr          z,DONOCRC
;     dec         e
;     jr          nz,DOWDCREP
; DONOCRC
;     ld          c,d
DOOPRET
    call        DISKRET
    ret
    ORG 0x23BE
DWRITE
    jp DWRITESD
;     call        FINDTRACK
;     jr          nc,DONOCRC
;     bit         0x5,(ix+0x1)
;     jr          z,DWRITE1
ERR40IN80
    ld          bc,0x402
    jr          DOOPRET
; DWRITE1
;     ld          ix,0x25ed
;     ld          a,0xa8
;     ld          b,0x3
;     jr          DOWDCOM
    ORG 0x23D8
DFORMA
    call        FORFINDTR
    jr          nc,DOOPRET
    bit         0x5,(ix+0x1)
    jr          nz,ERR40IN80
    push        bc
    ld          hl,VRAM_ATTR
    ld          a,(ATTR_P)
    and         0x38
    ld          b,a
    rrca
    rrca
    rrca
    or          b
    ld          bc,0x3
FSECOLOR
    ld (hl),a
    inc         hl
    djnz        FSECOLOR
    dec         c
    jr          nz,FSECOLOR
    ld hl,VRAM
    ; in          a,(DAT_io_0083)
    nop
    nop
    out         (0xfe),a
    and         0x1
    rlca
    rlca
    inc         a
    ld          e,a
    ld          d,0x0
MKFDATA
    ld          a,0x4e
    ld          b,0xa
    call        FILLCONST
    ld          a,0x0
    ld          b,0xc
    call        FILLCONST
    ld          a,0xf5
    ld          b,0x3
    call        FILLCONST
    ld          a,0xfe
    ld (hl),a
    inc         hl
    ; in          a,(DAT_io_0083)
    nop
    nop
    ld (hl),a
    inc         hl
    ld          a,(SVSIDE)
    ld (hl),a
    inc         hl
    ld          a,e
    ld (hl),a
    inc         hl
    ld          a,0x2
    ld (hl),a
    inc         hl
    ld          a,0xf7
    ld (hl),a
    inc         hl
    ld          a,0x4e
    ld          b,0x16
    call        FILLCONST
    ld          a,0x0
    ld          b,0xc
    call        FILLCONST
    ld          a,0xf5
    ld          b,0x3
    call        FILLCONST
    ld          a,0xfb
    ld (hl),a
    inc         hl
    ld          a,0xe5
    ld          b,0x0
    call        FILLCONST
    call        FILLCONST
    ld          a,0xf7
    ld (hl),a
    inc         hl
    ld          a,0x4e
    ld          b,0x28
    call        FILLCONST
    ld          a,e
    inc         e
    cp          (ix+0x3)
    jr          c,MAKENEXT
    ld          e,0x1
MAKENEXT
    inc         d
    ld          a,d
    cp          (ix+0x3)
    jr          nz,MKFDATA
    ld          a,0x4e
    ld          b,0x0
    call        FILLCONST
    call        FILLCONST
    pop         bc
    ld          hl,0x4000
    ld          ix,0x25ed
    ld          a,0xf0
    ld          b,0x3
    ; jp          DOWDCOM
    jp DOOPRET

    ORG 0x248E
FILLCONST
    ld          (hl),a
    inc         hl
    djnz        FILLCONST
    ret
FINDTRACK
    push        hl
    push        de
    push        bc
    ld          d,0x1c
FINDTRACK1
    ld          a,(WORKDR)
    call        DRVSEL
    bit         0x0,(ix+0x0)
    ld          bc,0x401
    jr          z,FINDTRRET
    ld          hl,0x0
    ld          a,(WORKDR)
    call        TESTDR
    jr          nz,FINDTRRD
    ld          bc,0x180
FINDTRRET
    pop         hl
    pop         hl
    pop         hl
    ret
FINDTRRD
    pop         bc
    inc         c
    ld          a,c
    ; out         (DAT_io_0085),a
    nop
    nop
    xor         a
    bit         0x4,(ix+0x1)
    jr          z,FINDTRSVS
    RR          b
    rla
    rlca
FINDTRSVS
    ld          (SVSIDE),a
    bit         0x5,(ix+0x1)
    jr          z,NOD40IN80
    ld          d,0x18
    sla         b
    ; in          a,(DAT_io_0083)
    nop
    nop
    add         a,a
    ; out         (DAT_io_0083),a
    nop
    nop
NOD40IN80
    bit         0x7,(ix+0x0)
    jr          z,FNDTRNOC
    ; in          a,(DAT_io_0083)
    nop
    nop
    cp          b
    jr          z,FINDTROK
FNDTRNOC
    ld          a,b
    ld          e,a
    call        SEEK
    and         0x98
    jr          z,FINDTROK
    call        HOME
    ld          a,e
    call        SEEK
    ld          c,a
    and         0x98
    jr          z,FINDTROK
    res         0x7,(ix+0x0)
    pop         de
    pop         hl
    ld          b,0x1
    ret
FINDTROK
    bit         0x5,(ix+0x1)
    jr          z,NOD40IN801
    ; in          a,(DAT_io_0083)
    nop
    nop
    rrca
    ; out         (DAT_io_0083),a
    nop
    nop
NOD40IN801
    di
    ld          (DOSIX2),ix
    pop         de
    pop         hl
    scf
    ret
FORFINDTR
    push        hl
    push        de
    push        bc
    ld          d,0x18
    jp          FINDTRACK1
DISKRET
    ld          ix,(DOSIX2)
    ; in          a,(DAT_io_0083)
    nop
    nop
    ld          (ix+0x4),a
    xor         a
    ld          (INTCNT),a
    ei
    ld          a,c
    and         a
    ret         Z
    res         0x7,(ix+0x0)
    ret
DSKSTP
    xor         a
    call        OUTTODR
    call        DRVCMP
    res         0x7,(ix+0x0)
    ld          a,0x1
    call        DRVCMP
    res         0x7,(ix+0x0)
    ret
    ORG 0x254B
DRVSEL
    push        af
    push        bc
    push        hl
    call        DRVCMP
    bit         0x2,(ix+0x1)
    ld          a,0x5
    jr          z,DRVSELOUT
    rlca
DRVSELOUT
    ld          c,a
    ld          a,(SELSTA1)
    and         0xfc
    or          c
    call        OUTTODR
    ld          a,(ix+0x4)
    ; out         (DAT_io_0083),a
    nop
    nop
    pop         hl
    pop         bc
    pop         af
    ret
    ORG 0x256D
; a>drive
; ix>drive param
; Z<drive not ready
; NZ<drive ready
TESTDR
    ; CALL DRVSEL
    push hl
    call SELIMGSTAT
    bit 6,(hl)      ; disk image mounted?
    jr nz,TESTDR_RET
    xor a           ; pokud neni namountovan image
    ld (ix+0x30),a  ; nastav neaktivni
TESTDR_RET
    pop hl
    ret
;     ei
;     bit         0x7,(ix+0x0)
;     ret         nz
;     push        bc
;     push        hl
;     call        DRVSEL
;     ld          hl,0x25b6
;     ld          (TERADR),hl
;     ld          a,0x64
;     ld          (INTCNT),a
;     call        TESTRDR
;     set         0x7,(ix+0x0)
;     jr          nz,TESTDRRET
;     call        OUTTODR
;     ld          (ix+0x30),a
;     res         0x7,(ix+0x0)
; TESTDRRET
;     pop         hl
;     pop         bc
;     ret
; TESTRDR
;     ld          a,0xd0
;     out         (DAT_io_0081),a
;     ld          (HERRSP2),sp
;     ld          b,0x2
; LOOPISDRQ
;     call        TESTDRQ
;     jr          nz,LOOPISDRQ
; LPNOTDRQ
;     call        TESTDRQ
;     jr          z,LPNOTDRQ
;     djnz        LOOPISDRQ
;     xor         a
;     ld          (INTCNT),a
;     dec         a
;     scf
;     ret
; INVALRET
;     ld          sp,(HERRSP2)
;     xor         a
;     ret
    ORG 0x25BC
OUTTODR
    ; out         (DAT_io_0089),a
    nop
    nop
    ld          (SELSTA1),a
    ret
TESTDRQ
    ; in          a,(DAT_io_0081)
    nop
    nop
    and         0x2
    ret
DELAY
    push        bc
    ld          b,0xa
DELAYLOOP
    djnz        DELAYLOOP
    pop         bc
    ret
INTERRUPT
; --- navrat z divide trapu 0x38
    push hl
    ld hl,0x39
TRAPRET
    ex (sp),hl
    jp ZXROM

    
; ---
    push        af
    ld          a,(INTCNT)
    and         a
    jr          z,OKINTERR
    dec         a
    ld          (INTCNT),a
    jr          nz,OKINTERR
    ld          hl,(TERADR)
    ld          a,h
    or          l
    jr          nz,GOINTERR
OKINTERR
    pop         af
ENDINTERR
    ei
    reti
GOINTERR
    pop         af
    ex          (sp),hl
    jr          ENDINTERR
REANMI
    ini
    ret
WRINMI
    outi
    ret
; tady by melo byt volno
;   od 0x25ef
; -----------------------------------------------------
CALLZX1off
    ex (sp),hl
    push        hl
    ld hl,SYSFLAG   ; 0x52
    ld (hl),0x4f
    ld          hl,0x0
    ex (sp),hl
    push        de
    ld          de,(SAVE_DE)
    jp ZXROM

SAVEDATAoff
    jp nz,SAVESCRN
    ld a,(T_ADDR)
    cp 3
    jp SAVEDATAcont


SYSMSG
    ; 29 "*"+128
    db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
    db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
    db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
    db 0AAH,0AAH,0AAH,0AAH,0AAH
    db          "File not foun",0E4h
    db          "File exist",0F3h
    db          "Disk ful",0ECh
    db          "Directory ful",0ECh
    db          "Advanced featur",0E5h
    db          "Bad device typ",0E5h
    db          "Device ident missin",0E7h
    db          "Device unavailabl",0E5h
    db          0A0h,0A0h,0A0h,0A0h,0A0h,0A0h
    db          "Device I/O erro",0F2h
    db          "Bad volume nam",0E5h
    db          "Bad file typ",0E5h
    db          "Volume not foun",0E4h
    db          "File is read protecte",0E4h
    db          "File is write protecte",0E4h
    db          "File is not executabl",0E5h
    db          "File is delete protecte",0E4h
    db          "Bad record numbe",0F2h
    db          "Impossible to RENAM",0C5h
    db          "Impossible to COP",0D9h
    db          "Corrupted FAT structur",0E5h
    db          "Stream already ope",0EEh
    db          "Drive is not read",0F9h
    db          "Seek erro",0F2h
    db          "Sector not foun",0E4h
    db          "CRC erro",0F2h
    db          "Disk is write protecte",0E4h
    db          "Internal erro",0F2h
    db          "Please insert volume #",08Dh
    db          "Erase all files ",0BFh
    db          "Rewrite old file ",0BFh
    db          "All data will be discarded !  ",0A0h
    db          "File too lon",0E7h



LOAFND_      ; 0x1FA5
    push        hl
    ld          hl,(SVADRA)
    jr          LOADFND1
LOAWITHF_    ; 0x1FAB
    push        hl
    call        FIRSTMASK
    jr          z,LOADFND1
REPORTS
    ld          a,0x1b
    jp          ERRR
LOADFND1
    call        GETATR
    bit         0x3,a
    jr          nz,LOAFND2
REPORTE
    ld          a,0x2d
    jp          ERRR
LOAFND2
    ld          a,0x11
    call        ADDHLA
    ld          a,(hl)
    inc         hl
    ld          h,(hl)
    ld          l,a
LOAFNDLP    ; 0x1fcb
    push        hl
    call        LOGFYZ
    pop         hl
    push        bc
    call        COUNTCSEC
    ex          de,hl
    bit         0x3,h
    ld          d,b
    ld          e,0x0
    pop         bc
    jr          nz,LOAFND4
    ex          (sp),hl
    call        BREADA
    ex          (sp),hl
    jr          LOAFNDLP
LOAFND4
    bit         0x1,h
    jr          z,LFNDNULL
    ld          a,h
    and         0x1
    ld          h,a
    ld          a,h
    or          l
    jr          nz,LOAFND3
    pop         hl
    call        BREADA
    call        ERAVAR
    ret
LOAFND3
    dec         d
    jr          z,LOAFNDLS
    ex          (sp),hl
    call        BREADA
    ex          (sp),hl
LOAFNDLS
    push        hl
    ld          hl,(SVFRSC)
    call        LOGFYZ
    ld          hl,0x3a00
    ld          de,0x101
    call        BREADA
    pop         bc
    pop         de
    ld          hl,0x3a00
    ldir
LOAFNDEND
    call        ERAVAR
    ret
LFNDNULL
    pop         hl
    jr          LOAFNDEND


;---------------------------------------------
; SD cast
;---------------------------------------------

; disk image params
; 0:drive status
;   bit 5:  1 = 40 tracks 
;   bit 6:  1 = mounted
;   bit 7:  1 = READONLY
; 1,2,3,4 LBA start - in future, it will be first cluster of file
; 5,6 
;
DIMAGESTAT
    db 0
    dw 0,0
    dw 0
    db 0
    dw 0,0
    dw 0
    ; db 1
    ; dw 0xBA40,0

    ; db 1+128
    ; dw 0x7730,0

    ; pokud bude podpora disku C: a D:
    ; db 0
    ; db 0,0,0,0
    ; db 0
    ; db 0,0,0,0
SDDRVB
    db SD_0
SDDRIVEBYTES
    db SD_0
    db SD_1
; a > drive 0-1 (0-3)
; hl < DISK IMAGE STATUS
; (SDDRVB)<SD DRIVE ACTIVE byte
SELIMGSTAT
    ld l,a
    add a,a ; *2
    ld h,a
    add a,a ; *4
    add a,h ; *6
    add a,l ; *7
    ld l,a
    ld h,0
    ld de,DIMAGESTAT
    add hl,de
    push hl
    push de
    ld a,(hl)
    and 1
    ld l,a
    ld h,0
    ld de,SDDRIVEBYTES
    add hl,de
    ld a,(hl)
    ld (SDDRVB),a
    pop de
    pop hl
    ret


SPI_PORT	equ 0ebh
OUT_PORT	equ 0e7h	; port for CS control (D1:D0)
CMD_17      equ	040h+17	; READ_SINGLE_BLOCK
CMD_24      equ 040h+24	; WRITE_BLOCK

SD_0		equ 0FEh    ; D0 LOW = SLOT0 active;
; 11111110b
SD_1		equ 0FDh    ; D1 LOW = SLOT1 active;
; 11111101b

; hl = DIMAGESTAT
; de = mdos logical sector
; hlde = SD LBA sector
ADD_LBA_OFF
    push hl
    pop ix
    ld l,(ix+1)
    ld h,(ix+2)
    add hl,de   ; add lba byte 0,1
    push hl
    ld l,(ix+3)
    ld h,(ix+4)
    ld de,0
    adc hl,de
    pop de
    ret

; b>track
; c>sector
; hl<abs LOGICAL sector
FYZLOGSD
    ld l,b
    ld h,0
    push hl
    add hl,hl   ; *2
    add hl,hl   ; *4
    add hl,hl   ; *8
    pop de
    add hl,de   ; *9
    ; add hl,hl ; h=h*2
    ld b,0
    add hl,bc   ; add sector

    ret

; a>disk
; b>track
; c>sector
; hl>where
; e>retry count
; c<result
; b*9 + (svside+1)*c
; staci pouzit FYZLOG
DREADSD
    push ix
    push hl
    ld a,(WORKDR)
    call SELIMGSTAT
    bit 6,(hl)
    jr z,DREADSD_NR

    push hl ; hl=DIMAGESTAT

    call FYZLOGSD
    pop de
    ex de,hl    ; hl = DIMAGESTAT
                ; de = MDOS logical sector
    call ADD_LBA_OFF
            ; hlde=sektor
    pop ix  ; ix = addr to read

SD_READ:
	; hlde = sector
	; ix = to address
;----
    ld a,(SDDRVB)
	out (OUT_PORT),a

	ld a,0xff
	out (SPI_PORT),a
;----
	; hlde = sector
	ld a,CMD_17
	call SD_SENDCMD
	; 0 = ok
	cp 0
    ret nz
    ld e,a  ; store R1
    ; call pause
	call WAIT_DATA
		; cp 0xFE
		; jr nz,wderr
	; 0xFE = data start
	push ix
	pop hl

	ld bc,SPI_PORT
	inir
	inir
	; ENDIF

	; 2b crc
	in a,(SPI_PORT)
	in a,(SPI_PORT)
;----
	ld a,255
	out (OUT_PORT),a
    out (SPI_PORT),a
;----
    ld a,e  ; restore R1


    ld c,0
DREADSD_ERR
    ld b,2
    pop ix
	ret
DREADSD_NR  ; disk not mounted/ready
    pop hl
    ld c,128
    jr DREADSD_ERR

; hl = from
; c = sector
; b = track
DWRITESD
    push ix
    push hl
    
    ld a,(WORKDR)
    call SELIMGSTAT
    bit 6,(hl)
    jr z,DWRITESD_NR
    bit 7,(hl)
    jr nz,DWRITESD_WP

    push hl ; hl=DIMAGESTAT
    ; ld de,5
    ; add hl,de
    ; push hl
    ; call FYZLOGSD
    ; pop de
    ; or a
    ; sbc hl,de
    ; add hl,de
    ; ; nc= log sector>=disk image sec len
    ; jp nc,DWRITE_EOF
    pop de
    ex de,hl    ; hl = DIMAGESTAT
                ; de = MDOS logical sector
    call ADD_LBA_OFF
            ; hlde=sektor
    pop ix  ; ix = addr to read

SD_WRITE:
	; hlde = sector
	; ix = from address
;----
    ; ld a,SD_1
    ld a,(SDDRVB)
	out (OUT_PORT),a
	ld a,0xff
	out (SPI_PORT),a
;----	
	ld a,CMD_24
	call SD_SENDCMD
	cp 0    ; 0 = ok

	ld a,0FEh	; data start
	; out (c),a
	out (SPI_PORT),a

	push ix
	pop hl

	ld bc,SPI_PORT
	otir
	otir

	xor a
	; 2b crc
	out (SPI_PORT),a
	out (SPI_PORT),a

	call WAIT
	; a = Data response
	ld e,a
	
wbsy:
	call WAIT
	cp 0
	jr z,wbsy

;----
	ld a,255
	out (OUT_PORT),a
    out (SPI_PORT),a
;----

	ld a,e
	and 01fh
	; a = Data response

    ld c,0
DWRITESD_ERR
    ld b,3
    pop ix
    ret
DWRITESD_NR
    ld c,128
    jr DWSDERREX
DWRITESD_WP
    ld c,64 ; write protect
DWSDERREX
    pop hl
    jr DWRITESD_ERR
DWRITE_EOF
    pop hl
    pop hl
    ld c,2
    jr DWRITESD_ERR


SD_SENDCMD:
	ld c,SPI_PORT
	out (c),a
    nop         ; DIVMMC needs more time
	out (c),h
    nop
	out (c),l
    nop
	out (c),d
    nop
	out (c),e

	; xor a
    ld a,0xff
	out	(c),a 

WAIT:
	ld bc,0
wloop:
	in a,(SPI_PORT)
	cp 0FFh
	ret nz
	dec bc
	ld a,b
	or c
	jr nz,wloop
    ld a,0xff
	ret

WAIT_DATA:
    ; ld b,0
	ld bc,0
wdata_loop:
	in a,(SPI_PORT)
	cp 0FEh
    ret z
	dec bc
	ld a,b
	or c
	jr nz,wdata_loop
    ld a,0xff

	ret
    ORG 0x37f2
FAKESP
    dw 1    ; DivMMC compatibility patch by u880d

    ORG 0x3800
DIRBUF  ds      200h
AUXBUF  ds      200h
; TODO: pozice v auxbuf
DAT_ram_3ab1    equ 0x3ab1
DAT_ram_3ab2    equ 0x3ab2
DAT_ram_3ab3    equ 0x3ab3
FATBUF  ds      200h
DRPARZN ds 4*12 ; DRZONE  ds      4*12
DRNAMES ds 4*12 ; VNZONE  ds      4*12
DEBUG   ds      1
SNPCOUNT    ds 1    ; SNPCNT  ds      1
AIFASK  ds 1    ; CONFRM  ds      1
MODJP1  ds  1   ; MODJP   ds      1
MODJPA2 ds 2    ; MODJPA  ds      2
SAVE_DE ds 2    ; DESTOR  ds      2
VARIA1  ds 1    ; SQC     ds      1
VARIA2  ds 1    ; DIRSQC  ds      1
VARIA3  ds 1    ; SYSLD   ds      1
WORKDR  ds 1    ; ACTDR   ds      1
CHNGFLAG    ds 1    ; FATACT  ds      1
FATSC   ds 1    ; FATEL   ds      1
FATDR   ds      1
ADRSCTR   ds 2    ; DIRTS   ds      2
ADRDR   ds 1    ; DIRDR   ds      1
SVADRA  ds 2    ; ENTADR  ds      2
STARTADR    ds 2    ;LOADIX  ds      2
LENDAT  ds 2    ; LOALEN  ds      2
VALSYX  ds 2    ; VALX    ds      2
VALSYX1 equ VALSYX+1
VALSYY  ds 2    ; VALY    ds      2
HEAD20  ds 2    ; VALEX   ds      2
SVFRSC  ds 2    ; LSTENT  ds      2
DNZONE1 ds 10   ; DNZONE  ds      10
FNZONE1 ds 10   ; FNZONE  ds      10
EXTE1   ds 1    ; FILTYP  ds      1
DNZON2  ds      10
; TODO: pozice v DNZON2
SNONMB1 equ 0x3e92
SNONMB2 equ 0x3e93
FNZON2  ds      10
EXTE2   ds 1    ; FILTY2  ds      1
ACDRIVE ds 10   ; CURDEV  ds      10
SVHEAD  ds 32   ; FHBUF   ds      32
; TODO: pozice v SVHEAD
SVFSC   equ 0x3ec5
SV24NM  ds 6    ; LDBUF   ds      6
ASCIINM ds 8    ; LDNUM   ds      8
INTCNT  ds      1
TERADR  ds      2
HERRSP2 ds 2    ; HERRSP  ds      2
DOSIX2  ds 2    ; DOSIX   ds      2
SELSTA1 ds 2    ; SELSTA  ds      2
SVSIDE  ds 1    ; RWSSO   ds      1
IREG2   ds 2    ; IREG    ds      2
SNAPINF ds 1    ; SNAPO   ds      1
SYSMRK  ds      4
; > 3ef3
; TODO: zkontrolovat
        ds 4
SYSFLAG ds 1
SVREG   ds 262
SAVE_SP ds 2
; SYSFLAG 3ef7
; SVREG 3ef8
; SAVE_SP 3ffe
SNAP_SP equ 0x3ffe
;------------------------------------------------------------------------------

; IO
; DAT_io_0081 equ 081h
; DAT_io_0083 equ 083h
; DAT_io_0085 equ 085h
; DAT_io_0087 equ 087h
; DAT_io_0089 equ 089h
; DAT_io_00fe equ 0xfe
VRAM    equ 0x4000
VRAM_ATTR   equ 0x5800
; ZX BASIC VARS
T_ADDR  equ 0x5c74
ERR_NR  equ 0x5c3a
ERR_SP   equ 0x5c3d
CH_ADD  equ 0x5c5d
ATTR_P  equ 0x5c8d
LAST_K  equ 0x5c08
CHANS   equ 0x5c4f
CURCHL  equ 0x5c51
PROG    equ 0x5c53
E_LINE  equ 0x5c59
X_PTR   equ 0x5c5f
STKEND  equ 0x5c65
RAMTOP  equ 0x5cb2
VARS    equ 0x5c4b
NEWPPC  equ 0x5c42
DEFADD  equ 0x5c0b
STRMS6  equ 0x5c16
; ERR_SP  equ 0x5c3d
    SAVEBIN "mdos1sd.bin",0,16384