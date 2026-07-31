    ; DEVICE zxspectrum48
    ; org 32768
WAIT_DATA_TIMEOUT   equ 2048
WAIT_CMD_TIMEOUT    equ 2048
DIVPORT equ 227
CONMEM  equ 128
MAPRAM  equ 64
SPI_PORT	equ 0ebh
OUT_PORT	equ 0e7h	; port for CS control (D1:D0)
; CMD_17      equ	040h+17	; READ_SINGLE_BLOCK
; CMD_24      equ 040h+24	; WRITE_BLOCK
CMD_0		equ	0x40	; Go idle state
CMD_1		equ	0x40+1	; SEND_OP_COND
CMD_8		equ 0x40+8	; SEND_IF_COND
CMD_9		equ 0x40+9	; SEND_CSD
CMD_10		equ	0x40+10	; SEND_CID
CMD_12		equ 0x40+12	; STOP_TRANSMISSION
CMD_16		equ	0x40+16	; SET_BLOCKLEN
CMD_17		equ	0x40+17	; READ_SINGLE_BLOCK
CMD_18		equ	0x40+18	; READ_MULTIPLE_BLOCK
;CMD_23		equ 0x40+23	; SET_BLOCK_COUNT (MMC ONLY)
ACMD23		equ 0x40+23	; SET_WR_BLOCK_ERASE_COUNT
CMD_24		equ 0x40+24	; WRITE_BLOCK
CMD_25		equ 0x40+25	; WRITE_MULTIPLE_BLOCK
ACMD41		equ 0x40+41	; APP_SEND_OP_COND
CMD_55		equ 0x40+55	; APP_CMD
CMD_58		equ 0x40+58	; READ_OCR
SD_0		equ 0FEh    ; D0 LOW = SLOT0 active;
; 11111110b
SD_1		equ 0FDh    ; D1 LOW = SLOT1 active;
; 11111101b

; from https://elm-chan.org/docs/fat_e.html
; BOOT sector vars offset
BPB_SecPerClus  equ 13  ; 1B number of sectors per cluster
BPB_RsvdSecCnt  equ 14  ; 2B number of sectors in reserved area
BPB_NumFATs     equ 16  ; 1B number of FATs
BPB_HiddSec     equ 28  ; 4B number of hidden sectors before first FAT
BPB_TotSec32    equ 32  ; 4B volume (partition) size, total numb	Volume serial number used with BS_VolLab to track a volume on the removable storageer of sectors of the FAT volume.
BPB_FATSz32     equ 36  ; 4B size of a FAT in unit of sector. The size of the FAT area is BPB_FATSz32 * BPB_NumFATs sector.
BPB_RootClus    equ 44  ; 2B First cluster number of the root directory. It is usually set to 2.
BPB_FSInfo      equ 48  ; 4B Sector of FSInfo structure in offset from top of the FAT32 volume. It is usually set to 1, next to the boot sector.
BS_BootSig      equ 66  ; 1B Extended boot signature (0x29). This is a signature byte indicates that the following three fields are present.
BS_VolID        equ 67  ; 4B Volume serial number used with BS_VolLab to track a volume on the removable storage.
BS_VolLab       equ 71  ; 11B This field is the 11-byte volume label and it matches volume label recorded in the root directory.
BS_FilSysType   equ 82  ; 8B Always "FAT32   " and it does not have any effect in determination of FAT type.
; PARTITIONS offsets
MBR_Partition1  equ 446 ; 16B Partition 1
MBR_Partition2  equ 462 ; 16B Partition 2
MBR_Partition3  equ 478 ; 16B Partition 3
MBR_Partition4  equ 494 ; 16B Partition 4
BS_Sign         equ 510 ; 0xAA55. A boot signature indicating that this is a valid boot sector.

; PARTITON vars offset
PT_BootID       equ 0   ; 1B Boot indicator. Not bootable (0x00) or Bootable (0x80).
PT_System       equ 4   ; 1B Type of partition.
PT_LbaOfs       equ 8   ; 4B Partition start sector in 32-bit LBA (1 - 0xFFFFFFFF).
PT_LbaSize      equ 12  ; 4B Partition size in unit of sector (1 - 0xFFFFFFFF).
                            ; Typical partition type values are:
                            ; 0x00: Blank entry. Any other field must be zero.
                            ; 0x01: FAT12 (CHS/LBA, < 65536 sectors)
                            ; 0x04: FAT16 (CHS/LBA, < 65536 sectors)
                            ; 0x05: Extended partition (CHS/LBA)
                            ; 0x06: FAT12/16 (CHS/LBA, >= 65536 sectors)
                            ; 0x07: HPFS/NTFS/exFAT (CHS/LBA)
                            ; 0x0B: FAT32 (CHS/LBA)
                            ; 0x0C: FAT32 (LBA)
                            ; 0x0E: FAT12/16 (LBA)
                            ; 0x0F: Extended partition (LBA)

