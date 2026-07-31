    DEVICE ZXSPECTRUM48
    ; ORG 32768
AY_REG  equ 0xFFFD
AY_DATA equ 0xBFFD
    org 8192
start
    jp nmimenu

; 1 byte status
; bit 0 drive 0/1
; bit 6=1 mounted
; bit 7=1 write protect
; 4 byte LBA start
; 2 byte image len in sectors
DIMAGESTAT
    db 0
    dw 0x0000,0x0000
    dw 0
    db 0
    dw 0x0000,0x0000
    dw 0
DNAMES
    db "  <select>  "
    db "  <select>  "
nmimenu
    ei
    call main_init
state_loop
    call keytest
    call dispatch_state
    call delay
    jr state_loop

set_state
    ld (app_state),hl
    ret

dispatch_state
    ld hl,(app_state)
    jp (hl)

ay_vol_off
    ld a,8
    ld de,3*256 ; d=3
1
    ld bc,AY_REG
    out (c),a
    ld bc,AY_DATA
    out (c),e
    inc a
    dec d
    jr nz,1b
    ret

print_entry
    ld a,(direntry+DIR_Attr)
    and ATTR_DIRECTORY
    jr z,print_fname
    jr print_dname
print_fname
    ld hl,direntry
    ld b,8
    call w_print_b
    ld a,"."
    call w_charout
    ld hl,direntry+8
    ld b,3
    call w_print_b
    ret
print_dname
    ld hl,direntry
    ld b,11
    call w_print_b
    ; todo: ukoncit jakmile " "
pdnameend
    ld a,"/"
    call w_charout
    ret

filter_entry
    ld b,3
    ld hl,direntry+8
    ld de,suffix1
    call CP_HLDE_B
    ret z
    ld b,3
    ld hl,direntry+8
    ld de,suffix2
    call CP_HLDE_B
    ret


keytest
    ; up 7
    ld c,'u'
    ld a,251
    in a,(254)
    bit 0,a
    jp z,keytest_exit
    ld a,239
    in a,(254)
    bit 3,a
    jp z,keytest_exit
    ; down 6
    ld c,'d'
    ld a,253
    in a,(254)
    bit 0,a
    jr z,keytest_exit
    ld a,239
    in a,(254)
    bit 4,a
    jr z,keytest_exit
    ; left
    ld c,'l'
    ld a,247
    in a,(254)
    bit 4,a
    jr z,keytest_exit
    ld a,223
    in a,(254)
    bit 1,a
    jr z,keytest_exit
    ; right
    ld c,'r'
    ld a,239
    in a,(254)
    bit 2,a
    jr z,keytest_exit
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
    ; s
    ld c,'s'
    ld a,253
    in a,(254)
    bit 1,a
    jr z,keytest_exit
    ; w
    ld c,'w'
    ld a,251
    in a,(254)
    bit 1,a
    jr z,keytest_exit
    ; e
    ld c,'e'
    bit 2,a
    jr z,keytest_exit

    ; d
    ld c,'v'
    ld a,253
    in a,(254)
    bit 2,a
    jr z,keytest_exit

    ; r
    ld c,'R'
    ld a,251
    in a,(254)
    bit 3,a
    jr z,keytest_exit

    ; break
    ;   caps
    ld c,27
    ld a,254
    in a,(254)
    bit 0,a
    jr nz,nokey
    ;   space
    ld a,127
    in a,(254)
    bit 0,a
    jr z,keytest_exit



nokey
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

; hl>16bit number
; printhex
;    ld  c,h
;    call  printhex8
;    ld  c,l
; ; c>8bit number
; printhex8
;    ld  a,c
;    rra
;    rra
;    rra
;    rra
;    call  Conv
;    ld  a,c
; Conv:
;    and  0Fh
;    add  a,090h
;    daa
;    adc  a,040h
;    daa
;    push hl
;    push bc
;    call charout
;    pop bc
;    pop hl
;    ret


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
    ; ld a,b
    ; call attrposy
    ld l,b
    ld h,0
    add hl,hl   ; *2
    add hl,hl   ; *4
    add hl,hl   ; *8
    add hl,hl   ; *16
    add hl,hl   ; *32
    ld de,22528
    add hl,de
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


cls
    ld hl,16384
    ld de,16385
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,22528
    ld de,22529
    ld bc,767
    ld (hl),56
    ldir
    ret

