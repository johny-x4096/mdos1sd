    DEVICE ZXSPECTRUM48
    ORG 32768
    ; org 8192
start
    jp nmimenu

; tady by melo byt pro oba disky:
; 4b start souboru
; todo: sd slot
; 13b nazev fat32file
; 10b nazev MDOS disku
DIMAGESTAT
    db 0
    dw 0x0000,0x0000
    ; db 1+128
    ; dw 0x7730,0
    db 0
    dw 0x0000,0x0000


; images
;     ds 5
;     ds 5
; images_fn
;     ds 13
;     ds 10
;     ds 13
;     ds 10

nmimenu
    di
    push iy


    call init
    ld ix,volume1
    ld iy,testfp
    ; ld de,0x196
    ld de,0
    ld hl,0
    call CHDIR
    ld hl,main_menu
    call set_state
    ei
state_loop
    call keytest
    call dispatch_state
    call delay
    jr state_loop

main_menu
    ld bc,256*4+2
    ld de,256*4+14
    call draw_win
    ld bc,256*4+2
    call psetpos
    call print_i
    db "MDOS1SD v0.1",0  
    ld bc,256*5+3
    call psetpos
    call print_i
    db "A:DISK1   .D80",0
    ld bc,256*6+3
    call psetpos
    call print_i
    db "B:DISK2   .D80",0
    ld bc,256*7+3
    call psetpos
    call print_i
    db "Snapshot",0 
    ld bc,256*8+3
    call psetpos
    call print_i
    db "Return",0


    ; ld bc,256*4+2
    ; ld de,256*3+16
    ; call draw_win

    ; ld bc,256*4+2
    ; call psetpos
    ; call print_i
    ; db "Mdos1SD",0

    ; ld bc,256*5+3
    ; call psetpos
    ; call print_i
    ; db "S"+128,"napshot",0
    
    ; ld bc,256*6+3
    ; call psetpos
    ; call print_i
    ; db "D"+128,"isks",0
    
    ; ld bc,256*7+3
    ; call psetpos
    ; call print_i
    ; db "E"+128,"xit",0

    ld bc,23*256
    call psetpos
    call print_i
    db "(S)napshot (D)isks (E)xit",0
    ld bc,0
    call psetpos
    ld hl,menu_wait
    jp set_state

menu_wait
    cp 13
    ret nz

    ld hl,browser_init
    jp set_state
exit
    pop iy
    pop iy
    ret

set_state
    ld (app_state),hl
    ret

dispatch_state
    ld hl,(app_state)
    jp (hl)


browser_init
    ld bc,23*256
    call psetpos
    call print_i
    db "(E)ject E(x)it                ",0
    ld de,0
    ld (b_dir_cluster),de
    ld (b_dir_cluster+2),de
    ld (b_pg_start),de
    ld (b_pg_start+2),de
    ld a,0
    ld (b_selected_i),a
    ld bc,0
    call psetpos
    ld hl,browser_refresh
    jp set_state

browser_refresh
    di
    ld a,0
    ld (b_item_cnt),a

    ld b,max_files_per_page
    ld hl,lineaddr
brcls
    push bc
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    push hl
    ld b,8
brclsl
    push bc
    push de
    push hl
    ld l,e
    ld h,d
    inc de
    ld (hl),0
    ld bc,32
    ldir
    pop hl
    pop de
    pop bc
    inc d
    djnz brclsl
    pop hl

    pop bc

    djnz brcls

; clear attrs
    ld b,max_files_per_page
    ld hl,22528
1
    push bc
    ld e,l
    ld d,h
    inc de
    ld a,(menu_attr)
    ld (hl),a
    ld bc,31
    ldir
    pop bc
    djnz 1b
; show select bar
    ld a,(b_selected_i)
    call br_hover

    ld bc,0
    call psetpos
    ld de,(b_pg_start)
    ld hl,(b_pg_start+2)
    call SEEK