; DIR entry structure vars offset
DIR_Name        equ 0   ; 11B Short file name (SFN) of the object.
                            ; if first byte = 0xE5 (or 0x05), entry is empty/deleted.
                            ; if first byte = 0, it should be end of directory
DIR_Attr        equ 11  ; 1B File attribute.
DIR_NTRes       equ 12  ; 1B Optional flags that indicates case information of the SFN.
DIR_CrtTimeTenth equ 13 ; 1B Optional sub-second information corresponds to DIR_CrtTime.
DIR_CrtTime     equ 14  ; 2B Optional file creation time.
DIR_CrtDate     equ 16  ; 2B Optional file creation date.
DIR_LstAccDate  equ 18  ; 2B Optional last accesse date.
DIR_FstClusHI   equ 20  ; 2B Upper part of cluster number.
DIR_WrtTime     equ 22  ; 2B Last time when any change is made to the file.
DIR_WrtDate     equ 24  ; 2B Last data when any change is made to the file.
DIR_FstClusLO   equ 26  ; 2B Lower part of cluster number. When the file size is zero, no cluster is assigned and this item must be zero. Always an valid value if it is a directory.
DIR_FileSize    equ 28  ; 4B Size of the file in unit of byte. Not used when it is a directroy and the value must be always zero.

; DIR entry attributes
ATTR_READ_ONLY  equ 0x01    ; BIT 0 (Read-only)
ATTR_HIDDEN     equ 0x02    ; BIT 1 (Hidden)
ATTR_SYSTEM     equ 0x04    ; BIT 2 (System)
ATTR_VOLUME_ID  equ 0x08    ; BIT 3 (Volume label)
ATTR_DIRECTORY  equ 0x10    ; BIT 4 (Directory)
ATTR_ARCHIVE    equ 0x20    ; BIT 5 (Archive)
ATTR_LONG_FILE_NAME equ 0x0F ; BITs 0-3 (LFN entry)


; VOLUME vars offset
V_START         equ 0   ; 4B Start of volume in sectors (0 for non partitioned, partition start for partitioned)
V_FATSTART      equ 4   ; 4B Start of fat table in sectors (Absolute from start of disk)
V_DATASTART     equ 8   ; 4B Start of data area in sectors (Absolute from start of disk)
V_CLUSTERSIZE   equ 12  ; 1B size of cluster
V_CLUSTERSH     equ 13  ; 1B shift value for size of cluster
V_CLUSTERMSK    equ 14  ; 1B cluster mask
V_ROOTCLUSTER   equ 15  ; 2B first cluster number of root dir
V_ID            equ 17  ; 4B Volume ID from BS_VolID, to check if volume changed
V_SEC_ACT       equ 21  ; 4B Actual LBA sector in buffer
V_VARS_LEN      equ 26
; FILE vars offset
F_FPOS          equ 0   ; 4B byte position in stream
F_SIZE          equ 4   ; 4B file size, 0 for directory
F_FCLUSTER      equ 8   ; 4B first cluster of file/dir
F_ACLUSTER      equ 12  ; 4B actual cluster
F_ICLUSTER      equ 16  ; 4B cluster index in file
; jeste domyslet:
; mel bych ulozit jeste ATTR pro zjisteni file/dir/ro
; mozna i sektor a pozici v sektoru
; at se to nemusi resit pres SP
; nebo pocitat vickrat. MOZNA
; F_DENTRY_LBA    equ 16  ; 4B ABS sector where is actual file/dir entry, 0 for ROOT
; F_DENTRY_POS    equ 17  ; 1B dir entry position (0..15) in sector

/*
sector = data_start_abs + ((cluster - 2) << cluster_shift)
fat_offset = cluster * 4
fat_sector = fat_start_abs + (fat_offset >> 9)
fat_byte   = fat_offset & 0x1FF
*/
    MACRO PADORG addr
         ; add padding
         IF $ < addr
         BLOCK addr-$
         ENDIF
         ORG addr
    ENDM

;a>drive CS byte
DRIVE_SELECT
    ld l,a
    ld h,0
    ld de,DRV_CSL
    add hl,de
    ld a,(hl)
    ld (CARD_SELECT),a
    ; todo: vyber drive podle A
    ; a 0,1 -> ulozi drive CS
    ; otestuje disk
    ; vrati jestli je/neni disk
    ret