clw
    ld bc,(win_pos)
    inc b
    inc c
    call scrpos
    ld a,(win_h)
    add a,a ;*2
    add a,a ;*4
    add a,a ;*8
    ld b,a
1
    push bc
    push hl
    ld (hl),0
    ld e,l
    ld d,h
    inc de
    ld a,(win_w)
    dec a
    ld c,a
    ld b,0
    ldir
    pop hl
    pop bc
    call downhl
    djnz 1b
    ret

w_set_act
    ld de,win_act
    ld bc,4
    ldir
    ret

; hl>action table
w_action_jp
    ld a,(win_select_pos)
    add a,a
    ld e,a
    ld d,0
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    jp (hl)

w_draw
    ;initial settings
    ;win printpos
    ld bc,256   ; y=1,x=0
    ld (win_py),bc
    ;attrs - title
    ld bc,(win_pos)
    call attrpos

    push hl
    ld a,(win_w)
    ; dec a
    ld c,a
    ld a,64+7
    call w_attr_line
    ; didaktik logo RED
    ld a,2
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    pop hl
    ld de,32
    add hl,de
    ld a,(win_h)
    inc a
    ld b,a
    ld a,(win_w)
    add a,2
    ld c,a
    ld a,64+56
1
    push bc
    push hl
    call w_attr_line
    pop hl
    pop bc
    ld de,32
    add hl,de
    djnz 1b

    ; borders
    ld bc,(win_pos)
    inc b
    call scrpos

    ld a,(win_h)
    inc a
    add a,a ;*2
    add a,a ;*4
    add a,a ;*8
    dec a
    ld b,a
1
    push bc
    push hl
    ld (hl),128
    inc hl
    ld (hl),0
    ld e,l
    ld d,h
    inc de
    ld a,(win_w)
    ld c,a
    ld b,0
    ; inc bc
    ldir
    ld (hl),1
    pop hl
    pop bc
    call downhl
    djnz 1b
    ; last line
    ld e,l
    ld d,h
    inc de
    ld (hl),255
    ld a,(win_w)
    inc a
    ld c,a
    ld b,0
    ldir

    ld bc,0
    ld (win_px),bc
    call w_ppos

    ret
; hl>target
; a>attribut
; c>len
w_attr_line
    ld (hl),a
    ld e,l
    ld d,h
    inc de
    ld b,0
    dec bc
    ldir
    ret

w_ppos
    ld bc,(win_pos)
    ld a,(win_py)
    add a,b
    inc a
    ld b,a
    ld a,(win_px)
    add a,c
    inc a
    ld c,a
    call scrpos
    ld (w_scraddr+1),hl
    ret

w_newline
    ld bc,(win_px)
    ld c,0
    inc b
    ld (win_px),bc
    jr w_ppos

w_logo
    ld bc,(win_pos)
    ld a,(win_w)
    add a,c
    sub 1
    ld c,a
    call scrpos
    ld (w_scraddr+1),hl
    ld hl,logo_didaktik
    call w_char_hl
    ld hl,(w_scraddr+1)
    inc hl
    ld (w_scraddr+1),hl
    ld hl,logo_didaktik+8
    call w_char_hl
    ld hl,(w_scraddr+1)
    inc hl
    ld (w_scraddr+1),hl
    ld hl,logo_didaktik+16
    call w_char_hl
    ret

w_title
    call w_logo
    ld bc,(win_pos)
    call scrpos
    ld (w_scraddr+1),hl
    ld a,255
    ld (win_py),a
w_print_i
    pop hl
1
    ld a,(hl)
    inc hl
    cp 0
    jr z,w_pret
    push hl
    call w_charout
    pop hl
    jr 1B
w_pret
    push hl
    ret

w_print_b
    push bc
    push hl
    ld a,(hl)
    call w_charout
    pop hl
    pop bc
    inc hl
    djnz w_print_b
    ret

w_charout
    cp 13
    jr z,w_newline
    call w_char
    ld a,(win_px)
    inc a
    and 31
    ld (win_px),a
    ld hl,(w_scraddr+1)
    inc hl
    ld (w_scraddr+1),hl
    ret

w_char
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,font-256
    add hl,de
w_char_hl
w_scraddr
    ld de,16384
    ld b,8