brnext
    ld de,direntry
    call GET_DIR_ENTRY
    cp 0xff
    jp z,brend
    ; end of dir?
    ld a,(direntry)
    cp 0
    jp z,brend
    ; empty entry?
    cp 0xe5
    jp z,brnext
    ; is "this dir" . ?
    cp "."
    jr nz,1f
    ld a,(direntry+1)
    cp " "
    jr z,brnext
1
    ld a,(direntry+DIR_Attr)
    ; volume label?
    cp 0x8
    jr z,brnext
    ; LFN entry?
    and ATTR_LONG_FILE_NAME
    cp ATTR_LONG_FILE_NAME 
    jr z,brnext

    call print_entry


    ld a,15
    call ptab

    ld hl,(direntry+DIR_FstClusHI)
    call printhex
    ld hl,(direntry+DIR_FstClusLO)
    call printhex
    ld a,"/"
    call charout
    ld de,(direntry+DIR_FstClusLO)
    ld hl,(direntry+DIR_FstClusHI)
    ld a,0
    call ADDR2LBA
    push de
    call printhex
    pop hl
    call printhex

    ld a,13
    call charout

    ld a,(b_item_cnt)
    ld l,a
    ld h,0
    add hl,hl   ; *2
    add hl,hl   ; *4
    ld de,fentryes
    add hl,de
    push hl
    ld e,(iy+F_FPOS+0)
    ld d,(iy+F_FPOS+1)
    ld l,(iy+F_FPOS+2)
    ld h,(iy+F_FPOS+3)
    ld a,32
    call SUB_HLDE_A
    ld c,l
    ld b,h
    pop hl

    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    ld (hl),c
    inc hl
    ld (hl),b



    ld a,(b_item_cnt)
    inc a
    cp max_files_per_page    ; todo
    jr z,brend_next_pg
    ld (b_item_cnt),a
    jp brnext

; file browser printed all lines
; set last fpos as "next page dir pointer"
brend_next_pg
    ld a,(b_page_act)
    ld l,a
    ld h,0
    ; inc a
    ; ld (b_page_act),a
    add hl,hl   ; *2
    add hl,hl   ; *4
    ld de,browser_pages
    add hl,de
    ld e,(iy+F_FPOS+0)
    ld d,(iy+F_FPOS+1)
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    ld e,(iy+F_FPOS+2)
    ld d,(iy+F_FPOS+3)
    ld (hl),e
    inc hl
    ld (hl),d
brend
    ; end refresh, continue to select
    ei
    ld hl,browser_active
    jp set_state

browser_active
    cp 0
    ret z
    cp 'u'
    jp z,br_act_up
    cp 'd'
    jp z,br_act_down
    cp 13
    ret nz
    call delay
    ld hl,browser_action
    jp set_state


br_next_pg
    ld a,(b_page_act)
    ld l,a
    ld h,0
    inc a
    ld (b_page_act),a
    add hl,hl   ; *2
    add hl,hl   ; *4
    ld de,browser_pages
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld (b_pg_start),de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (b_pg_start+2),de
    ld a,0
    ld (b_selected_i),a
    ; ld (b_item_cnt),a
    ld hl,browser_refresh
    jp set_state

br_prev_pg
; if b_page_act==0: return
    ld a,(b_page_act)
    or a
    ret z
; if b_page_act==1: b_pg_start=0, b_page_act=9
    ; cp 1
    dec a
    jr nz,1f
    xor a
    ld (b_page_act),a
    ld hl,0
    ld (b_pg_start),hl
    ld (b_pg_start+2),hl
    jr br_ppg_exit
    ; ld hl,browser_refresh
    ; jp set_state