DRIVE_INIT
    call SD_INIT
    cp 0xff
    ret z

    ret

; na aktualnim drive otestuje primary partition 1-4
; a pokud je typu 0xC zavola VOLUME_INIT
; ix>volume vars
; a> partition 1-4
VOLUME_SELECT
    ; cp 0    ; todo: detekovat non-partition sd
    ; jr z,vserr
    push af
    ; ; reset sector buffer
    ; ld a,0xff
    ; ld (ix+V_SEC_ACT+0),a
    ; ld (ix+V_SEC_ACT+1),a
    ; ld (ix+V_SEC_ACT+2),a
    ; ld (ix+V_SEC_ACT+3),a
    ; read MBR to buffer
    ld de,0
    ld hl,0
    call READSEC
    ; error handling patch by u880d
    jr z,vol_sel_rdsec_ok
    pop af
    jr vserr

vol_sel_rdsec_ok
    pop af
    cp 0    ; todo: detekovat non-partition sd
    jr nz,1f
    ld hl,buff1+BS_FilSysType
    ld de,fat32sign
    ld b,5
    call CP_HLDE_B
    jr nz,vserr
    ld de,0
    ld hl,0
    jp VOLUME_INIT

    ; jr z,vserr
1
    ; get buffer + partition offset
    dec a
    ld l,a
    ld h,0
    add hl,hl   ; *x
    ld de,part_offsets
    add hl,de

    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl

    push de
    inc de
    inc de
    inc de
    inc de
    ld a,(de)
    cp 0xC
    jr nz,vsnot
    pop hl
    ; add offset to volume start to partition record
    ld de,PT_LbaOfs
    add hl,de

    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    push bc
    pop hl
    jp VOLUME_INIT



vsnot   ; volume_select not 0xc partition
    pop de
vserr
    ld a,0xff
    ret

part_offsets
    dw buff1+MBR_Partition1
    dw buff1+MBR_Partition2
    dw buff1+MBR_Partition3
    dw buff1+MBR_Partition4
fat32sign
    db "FAT32"

; cp values from hl
; with values from de
; count b
; z=same
CP_HLDE_B
    ld a,(de)
    cp (hl)
    ret nz
    inc de
    inc hl
    djnz CP_HLDE_B
    xor a
    ret

/*
; a>volume number 0-7
; ix<volume vars
; set V_SECT_ACT to 0xffffffff
VOLUME_SELECT
    ld l,a
    ld h,0
    add hl,hl   ;*2
    add hl,hl   ;*4
    add hl,hl   ;*8
    add hl,hl   ;*16
    add hl,hl   ;*32
    ld de,VOLUMES
    add hl,de
    push hl
    pop ix
    ld a,0xff
    ld (ix+V_SEC_ACT+0),a
    ld (ix+V_SEC_ACT+1),a
    ld (ix+V_SEC_ACT+2),a
    ld (ix+V_SEC_ACT+3),a
    ret
*/

; ix>volume vars
; hlde>volume start
VOLUME_INIT
    ; set "actual sector in buffer" to non-existent
    ld a,0xff
    ld (ix+V_SEC_ACT+0),a
    ld (ix+V_SEC_ACT+1),a
    ld (ix+V_SEC_ACT+2),a
    ld (ix+V_SEC_ACT+3),a
    ld (ix+V_START+0),e
    ld (ix+V_START+1),d
    ld (ix+V_START+2),l
    ld (ix+V_START+3),h
    ; read first sector of volume
    ; ld de,0
    ; ld hl,0
    call READSEC
    ; TODO: check if FAT volume
    ; ld ix,volume1

    ; set FAT start
    ld de,(buff1+BPB_RsvdSecCnt)
    ld hl,0
    ; add volume/partition start
    ld a,(ix+V_START+0)
    add a,e
    ld (ix+V_FATSTART+0),a
    ld a,(ix+V_START+1)
    adc a,d
    ld (ix+V_FATSTART+1),a
    ld a,(ix+V_START+2)
    adc a,l
    ld (ix+V_FATSTART+2),a
    ld a,(ix+V_START+3)
    adc a,h
    ld (ix+V_FATSTART+3),a

    ; ld (ix+V_FATSTART+0),e
    ; ld (ix+V_FATSTART+1),d
    ; ld (ix+V_FATSTART+2),l
    ; ld (ix+V_FATSTART+3),h

    ; set DATA start
    ; get FAT size
    ld de,(buff1+BPB_FATSz32)
    ld hl,(buff1+BPB_FATSz32+2)
    ; multiply by 2 (<<1) (two FAT areas by "norm")
    sla e
    rl d
    rl l
    rl h
    ; add FAT START and store DATA start
    ld a,e
    add a,(ix+V_FATSTART+0)
    ld (ix+V_DATASTART+0),a
    ld a,d
    adc a,(ix+V_FATSTART+1)
    ld (ix+V_DATASTART+1),a
    ld a,l
    adc a,(ix+V_FATSTART+2)
    ld (ix+V_DATASTART+2),a
    ld a,h
    adc a,(ix+V_FATSTART+3)
    ld (ix+V_DATASTART+3),a

    ; set cluster size
    ld a,(buff1+BPB_SecPerClus)
    ld (ix+V_CLUSTERSIZE),a
    push af

    ; set cluster shift
    call CALC_CLUSTER_SHIFT
    ld (ix+V_CLUSTERSH),c
    ; set cluster mask
    pop af
    dec a
    ld (ix+V_CLUSTERMSK),a

    ; set first ROOT cluster
    ld hl,(buff1+BPB_RootClus)
    ld (ix+V_ROOTCLUSTER+0),l
    ld (ix+V_ROOTCLUSTER+1),h

    ; set Volume ID
    ld de,(buff1+BS_VolID)
    ld hl,(buff1+BS_VolID+2)
    ld (ix+V_ID+0),e
    ld (ix+V_ID+1),d
    ld (ix+V_ID+2),l
    ld (ix+V_ID+3),h



    ret