1
    ld a,(hl)
    ld (de),a
    inc hl
    inc d
    djnz 1b
    ret

w_draw_select
    ld a,64+8*5
    jr w_selectbar
w_hide_select
    ld a,64+56
w_selectbar
    push af
    ld bc,(win_pos)
    inc b
    ld a,(win_select_pos)
    add a,b
    ld b,a
    call attrpos
    ld a,(win_w)
    add a,2
    ld c,a
    pop af
    jp w_attr_line

w_select_up
    call w_hide_select
    ld a,(win_select_pos)
    cp 0
    jr z,1f
    dec a
    ld (win_select_pos),a
1
    call w_draw_select
    ret
w_select_down
    call w_hide_select
    ld a,(win_select_pos)
    inc a
    ld hl,win_items_cnt
    cp (hl)
    jr z,1f
    ld (win_select_pos),a
1
    call w_draw_select
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

main_init
    call ay_vol_off
    call cls
    ld hl,win_main
    call w_set_act
    call w_draw
    call w_title
    db "MDOS1SD v0.7c",13,0

    ld a,0
    ld (win_select_pos),a
    ld hl,main_draw
    jp set_state

main_draw
    ld bc,0
    ld (win_px),bc
    call w_ppos
    call w_print_i
    db "A:",0
    ld hl,DNAMES
    ld b,12
    call w_print_b

    ld a,(DIMAGESTAT)
    bit 7,a
    call main_draw_lock
    call w_newline

    call w_print_i
    db "B:",0
    ld hl,DNAMES+12
    ld b,12
    call w_print_b
    ld a,(DIMAGESTAT+7)
    bit 7,a
    call main_draw_lock
    call w_newline

    call w_print_i
    db "Snapshot",13,0
    call w_print_i
    db "Return",13,0
    
    ld a,4
    ld (win_items_cnt),a

    call w_draw_select

    ld hl,main_select
    jp set_state

; nz>draw space
; z>draw lock
main_draw_lock
    ld hl,(w_scraddr+1)
    inc hl
    ld (w_scraddr+1),hl

    jr z,1f
    ld hl,ico_lock
    jr 2f
1
    ld hl,font  ; font begins with space
2

    call w_char_hl  
    ret

main_select
    cp 0
    ret z
    cp 'u'
    jp z,w_select_up
    cp 'd'
    jp z,w_select_down
    cp 'e'
    jp z,main_eject
    cp 'w'
    jp z,main_wprotect_tgl
    cp 's'
    jp z,snapshot
    cp 27
    jp z,return
    cp 13
    ret nz
    ld hl,main_action
    jp set_state

main_wprotect_tgl
    ld a,(win_select_pos)
    cp 2
    jr nc,1f
    call get_drvstat_a
    ld a,(hl)
    bit 6,a
    jr z,1f
    xor 128
    ld (hl),a
    ld hl,main_draw
    jp set_state
1
    ld hl,main_select
    jp set_state

main_action
    ld hl,main_select_actions
    jp w_action_jp

; hl<drvstat addr
get_drvstat
    ld a,(act_mdos_drv)
get_drvstat_a
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
    ret
; hl<dname
get_drvname
    ld a,(act_mdos_drv)
    add a,a ; *2
    add a,a ; *4
    ld e,a
    add a,a ; *8
    add a,e ; *12
    ld e,a
    ld d,0
    ld hl,DNAMES
    add hl,de
    ret

eject_a
    ld a,0
    jr eject
eject_b
    ld a,1
eject
    ld (act_mdos_drv),a
    push af
    call get_drvstat
    ld (hl),0
    ld e,l
    ld d,h
    inc de
    ld bc,4
    ldir
    pop af

    call get_drvname
    ex de,hl
    ld hl,empty_str
    ld bc,12
    ldir

    ld hl,main_draw
    jp set_state

empty_str
    db "  <select>  "

mount_a
    ld a,0
    jr mount
mount_b
    ld a,1
mount
    ld (act_mdos_drv),a
    ld hl,browser_init
    jp set_state
snapshot
    pop hl
    ld a,'s'
    ret
return
    pop hl
    ld a,0
    ret

main_eject
    ld a,(win_select_pos)
    cp 2
    ret nc
    ld (act_mdos_drv),a
    jr eject