1
; get "next page from act_page-2"
    ; dec a
    ld (b_page_act),a
    dec a
    ld l,a
    ld h,0
    add hl,hl   ; *2
    add hl,hl   ; *4
    ld de,browser_pages
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld (b_pg_start),de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (b_pg_start+2),de
br_ppg_exit
    ld a,max_files_per_page
    dec a
    ld (b_selected_i),a
    ld hl,browser_refresh
    jp set_state


br_act_up
; if b_page_act==0 && b_selected_i==0: return
    ld a,(b_selected_i)
    ld hl,b_page_act
    or (hl)
    ret z

    ; "unselect"
    ld a,(b_selected_i)
    call br_hide
; if b_selected_i==0: br_prev_pg
    ld a,(b_selected_i)
    or a
    jr z,br_prev_pg
; else bselected_i--;
    dec a
    ld (b_selected_i),a
; draw select
    jr br_hover

br_act_down
    ld a,(b_selected_i)
    ; cp max_files_per_page    ; todo
    ; ret z
    ; ld hl,b_item_cnt
    ; cp (hl)
    ; ret z
    call br_hide
    inc a

    cp max_files_per_page
    jp z,br_next_pg
    ; ld hl,b_item_cnt
    ; cp (hl)
    ; jr z,br_next_pg
    ; jr z,br_hover
    ld (b_selected_i),a

br_hover
    ld d,a
    ld a,(menu_attr_act)
    ld e,a
    jr br_line
br_hide
    ld d,a
    ld a,(menu_attr)
    ld e,a
br_line
    ld a,d
    ld c,0
    ld b,16
; a>attr line Y
; c>x
; b>len
; e>attr
attr_line
    push de
    call attrposy
    ld e,b  ; store len
    ld b,0
    add hl,bc   ; add x
    ld c,e  ; c>len to bc
    ld b,0
    pop de
    ld (hl),e
    ld e,l
    ld d,h
    inc de
    ldir
    ret

browser_action
    ld bc,22*256
    call psetpos
    ld a,(b_selected_i)
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    ld de,fentryes
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    push de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    pop de
    call SEEK
    ld de,direntry
    call GET_DIR_ENTRY
    call print_entry

    ld a,(direntry+DIR_Attr)
    ; and 15
    cp ATTR_DIRECTORY
    jr nz,1f

; change dir
; b_selected_index=0
; b_page_act=0
; b_pg_start=0
; b_dir_cluster=selected dir cluster
    ld a,0
    ; ld (b_item_cnt),a
    ld (b_selected_i),a
    ld (b_page_act),a
    ld hl,0
    ld (b_pg_start),hl
    ld (b_pg_start+2),hl
    ld de,(direntry+DIR_FstClusLO)
    ld (b_dir_cluster),de
    ld hl,(direntry+DIR_FstClusHI)
    ld (b_dir_cluster+2),hl

    call CHDIR
    
    ld hl,browser_refresh
    jp set_state
1
    ld a,1
    ld (DIMAGESTAT),a
    ld de,(direntry+DIR_FstClusLO)
    ld hl,(direntry+DIR_FstClusHI)
    ld a,0
    call ADDR2LBA
    ld (DIMAGESTAT+1),de
    ld (DIMAGESTAT+3),hl

    ; ld hl,main_menu
    ; jp set_state
    ; ld hl,browser_active
    ld hl,exit
    jp set_state

; print_dir
; print_file
; print_label
print_entry
    ; ld a,(direntry+DIR_Attr)
    ; and ATTR_LONG_FILE_NAME
    ; cp ATTR_LONG_FILE_NAME
    ; ret z
    ld a,(direntry+DIR_Attr)
    and ATTR_DIRECTORY
    jr z,print_fname
    ; ld a,(direntry+DIR_Attr)
    ; and ATTR_VOLUME_ID
    ; jr z,print_fname
    jr print_dname
    ; ld a,(direntry+DIR_Attr)
    ; and ATTR_DIRECTORY
    ; jr z,fbndir ; not dir
    ; call print_dname