; ix=volume vars
; iy=file descriptor
; hlde=first cluster of directory
CHDIR
    ; check if hlde=0
    ld a,e
    or d
    or l
    or h
    jr nz,chdir1
    ; yes, set root dir cluster 
    ld e,(ix+V_ROOTCLUSTER+0)
    ld d,(ix+V_ROOTCLUSTER+1)
    ld hl,0
chdir1
    ld (iy+F_FCLUSTER+0),e
    ld (iy+F_FCLUSTER+1),d
    ld (iy+F_FCLUSTER+2),l
    ld (iy+F_FCLUSTER+3),h
    ld de,0
    ld hl,0
    call SEEK
    ret

; ix>volume vars
; iy>file descriptor
; de>where to load
; a<0 ok, 255 end
; todo: ^^^ zkontrolovat
GET_DIR_ENTRY
    ld bc,32
    call S_READ
    or a
    ret nz
    ldir
    ret

; ; ix>volume vars
; ; iy>file descriptor
; ; hlde<fpos
; GET_FPOS
;     ld e,(iy+F_FPOS+0)
;     ld d,(iy+F_FPOS+1)
;     ld l,(iy+F_FPOS+2)
;     ld h,(iy+F_FPOS+3)
;     ret

; ix>volume vars
; iy>file descriptor
; c<lfn sum
GET_VOL_LABEL

; de>dir entry
MK_LFN_SUM
    ld b,11
    ld c,0  ; sum
mk_lfn_loop
    ; sum>>1 + sum<<7 + entry[b]
    ; sum<<7 = rotate right, and 7bit
    ld a,c
    rrca
    and 0x80
    ; sum>>1
    srl c
    add a,c
    ld c,a
    ld a,(de)
    add a,c
    ld c,a
    inc de
    djnz mk_lfn_loop
    ret



; a>sectors per cluster
; c<shift
CALC_CLUSTER_SHIFT
    ld c,0
1
    cp 1
    ret z
    srl a
    inc c
    jr 1b

; get abs sector number and sector offset
; of FAT record from cluster number
; hlde > cluster number
; ----bc > buffer address ( ? mozna )
; ix > volume vars
; hl < address of FAT record in buffer
GET_FAT_REC
        ; ne -2, ve fat je to od c2
        ; cluster = cluster -2
        ; ld a,2
        ; call SUB_HLDE_A
    ; sector = cluster number * 4 / 512
    ; = cluster number >> 7
    ; store buffer address
    ; push bc
    ; store de for later sector offset calculation
    push de
    ; first, store 7bit of e into carry
    ld a,e
    add a,a
    ; cluster number >> 8
    ld e,d
    ld d,l
    ld l,h
    ld h,0
    ; << 1 with carry from a
    rl e
    rl d
    rl l
    rl h
    ; hlde = cluster * 4 / 512 = cluster >> 7

    ; add abs FAT START
    ld a,(ix+V_FATSTART+0)
    add a,e
    ld e,a
    ld a,(ix+V_FATSTART+1)
    adc a,d
    ld d,a
    ld a,(ix+V_FATSTART+2)
    adc a,l
    ld l,a
    ld a,(ix+V_FATSTART+3)
    adc a,h
    ld h,a