main_select_actions
    dw mount_a
    dw mount_b
    dw snapshot
    dw return

browser_init
    ld a,(drive_act)
    call DRIVE_SELECT
    ld a,(volume_act)
    ld ix,volume1
    ld e,0xff
    ld (ix+V_SEC_ACT+0),e
    ld (ix+V_SEC_ACT+1),e
    ld (ix+V_SEC_ACT+2),e
    ld (ix+V_SEC_ACT+3),e
    call VOLUME_SELECT

    ld iy,testfp
    ld de,(b_dir_cluster)
    ld hl,(b_dir_cluster+2)
    call CHDIR
; tohle resi chdir ne?
    ld de,0
    ld (b_pg_start),de
    ld (b_pg_start+2),de

    ld hl,win_browser
    call w_set_act
    call w_draw
    call w_title
    db "Select disk image",13,0

    ld a,0
    ld (win_select_pos),a
    ld (b_page_act),a

    ld hl,browser_draw
    jp set_state

browser_draw
    di
    call clw
    ld bc,0
    ld (win_px),bc
    call w_ppos
    ld a,0
    ld (win_items_cnt),a
    ld de,(b_pg_start)
    ld hl,(b_pg_start+2)
    call SEEK
bd_next
    ld de,direntry
    call GET_DIR_ENTRY
    cp 0xff
    ; jp z,bd_end
    jp z,bd_next_pg
    ; end of dir?
    ld a,(direntry)
    cp 0
    ; jp z,bd_end
    jp z,bd_next_pg
    ; empty entry?
    cp 0xe5
    jp z,bd_next
    ; is "this dir" . ?
    cp "."
    jr nz,1f
    ld a,(direntry+1)
    cp " "
    jr z,bd_next
1
    ld a,(direntry+DIR_Attr)
    ; volume label?
    cp 0x8
    jr z,bd_next
    ; LFN entry?
    and ATTR_LONG_FILE_NAME
    cp ATTR_LONG_FILE_NAME 
    jr z,bd_next

    ld a,(direntry+DIR_Attr)
    cp ATTR_DIRECTORY
    jr z,1f
    call filter_entry
    jr nz,bd_next
1
    call print_entry
    call w_newline

    ld a,(win_items_cnt)
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

    ld a,(win_items_cnt)
    inc a
    ld (win_items_cnt),a

    ld hl,win_browser+3
    cp (hl)
    jr z,bd_next_pg
    jp bd_next

bd_next_pg
    ld a,(b_page_act)
    ld l,a
    ld h,0
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
bd_end
    ei
    ; todo: nefunguje spravne u prazdneho volume
    ; ld a,(direntry)
    ; cp 0
    ; jr z,1f

    ; is it empty volume?
    ld hl,b_page_act
    ld a,(win_items_cnt)
    or (hl)
    jr z,bd_empty

    ld a,(win_items_cnt)
    cp 0
    jp z,br_pg_prev

1
    call w_draw_select
    ld hl,browser_select
    jp set_state

bd_empty
    ld hl,win_info
    call w_set_act
    call w_draw
    call w_title
    db "Empty volume",13,0
    call w_print_i
    db "Select another",0
1
    call delay
    call keytest
    cp 0
    jr z,1b

    ld hl,drives_init
    jp set_state

browser_select
    cp 0
    ret z
    cp 'u'
    jp z,br_select_up
    cp 'd'
    jp z,br_select_down
    cp 'l'
    jp z,br_pg_prev
    cp 'r'
    jp z,br_pg_next
    cp 'v'
    ld hl,drives_init
    jp z,set_state
    cp 27
    jr z,br_exit
    cp 13
    ret nz
    ld hl,browser_action
    jp set_state

br_exit
    ld hl,main_init
    jp set_state

br_select_up
    ld hl,b_page_act
    or (hl)
    ret z

    ld a,(win_select_pos)
    cp 0
    jr z,br_pg_prev

    call w_hide_select

    ld a,(win_select_pos)
    dec a
    ld (win_select_pos),a
    jp w_draw_select
    ld a,(win_select_pos)

br_select_down
    ld a,(win_select_pos)
    inc a
    ld hl,win_items_cnt
    cp (hl)
    jr nz,1f
    cp max_files_per_page
    jr z,br_pg_next
    ret