print_fname
    ld hl,direntry
    ld b,8
    call print_b
    ld a,"."
    call charout
    ld hl,direntry+8
    ld b,3
    call print_b
    ret
print_dname
    ld hl,direntry
    ld b,11
    call print_b
    ; todo: ukoncit jakmile " "
pdnameend
    ld a,"/"
    call charout
    ret



keytest
    ; up
    ld c,'u'
    ld a,251
    in a,(254)
    bit 0,a
    jr z,keytest_exit
    ld a,239
    in a,(254)
    bit 3,a
    jr z,keytest_exit
    ; down
    ld c,'d'
    ld a,253
    in a,(254)
    bit 0,a
    jr z,keytest_exit
    ld a,239
    in a,(254)
    bit 4,a
    jr z,keytest_exit
    ; o
    ld c,'l'
    ld a,223
    in a,(254)
    bit 1,a
    jr z,keytest_exit
    ; p
    ld c,'r'
    ld a,223
    in a,(254)
    bit 0,a
    jr z,keytest_exit
    ; enter
    ld c,13
    ld a,191
    in a,(254)
    bit 0,a
    jr z,keytest_exit
    ld c,0
keytest_exit
    ld a,c
    ret

delay
    ld b,5
1
    halt
    djnz 1b
    ret



init
    ; ld hl,15616
    ; ld de,font
    ; ld bc,768
    ; ldir
    ld hl,0
    ld (pposx),hl
    ld hl,(lineaddr)
    ld (printpos),hl
    ld hl,16384
    ld de,16385
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,22528
    ld de,22529
    ld bc,767
    ld a,(menu_attr)
    ld (hl),a
    ldir
    ld bc,23*256
    call psetpos
    call print_i
    db "NMI Menu MDOS1SD v0.0",0
    ld bc,0
    call psetpos
    call VOLUME_INIT
    ret

; bc>pos yx
; de>h,w (without "borders")
draw_win
    ld (win_yx),bc
    ld (win_hw),de
    push bc
    call attrpos
    ; title
    ld bc,(win_hw)
    inc b
    inc b
    ld a,7+64
1
    push bc
    push hl
    ld bc,(win_hw)
    ld b,0
    inc bc
    ld e,l
    ld d,h
    inc de
    ld (hl),a
    ldir
    pop hl
    ld de,32
    add hl,de
    pop bc
    ld a,64+56
    djnz 1b

    pop bc
    inc b
    call scrpos

menu_line
    ld b,8
1
    push bc
    push hl
    ld (hl),128
    inc hl
    ld bc,(win_hw)
    ld b,0
    ; inc bc
    ld e,l
    ld d,h
    inc de
    ld (hl),0
    ldir
    ld (hl),1
    pop hl
    pop bc
    inc h
    djnz 1b

menu_last_line
    dec h
    ld e,l
    ld d,h
    inc de
    ld bc,(win_hw)
    ld b,0
    inc bc
    ld (hl),255
    ldir
    ret

win_yx
    dw 0
win_hw
    dw 0

; bc>pos yx
; de>wh (without "borders")
clear_win

; hl>16bit number
printhex
   ld  c,h
   call  printhex8
   ld  c,l
; c>8bit number
printhex8
   ld  a,c
   rra
   rra
   rra
   rra
   call  Conv
   ld  a,c
Conv:
   and  0Fh
   add  a,090h
   daa
   adc  a,040h
   daa
   push hl
   push bc
   call charout
   pop bc
   pop hl
   ret

print_b
    push bc
    push hl
    ld a,(hl)
    call charout
    pop hl
    pop bc
    inc hl
    djnz print_b
    ret

print_i
    pop hl
1
    ld a,(hl)
    inc hl
    cp 0
    jr z,pret
    push hl
    call charout
    pop hl
    jr 1B
pret
    push hl
    ret

charout
    cp 13
    jr z,newline
    bit 7,a
    jr z,1f
    call drawchar_i
    jr 2f