;    push ix
    ; where to load
    ; push bc
    ; pop ix
;    ld ix,buff1
    ; read sector with fat into sector buffer
    ; call SD_READ
    call READSEC
;    pop ix

    pop hl  ; hl = low word of cluster
    add hl,hl   ; *2
    add hl,hl   ; *4
    ld a,h
    and 1
    ld h,a      ; hl = 0-511
    ; hl = cluster offset
    ; pop bc  ; restore buffer address
    ld bc,buff1
    add hl,bc   ; hl = address of FAT record
    ret
; ix>volume vars
    ; iy>file descriptor
; hlde>actual cluster
GET_NEXT_CL
    ld e,(iy+F_ACLUSTER+0)
    ld d,(iy+F_ACLUSTER+1)
    ld l,(iy+F_ACLUSTER+2)
    ld h,(iy+F_ACLUSTER+3)

    call GET_FAT_REC

    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld l,c
    ld h,b

    ret

; ix>volume vars
; iy>file descriptor
; hlde>cluster in file index
; hlde<cluster number
FIND_CL
    exx
    ld e,(iy+F_FCLUSTER+0)
    ld d,(iy+F_FCLUSTER+1)
    ld (tmp32_1),de
    ld l,(iy+F_FCLUSTER+2)
    ld h,(iy+F_FCLUSTER+3)
    ld (tmp32_1+2),hl
    exx
    ld a,e
    or d
    or l
    or h
    jr z,find_cl_first_cl
find_cl_loop
    exx
    ; call GET_NEXT_CL
    call GET_FAT_REC
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld l,c
    ld h,b
    ld (tmp32_1),de
    ld (tmp32_1+2),hl
    exx

    ld a,1
    call SUB_HLDE_A
    ld a,e
    or d
    or l
    or h
    ; ret z
    jr nz,find_cl_loop
    exx
    ret
find_cl_first_cl
    ld de,(tmp32_1)
    ld hl,(tmp32_1+2)
    ret
; hlde>32bit number
; a>8bit number
; hlde<hlde-a
SUB_HLDE_A
    ld c,a

    ld a,e
    sub c
    ld e,a
    ld a,d
    sbc a,0
    ld d,a
    ld a,l
    sbc a,0
    ld l,a
    ld a,h
    sbc a,0
    ld h,a
    ret
    ; ret nc
    ; dec d
    ; ret nz
    ; dec l
    ; ret nz
    ; dec h
    ; ret

; hlde>32bit number
; a>8bit number
; hlde<hlde+a
ADD_HLDE_A
    add a,e
    ld e,a
    ret nc
    inc d
    ret nz
    inc l
    ret nz
    inc h
    ret
; hlde>32bit number
; z/nz< return
; IS_ZERO32
;     ld a,e
;     or d
;     or l
;     or h
;     ret

/*
offset_in_sector = spodních 9 bitů fpos
tmp = fpos >> 9
sector_in_cluster = tmp & spc_mask
cluster_index     = tmp >> spc_shift

cluster_lba = data_start + ((real_cluster - 2) << spc_shift)
sector_lba = cluster_lba + sector_in_cluster
*/

; ix>volume vars
; hlde>fpos
; hlde<cluster index in file
; bc<offset in sector
; a<sector in cluster
FPOS2ADDR
    ; get byte offset in sector
    ld c,e
    ld a,d
    and 1
    ld b,a  ; bc=offset in sector
    push bc
    ; get sector in cluster from fpos
    ; hlde >> 8 >> 1
    ld e,d
    ld d,l
    ld l,h
    ld h,0
    srl h
    rr l
    rr d
    rr e
    ; sector_in_cluster
    ld a,e
    and (ix+V_CLUSTERMSK)
    ld c,a

    ld a,(ix+V_CLUSTERSH)
    or a
    jr z,no_cl_shift
    ld b,a
cl_shift
    srl h
    rr l
    rr d
    rr e
    djnz cl_shift
no_cl_shift
    ld a,c
    pop bc
    ret

; ix>volume vars
; hlde>cluster
; a>sector in cluster
; hlde<lba sector
ADDR2LBA
    push af
    ld a,2
    call SUB_HLDE_A

    ld a,(ix+V_CLUSTERSH)
    or a
    jr z,clcont2
    ld b,a
cl_shift2
    sla e
    rl d
    rl l
    rl h
    djnz cl_shift2