1
    push af
    call w_hide_select
    pop af

    ld (win_select_pos),a
    jp w_draw_select

br_pg_prev
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
1
; get "next page from act_page-1"
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
    call w_hide_select
    ld hl,browser_draw
    jp set_state

br_pg_next
    call w_hide_select
    ld a,0
    ld (win_select_pos),a
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
    ld (win_select_pos),a

    ld hl,browser_draw
    jp set_state

browser_action
    ld a,(win_select_pos)
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

    ld a,(direntry+DIR_Attr)
    cp ATTR_DIRECTORY
    jr nz,1f

; change dir
; b_selected_index=0
; b_page_act=0
; b_pg_start=0
; b_dir_cluster=selected dir cluster
    call w_hide_select
    ld a,0
    ld (win_select_pos),a
    ld (b_page_act),a
    ld hl,0
    ld (b_pg_start),hl
    ld (b_pg_start+2),hl
    ld de,(direntry+DIR_FstClusLO)
    ld (b_dir_cluster),de
    ld hl,(direntry+DIR_FstClusHI)
    ld (b_dir_cluster+2),hl

    call CHDIR
    
    ld hl,browser_draw
    jp set_state
; action select file
1
    call get_drvname
    ld de,direntry
    ex de,hl

    ld bc,8
    ldir
    ld a,"."
    ld (de),a
    inc de
    ld bc,3
    ldir

    call get_drvstat
    push hl
    ld a,(drive_act)
    set 6,a
    ld (hl),a
    inc hl
    push hl
    ld de,(direntry+DIR_FstClusLO)
    ld hl,(direntry+DIR_FstClusHI)
    ld a,0
    call ADDR2LBA
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
    inc hl
    ; get filesize>>9 ( /512)
    ld de,(direntry+DIR_FileSize+1)
    srl d
    rr e
    ld (hl),e
    inc hl
    ld (hl),d
    ; if de>=721, set 40 tracks bit
    or a
    ld hl,721
    sbc hl,de
    pop hl
    jr c,1f
    set 5,(hl)
1

    ld hl,main_init
    jp set_state



drives_init
    ld hl,win_drives
    call w_set_act
    call w_draw
    call w_title
    db "Probing drives",13,0

    ld a,0
    ld (win_select_pos),a
    ld (win_items_cnt),a
    ld hl,drives_draw
    jp set_state

drives_draw
    ld ix,volume_tmp
    ld a,(drive_act)
    ld (drive_tmp),a
    ld a,0
    ld (drive_act),a
    ld (volumes_cnt),a
print_drv
    ld a,(drive_act)
    call DRIVE_SELECT
    ld a,(drives_reinit)
    or a
    call nz,DRIVE_INIT
    ld a,0
    ld (volume_act),a
print_part
    ld a,(volume_act)
    ; reset sector buffer
    ld e,0xff
    ld (ix+V_SEC_ACT+0),e
    ld (ix+V_SEC_ACT+1),e
    ld (ix+V_SEC_ACT+2),e
    ld (ix+V_SEC_ACT+3),e

    call VOLUME_SELECT
    cp 0xff
    jr z,1f

    call w_print_i
    db "SD",0
    ld a,(drive_act)
    add a,'0'
    call w_charout
    ld a,','
    call w_charout
    ld a,(volume_act)
    add a,'0'
    call w_charout
    ld a,'/'
    call w_charout

    ld iy,tmpfp
    ld de,2
    ld hl,0
    ld (iy+F_FCLUSTER+0),e
    ld (iy+F_FCLUSTER+1),d
    ld (iy+F_FCLUSTER+2),l
    ld (iy+F_FCLUSTER+3),h
    call REWIND
    ld de,direntry
    call GET_DIR_ENTRY
    ld hl,direntry
    ld b,11
    call w_print_b
    ld a,13
    call w_charout

    ld hl,volumes_cnt
    ld a,(hl)
    inc (hl)
    ld l,a
    ld h,0
    add hl,hl
    ld de,volumes
    add hl,de
    ld a,(drive_act)
    ld (hl),a
    inc hl
    ld a,(volume_act)
    ld (hl),a