1
    call drawchar
2
    ld a,(pposx)
    inc a
    and 31
    ld (pposx),a
    ld hl,(printpos)
    inc hl
    ld (printpos),hl
    ret
; a>tab pos 0-31
ptab
    ld bc,(pposx)
    ld c,a
; bc>yx
psetpos
    ld (pposx),bc
    call scrpos
    ld (printpos),hl
    ret

; bc>yx
; hl<screen addr
scrpos
    ld l,b
    ld h,0
    add hl,hl
    ld de,lineaddr
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld b,0
    ex hl,de
    add hl,bc
    ret
; bc>yx
; hl<attrpos
attrpos
    ld a,b
    call attrposy
    ld b,0
    add hl,bc
    ret
; a>Y
; hl<attr pos
attrposy
    ld l,a
    ld h,0
    add hl,hl   ; *2
    add hl,hl   ; *4
    add hl,hl   ; *8
    add hl,hl   ; *16
    add hl,hl   ; *32
    ld de,22528
    add hl,de
    ret

newline
    xor a
    ld (pposx),a
    ld a,(pposy)
    inc a
    cp 23
    jr c,nline
    ; ret nc
    xor a
nline
    ld (pposy),a
    ld l,a
    ld h,0
    add hl,hl
    ld de,lineaddr
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (printpos),de
    ret

drawchar
    call get_char
    ld b,8
1
    ld a,(hl)
    ld (de),a
    inc hl
    inc d
    djnz 1b
    ret
drawchar_i
    res 7,a
    call get_char
    ld b,8
1
    ld a,(hl)
    xor 255
    ld (de),a
    inc hl
    inc d
    djnz 1b
    ret

get_char
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,font-256
    add hl,de
    ld de,(printpos)
    ret
    ; ALIGN 256

font
    ; ds 768
    incbin "zx.fnt"
lineaddr
    dw 0x4000
    dw 0x4020
    dw 0x4040
    dw 0x4060
    dw 0x4080
    dw 0x40A0
    dw 0x40C0
    dw 0x40E0
    dw 0x4800
    dw 0x4820
    dw 0x4840
    dw 0x4860
    dw 0x4880
    dw 0x48A0
    dw 0x48C0
    dw 0x48E0
    dw 0x5000
    dw 0x5020
    dw 0x5040
    dw 0x5060
    dw 0x5080
    dw 0x50A0
    dw 0x50C0
    dw 0x50E0

testfp
    dw 0,0  ; fpos
    dw 0,0  ; size
    dw 2,0  ; first cluster
    dw 2,0  ; actual cluster
    dw 0,0  ; cluster index in file
; testfpx
;     dw 0,0  ; fpos
;     dw 0,0  ; size
;     dw 0x0196,0x0000  ; first cluster
;     dw 0x0196,0x0000  ; actual cluster
;     dw 0,0  ; cluster index in file

    include "fat32drv/fat32drv.asm"

printpos
    dw 16384
pposx
    db 0
pposy
    db 0

app_state       ; app state machine
    dw 0
b_dir_cluster   ; zacatek dir
    dw 0,0
b_pg_start      ; fpos v dir
    dw 0,0
b_item_cnt      ; number of items on page
    db 0
b_selected_i    ; selected index
    db 0
b_page_act      ; actual page number
    db 0
b_pages_cnt     ; total no of pages
    db 0
direntry
    ds 32
fpage
    db 0
fentryes
    ds 4*max_files_per_page ; dir pos
browser_pages
    ds 4*max_browser_pages

max_files_per_page  equ 16
max_browser_pages   equ 32

menu_attr
    ; db 56
    db 15
menu_attr_act
    db 71
    ; db 64+40





end
    DISPLAY "Length:",/A,end-start
    SAVETAP "nmimenu.tap",start
    SAVEBIN "mdosmenu.nmi",start,8192