clcont2
    ld a,e
    add a,(ix+V_DATASTART+0)
    ld e,a
    ld a,d
    adc a,(ix+V_DATASTART+1)
    ld d,a
    ld a,l
    adc a,(ix+V_DATASTART+2)
    ld l,a
    ld a,h
    adc a,(ix+V_DATASTART+3)
    ld h,a

    pop af
    ; add sector to cluster
    call ADD_HLDE_A
    ret

; ix>volume vars
; iy>file descriptor
; iy<file descriptor updated F_ACLUSTER
REWIND
    ld de,0
    ld hl,0
; ix>volume vars
; hlde>fpos
; iy>file descriptor
; iy<file descriptor updated F_ACLUSTER
SEEK
    ld (iy+F_FPOS+0),e
    ld (iy+F_FPOS+1),d
    ld (iy+F_FPOS+2),l
    ld (iy+F_FPOS+3),h
    call FPOS2ADDR
    ; hlde=cluster index in file
    ; store new ICLUSTER
    ld (iy+F_ICLUSTER+0),e
    ld (iy+F_ICLUSTER+1),d
    ld (iy+F_ICLUSTER+2),l
    ld (iy+F_ICLUSTER+3),h
    ; find actual cluster
    call FIND_CL
    ld (iy+F_ACLUSTER+0),e
    ld (iy+F_ACLUSTER+1),d
    ld (iy+F_ACLUSTER+2),l
    ld (iy+F_ACLUSTER+3),h
    ret



    
; ix>volume vars
; iy>file descriptor
; de>where to load
; bc>how many bytes to load
S_READ
    push de
    push bc
    ld e,(iy+F_FPOS+0)
    ld d,(iy+F_FPOS+1)
    ld l,(iy+F_FPOS+2)
    ld h,(iy+F_FPOS+3)
;     ; get byte offset in sector
;     ld c,e
;     ld a,d
;     and 1
;     ld b,a  ; bc=offset in sector
;     push bc
;     ; get sector in cluster from fpos
;     ; hlde >> 8 >> 1
;     ld e,d
;     ld d,l
;     ld l,h
;     ld h,0
;     srl h
;     rr l
;     rr d
;     rr e
;     ; sector_in_cluster
;     ld a,e
;     and (ix+V_CLUSTERMSK)
;     ld c,a

;     ld a,(ix+V_CLUSTERSH)
;     or a
;     jr z,no_cl_shift
;     ld b,a
; cl_shift
;     srl h
;     rr l
;     rr d
;     rr e
;     djnz cl_shift
; no_cl_shift
;     ld a,c
    call FPOS2ADDR
    push bc
    push af
    ; pop bc
    ; a = sector in cluster
    ; bc = offset in sector
    ; hlde = cluster index in file
    ; pokud hlde=F_ACLUSTER
    ; pokud ne, zjistit jaky je aktualni cluster,
    ; a nastavit
    ; pokud jiny, najit ve fat
    ld a,e
    cp (iy+F_ICLUSTER+0)
    jr nz,next_cluster
    ld a,d
    cp (iy+F_ICLUSTER+1)
    jr nz,next_cluster
    ld a,l
    cp (iy+F_ICLUSTER+2)
    jr nz,next_cluster
    ld a,h
    cp (iy+F_ICLUSTER+3)
    jr z,same_cluster
next_cluster
    ; ld (iy+F_ICLUSTER+0),e
    ; ld (iy+F_ICLUSTER+1),d
    ; ld (iy+F_ICLUSTER+2),l
    ; ld (iy+F_ICLUSTER+3),h
    push hl
    push de
    call GET_NEXT_CL
    ; check if next cluster is not end of chain 0x0ffffff8
    ld a,0xf8
    cp e
    jr nz,not_end_cl
    ld a,0xff
    cp d
    jr nz,not_end_cl
    cp l
    jr nz,not_end_cl
    ld a,0x0f
    cp h
    ; jr z,end_cl
    jp z,end_cl
not_end_cl
    exx
    pop de
    pop hl
    ld (iy+F_ICLUSTER+0),e
    ld (iy+F_ICLUSTER+1),d
    ld (iy+F_ICLUSTER+2),l
    ld (iy+F_ICLUSTER+3),h
    exx
    ld (iy+F_ACLUSTER+0),e
    ld (iy+F_ACLUSTER+1),d
    ld (iy+F_ACLUSTER+2),l
    ld (iy+F_ACLUSTER+3),h   
    jr clcont
same_cluster
    ld e,(iy+F_ACLUSTER+0)
    ld d,(iy+F_ACLUSTER+1)
    ld l,(iy+F_ACLUSTER+2)
    ld h,(iy+F_ACLUSTER+3)
clcont
;     ld a,2
;     call SUB_HLDE_A