1
    ld a,(volume_act)
    inc a
    ld (volume_act),a
    cp 5
    jp nz,print_part


    ld a,(drive_act)
    inc a
    ld (drive_act),a
    cp 2
    jp nz,print_drv

    ld a,(volumes_cnt)
    ld (win_items_cnt),a

    ld a,0
    ld (drives_reinit),a

    call w_draw_select
    call w_title
    db "Select volume ",13,0
    ld hl,drives_select
    jp set_state

drives_select
    cp 0
    ret z
    cp 'u'
    jp z,w_select_up
    cp 'd'
    jp z,w_select_down

    cp 'R'
    jr z,drives_refresh
    ; ld hl,browser_init
    cp 27
    ; jp z,return
    ; jp z,set_state
    jr z,drives_exit
    cp 13
    ret nz
    ld hl,drives_action
    jp set_state

drives_exit
    ld a,(drive_tmp)
    ld (drive_act),a
    ld hl,browser_init
    jp set_state

drives_refresh
    ld a,1
    ld (drives_reinit),a
    jp drives_init

drives_action
    ld a,(win_select_pos)
    ld l,a
    ld h,0
    add hl,hl
    ld de,volumes
    add hl,de
    ld a,(hl)
    ld (drive_act),a
    inc hl
    ld a,(hl)
    ld (volume_act),a
    ld hl,0
    ld (b_dir_cluster),hl
    ld (b_dir_cluster+2),hl
    ld hl,browser_init
    jp set_state



; drive number,volume number
drive_act
    db 0
drive_tmp
    db 0
volume_act
    db 1

volumes
    ds 8*2
volumes_cnt
    db 0

    include "fat32drv/fat32drv.asm"

; printpos
;     dw 16384
; pposx
;     db 0
; pposy
;     db 0

font
    ; ds 768
    incbin "zx.fnt"
logo_didaktik
    db 0b00000001
    db 0b00000010
    db 0b00000100
    db 0b00001001
    db 0b00010011
    db 0b00100110
    db 0b01001100
    db 0b10011001
    db 0b00110011
    db 0b01100111
    db 0b11001110
    db 0b10011100
    db 0b00111001
    db 0b01110011
    db 0b11100111
    db 0b11001111
    db 0b10011110
    db 0b00111100
    db 0b01111000
    db 0b11110000
    db 0b11100000
    db 0b11000000
    db 0b10000000
    db 0b00000000

ico_lock
    db 0b00000000
    db 0b00011000
    db 0b00100100
    db 0b00100100
    db 0b01111110
    db 0b01111110
    db 0b01111110
    db 0b00000000

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

suffix1
    db "D80"
suffix2
    db "D40"

testfp
    dw 0,0  ; fpos
    dw 0,0  ; size
    dw 2,0  ; first cluster
    dw 2,0  ; actual cluster
    dw 0,0  ; cluster index in file
tmpfp
    dw 0,0
    dw 0,0
    dw 2,0
    dw 0,0
    dw 0,0


app_state       ; app state machine
    dw 0
b_dir_cluster   ; start cluster of dir
    dw 0,0
b_pg_start      ; fpos in dir
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
act_mdos_drv
    db 0
; act_sd_drv
;     db 0
drives_reinit
    db 0
fentryes
    ds 4*max_files_per_page ; dir pos
browser_pages
    ds 4*max_browser_pages

max_files_per_page  equ 22
max_browser_pages   equ 32

; menu_attr
    ; db 56
    ; db 15
; menu_attr_act
    ; db 71
    ; db 64+40


; windows defs
; pos xy, dim wh
; dimensions are without borders
; left/right total 2
; top LABEL 1
; bottom    1
win_act
win_pos     ; win position in chars
    db 0,0
win_w       ; win dimension in chars
    db 0
win_h
    db 0
; win_bg ? pro moznost treba cervenyho upozorneni?
win_px
    db 0
win_py       ; print pos
    db 0
win_p_attr
    db 56+64    ; current attr for print
win_items_cnt
    db 0
win_select_pos
    db 0

win_main
    db 7,7,16,4
win_browser
    db 0,0,30,max_files_per_page
win_eject
    db 4,4,2,16
win_drives
    db 6,7,18,8
win_info
    db 8,9,14,1


volume_tmp
    ds 32
; 12345678901234567
; sd0,0/12345678901
end
    DISPLAY "Length:",/A,end-start
    SAVETAP "nmimenu.tap",start
    SAVEBIN "mdosmenu.nmi",start,8192