;     ld a,(ix+V_CLUSTERSH)
;     or a
;     jr z,clcont2
;     ld b,a
; cl_shift2
;     sla e
;     rl d
;     rl l
;     rl h
;     djnz cl_shift2

; clcont2
;     ld a,e
;     add a,(ix+V_DATASTART+0)
;     ld e,a
;     ld a,d
;     adc a,(ix+V_DATASTART+1)
;     ld d,a
;     ld a,l
;     adc a,(ix+V_DATASTART+2)
;     ld l,a
;     ld a,h
;     adc a,(ix+V_DATASTART+3)
;     ld h,a

    pop af
;     ; add sector to cluster
;     call ADD_HLDE_A
    CALL ADDR2LBA
    call READSEC
    pop bc

    ld hl,buff1
    add hl,bc

    pop bc  ; bc = how many
    ld a,(iy+F_FPOS+0)
    add a,c
    ld (iy+F_FPOS+0),a

    ld a,(iy+F_FPOS+1)
    adc a,b
    ld (iy+F_FPOS+1),a

    ld a,(iy+F_FPOS+2)
    adc a,0
    ld (iy+F_FPOS+2),a

    ld a,(iy+F_FPOS+3)
    adc a,0
    ld (iy+F_FPOS+3),a   
    pop de  ; where to load
    xor a
    ret
end_cl
    pop de
    pop hl
    pop af
    pop bc
    pop bc
    pop de
    ; ld bc,0
    ld a,0xff   ; EOF
    ret
; iy>file descriptor
; hlde>cluster in file
; CLUSTER_TO_LBA 
;     push hl
;     push de
;     ld a,e
;     or d
;     or l
;     or h
;     ; jr z,
;     pop hl
;     pop de
;     ret

; hlde>sector
; ix>volume vars
READSEC
    ; compare hlde sector with V_SECT_ACT
    ; if same, return
    ld a,e
    cp (ix+V_SEC_ACT+0)
    jr nz,read_continue
    ld a,d
    cp (ix+V_SEC_ACT+1)
    jr nz,read_continue
    ld a,l
    cp (ix+V_SEC_ACT+2)
    jr nz,read_continue
    ld a,h
    cp (ix+V_SEC_ACT+3)
    ret z
read_continue
    push ix
    ld ix,buff1
    call SD_READ
    pop ix
    ret

;--------------------
SD_INIT
    ld b,10

sd_init_loop
    push bc
	call SD_POWER_ON
	call SD_RESET
    cp 1
    jr nz,sd_init_fail
	; resp = 1
	call SD_SEND_IF_COND
	; 0 = OK
    or a
    jr nz,sd_init_fail
	; resp = 0x1AA
	call SD_OCR
    or a
    jr nz,sd_init_fail
    call SD_POWER_ON
    pop bc
    xor a   ; no error
	ret
sd_init_fail
    call SD_POWER_ON
    pop bc
    djnz sd_init_loop
    ld a,0xff   ; cannot initialise
    ret

SD_POWER_ON
; Set DI and CS high and apply 74 or more clock pulses to SCLK.
; The card will enter its native operating mode and go ready to accept native command.
    ld a,0xff
	out (OUT_PORT),a
    ; send 80clocks
	; 10x8bits
	ld b,10
	ld a,0xff
1
	out (SPI_PORT),a
	djnz 1B
	ret

SD_RESET
    ; activate CS for card
    ld a,(CARD_SELECT)
    out (OUT_PORT),a
    ; dummy clock
	ld a,0xff
	out (SPI_PORT),a
	; send CMD_0
	; param =0,0,0,0
	; crc = 0x95
	ld a,CMD_0
	out (SPI_PORT),a
	xor a
	out (SPI_PORT),a
	out (SPI_PORT),a
	out (SPI_PORT),a
	out (SPI_PORT),a
	ld a,0x95
	out (SPI_PORT),a

	call WAIT
	cp 1
    ret z

SD_ERROR
    ld e,a
    call SD_POWER_ON
    ld a,e
    ret


SD_SEND_IF_COND
	ld a,0xff
	out (SPI_PORT),a
	ld a,CMD_8
	out (SPI_PORT),a
	xor a
	out (SPI_PORT),a
	xor a               ; more time for DIVMMC
	out (SPI_PORT),a
	ld a,1
	out (SPI_PORT),a
	ld a,0xaa
	out (SPI_PORT),a
	; CRC for CMD_8
	ld a,0x87
	out (SPI_PORT),a

	call WAIT
    cp 1
    jr nz,SD_ERROR

	; in a,(SPI_PORT) - from WAIT	; R7 (R1+32bit response)
	in a,(SPI_PORT)
    or a
    jr nz,SD_ERROR
	in a,(SPI_PORT)
    or a
    jr nz,SD_ERROR
	in a,(SPI_PORT)
    cp 1
    jr nz,SD_ERROR
	in a,(SPI_PORT)
    cp 0xAA
    jr nz,SD_ERROR
	; if 0x1AA, V2
	; send acmd41
    ld b,200
retry_41
    push bc
	ld a,0xff
	out (SPI_PORT),a
	ld a,CMD_55
	out (SPI_PORT),a
	xor a
	out (SPI_PORT),a
	out (SPI_PORT),a
	out (SPI_PORT),a
	out (SPI_PORT),a
	; "crc" not needed
    ld a,0xff
	out (SPI_PORT),a

	call WAIT
    cp 2
    jr nc,cmd55err ;anything >1 = error

	ld a,0xff
	out (SPI_PORT),a

	; in a,(SPI_PORT)	from wait

	ld a,ACMD41
	out (SPI_PORT),a
	ld a,0b01000000	; HCS / bit 30
	out (SPI_PORT),a
	xor a
	out (SPI_PORT),a
	out (SPI_PORT),a
	out (SPI_PORT),a
	; "crc" not needed
    ld a,0xff
	out (SPI_PORT),a

	call WAIT

	; in a,(SPI_PORT)	; from wait
	; 0 = ok
	; 1 = still in idle
    pop bc
	; cp 1
    or a
    ret z
    djnz retry_41
	; jr z,retry_41
    ld a,0xff   ; timeout
	ret
cmd55err
    pop bc
    jp SD_ERROR

SD_OCR
	ld a,CMD_58
	ld hl,0
	ld de,0
	call SD_SENDCMD
	; a = R1
	ld e,a
    in a,(SPI_PORT)
	in a,(SPI_PORT)
	in a,(SPI_PORT)
	in a,(SPI_PORT)
	; 128 = ready
        ; test SDXC
	ld a,e	; a = R1
	ret

SD_CSD	; get CSD register
	ld a,CMD_9
	jr csd_cid_comm
SD_CID	; get CID register
	; ix = read to address
	ld a,CMD_10
csd_cid_comm	; common for CSD/CID read
	ld hl,0
	ld de,0
	call SD_SENDCMD
	cp 0
	ret nz
    ld e,a  ; store R1
	call WAIT_DATA

	push ix
	pop hl
	ld bc,(256*16)+SPI_PORT ; 16 bytes
	inir
    in a,(SPI_PORT)
	in a,(SPI_PORT)
    ld a,e  ; restore R1
	ret


;-----------------

SD_READ:
	; hlde = sector
	; ix = to address
    ld a,(CARD_SELECT)
	out (OUT_PORT),a
	ld a,0xff
	out (SPI_PORT),a
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

	; IF DMA_SD
	; call dma_read
	; ELSE
	ld bc,SPI_PORT
	inir
	inir
	; ENDIF

	; 2b crc
    nop
	in a,(SPI_PORT)
    nop
	in a,(SPI_PORT)
;----
	ld a,255
	out (OUT_PORT),a
    out (SPI_PORT),a
;----
    ld a,e  ; restore R1
    or a
    ret
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
	ld bc,WAIT_CMD_TIMEOUT
wloop:
	in a,(SPI_PORT)
	cp 0FFh
	ret nz
	dec bc
	ld a,b
	or c
	jr nz,wloop
    ; djnz wloop
    ld a,0xff
	ret

WAIT_DATA:
    ; ld b,0
	ld bc,WAIT_DATA_TIMEOUT
wdata_loop:
	in a,(SPI_PORT)
	cp 0FEh
    ret z
	dec bc
	ld a,b
	or c
	jr nz,wdata_loop
    ; djnz wdata_loop
	; jr WAIT_DATA
    ld a,0xff
	ret

tmp32_1
    dw 0,0

; testfp
;     dw 0,0  ; fpos
;     dw 0,0  ; size
;     dw 2,0  ; first cluster
;     dw 2,0  ; actual cluster
;     dw 0,0  ; cluster index in file
; testfpx
;     dw 0,0  ; fpos
;     dw 0,0  ; size
;     dw 0x103c,0x0000  ; first cluster
;     dw 0x103c,0x0000  ; actual cluster
;     dw 0,0  ; cluster index in file
DRV_CSL
    db SD_0
    db SD_1
CARD_SELECT
    db SD_0

VOLUMES
volume1
    ds 32*8
buff1
    ds 512

    ; SAVETAP "fat32drv.tap",start
    ; END

