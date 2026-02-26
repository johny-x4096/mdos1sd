    DEVICE ZXSPECTRUM48
    ORG 0
RST00                         
    NOP                                                 
    JR          START1                                  
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
RST08                         
    LD          HL,(CH_ADD)                             
    JP          SYNTAX1                                 
    db          0FFh                                     
    db          0FFh                                     
RST10                         
    RST         RST28                                   
    dw          10h                                     
    RET                                                 
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
RST18                         
    RST         RST28                                   
    dw          18h                                     
    RET                                                 
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
RST20                         
    RST         RST28                                   
    dw          20h                                     
    RET                                                 
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
;undefined RST28()
RST28
    JP          CALLZX1                                 
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
RST30                         
    BIT         0x7,(IY+0x1)                            
    RET                                                 
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
MASK_INT                      
    JP          INTERRUPT                               
                            ;undefined CALLZX1()
          ;local_res0    undefined2           0                      ;             ;ram:0044(*),ram:004d(*)
          ;local_2       undefined2          -2                      ;             ;ram:0057(*)
CALLZX1
    PUSH        AF                                      
    LD          A,(SNAPINF)                             
    AND         A                                       
    JP          NZ,SNAPRET                              
    POP         AF                                      
    ; EX          (SP=>local_res0),HL
    EX (SP),HL
    LD          (SAVE_DE),DE                            
    LD          E,(HL)                                  
    INC         HL                                      
    LD          D,(HL)                                  
    INC         HL                                      
    ; EX          (SP=>local_res0),HL
    EX (SP),HL
    PUSH        HL                                      
    ; LD          HL,0x3ef7
    LD HL,SYSFLAG
    ; LD          (HL=>SYSFLAG),0x4f
    LD (HL),0x4f
    LD          HL,0x0                                  
    ; EX          (SP=>local_2),HL
    EX (SP),HL
    PUSH        DE                                      
    LD          DE,(SAVE_DE)                            
    JP          STANDROM                                
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
NMI                           
    JP          (IX)                                    
START1                        
    EX          (SP),HL                                 
    PUSH        BC                                      
    PUSH        AF                                      
    LD          A,I                                     
    DI                                                  
    PUSH        AF                                      
    POP         BC                                      
    LD          (IREG2),BC                              
    PUSH        HL                                      
    ; LD          HL,0x3eef
    LD HL,SYSMRK
    LD          B,0x8                                   
CHCOLD                        
    LD          A,H                                     
    XOR         L                                       
    ; CP          (HL=>SYSMRK)
    CP (HL)
    JR          NZ,COLD                                 
    INC         HL                                      
    DJNZ        CHCOLD                                  
    ; LD          A,(HL=>DAT_ram_3ef1)
    LD A,(HL)
    ; LD          (HL=>DAT_ram_3ef1),0x20
    LD (HL),0x20
    CP          0x4f                                    
    JP          Z,ROMRET                                
    CP          0x45                                    
    JP          Z,ERRCOD                                
    POP         HL                                      
    LD          A,(HL)                                  
    CP          '*'                                     
    JP          Z,SPECCOMM                              
    PUSH        DE                                      
    LD          B,H                                     
    LD          C,L                                     
    ; LD          HL,0x19a   
    LD HL,IORTAB                             
TESTROUT                      
    ; LD          E,(HL=>IORTAB)
    LD E,(HL)
    INC         HL                                      
    ; LD          D,(HL=>IORTAB+1)
    LD D,(HL)
    INC         HL                                      
    EX          DE,HL                                   
    LD          A,H                                     
    OR          L                                       
    JR          Z,COLD                                  
    SBC         HL,BC                                   
    EX          DE,HL                                   
    ; LD          E,(HL=>WORD_ram_019c)                   
    LD E,(HL)
    INC         HL                                      
    ; LD          D,(HL=>WORD_ram_019c+1)                 
    LD D,(HL)
    INC         HL                                      
    JR          NZ,TESTROUT                             
    EX          DE,HL                                   
    POP         DE                                      
    POP         AF                                      
    POP         BC                                      
    EX          (SP),HL                                 
    RET                                                 
COLD                          
    LD          HL,0x0                                  
    LD          DE,0x3800                               
    LD          BC,0x800                                
    LDIR                                                
    LD          HL,0x0                                  
    LD          DE,0x3800                               
    LD          BC,0x800                                
RAMTEST                       
    LD          A,(DE)                                  
    INC         DE                                      
    CPI                                                 
    JR          NZ,RAMERR                               
    JP          PE,RAMTEST                              
    LD          HL,0x3800                               
    LD          D,H                                     
    LD          E,L                                     
    INC         DE                                      
    LD          BC,0x800                                
    LD          (HL),0x0                                
    LDIR                                                
    LD          HL,0x3eef                               
    LD          B,0x8                                   
SETMRK                        
    LD          A,H                                     
    XOR         L                                       
    LD          (HL),A                                  
    INC         HL                                      
    DJNZ        SETMRK                                  
    LD          (HL),0x20                               
    LD          A,0x7f                                  
    IN          A,(0xfe)                                
    RRA                                                 
    JR          C,NODEB                                 
    RRA                                                 
    JR          NC,NODEB                                
    RRA                                                 
    JR          C,NODEB                                 
    RRA                                                 
    JR          NC,NODEB                                
    RRA                                                 
    JR          C,NODEB                                 
    LD          (DEBUG),A                               
NODEB                         
    LD          DE,0x3e00                               
    LD          HL,0xef8                                
    LD          BC,0x18                                 
    LDIR                                                
    LD          A,'A'                                   
    LD          (ACDRIVE),A                             
    LD          HL,0x5800                               
    LD          DE,0x5801                               
    LD          BC,0x300                                
    LD          (HL),0x12                               
    LDIR                                                
    LD          A,0x2                                   
    OUT         (0xfe),A                                
    LD          SP,0x4000                               
    CALL        HWINIT                                  
    DI                                                  
    LD          SP,0x1019                               
    JP          STANDROM                                
RAMERR                        
    XOR         A                                       
CYCLE                         
    DEC         A                                       
    OUT         (0xfe),A                                
    EX          (SP),HL                                 
    EX          (SP),HL                                 
    JR          NZ,CYCLE                                
    JP          RST00                                   
ROMRET                        
    POP         HL                                      
    POP         AF                                      
    POP         BC                                      
    EX          (SP),HL                                 
    EI                                                  
    RET                                                 
ERRCOD                        
    POP         HL                                      
    POP         AF                                      
    POP         BC                                      
    EX          (SP),HL                                 
    EI                                                  
    HALT                                                
    RES         0x5,(IY+0x1)                            
    BIT         0x1,(IY+0x30)                           
    JR          Z,NOCOPYBUF                             
    RST         RST28                                   
    dw          0ECDh                                    
NOCOPYBUF                     
    LD          A,(ERR_NR)                              
    INC         A                                       
    PUSH        AF                                      
    LD          HL,0x0                                  
    LD          (IY+0x37),H                             
    LD          (IY+0x26),H                             
    LD          (DEFADD),HL                             
    INC         HL                                      
    LD          (STRMS6),HL                             
    RST         RST28                                   
    dw          16B0h                                   
    RES         0x5,(IY+0x37)                           
    RST         RST28                                   
    dw          0D6Eh                                    
    SET         0x5,(IY+0x2)                            
    CALL        ERAVAR                                  
    POP         AF                                      
    CP          0x1c                                    
    JR          NC,ERRMDOS                              
    LD          HL,0x1335                               
HLROMRET                      
    PUSH        HL                                      
    JP          STANDROM                                
ERRMDOS                       
    LD          B,A                                     
    ADD         A,0x7                                   
    RST         RST28                                   
    dw          15EFh                                   
    LD          A,0x20                                  
    RST         RST10                                   
    LD          A,B                                     
    LD          DE,0x3af                                
    CALL        PRTMES                                  
    LD          HL,0x1349                               
    JR          HLROMRET                                
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
    dw          067h                                     
    dw          02E7h                                    
    dw          0h                                      
SPECCOMM                      
    INC         HL                                      
    LD          A,(HL)                                  
    CP          '='                                     
    JP          NZ,COLD                                 
    INC         HL                                      
    LD          A,(HL)                                  
    INC         HL                                      
    POP         BC                                      
    POP         BC                                      
    EX          (SP),HL                                 
    EI                                                  
    OUT         (DAT_io_00fe),A                         
    LD          C,L                                     
    LD          B,H                                     
    CALL        BCPRT                                   
    JP          STANDROM                                
;undefined PRTMES()
PRTMES
    EX          DE,HL                                   
    INC         A                                       
    INC         A                                       
SETMESS                       
    DEC         A                                       
    JR          Z,PMESSAGE                              
SETNMESS                      
    BIT         0x7,(HL)                                
    INC         HL                                      
    JR          Z,SETNMESS                              
    JR          SETMESS                                 
PMESSAGE                      
    LD          A,(HL)                                  
    PUSH        HL                                      
    RES         0x7,A                                   
    CP          0x23                                    
    ; LD          HL,0x3e80
    LD HL,DNZONE1                              
    JR          Z,PRNAME                                
    CP          0x40                                    
    LD          HL,0x3e8a                               
    JR          Z,PRNAME                                
    POP         HL                                      
    RST         RST28                                   
    dw          0C3Bh                                    
    BIT         0x7,(HL)                                
    RET         NZ                                      
PNEXTCH                       
    INC         HL                                      
    JR          PMESSAGE                                
PRNAME                        
    PUSH        BC                                      
    LD          B,0xa                                   
PRNAMEL                       
    ; LD          A,(HL=>FNZONE1)
    LD A,(HL)
    AND         A                                       
    JR          Z,STOPPRNM                              
    INC         HL                                      
    PUSH        BC                                      
    RST         RST28                                   
    dw          0C3Bh                                    
    POP         BC                                      
    DJNZ        PRNAMEL                                 
STOPPRNM                      
    POP         BC                                      
    POP         HL                                      
    JR          PNEXTCH                                 
ERRR                          
    PUSH        AF                                      
    LD          A,(SNAPINF)                             
    AND         A                                       
    JP          NZ,SNAPRET                              
    POP         AF                                      
    ; LD          HL,0x5c3a  
    LD HL,ERR_NR                             
    ; LD          (HL=>ERR_NR),A                          
    LD (HL),a
    PUSH        HL                                      
    LD          HL,(CH_ADD)                             
SYNTAX1                       
    POP         BC                                      
    LD          A,(SNAPINF)                             
    AND         A                                       
    JP          NZ,SNAPRET                              
    LD          A,(DEBUG)                               
    AND         A                                       
    JR          Z,COMMAND                               
    PUSH        BC                                      
    LD          HL,(STKEND)                             
    LD          DE,0xa                                  
    ADD         HL,DE                                   
    LD          (STKEND),HL                             
    LD          A,0x2                                   
    RST         RST28                                   
    dw          1601h                                   
    POP         BC                                      
    PUSH        BC                                      
    CALL        BCPRT                                   
    LD          A,' '                                   
LAB_ram_023a                  
    RST         RST10                                   
LAB_ram_023b                  
    LD          BC,(T_ADDR)                             
    CALL        BCPRT                                   
    LD          A,0x20                                  
    RST         RST10                                   
    LD          HL,0x0                                  
    ADD         HL,SP                                   
    LD          DE,(ERR_SP)                             
    DEC         DE                                      
    DEC         DE                                      
    EX          DE,HL                                   
    AND         A                                       
    SBC         HL,DE                                   
    LD          B,H                                     
    LD          C,L                                     
    CALL        BCPRT                                   
    LD          A,0xd                                   
    RST         RST10                                   
    LD          HL,(STKEND)                             
    LD          BC,0xfff6                               
    ADD         HL,BC                                   
    LD          (STKEND),HL                             
    POP         BC                                      
COMMAND                       
    ; LD          IX,0x5ff
    LD IX,SYNTAB
SETCOMM                       
    ; LD          L,(IX+0x0)=>SYNTAB                      
    LD L,(IX+0)
    ; LD          H,(IX+0x1)=>SYNTAB+1                    
    LD H,(IX+1)
    LD          A,H                                     
    OR          L                                       
    JR          Z,NOCOM                                 
    LD          DE,(T_ADDR)                             
    SBC         HL,DE                                   
    JR          NZ,NEXTCOM                              
    ; LD          L,(IX+0x2)=>WORD_ram_0601               
    LD L,(IX+2)
    ; LD          H,(IX+0x3)=>WORD_ram_0601+1             
    LD H,(IX+3)
    SBC         HL,BC                                   
    JR          NZ,NEXTCOM                              
    LD          HL,0x0                                  
    ADD         HL,SP                                   
    LD          DE,(ERR_SP)                             
    EX          DE,HL                                   
    AND         A                                       
    SBC         HL,DE                                   
    ; LD          E,(IX+0x4)=>WORD_ram_0603               
    LD E,(IX+4)
    ; LD          D,(IX+0x5)=>WORD_ram_0603+1             
    LD D,(IX+5)
    SBC         HL,DE                                   
    JR          Z,DOCOM                                 
NEXTCOM                       
    LD          DE,0x8                                  
    ADD         IX,DE                                   
    JR          SETCOMM                                 
NOCOM                         
    PUSH        BC                                      
    LD          HL,0xb                                  
    PUSH        HL                                      
    LD          HL,(ERR_SP)                             
    LD          E,(HL)                                  
    INC         HL                                      
    LD          D,(HL)                                  
    EX          DE,HL                                   
    LD          BC,0x1303                               
    AND         A                                       
    SBC         HL,BC                                   
    JR          NZ,ERROR                                
    EX          DE,HL                                   
    LD          (HL),0x0                                
    DEC         HL                                      
    LD          (HL),0x0                                
    ; LD          HL,0x3ef7
    LD HL,SYSFLAG
    ; LD          (HL=>SYSFLAG),0x45                      
    LD (HL),0x45
ERROR                         
    CALL        DSKSTP                                  
    LD          HL,(CH_ADD)                             
    JP          STANDROM                                
DOCOM                         
    LD          SP,(ERR_SP)                             
    LD          HL,0x1b76                               
    PUSH        HL                                      
    LD          HL,0x2e1                                
    PUSH        HL                                      
    LD          (T_ADDR),HL                             
    ; LD          L,(IX+offset WORD_ram_0605 >>8)         
    LD L,(IX+6)
    ; LD          H,(IX+0x7)=>WORD_ram_0605+1             
    LD H,(IX+7)
    ; JP          (HL=>CATFN)                             
    JP (HL)
RETURN                        
    CALL        DSKSTP                                  
    JP          STANDROM                                
SNAPR                         
    LD          (SAVE_SP),SP                            
    ; LD          SP,0x3ffe
    LD SP,SNAP_SP
    ; PUSH        AF=>DAT_ram_3ffc
    PUSH AF
    ; PUSH        BC=>DAT_ram_3ffa
    PUSH BC
    ; PUSH        DE=>DAT_ram_3ff8
    PUSH DE
    ; PUSH        HL=>DAT_ram_3ff6
    PUSH HL
    EXX                                                 
    ; EX          AF,AF_
    EX AF,AF'
    ; PUSH        AF=>DAT_ram_3ff4
    PUSH AF
    ; PUSH        BC=>DAT_ram_3ff2
    PUSH BC
    ; PUSH        DE=>DAT_ram_3ff0
    PUSH DE
    ; PUSH        HL=>DAT_ram_3fee
    PUSH HL
    ; PUSH        IX=>DAT_ram_3fec
    PUSH IX
    ; PUSH        IY=>DAT_ram_3fea
    PUSH IY
    LD          BC,(IREG2)                              
    ; PUSH        BC=>SVREG
    PUSH BC
    IM          1                                       
    LD          A,0xff                                  
    LD          (SNAPINF),A                             
    ; LD          HL,0x3eaa
    LD HL,ACDRIVE                          
    ; LD          DE,0x3e80   
    LD DE,DNZONE1
    LD          BC,0xa                                  
    LDIR                                                
    LD          HL,0x3a4                                
    LD          DE,0x3e8a                               
    LD          BC,0xb                                  
    LDIR                                                
    LD          A,(SNPCOUNT)                            
    INC         A                                       
    LD          (SNPCOUNT),A                            
    DEC         A                                       
    LD          B,0x0                                   
DECLOP                        
    SUB         0xa                                     
    JR          C,DECOK                                 
    INC         B                                       
    JR          DECLOP                                  
DECOK                         
    ADD         A,0x3a                                  
    LD          (SNONMB2),A                             
    LD          A,B                                     
    ADD         A,0x30                                  
    LD          (SNONMB1),A                             
    EI                                                  
    LD          HL,0x3f80                               
    LD          (STARTADR),HL                           
    LD          DE,0xc080                               
    CALL        SAVRUN                                  
    CALL        DSKSTP                                  
SNAPRET                       
    CALL        DSKSTP                                  
    DI                                                  
    LD          SP,0x3fe8                               
    XOR         A                                       
    LD          (SNAPINF),A                             
    ; POP         AF=>SVREG                               
    POP AF
    JP          PE,SNPRT1                               
    LD          I,A                                     
    CP          0x3f                                    
    JR          Z,NOIM2                                 
    IM          2                                       
NOIM2                         
    ; POP         IY=>DAT_ram_3fea                        
    POP IY
    ; POP         IX=>DAT_ram_3fec                        
    POP IX
    ; POP         HL=>DAT_ram_3fee                        
    POP HL
    ; POP         DE=>DAT_ram_3ff0                        
    POP DE
    ; POP         BC=>DAT_ram_3ff2                        
    POP BC
    ; POP         AF=>DAT_ram_3ff4                        
    POP AF
    ; EX          AF,AF_
    EX AF,AF'
    EXX                                                 
    ; POP         HL=>DAT_ram_3ff6                        
    POP HL
    ; POP         DE=>DAT_ram_3ff8                        
    POP DE
    ; POP         BC=>DAT_ram_3ffa                        
    POP BC
    ; POP         AF=>DAT_ram_3ffc                        
    POP AF
    LD          SP,(SAVE_SP)                            
    JP          STANDROM                                
SNPRT1                        
    LD          I,A                                     
    CP          0x3f                                    
    JR          Z,NOIM21                                
    IM          2                                       
NOIM21                        
    ; POP         IY=>DAT_ram_3fea                        
    POP IY
    ; POP         IX=>DAT_ram_3fec                        
    POP IX
    ; POP         HL=>DAT_ram_3fee                        
    POP HL
    ; POP         DE=>DAT_ram_3ff0                        
    POP DE
    ; POP         BC=>DAT_ram_3ff2                        
    POP BC
    ; POP         AF=>DAT_ram_3ff4                        
    POP AF
    ; EX          AF,AF_
    EX AF,AF'
    EXX                                                 
    ; POP         HL=>DAT_ram_3ff6                        
    POP HL
    ; POP         DE=>DAT_ram_3ff8                        
    POP DE
    ; POP         BC=>DAT_ram_3ffa                        
    POP BC
    ; POP         AF=>DAT_ram_3ffc                        
    POP AF
    LD          SP,(SAVE_SP)                            
    EI                                                  
    JP          STANDROM                                
SNPLOA                        
    LD          SP,0x3f80                               
    LD          IX,0x3f80                               
    LD          DE,0xc080                               
    CALL        LOADBLOCK                               
    JP          SNAPRET                                 
SNAMNM                        
    db          "SNAPSHOT00S"                           
SYSMSG                        
    ; ds          AAh,AAh,AAh,AAh,AAh,AAh,AAh,AAh,AAh,A...
    ; 28 "*"+128
    db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
    db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
    db 0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH,0AAH
    db 0AAH,0AAH,0AAH,0AAH
    db 0AAH
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
    CP          '#'                                     
    JR          Z,HASHOK                                
REPORTC                       
    LD          A,0xb                                   
    JP          ERRR                                    
HASHOK                        
    RST         RST20                                   
    RST         RST28                                   
    dw          1C82h                                   
    RST         RST18                                   
    CP          ','                                     
    JR          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C82h                                   
    CALL        ISSYNCONTR                              
    RST         RST28                                   
    dw          1E85h                                   
    PUSH        AF                                      
    LD          A,B                                     
    CP          0x2                                     
    JR          C,NOOUT                                 
    LD          A,0xa                                   
    JP          ERRR                                    
NOOUT                         
    POP         AF                                      
    LD          HL,0x3e00                               
    ADD         HL,BC                                   
    ; LD          (HL),A=>DRPARZN                         
    LD (HL),A
    RET                                                 
LETFNATTR                     
    RST         RST18                                   
    CP          0xab                                    
    LD          HL,0x723                                
    JR          Z,SELLLET                               
    CP          0xa8                                    
    LD          HL,0x778                                
    JR          Z,SELLLET                               
GOREPC                        
    JP          REPORTC                                 
SELLLET                       
    LD          (VALSYX),HL                             
    RST         RST20                                   
    CP          0x28                                    
    JR          NZ,GOREPC                               
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
    RST         RST18                                   
    CP          ')'                                     
    JR          NZ,GOREPC                               
    RST         RST20                                   
    CP          '='                                     
    JR          NZ,GOREPC                               
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
    CALL        ISSYNCONTR                              
    LD          HL,(VALSYX)                             
    ; JP          (HL=>LETFN)                             
    JP (HL)
LETATTR                       
    RST         RST28                                   
    dw          2BF1h                                   
    LD          A,B                                     
    AND         A                                       
    JR          NZ,REPORTA                              
    LD          B,C                                     
    LD          C,0x0                                   
    LD          A,B                                     
    AND         A                                       
    JR          Z,ATRNAME                               
ANALATR                       
    ; LD          HL,0x127b                               
    LD HL,DEFATTR
    LD          A,(DE)                                  
    AND         0xdf                                    
    INC         DE                                      
    PUSH        DE                                      
    LD          E,0x80                                  
RFINDATR                      
    ; CP          (HL=>DEFATTR)                           
    CP (HL)
    INC         HL                                      
    JR          Z,SETATR                                
    RRC         E                                       
    JR          NC,RFINDATR                             
REPORTA                       
    LD          A,0x9                                   
    JP          ERRR                                    
SETATR                        
    LD          A,C                                     
    OR          E                                       
    LD          C,A                                     
    POP         DE                                      
    DJNZ        ANALATR                                 
ATRNAME                       
    ; EX          AF,AF_
    EX AF,AF'
    CALL        DIVSTRING                               
    CALL        TESTNM                                  
    CALL        ARRANGNM                                
    CALL        SETWDNM                                 
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JP          NZ,REPORTS                              
WATTR                         
    ; EX          AF,AF_
    EX AF,AF'
    PUSH        HL                                      
    EX          (SP),IX                                 
    ; LD          (IX+0x14)=>LAB_ram_1291,A               
    LD (IX+0x14),A
    EX          (SP),IX                                 
    POP         HL                                      
    CALL        WSCADR                                  
    ; EX          AF,AF_                                  
    EX AF,AF'
    CALL        NEXTMASK                                
    RET         NZ                                      
    JR          WATTR                                   
LETFN                         
    CALL        ANSTRING                                
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JR          NZ,NOEXIST                              
    LD          A,0x1c                                  
    JP          ERRR                                    
NOEXIST                       
    LD          HL,0x3e80                               
    LD          DE,0x3e95                               
    LD          BC,0x15                                 
    LDIR                                                
    CALL        ANSTRING                                
    ; LD          HL,0x3e94                               
    LD HL,EXTE1
    LD          A,(EXTE2)                               
    ; CP          (HL=>EXTE1)                             
    CP (HL)
    JR          Z,EXTISSOME                             
REPORTJ                       
    LD          A,0x32                                  
    JP          ERRR                                    
EXTISSOME                     
    LD          HL,0x3e80                               
    LD          DE,0x3e95                               
    LD          BC,0xa                                  
    CALL        VERIFY                                  
    JR          NZ,REPORTJ                              
    CALL        FIRSTMASK                               
    JP          NZ,REPORTS                              
    INC         HL                                      
    LD          DE,0x3e9f                               
    LD          BC,0xa                                  
    EX          DE,HL                                   
    LDIR                                                
    CALL        WSCADR                                  
    CALL        ERAVAR                                  
    RET                                                 
ANSTRING                      
    CALL        DIVSTRING                               
    CALL        SETWDNM                                 
    CALL        ANALWDNM                                
    INC         A                                       
    JP          Z,REPORTX                               
    CALL        ARRANGNM                                
    JP          C,REPORTF                               
    LD          A,(EXTE1)                               
    CP          '?'                                     
    JP          Z,REPORTF                               
    RET                                                 
L_PRINT                       
    RST         RST18                                   
    CP          0x2a                                    
    JP          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
    CALL        ISSYNCONTR                              
    CALL        DIVSTRING                               
    CALL        SETWDNM                                 
    CALL        ANALWDNM                                
    INC         A                                       
    JP          Z,REPORTX                               
    CALL        ARRANGNM                                
    JP          C,REPORTF                               
    JR          Z,LPSETEXT                              
    LD          A,(EXTE1)                               
    CP          'Q'                                     
    JP          NZ,REPORTF                              
LPSETEXT                      
    LD          A,'Q'                                   
    LD          (EXTE1),A                               
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JP          NZ,REPORTS                              
    CALL        GETATR                                  
    BIT         0x3,A                                   
    JP          Z,REPORTE                               
    LD          A,0x11                                  
    CALL        ADDHLA                                  
    LD          E,(HL)                                  
    INC         HL                                      
    LD          D,(HL)                                  
    EX          DE,HL                                   
PRINTSEC                      
    CALL        GETWTEST                                
    LD          A,D                                     
    CP          0xc                                     
    RET         Z                                       
    LD          (VALSYX),DE                             
    CALL        LOGFYZ                                  
    LD          DE,0x101                                
    LD          HL,0x3a00                               
    CALL        BREADA                                  
    LD          DE,(VALSYX)                             
    LD          A,D                                     
    CP          0xe                                     
    JR          C,PRINTALL                              
    AND         0x1                                     
    LD          D,A                                     
    OR          E                                       
    JR          NZ,PRINTBUFF                            
PRINTALL                      
    LD          DE,0x200                                
PRINTBUFF                     
    ; LD          HL,0x3a00                               
    LD HL,AUXBUF
PRNTLOOP                      
    PUSH        DE                                      
    PUSH        HL                                      
    ; LD          A,(HL=>AUXBUF)                          
    LD A,(HL)
    RST         RST10                                   
    POP         HL                                      
    POP         DE                                      
    INC         HL                                      
    DEC         DE                                      
    LD          A,D                                     
    OR          E                                       
    JR          NZ,PRNTLOOP                             
    LD          HL,(VALSYX)                             
    LD          A,H                                     
    CP          0xe                                     
    RET         NC                                      
    JR          PRINTSEC                                
L_LIST                        
    RST         RST18                                   
    CP          0x2a                                    
    JP          NZ,REPORTC                              
    RST         RST20                                   
    CALL        ISSYNCONTR                              
    LD          A,0xd                                   
    RST         RST10                                   
    XOR         A                                       
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          A,0x1                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          A,0x41                                  
    ; LD          IX,0x3e00                               
    LD IX,DRPARZN
RINFO2                        
    PUSH        IX                                      
    PUSH        AF                                      
    ; LD          A,(IX+0x2)=>DAT_ram_3e02                
    LD A,(IX+2)
    AND         A                                       
    JR          Z,RINFO1                                
    POP         AF                                      
    PUSH        AF                                      
    RST         RST10                                   
    LD          A,0x2                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
RINFO1                        
    POP         AF                                      
    POP         IX                                      
    LD          DE,0xc                                  
    ADD         IX,DE                                   
    INC         A                                       
    CP          0x45                                    
    JR          C,RINFO2                                
    LD          A,0x3                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          A,0x41                                  
    ; LD          IX,0x3e00                               
    LD IX,DRPARZN
RINFO4                        
    PUSH        IX                                      
    PUSH        AF                                      
    ; BIT         0x0,(IX+0x0)=>DRPARZN                   
    BIT 0,(IX+0)
    JR          Z,RINFO3                                
    POP         AF                                      
    PUSH        AF                                      
    RST         RST10                                   
    LD          A,0x2                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
RINFO3                        
    POP         AF                                      
    POP         IX                                      
    LD          DE,0xc                                  
    ADD         IX,DE                                   
    INC         A                                       
    CP          0x45                                    
    JR          C,RINFO4                                
    LD          A,0x4                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          HL,0x3eaa                               
    CALL        PTRSTR                                  
    LD          A,0x5                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    CALL        INITALLDR                               
    LD          B,0x4                                   
    ; LD          HL,0x3e30                               
    LD HL,DRNAMES
RINFO5                        
    PUSH        BC                                      
    PUSH        HL                                      
    ; LD          A,(HL=>DRNAMES)                         
    LD A,(HL)
    AND         A                                       
    JR          Z,RINFO6                                
    LD          A,0x20                                  
    RST         RST10                                   
    LD          A,0x20                                  
    RST         RST10                                   
    POP         HL                                      
    PUSH        HL                                      
    CALL        PTRSTR                                  
    LD          A,0xd                                   
    RST         RST10                                   
RINFO6                        
    POP         HL                                      
    POP         BC                                      
    LD          A,0xc                                   
    CALL        ADDHLA                                  
    DJNZ        RINFO5                                  
    LD          A,0x6                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          HL,(VARS)                               
    PUSH        HL                                      
    LD          DE,(PROG)                               
    AND         A                                       
    SBC         HL,DE                                   
    LD          C,L                                     
    LD          B,H                                     
    CALL        BCPRT                                   
    LD          A,0x7                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          HL,(E_LINE)                             
    POP         DE                                      
    AND         A                                       
    SBC         HL,DE                                   
    LD          C,L                                     
    LD          B,H                                     
    CALL        BCPRT                                   
    LD          A,0x8                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    LD          BC,(RAMTOP)                             
    CALL        BCPRT                                   
    LD          A,0x9                                   
    LD          DE,0x971                                
    CALL        PRTMES                                  
    RST         RST28                                   
    dw          1F1Ah                                   
    LD          HL,0xffff                               
    AND         A                                       
    SBC         HL,BC                                   
    LD          C,L                                     
    LD          B,H                                     
    CALL        BCPRT                                   
    LD          A,0xd                                   
    RST         RST10                                   
    RET                                                 
INFMES                        
    db          80h                                     
    db          "MDOS Release: 1.0 (01-Sep-92)\r"       
    ; db          "(C) Didaktik Skalica 1992\r",08Dh
    db "(C) Didaktik Skalica 1992",0Dh,08Dh
    ; db          "Drives Defined  :",0A0h,":,",0A0h,"\b\...
    db "Drives Defined  :"," "+080h
    db ":,"," "+80h
    ; db          "Drives Installed:",0A0h,"\b\b \r"
    db 8,8,32,0Dh
    db "Drives Installed:",0A0h
    db 8,8,32,0Dh
    ; db          "Current Device  :",0A0h,":\r\r"
    db "Current Device  :",0A0h
    db ":",0Dh,0Dh
    ; db          "Volumes Available:",08Dh,"\r"
    db "Volumes Available:",08Dh
    db 0Dh
    ; db          "Length of Program  :",0A0h,"\r"
    db "Length of Program  :",0A0h
    db 0Dh
    ; db          "Length of Variables:",0A0h,"\r\r"
    db "Length of Variables:",0A0h
    db 0Dh,0Dh
    ; db          "Top of RAM :",0A0h,"\r"
    db "Top of RAM :",0A0h
    db 0Dh
    db          "Free memory:",0A0h                      
RESTORE                       
    LD          HL,0x2296                               
    JR          RRPRG                                   
READ                          
    LD          HL,0x22a5                               
RRPRG                         
    LD          (VALSYX),HL                             
    RST         RST18                                   
    CP          0x2a                                    
JMPREPC                       
    JP          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
    LD          B,0x2                                   
RRPRGPAR                      
    PUSH        BC                                      
    RST         RST18                                   
    CP          0x2c                                    
    JR          NZ,JMPREPC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C82h                                   
    POP         BC                                      
    DJNZ        RRPRGPAR                                
    CALL        ISSYNCONTR                              
    RST         RST28                                   
    dw          1E99h                                   
    LD          (VALSYY),BC                             
    RST         RST28                                   
    dw          1E99h                                   
    PUSH        BC                                      
    CALL        DIVSTRING                               
    CALL        SETWDNM                                 
    CALL        SETACT                                  
    LD          A,(FNZONE1)                             
    AND         A                                       
    JR          Z,RRINDISK                              
    CALL        ARRANGNM                                
    JP          C,REPORTF                               
    CALL        FIRSTMASK                               
    JP          NZ,REPORTS                              
    LD          A,0x11                                  
    CALL        ADDHLA                                  
    ; LD          A,(HL=>BWRITE)                          
    LD A,(HL)
    INC         HL                                      
    ; LD          H=>LAB_ram_2297,(HL)                    
    LD H,(HL)
    LD          L,A                                     
    POP         BC                                      
RRFINDSC                      
    LD          A,B                                     
    OR          C                                       
    JR          Z,RRFINDOK                              
    DEC         BC                                      
    CALL        GETWTEST                                
    EX          DE,HL                                   
    BIT         0x3,H                                   
    JR          Z,RRFINDSC                              
    LD          A,0x31                                  
    JP          ERRR                                    
RRINDISK                      
    POP         HL                                      
RRFINDOK                      
    CALL        LOGFYZ                                  
    LD          DE,0x100                                
    CALL        ERAVAR                                  
    LD          A,(WORKDR)                              
    LD          HL,(VALSYX)                             
    PUSH        HL                                      
    LD          HL,(VALSYY)                             
    RET                                                 
OPENINPUT                     
    LD          HL,(STKEND)                             
    LD          DE,0xa                                  
    ADD         HL,DE                                   
    LD          (STKEND),HL                             
    RST         RST28                                   
    dw          171Eh                                   
    LD          (VALSYX),HL                             
    LD          A,B                                     
    OR          C                                       
    JR          Z,STRNOOPEN                             
    LD          A,B                                     
    AND         A                                       
    JR          NZ,REPORTM                              
    LD          A,C                                     
    CP          0x11                                    
    JR          C,STRNOOPEN                             
REPORTM                       
    LD          A,0x35                                  
    JP          ERRR                                    
STRNOOPEN                     
    CALL        ANAOPENNM                               
    PUSH        IX                                      
    CALL        SETSTRNM                                
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JP          NZ,REPORTS                              
    CALL        GETATR                                  
    BIT         0x3,A                                   
    JP          Z,REPORTE                               
    PUSH        HL                                      
    CALL        MAKE544B                                
    PUSH        HL                                      
    CALL        SETSTRBUF                               
    POP         HL                                      
    LD          (VALSYY),HL                             
    LD          DE,0x15c4                               
    CALL        LD_HL_DE                                
    LD          DE,0x22c2                               
    CALL        LD_HL_DE                                
    LD          A,0xeb                                  
    CALL        LD_HL_A                                 
MAKEHBUF                      
    LD          A,(WORKDR)                              
    CALL        LD_HL_A                                 
    EX          DE,HL                                   
    PUSH        IX                                      
    POP         HL                                      
    LD          A,0x30                                  
    CALL        ADDHLA                                  
    LD          BC,0xc                                  
    LDIR                                                
    EX          DE,HL                                   
    LD          DE,(ADRSCTR)                            
    CALL        LD_HL_DE                                
    POP         DE                                      
    PUSH        DE                                      
    CALL        LD_HL_DE                                
    EX          (SP),IX                                 
    LD          A,(IX+0xb)                              
    CALL        LD_HL_A                                 
    LD          A,(IX+0xc)                              
    CALL        LD_HL_A                                 
    LD          A,(IX+0x15)                             
    CALL        LD_HL_A                                 
    LD          E,(IX+0x11)                             
    LD          D,(IX+0x12)                             
    CALL        LD_HL_DE                                
    POP         IX                                      
    LD          DE,0x0                                  
    CALL        LD_HL_DE                                
    LD          E,L                                     
    LD          D,H                                     
    INC         DE                                      
    INC         DE                                      
    INC         DE                                      
    CALL        LD_HL_DE                                
    CALL        ERAVAR                                  
    POP         IX                                      
    LD          HL,0x1b00                               
    LD          (T_ADDR),HL                             
    RET                                                 
ONLYOUT                       
    RST         RST30                                   
    JR          Z,NOOPEN1                               
    RST         RST28                                   
    dw          171Eh                                   
    LD          (VALSYX),HL                             
    LD          A,B                                     
    OR          C                                       
    JR          Z,NOOPEN1                               
    LD          A,B                                     
    AND         A                                       
    JP          NZ,REPORTM                              
    LD          A,C                                     
    CP          0x11                                    
    JP          NC,REPORTM                              
NOOPEN1                       
    RST         RST18                                   
    CP          0x2c                                    
    JP          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
    CALL        ISSYNCONTR                              
    CALL        DIVSTRING                               
OPENOUTF                      
    PUSH        IX                                      
    CALL        SETSTRNM                                
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JR          NZ,OPENNULF                             
    CALL        GETATR                                  
    BIT         0x2,A                                   
    ; JP          Z,REPORTF 
    JP Z,WPRTER                              
    CALL        DFILER                                  
OPENNULF                      
    CALL        SETEMPTYF                               
    PUSH        HL                                      
    CALL        MAKE544B                                
    PUSH        HL                                      
    CALL        SETSTRBUF                               
    POP         HL                                      
    LD          DE,0x25ab                               
    CALL        LD_HL_DE                                
    LD          DE,0x15c4                               
    CALL        LD_HL_DE                                
    LD          A,0xeb                                  
    CALL        LD_HL_A                                 
    JP          MAKEHBUF                                
OPENIO                        
    RST         RST18                                   
    CP          0x2c                                    
    JP          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
    CALL        ISSYNCONTR                              
    CALL        DIVSTRING                               
    CALL        OPENOUTF                                
    LD          HL,(VALSYY)                             
    LD          DE,0x27ac                               
    CALL        LD_HL_DE                                
    LD          DE,0x27a5                               
    CALL        LD_HL_DE                                
    LD          A,0xeb                                  
    CALL        LD_HL_A                                 
    LD          HL,(VALSYX)                             
    CALL        LD_DE_HL                                
    LD          BC,0xfde0                               
    EX          DE,HL                                   
    ADD         HL,BC                                   
    EX          DE,HL                                   
    DEC         HL                                      
    DEC         HL                                      
    CALL        LD_HL_DE                                
    RET                                                 
CLOSESTR                      
    LD          HL,(STKEND)                             
    LD          DE,0x5                                  
    ADD         HL,DE                                   
    LD          (STKEND),HL                             
    RST         RST28                                   
    dw          1E94h                                   
    RST         RST28                                   
    dw          1721h                                   
CLOUTSTRF                     
    PUSH        HL                                      
    CALL        CLOPENF                                 
    POP         HL                                      
    RST         RST28                                   
    dw          16EBh                                   
    RET                                                 
CLOSEALL                      
    CALL        ISSYNCONTR                              
    XOR         A                                       
CLOSEALL1                     
    PUSH        AF                                      
    RST         RST28                                   
    dw          1721h                                   
    PUSH        HL                                      
    LD          HL,(CHANS)                              
    ADD         HL,BC                                   
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    LD          A,(HL)                                  
    POP         HL                                      
    CP          0xeb                                    
    CALL        Z,CLOUTSTRF                             
    POP         AF                                      
    INC         A                                       
    CP          0x10                                    
    JR          C,CLOSEALL1                             
    RET                                                 
CLOPENF                       
    LD          A,B                                     
    OR          C                                       
    RET         Z                                       
    LD          HL,(CHANS)                              
    ADD         HL,BC                                   
    LD          D,(HL)                                  
    DEC         HL                                      
    LD          E,(HL)                                  
    EX          DE,HL                                   
    LD          BC,0x25ab                               
    SBC         HL,BC                                   
    JR          Z,CLOSEOUTF                             
    LD          BC,0x201                                
    AND         A                                       
    SBC         HL,BC                                   
    JR          Z,CLOSEOF1                              
CLOERROOM                     
    EX          DE,HL                                   
    LD          BC,0x220                                
    CALL        DESTRBYTE                               
    RET                                                 
CLOSEOF1                      
    PUSH        DE                                      
    CALL        CLOERROOM                               
    POP         DE                                      
CLOSEOUTF                     
    PUSH        IX                                      
    EX          DE,HL                                   
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    LD          DE,0x3e80                               
    LD          BC,0xa                                  
    LDIR                                                
    INC         HL                                      
    INC         HL                                      
    CALL        SETACT                                  
    CALL        LD_DE_HL                                
    LD          C,E                                     
    LD          B,D                                     
    LD          (ADRSCTR),DE                            
    LD          A,(WORKDR)                              
    LD          (ADRDR),A                               
    LD          DE,0x101                                
    PUSH        HL                                      
    LD          HL,0x3800                               
    CALL        BREADA                                  
    POP         HL                                      
    CALL        LD_DE_HL                                
    PUSH        DE                                      
    POP         IX                                      
    CALL        LD_DE_HL                                
    PUSH        DE                                      
    LD          C,(HL)                                  
    INC         HL                                      
    CALL        LD_DE_HL                                
    EX          DE,HL                                   
    EX          (SP),HL                                 
    PUSH        HL                                      
    EX          DE,HL                                   
    CALL        LD_DE_HL                                
    LD          (IX+0xb),E                              
    POP         AF                                      
    ADD         A,D                                     
    LD          (IX+0xc),A                              
    LD          A,C                                     
    ADC         A,0x0                                   
    LD          (IX+0x15),A                             
    CALL        WSCADR                                  
    CALL        DRVSYS                                  
    LD          A,D                                     
    OR          E                                       
    EX          (SP),HL                                 
    JR          Z,CLOSEEND                              
    PUSH        DE                                      
    CALL        GETWTEST                                
    LD          A,D                                     
    CP          0xc                                     
    JR          Z,CLEMPTYF                              
    PUSH        HL                                      
    CALL        FIEMPTYFAT                              
    JP          NZ,RETREP                               
    POP         DE                                      
    EX          DE,HL                                   
    CALL        WRTOFAT                                 
    EX          DE,HL                                   
CLEMPTYF                      
    POP         DE                                      
    LD          A,D                                     
    OR          0xe                                     
    LD          D,A                                     
    CALL        WRTOFAT                                 
    CALL        WFATIFCH                                
    CALL        LOGFYZ                                  
    POP         HL                                      
    PUSH        HL                                      
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    LD          DE,0x100                                
    LD          A,(WORKDR)                              
    CALL        BWRITE                                  
CLOSEEND                      
    POP         HL                                      
    LD          DE,0xffe3                               
    ADD         HL,DE                                   
    LD          BC,0x220                                
    CALL        DESTRBYTE                               
    CALL        ERAVAR                                  
    POP         IX                                      
    RET                                                 
ANAOPENNM                     
    RST         RST28                                   
    dw          2BF1h                                   
    LD          A,B                                     
    OR          C                                       
    JP          Z,REPORTF                               
    CALL        ANALSTE                                 
    AND         A                                       
    RET                                                 
SETSTRBUF                     
    LD          DE,(CHANS)                              
    AND         A                                       
    SBC         HL,DE                                   
    INC         HL                                      
    EX          DE,HL                                   
    LD          HL,(VALSYX)                             
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    RET                                                 
SETEMPTYF                     
    CALL        FINDANDFILL                             
    LD          B,0x6                                   
CLSHEADINF                    
    LD          (HL),0x0                                
    INC         HL                                      
    DJNZ        CLSHEADINF                              
    PUSH        HL                                      
    LD          HL,0x0                                  
    CALL        FIEMPTYFAT                              
    JP          NZ,RETREP                               
    EX          DE,HL                                   
    POP         HL                                      
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    INC         HL                                      
    PUSH        HL                                      
    EX          DE,HL                                   
    LD          DE,0xc00                                
    CALL        WRTOFAT                                 
    POP         HL                                      
    LD          (HL),0x0                                
    INC         HL                                      
    LD          (HL),0xf                                
    INC         HL                                      
    LD          (HL),0x0                                
    LD          DE,0xffeb                               
    ADD         HL,DE                                   
    CALL        WSCADR                                  
    CALL        WFATIFCH                                
    RET                                                 
LD_HL_DE                      
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    INC         HL                                      
    RET                                                 
LD_HL_A                       
    LD          (HL),A                                  
    INC         HL                                      
    RET                                                 
MAKE544B                      
    LD          BC,0x220                                
    JR          MAKEROOM                                
MAKE1088B                     
    LD          BC,0x440                                
MAKEROOM                      
    LD          HL,(PROG)                               
    DEC         HL                                      
    RST         RST28                                   
    dw          1655h                                   
    INC         HL                                      
    RET                                                 
DESTRBYTE                     
    PUSH        HL                                      
    PUSH        BC                                      
    RST         RST28                                   
    dw          19E8h                                   
    POP         BC                                      
    POP         HL                                      
    LD          DE,(CHANS)                              
    AND         A                                       
    SBC         HL,DE                                   
    INC         HL                                      
    PUSH        HL                                      
    LD          HL,0x5c10                               
    LD          A,0x13                                  
CRECTADR                      
    CALL        LD_DE_HL                                
    EX          (SP),HL                                 
    SBC         HL,DE                                   
    ADD         HL,DE                                   
    JR          NC,NOCRECT                              
    EX          DE,HL                                   
    AND         A                                       
    SBC         HL,BC                                   
    EX          DE,HL                                   
    EX          (SP),HL                                 
    DEC         HL                                      
    DEC         HL                                      
    CALL        LD_HL_DE                                
    EX          (SP),HL                                 
NOCRECT                       
    EX          (SP),HL                                 
    DEC         A                                       
    JR          NZ,CRECTADR                             
    POP         HL                                      
    RET                                                 
LD_DE_HL                      
    LD          E,(HL)                                  
    INC         HL                                      
    LD          D,(HL)                                  
    INC         HL                                      
    RET                                                 
SETSTRNM                      
    CALL        SETWDNM                                 
    CALL        ANALWDNM                                
    INC         A                                       
    JP          Z,REPORTX                               
    CALL        ARRANGNM                                
    JP          C,REPORTF                               
    LD          A,(EXTE1)                               
    CP          'B'                                     
    RET         Z                                       
    CP          'Q'                                     
    RET         Z                                       
    CP          '?'                                     
    JP          NZ,REPORTF                              
    LD          A,'Q'                                   
    LD          (EXTE1),A                               
    RET                                                 
RDFROMSTR                     
    EI                                                  
    RES         0x3,(IY+0x2)                            
    LD          HL,(ERR_SP)                             
    DEC         HL                                      
    LD          B,(HL)                                  
    DEC         HL                                      
    PUSH        HL                                      
    LD          C,(HL)                                  
    LD          HL,0xf3b                                
    AND         A                                       
    SBC         HL,BC                                   
    POP         HL                                      
    JR          NZ,NOINPUT                              
    LD          (HL),0x48                               
NOINPUT                       
    LD          HL,0x18                                 
    ADD         HL,DE                                   
    LD          E,(HL)                                  
    INC         HL                                      
    LD          D,(HL)                                  
    INC         HL                                      
    LD          C,(HL)                                  
    INC         HL                                      
    LD          B,(HL)                                  
    LD          A,D                                     
    OR          E                                       
    JR          NZ,NOEMPTBF                             
    PUSH        HL                                      
    CALL        STRRDNSEC                               
    POP         HL                                      
    JR          C,STRNEXT                               
    OR          0xff                                    
    JP          STANDROM                                
STRNEXT                       
    LD          C,L                                     
    LD          B,H                                     
    INC         BC                                      
    INC         BC                                      
NOEMPTBF                      
    DEC         DE                                      
    LD          A,(BC)                                  
INCPOINTERS                   
    INC         BC                                      
    LD          (HL),B                                  
    DEC         HL                                      
    LD          (HL),C                                  
    DEC         HL                                      
    ; LD          (HL),D=>LAB_ram_023b                    
    LD (HL),D
    DEC         HL                                      
    ; LD          (HL),E=>LAB_ram_023a                    
    LD (HL),E
    SCF                                                 
    JP          STANDROM                                
WRTOSTR2                      
    LD          HL,0x23a                                
    JR          WRTOSTR                                 
WRTOSTR1                      
    LD          HL,0x1a                                 
WRTOSTR                       
    EI                                                  
    ADD         HL,DE                                   
    ; LD          E,(HL=>LAB_ram_023a)                    
    LD E,(HL)
    INC         HL                                      
    ; LD          D,(HL=>LAB_ram_023b)                    
    LD D,(HL)
    INC         HL                                      
    LD          C,(HL)                                  
    INC         HL                                      
    LD          B,(HL)                                  
    LD          (BC),A                                  
    INC         DE                                      
    BIT         0x1,D                                   
    JR          Z,INCPOINTERS                           
    PUSH        HL                                      
    CALL        WFLSTRSC                                
    POP         HL                                      
    LD          C,L                                     
    LD          B,H                                     
    INC         BC                                      
    LD          DE,0x0                                  
    JR          INCPOINTERS                             
STRRDNSEC                     
    PUSH        IX                                      
    INC         HL                                      
    INC         HL                                      
    PUSH        HL                                      
    CALL        STRDRNMSC                               
    PUSH        HL                                      
    EX          DE,HL                                   
    BIT         0x3,H                                   
    JR          NZ,ISLAST                               
    CALL        SETACT                                  
    CALL        GETWTEST                                
    CALL        ERAVAR                                  
    CALL        LOGFYZ                                  
    POP         HL                                      
    CALL        LD_HL_DE                                
    LD          A,D                                     
    CP          0xc                                     
    JR          Z,ISEMPTY                               
    BIT         0x3,D                                   
    JR          Z,IS512B                                
    LD          A,D                                     
    AND         0x1                                     
    LD          D,A                                     
    OR          E                                       
    JR          NZ,NO512B                               
IS512B                        
    LD          DE,0x200                                
NO512B                        
    POP         HL                                      
    PUSH        DE                                      
    LD          DE,0x100                                
    CALL        BREADA                                  
    POP         DE                                      
    POP         IX                                      
    SCF                                                 
    RET                                                 
ISLAST                        
    POP         HL                                      
ISEMPTY                       
    POP         HL                                      
    POP         IX                                      
    AND         A                                       
    RET                                                 
STRDRNMSC                     
    LD          DE,0xffe6                               
    ADD         HL,DE                                   
    LD          DE,0x3e80                               
    LD          BC,0xa                                  
    LDIR                                                
    LD          DE,0x9                                  
    ADD         HL,DE                                   
    LD          E,(HL)                                  
    INC         HL                                      
    LD          D,(HL)                                  
    DEC         HL                                      
    RET                                                 
WFLSTRSC                      
    PUSH        IX                                      
    INC         HL                                      
    INC         HL                                      
    PUSH        HL                                      
    CALL        STRDRNMSC                               
    LD          (VALSYX),HL                             
    PUSH        DE                                      
    CALL        SETACT                                  
    POP         HL                                      
    CALL        GETWTEST                                
    LD          A,D                                     
    CP          0xc                                     
    JR          Z,NULENGTH                              
    PUSH        HL                                      
    CALL        FIEMPTYFAT                              
    JP          NZ,RETREP                               
    POP         DE                                      
    EX          DE,HL                                   
    CALL        WRTOFAT                                 
    LD          HL,(VALSYX)                             
    CALL        LD_HL_DE                                
    EX          DE,HL                                   
NULENGTH                      
    LD          DE,0xe00                                
    CALL        WRTOFAT                                 
    CALL        LOGFYZ                                  
    POP         HL                                      
    PUSH        HL                                      
    LD          DE,0x100                                
    LD          A,(WORKDR)                              
    CALL        BWRITE                                  
    POP         HL                                      
    LD          DE,0xfff7                               
    ADD         HL,DE                                   
    ; LD          A,(HL=>DAT_ram_fff9)
    LD A,(HL)                    
    ADD         A,0x2                                   
    ; LD          (HL),A=>DAT_ram_fff9                    
    LD (HL),A
    JR          NC,STRWOK                               
    INC         HL                                      
    ; INC         (HL=>DAT_ram_fffa)
    INC (HL)
    JR          NZ,STRWOK                               
    INC         HL                                      
    ; INC         (HL=>DAT_ram_fffb)                      
    INC (HL)
STRWOK                        
    CALL        WFATIFCH                                
    CALL        ERAVAR                                  
    POP         IX                                      
    RET                                                 
CLOSE0STR                     
    XOR         A                                       
    JP          CLOUTSTRF                               
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
    LD          C,0x8                                   
    LD          HL,0x3eda                               
CALCDIV                       
    PUSH        HL                                      
    LD          (IX+0x3),0x1                            
    LD          (IX+0x4),0x0                            
    LD          (IX+0x5),0x0                            
    LD          A,C                                     
    DEC         A                                       
    JR          Z,SETNUM                                
    LD          B,A                                     
    LD          A,(IX+0x3)                              
    LD          L,(IX+0x4)                              
    LD          H,(IX+0x5)                              
MULT10                        
    ADD         A,A                                     
    ADC         HL,HL                                   
    ADD         A,A                                     
    ADC         HL,HL                                   
    ADD         A,(IX+0x3)                              
    LD          E,(IX+0x4)                              
    LD          D,(IX+0x5)                              
    ADC         HL,DE                                   
    ADD         A,A                                     
    ADC         HL,HL                                   
    LD          (IX+0x3),A                              
    LD          (IX+0x4),L                              
    LD          (IX+0x5),H                              
    DJNZ        MULT10                                  
SETNUM                        
    POP         HL                                      
    ; LD          (HL=>ASCIINM),0x30                      
    LD (HL),0x30
    PUSH        HL                                      
SUBNUM                        
    LD          A,(IX+0x0)                              
    LD          L,(IX+0x1)                              
    LD          H,(IX+0x2)                              
    SUB         (IX+0x3)                                
    LD          E,(IX+0x4)                              
    LD          D,(IX+0x5)                              
    SBC         HL,DE                                   
    JR          C,ISLOW                                 
    LD          (IX+0x0),A                              
    LD          (IX+0x1),L                              
    LD          (IX+0x2),H                              
    POP         HL                                      
    ; INC         (HL=>ASCIINM)                           
    INC (HL)
    PUSH        HL                                      
    JR          SUBNUM                                  
ISLOW                         
    POP         HL                                      
    INC         HL                                      
    DEC         C                                       
    JR          NZ,CALCDIV                              
    ; LD          HL,0x3eda
    LD HL,ASCIINM                               
    LD          B,0x7                                   
CLSNUL                        
    ; LD          A,(HL=>ASCIINM)                         
    LD A,(HL)
    CP          0x30                                    
    JR          NZ,PRNUM                                
    ; LD          (HL=>ASCIINM),0x20                      
    LD (HL),0x20
    INC         HL                                      
    DJNZ        CLSNUL                                  
PRNUM                         
    ; LD          HL,0x3eda                               
    LD HL,ASCIINM
    LD          B,0x8                                   
PRNUM1                        
    ; LD          A,(HL=>ASCIINM)                         
    ld A,(HL)
    PUSH        HL                                      
    PUSH        BC                                      
    RST         RST10                                   
    POP         BC                                      
    POP         HL                                      
    INC         HL                                      
    DJNZ        PRNUM1                                  
    RET                                                 
TESTNM                        
    LD          A,(FNZONE1)                             
    AND         A                                       
    JP          Z,REPORTF                               
    RET                                                 
;undefined BCPRT()
BCPRT
    RST         RST28                                   
    dw          02D2Bh                                   
    RST         RST28                                   
    dw          02DE3h                                   
    RET                                                 
ADDHLA                        
    ADD         A,L                                     
    LD          L,A                                     
    RET         NC                                      
    INC         H                                       
    RET                                                 
ANALSTE                       
    LD          HL,0x3e80                               
    PUSH        BC                                      
    PUSH        DE                                      
    LD          B,0x15                                  
    CALL        BNULHL                                  
    POP         DE                                      
    POP         BC                                      
    JR          DIVSTRING1                              
DIVSTRCAT                     
    RST         RST18                                   
    CP          0xd                                     
    JR          Z,NOPARCAT                              
    CP          0x3a                                    
    JR          Z,NOPARCAT                              
    RST         RST28                                   
    dw          1C8Ch                                   
    CALL        TESTSYN1                                
DIVSTRING                     
    LD          HL,0x3e80                               
    LD          B,0x15                                  
    CALL        BNULHL                                  
    RST         RST28                                   
    dw          2BF1h                                   
DIVSTRING1                    
    EX          DE,HL                                   
    INC         B                                       
    DEC         B                                       
    JP          NZ,REPORTF                              
    LD          B,C                                     
    INC         B                                       
DIVLOOP                       
    DEC         B                                       
    RET         Z                                       
    LD          DE,0x3e80                               
    CALL        GETNAME                                 
    JR          NZ,MOVENAME                             
    JR          NC,NEXTANAL                             
    LD          A,(HL)                                  
    LD          (EXTE1),A                               
    DEC         B                                       
    DEC         B                                       
    JR          NZ,REPORTF                              
MOVENAME                      
    LD          HL,0x3e80                               
    LD          DE,0x3e8a                               
    LD          BC,0xa                                  
    LDIR                                                
    LD          HL,0x3e80                               
    LD          B,0xa                                   
    CALL        BNULHL                                  
    RET                                                 
NEXTANAL                      
    LD          A,C                                     
    AND         A                                       
    JR          Z,DIVLOOP                               
    DEC         B                                       
    RET         Z                                       
    LD          DE,0x3e8a                               
    CALL        GETNAME                                 
    JR          C,ANALFNM                               
    RET         NZ                                      
REPORTF                       
    LD          A,0xe                                   
    JP          ERRR                                    
ANALFNM                       
    LD          A,(HL)                                  
    LD          (EXTE1),A                               
    DEC         B                                       
    DEC         B                                       
    RET         Z                                       
    JR          REPORTF                                 
NOPARCAT                      
    CALL        TESTSYN1                                
    ; LD          HL,0x3e8a                               
    LD HL,FNZONE1
    LD          DE,0x3e8b                               
    ; LD          (HL=>FNZONE1),0x3f                      
    LD (HL),0x3f
    LD          BC,0xa                                  
    LDIR                                                
MOVEWDNM                      
    LD          HL,0x3eaa                               
    LD          DE,0x3e80                               
    LD          BC,0xa                                  
    LDIR                                                
    RET                                                 
SETWDNM                       
    ; LD          HL,0x3e80                               
    LD HL,DNZONE1
    ; LD          A,(HL=>DNZONE1)                         
    LD A,(HL)
    AND         A                                       
    RET         NZ                                      
    JR          MOVEWDNM                                
BNULHL                        
    LD          (HL),0x0                                
    INC         HL                                      
    DJNZ        BNULHL                                  
    RET                                                 
TESTSYN1                      
    RST         RST30                                   
    RET         NZ                                      
    POP         BC                                      
    NOP                                                 
    JR          SYNCRET                                 
ISSYNCONTR                    
    RST         RST30                                   
    RET         NZ                                      
SYNCRET                       
    POP         BC                                      
    POP         BC                                      
    POP         BC                                      
    PUSH        HL                                      
    LD          HL,0x1bf4                               
    EX          (SP),HL                                 
    JP          STANDROM                                
GETNAME                       
    LD          C,0x0                                   
MAKENAME                      
    LD          A,(HL)                                  
    INC         HL                                      
    CP          ':'                                     
    RET         Z                                       
    CP          '.'                                     
    SCF                                                 
    RET         Z                                       
    LD          (DE),A                                  
    INC         DE                                      
    INC         C                                       
    LD          A,C                                     
    CP          0xb                                     
    JP          NC,REPORTF                              
    DJNZ        MAKENAME                                
    AND         A                                       
    RET                                                 
ARRANGNM                      
    ; LD          HL,0x3e8a                               
    LD HL,FNZONE1
    ; LD          A,(HL=>FNZONE1)                         
    LD A,(HL)
    AND         A                                       
    JR          NZ,ARNGNM1                              
    ; LD          (HL=>FNZONE1),'*'                       
    LD (HL),"*"
ARNGNM1                       
    LD          B,0xa                                   
    LD          C,0x0                                   
ARRLOPPLD                     
    ; LD          A,(HL=>FNZONE1)                         
    LD A,(HL)
    AND         A                                       
    JR          Z,ARRANGEXT                             
    CP          '*'                                     
    JR          Z,FILLMARK                              
    CP          '?'                                     
    JR          NZ,NOWILD                               
    SET         0x0,C                                   
NOWILD                        
    INC         HL                                      
    DJNZ        ARRLOPPLD                               
ARRANGEXT                     
    CALL        SETEXT                                  
    AND         A                                       
    RR          C                                       
    RET                                                 
FILLMARK                      
    ; LD          (HL=>DAT_ram_3e8b),'?'                  
    LD (HL),"?"
    INC         HL                                      
    DEC         B                                       
FILLMARK1                     
    ; LD          A,(HL=>DAT_ram_3e8c)                    
    LD A,(HL)
    ; LD          (HL=>DAT_ram_3e8c),'?'                  
    LD (HL),"?"
    INC         HL                                      
    AND         A                                       
    JP          NZ,REPORTF                              
    DJNZ        FILLMARK1                               
    SET         0x0,C                                   
    JR          ARRANGEXT                               
SETEXT                        
    SET         0x1,C                                   
    LD          A,(EXTE1)                               
    CALL        UPPER                                   
    CP          '*'                                     
    JR          Z,SETMARK                               
    AND         A                                       
    JR          NZ,EXTIS                                
    RES         0x1,C                                   
SETMARK                       
    LD          A,0x3f                                  
EXTIS                         
    LD          (EXTE1),A                               
    PUSH        HL                                      
    PUSH        BC                                      
    LD          HL,0x10db                               
    LD          BC,0x7                                  
    CPIR                                                
    POP         BC                                      
    POP         HL                                      
    RET         Z                                       
    LD          A,0x2b                                  
    JP          ERRR                                    
EXTTAB                        
    db          "PNCBQS?"                               
ANALWDNM                      
    ; LD          HL,0x3e80                               
    LD HL,DNZONE1
ANALWNM                       
    LD          B,0xa                                   
ANALWDCH                      
    ; LD          A,(HL=>DNZONE1)                         
    LD A,(HL)
    AND         A                                       
    JR          Z,ANALWDEN                              
    CALL        ISALFNUM                                
    JR          NC,REPORTB                              
    INC         HL                                      
    DJNZ        ANALWDCH                                
ANALWDEN                      
    ; LD          HL,0x3e80                               
    LD HL,DNZONE1
    ; LD          A,(HL=>DNZONE1)                         
    LD A,(HL)
    AND         A                                       
    RET         Z                                       
    INC         HL                                      
    ; LD          A,(HL=>DAT_ram_3e81)                    
    LD A,(HL)
ANALWDNM1                     
    AND         A                                       
    SCF                                                 
    RET         NZ                                      
    DEC         HL                                      
    ; LD          A,(HL=>DNZONE1)                         
    LD A,(HL)
    CALL        UPPER                                   
    SUB         'A'                                     
    RET         C                                       
    CP          0x5                                     
    JR          Z,ANALWDNM1                             
    CCF                                                 
    RET         C                                       
    CP          0x4                                     
    CCF                                                 
    RET         NZ                                      
    OR          0xff                                    
    RET                                                 
REPORTB                       
    LD          A,0x2a                                  
    JP          ERRR                                    
UPPER                         
    CALL        ISALFABET                               
    RET         NC                                      
    AND         0xdf                                    
    RET                                                 
ISALFNUM                      
    CALL        ISNUM                                   
    CCF                                                 
    RET         C                                       
ISALFABET                     
    CP          'A'                                     
    CCF                                                 
    RET         NC                                      
    CP          '['                                     
    RET         C                                       
    CP          'a'                                     
    CCF                                                 
    RET         NC                                      
    CP          '{'                                     
    RET                                                 
ISNUM                         
    CP          '0'                                     
    RET         C                                       
    CP          ':'                                     
    CCF                                                 
    RET                                                 
RUN                           
    LD          BC,0x5                                  
    RST         RST28                                   
    dw          30h                                     
    LD          HL,0x1157                               
    LD          BC,0x3                                  
    PUSH        DE                                      
    LDIR                                                
    LD          BC,0x3                                  
    POP         DE                                      
    RST         RST28                                   
    dw          2AB2h                                   
    LD          A,0x1                                   
    LD          (T_ADDR),A                              
    JP          SMLSTART                                
TXTRUN                        
    db          "run"                                   
CATNOINF                      
    RST         RST20                                   
    CALL        DIVSTRCAT                               
    CALL        SETWDNM                                 
    CALL        ARRANGNM                                
    CALL        SETACT                                  
    LD          A,0x2                                   
    RST         RST28                                   
    dw          1601h                                   
    XOR         A                                       
    LD          DE,0x12ad                               
    CALL        PRTMES                                  
    CALL        NAMEDISK                                
    CALL        PTRSTR                                  
    LD          A,0xd                                   
    RST         RST10                                   
    LD          A,0xd                                   
    RST         RST10                                   
    LD          A,0xff                                  
    LD          C,0x0                                   
CATNOLOOP                     
    CALL        NEXTMASK                                
    JR          NZ,PRINTINF                             
    INC         C                                       
    PUSH        BC                                      
    PUSH        AF                                      
    CALL        GETATR                                  
    BIT         0x7,A                                   
    JR          NZ,ISHIDEEN                             
    LD          A,(HL)                                  
    INC         HL                                      
    RST         RST10                                   
    LD          A,0x20                                  
    RST         RST10                                   
    CALL        PTRSTR                                  
    LD          A,0x6                                   
    RST         RST10                                   
ISHIDEEN                      
    POP         AF                                      
    POP         BC                                      
    JR          CATNOLOOP                               
PRINTINF                      
    PUSH        BC                                      
    LD          A,0xd                                   
    RST         RST10                                   
    LD          A,0xd                                   
    RST         RST10                                   
    POP         BC                                      
    LD          B,0x0                                   
    CALL        BCPRT                                   
    LD          DE,0x12ad                               
    LD          A,0x1                                   
    CALL        PRTMES                                  
    CALL        FREECOUNT                               
    PUSH        IX                                      
    ; LD          IX,0x3ed4                               
    LD IX,SV24NM
    SLA         C                                       
    RL          B                                       
    ; LD          (IX+0x0)=>SV24NM,0x0                    
    LD (IX+0),0
    ; LD          (IX+0x1)=>DAT_ram_3ed5,C                
    LD (IX+1),C
    ; LD          (IX+0x2)=>DAT_ram_3ed6,B                
    LD (IX+2),B
    CALL        NUM24B                                  
    POP         IX                                      
    LD          A,0x2                                   
    LD          DE,0x12ad                               
    CALL        PRTMES                                  
    CALL        ERAVAR                                  
    RET                                                 
CATFN                         
    RST         RST18                                   
    CP          '-'                                     
    JP          Z,CATNOINF                              
    CALL        DIVSTRCAT                               
    CALL        SETWDNM                                 
    CALL        ARRANGNM                                
    CALL        SETACT                                  
    LD          A,0x2                                   
    RST         RST28                                   
    dw          1601h                                   
    XOR         A                                       
    LD          DE,0x129e                               
    CALL        PRTMES                                  
    CALL        NAMEDISK                                
    CALL        PTRSTR                                  
    LD          A,0xd                                   
    RST         RST10                                   
    LD          A,0xd                                   
    RST         RST10                                   
    LD          A,0xff                                  
    LD          C,0x0                                   
CATFNLOOP                     
    CALL        NEXTMASK                                
    JR          NZ,PRINTINF                             
    INC         C                                       
    PUSH        AF                                      
    CALL        GETATR                                  
    BIT         0x7,A                                   
    LD          B,A                                     
    PUSH        BC                                      
    JR          NZ,FNISHID                              
    PUSH        HL                                      
    LD          A,(HL)                                  
    INC         HL                                      
    RST         RST10                                   
    LD          A,0x20                                  
    RST         RST10                                   
    CALL        PTRSTR                                  
    POP         HL                                      
    LD          A,0xb                                   
    CALL        ADDHLA                                  
    PUSH        IX                                      
    ; LD          IX,0x3ed4                               
    LD IX,SV24NM
    LD          A,(HL)                                  
    ; LD          (IX+0x0)=>SV24NM,A                      
    LD (IX+0),A
    INC         HL                                      
    LD          A,(HL)                                  
    ; LD          (IX+0x1)=>DAT_ram_3ed5,A                
    LD (IX+1),A
    LD          A,0x9                                   
    CALL        ADDHLA                                  
    LD          A,(HL)                                  
    ; LD          (IX+0x2)=>DAT_ram_3ed6,A                
    LD (IX+2),A
    LD          A,0x17                                  
    RST         RST10                                   
    LD          A,0xe                                   
    RST         RST10                                   
    XOR         A                                       
    RST         RST10                                   
    CALL        NUM24B                                  
    POP         IX                                      
    LD          A,0x17                                  
    RST         RST10                                   
    LD          A,0x17                                  
    RST         RST10                                   
    XOR         A                                       
    RST         RST10                                   
    POP         BC                                      
    PUSH        BC                                      
    ; LD          HL,0x127b                               
    LD HL,DEFATTR
    LD          E,0x8                                   
CATFNATT                      
    RL          B                                       
    ; LD          A,(HL=>DEFATTR)                         
    LD A,(HL)
    INC         HL                                      
    JR          C,CATFNAPR                              
    LD          A,'-'                                   
CATFNAPR                      
    PUSH        HL                                      
    PUSH        DE                                      
    PUSH        BC                                      
    RST         RST10                                   
    POP         BC                                      
    POP         DE                                      
    POP         HL                                      
    DEC         E                                       
    JR          NZ,CATFNATT                             
    LD          A,0xd                                   
    RST         RST10                                   
FNISHID                       
    POP         BC                                      
    POP         AF                                      
    JP          CATFNLOOP                               
DEFATTR                       
    db          "HSPARWED"                              
GETATR                        
    PUSH        HL                                      
    EX          (SP),IX                                 
    LD          A,(IX+0x14)                             
    EX          (SP),IX                                 
    POP         HL                                      
    RET                                                 
PTRSTR                        
    PUSH        BC                                      
    LD          B,0xa                                   
PRTSTRLOOP                    
    LD          A,(HL)                                  
LAB_ram_1291                  
    AND         A                                       
    JR          Z,ENDPRTSTR                             
    PUSH        HL                                      
    PUSH        BC                                      
    RST         RST10                                   
    POP         BC                                      
    POP         HL                                      
    INC         HL                                      
    DJNZ        PRTSTRLOOP                              
ENDPRTSTR                     
    POP         BC                                      
    RET                                                 
TXTCAT1                       
    db          0FFh                                     
    db          "\rDirectory of",0A0h                    
TXTCAT2                       
    db          0FFh                                     
    db          "\rCatalogue of",0A0h," "                
    db          "File(s),",0A0h," "                      
    db          "Bytes free.",8Dh                       
ERASE                         
    CALL        DIVSTRING                               
    CALL        TESTNM                                  
    CALL        SETWDNM                                 
    CALL        ARRANGNM                                
    JP          Z,REPORTF                               
    ; LD          HL,0x3e8a                               
    LD HL,FNZONE1
    LD          B,0xa                                   
ERASEALL                      
    ; LD          A,(HL=>FNZONE1)                         
    LD A,(HL)
    INC         HL                                      
    CP          '?'                                     
    JR          NZ,ERANOALL                             
    DJNZ        ERASEALL                                
    LD          A,0xbd                                  
    LD          DE,0x3af                                
    CALL        KEYMSG                                  
    RET         NC                                      
ERANOALL                      
    CALL        DELALLFIL                               
    PUSH        AF                                      
    CALL        ERAVAR                                  
    POP         AF                                      
    RET         Z                                       
    LD          A,0x1b                                  
    JP          ERRR                                    
MOVEACT                       
    CALL        ISSYNCONTR                              
    CALL        DIVSTRING                               
    CALL        ANALWDNM                                
    ; LD          HL,0x3e80                               
    LD HL,DNZONE1
    ; LD          A,(HL=>DNZONE1)                         
    LD A,(HL)
    AND         A                                       
    JP          Z,REPORTB                               
    LD          DE,0x3eaa                               
    LD          BC,0xa                                  
    LDIR                                                
    RET                                                 
FORMAT                        
    CALL        DIVSTRING                               
    CALL        ANALWDNM                                
    JR          Z,REPORTY                               
    JR          NC,FORDROK                              
REPORTY                       
    LD          A,0x21                                  
    JP          ERRR                                    
FORDROK                       
    INC         A                                       
    JR          NZ,FORDISK                              
    LD          A,0x20                                  
    JP          ERRR                                    
FORDISK                       
    DEC         A                                       
    LD          (WORKDR),A                              
    CALL        DRVCMP                                  
    JR          NZ,FORMAT1                              
    LD          A,0x22                                  
    JP          ERRR                                    
FORMAT1                       
    CALL        ARRANGNM                                
    LD          HL,0x3e8a                               
    CALL        ANALWNM                                 
    JP          C,REPORTB                               
    LD          A,(IX+0x5)                              
    LD          (IX+0x1),A                              
    LD          A,(IX+0x6)                              
    LD          (IX+0x2),A                              
    LD          A,(IX+0x7)                              
    LD          (IX+0x3),A                              
    LD          A,(EXTE1)                               
    CP          'S'                                     
    JR          NZ,RFO41                                
    RES         0x4,(IX+0x1)                            
RFO41                         
    CALL        ERAVAR                                  
    PUSH        HL                                      
    PUSH        DE                                      
    LD          DE,0x3af                                
    LD          A,0xbf                                  
    CALL        KEYMSG                                  
    POP         DE                                      
    POP         HL                                      
    RET         NC                                      
    LD          A,(WORKDR)                              
    CALL        DRVSEL                                  
    CALL        HOME                                    
    LD          C,(IX+0x2)                              
    BIT         0x4,(IX+0x1)                            
    JR          Z,RFORM5                                
    RLC         C                                       
RFORM5                        
    LD          B,0x0                                   
RFORM6                        
    PUSH        BC                                      
    LD          DE,0x100                                
    LD          A,(WORKDR)                              
    CALL        BFORMA                                  
    POP         BC                                      
    INC         B                                       
    LD          A,B                                     
    CP          C                                       
    JR          NZ,RFORM6                               
    DEC         B                                       
FORMTEST                      
    LD          HL,0xffff                               
    PUSH        HL                                      
FORMTEST1                     
    LD          C,0x0                                   
FORMTEST2                     
    PUSH        BC                                      
    LD          HL,0x4900                               
    LD          DE,0x1                                  
    LD          A,C                                     
    OUT         (DAT_io_00fe),A                         
    LD          A,(WORKDR)                              
    CALL        DREAD                                   
    LD          A,0x2                                   
    CP          B                                       
    JR          Z,FORMNTEST                             
    LD          A,0x29                                  
    JP          ERRR                                    
FORMNTEST                     
    LD          A,0x85                                  
    AND         C                                       
    JR          Z,FNOTECH                               
    LD          A,0x3b                                  
    JP          ERRR                                    
FNOTECH                       
    LD          A,0x18                                  
    AND         C                                       
    POP         BC                                      
    JR          Z,FORMSOK                               
    PUSH        BC                                      
    CALL        FYZLOG                                  
    POP         BC                                      
    PUSH        HL                                      
FORMSOK                       
    INC         C                                       
    LD          A,(IX+0x3)                              
    CP          C                                       
    JR          NZ,FORMTEST2                            
    DJNZ        FORMTEST1                               
    ; LD          HL,0x3c00                               
    LD HL,FATBUF
    LD          E,L                                     
    LD          D,H                                     
    INC         DE                                      
    ; LD          (HL=>FATBUF),0x0                        
    LD (HL),0
    LD          BC,0x1ff                                
    LDIR                                                
    LD          DE,0x3c80                               
    LD          HL,0x3e00                               
    LD          BC,0x30                                 
    LDIR                                                
    PUSH        IX                                      
    POP         HL                                      
    LD          BC,0xc                                  
    LDIR                                                
    LD          DE,0x3cc0                               
    LD          HL,0x3e8a                               
    LD          BC,0xa                                  
    LDIR                                                
    LD          A,R                                     
    LD          (DE),A                                  
    INC         DE                                      
    HALT                                                
    LD          A,R                                     
    LD          (DE),A                                  
    INC         DE                                      
    LD          HL,0xf10                                
    LD          BC,0x4                                  
    LDIR                                                
    LD          DE,0x101                                
    LD          HL,0x3c00                               
    LD          BC,0x0                                  
    LD          A,(WORKDR)                              
    CALL        BWRITE                                  
    ; LD          HL,0x3c00                               
    LD HL,FATBUF
    PUSH        HL                                      
    LD          DE,0x3c01                               
    ; LD          (HL=>FATBUF),0xdd                       
    LD (HL),0xdd
    LD          BC,0x1ff                                
    LDIR                                                
    POP         HL                                      
    LD          C,0x1                                   
WEMPFAT                       
    PUSH        HL                                      
    LD          DE,0x101                                
    LD          B,0x0                                   
    PUSH        BC                                      
    LD          A,(WORKDR)                              
    CALL        BWRITE                                  
    POP         BC                                      
    POP         HL                                      
    INC         C                                       
    LD          A,0x6                                   
    CP          C                                       
    JR          NZ,WEMPFAT                              
    CALL        SECPERDISK                              
    AND         A                                       
    LD          DE,0xe                                  
    SBC         HL,DE                                   
    EX          DE,HL                                   
    PUSH        DE                                      
WTESTFAT                      
    PUSH        DE                                      
    LD          DE,0x0                                  
    CALL        WRTOFAT                                 
    POP         DE                                      
    INC         HL                                      
    DEC         DE                                      
    LD          A,D                                     
    OR          E                                       
    JR          NZ,WTESTFAT                             
    POP         BC                                      
    LD          DE,0x0                                  
WFAILSEC                      
    POP         HL                                      
    LD          A,H                                     
    AND         L                                       
    INC         A                                       
    JR          Z,WFATEND                               
    PUSH        DE                                      
    LD          DE,0xdff                                
    CALL        WRTOFAT                                 
    POP         DE                                      
    INC         DE                                      
    DEC         BC                                      
    JR          WFAILSEC                                
WFATEND                       
    CALL        WFATIFCH                                
    PUSH        DE                                      
    PUSH        BC                                      
    RST         RST28                                   
    dw          0D6Bh                                    
    LD          A,0xfe                                  
    RST         RST28                                   
    dw          1601h                                   
    XOR         A                                       
    LD          DE,0x14e1                               
    CALL        PRTMES                                  
    POP         BC                                      
    PUSH        BC                                      
    CALL        BCPRT                                   
    LD          A,0x1                                   
    LD          DE,0x14e1                               
    CALL        PRTMES                                  
    POP         BC                                      
    POP         DE                                      
    PUSH        BC                                      
    LD          B,D                                     
    LD          C,E                                     
    CALL        BCPRT                                   
    LD          A,0x2                                   
    LD          DE,0x14e1                               
    CALL        PRTMES                                  
    POP         BC                                      
    SLA         C                                       
    RL          B                                       
    ; LD          IX,0x3ed4                               
    LD IX,SV24NM
    ; LD          (IX+0x0)=>SV24NM,0x0                    
    LD (IX+0),0
    ; LD          (IX+0x1)=>DAT_ram_3ed5,C                
    LD (IX+1),C
    ; LD          (IX+0x2)=>DAT_ram_3ed6,B                
    LD (IX+2),B
    CALL        NUM24B                                  
    LD          A,0x3                                   
    LD          DE,0x14e1                               
    CALL        PRTMES                                  
    CALL        ERAVAR                                  
    LD          A,(ATTR_P)                              
    RRCA                                                
    RRCA                                                
    RRCA                                                
    OR          0xf8                                    
    OUT         (DAT_io_00fe),A                         
    RET                                                 
TXTFORM                       
    db          0FFh                                     
    db          "Format complete.\r"                    
    db          "Formatted",0A0h                         
    db          " good blocks\rand",0A0h                 
    db          " bad blocks.\r"                        
    db          "Total capacity i",0F3h                  
    db          " Bytes.",08Dh                           
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
    db          0h                                      
STANDROM                      
    RET                                                 
RSAVE                         
    LD          A,0x0                                   
    db          21h                                     
RLOAD                         
    LD          A,0x1                                   
    db          21h                                     
RMERGE                        
    LD          A,0x3                                   
SLMSYNTAX                     
    LD          (T_ADDR),A                              
    RST         RST18                                   
    CP          '*'                                     
    JP          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C8Ch                                   
SMLSTART                      
    RST         RST30                                   
    JR          Z,SAVEDATA                              
    LD          BC,0x11                                 
    LD          A,(T_ADDR)                              
    AND         A                                       
    JR          Z,SAVESPACE                             
    LD          C,0x22                                  
SAVESPACE                     
    RST         RST28                                   
    dw          30h                                     
    PUSH        DE                                      
    POP         IX                                      
    LD          B,0xb                                   
    LD          A,0x20                                  
SAVEBLANK                     
    LD          (DE),A                                  
    INC         DE                                      
    DJNZ        SAVEBLANK                               
    LD          (IX+0x1),0xff                           
    CALL        SLMASTR                                 
SAVEDATA                      
    RST         RST18                                   
    CP          0xe4                                    
    JR          NZ,SAVESCRN                             
    LD          A,(T_ADDR)                              
    CP          0x3                                     
    JP          Z,REPORTC                               
    RST         RST20                                   
    RST         RST28                                   
    dw          28B2h                                   
    SET         0x7,C                                   
    JR          NC,SAVEOLD                              
    LD          HL,0x0                                  
    LD          A,(T_ADDR)                              
    DEC         A                                       
    JR          Z,SAVENEW                               
    LD          A,0x1                                   
    JP          ERRR                                    
SAVEOLD                       
    JP          NZ,REPORTC                              
    RST         RST30                                   
    JR          Z,SAVEDATA1                             
    INC         HL                                      
    LD          A,(HL)                                  
    LD          (IX+0xb),A                              
    INC         HL                                      
    LD          A,(HL)                                  
    LD          (IX+0xc),A                              
    INC         HL                                      
SAVENEW                       
    LD          (IX+0xe),C                              
    LD          A,0x1                                   
    BIT         0x6,C                                   
    JR          Z,SAVETYPE                              
    INC         A                                       
SAVETYPE                      
    LD          (IX+0x0),A                              
SAVEDATA1                     
    EX          DE,HL                                   
    RST         RST20                                   
    CP          ')'                                     
    JR          NZ,SAVEOLD                              
    RST         RST20                                   
    CALL        ISSYNCONTR                              
    EX          DE,HL                                   
    JP          SAVEALL                                 
SAVESCRN                      
    CP          0xaa                                    
    JR          NZ,SAVECODE                             
    LD          A,(T_ADDR)                              
    CP          0x3                                     
    JP          Z,REPORTC                               
    RST         RST20                                   
    CALL        ISSYNCONTR                              
    LD          (IX+0xb),0x0                            
    LD          (IX+0xc),0x1b                           
    LD          HL,0x4000                               
    LD          (IX+0xd),L                              
    LD          (IX+0xe),H                              
    JR          SAVETYPE3                               
SAVECODE                      
    CP          0xaf                                    
    JR          NZ,SAVELINE                             
    LD          A,(T_ADDR)                              
    CP          0x3                                     
    JP          Z,REPORTC                               
    RST         RST20                                   
    RST         RST28                                   
    dw          2048h                                   
    JR          NZ,SAVECODE1                            
    LD          A,(T_ADDR)                              
    AND         A                                       
    JP          Z,REPORTC                               
    RST         RST28                                   
    dw          1CE6h                                   
    JR          SAVECODE2                               
SAVECODE1                     
    RST         RST28                                   
    dw          1C82h                                   
    RST         RST18                                   
    CP          ','                                     
    JR          Z,SAVECODE3                             
    LD          A,(T_ADDR)                              
    AND         A                                       
    JP          Z,REPORTC                               
SAVECODE2                     
    RST         RST28                                   
    dw          1CE6h                                   
    JR          SAVECODE4                               
SAVECODE3                     
    RST         RST20                                   
    RST         RST28                                   
    dw          1C82h                                   
SAVECODE4                     
    CALL        ISSYNCONTR                              
    RST         RST28                                   
    dw          1E99h                                   
    LD          (IX+0xb),C                              
    LD          (IX+0xc),B                              
    RST         RST28                                   
    dw          1E99h                                   
    LD          (IX+0xd),C                              
    LD          (IX+0xe),B                              
    LD          H,B                                     
    LD          L,C                                     
SAVETYPE3                     
    LD          (IX+0x0),0x3                            
    JR          SAVEALL                                 
SAVELINE                      
    CP          0xca                                    
    JR          Z,SAVELINE1                             
    CALL        ISSYNCONTR                              
    LD          (IX+0xe),0x80                           
    JR          SAVETYPE0                               
SAVELINE1                     
    LD          A,(T_ADDR)                              
    AND         A                                       
    JP          NZ,REPORTC                              
    RST         RST20                                   
    RST         RST28                                   
    dw          1C82h                                   
    CALL        ISSYNCONTR                              
    RST         RST28                                   
    dw          1E99h                                   
    LD          (IX+0xd),C                              
    LD          (IX+0xe),B                              
SAVETYPE0                     
    LD          (IX+0x0),0x0                            
    LD          HL,(E_LINE)                             
    LD          DE,(PROG)                               
    SCF                                                 
    SBC         HL,DE                                   
    LD          (IX+0xb),L                              
    LD          (IX+0xc),H                              
    LD          HL,(VARS)                               
    SBC         HL,DE                                   
    LD          (IX+0xf),L                              
    LD          (IX+0x10),H                             
    EX          DE,HL                                   
SAVEALL                       
    LD          A,(T_ADDR)                              
    AND         A                                       
    JP          Z,SAVECONTR                             
    PUSH        HL                                      
    LD          BC,0x11                                 
    ADD         IX,BC                                   
    PUSH        IX                                      
    CALL        LOAR01                                  
    POP         IX                                      
    POP         HL                                      
    LD          A,(IX+0x0)                              
    CP          0x3                                     
    JR          Z,VERIFYCONT                            
    LD          A,(T_ADDR)                              
    DEC         A                                       
    JP          Z,LOADCONT                              
    CP          0x2                                     
    JP          Z,MERGECONT                             
VERIFYCONT                    
    PUSH        HL                                      
    LD          L,(IX-0x6)                              
    LD          H,(IX-0x5)                              
    LD          E,(IX+0xb)                              
    LD          D,(IX+0xc)                              
    LD          A,H                                     
    OR          L                                       
    JR          Z,VERCONT1                              
    SBC         HL,DE                                   
    ; JR          C,REPORTX                               
    JR C,VERIFIERR
    JR          Z,VERCONT1                              
    LD          A,(IX+0x0)                              
    CP          0x3                                     
    ; JR          NZ,REPORTX                              
    JR NZ,VERIFIERR
VERCONT1                      
    POP         HL                                      
    LD          A,H                                     
    OR          L                                       
    JR          NZ,VERCONT2                             
    LD          L,(IX+0xd)                              
    LD          H,(IX+0xe)                              
VERCONT2                      
    PUSH        HL                                      
    POP         IX                                      
    JP          LOADBLOCK                               
; REPORTX
VERIFIERR
    LD          A,0x40                                  
    JP          ERRR                                    
LOADCONT                      
    LD          E,(IX+0xb)                              
    LD          D,(IX+0xc)                              
    PUSH        HL                                      
    LD          A,H                                     
    OR          L                                       
    JR          NZ,LOADCONT1                            
    INC         DE                                      
    INC         DE                                      
    INC         DE                                      
    EX          DE,HL                                   
    JR          LOADCONT2                               
LOADCONT1                     
    LD          L,(IX-0x6)                              
    LD          H,(IX-0x5)                              
    EX          DE,HL                                   
    SCF                                                 
    SBC         HL,DE                                   
    JR          C,LOADDATA                              
LOADCONT2                     
    LD          DE,0x5                                  
    ADD         HL,DE                                   
    LD          B,H                                     
    LD          C,L                                     
    RST         RST28                                   
    dw          1F05h                                   
LOADDATA                      
    POP         HL                                      
    LD          A,(IX+0x0)                              
    AND         A                                       
    JR          Z,LOADPROG                              
    LD          A,H                                     
    OR          L                                       
    JR          Z,LOADDATA1                             
    DEC         HL                                      
    ; LD          B,(HL=>DAT_ram_3fff)                    
    LD B,(HL)
    DEC         HL                                      
    ; LD          C,(HL=>SAVE_SP)                         
    LD C,(HL)
    DEC         HL                                      
    INC         BC                                      
    INC         BC                                      
    INC         BC                                      
    LD          (X_PTR),IX                              
    RST         RST28                                   
    dw          19E8h                                   
    LD          IX,(X_PTR)                              
LOADDATA1                     
    LD          HL,(E_LINE)                             
    DEC         HL                                      
    LD          C,(IX+0xb)                              
    LD          B,(IX+0xc)                              
    PUSH        BC                                      
    INC         BC                                      
    INC         BC                                      
    INC         BC                                      
    LD          A,(IX-0x3)                              
    PUSH        AF                                      
    RST         RST28                                   
    dw          1655h                                   
    INC         HL                                      
    POP         AF                                      
    LD          (HL),A                                  
    POP         DE                                      
    INC         HL                                      
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    INC         HL                                      
    PUSH        HL                                      
    POP         IX                                      
    SCF                                                 
    LD          A,0xff                                  
    JP          LOADBLOCK                               
LOADPROG                      
    EX          DE,HL                                   
    LD          HL,(E_LINE)                             
    DEC         HL                                      
    LD          (X_PTR),IX                              
    LD          C,(IX+0xb)                              
    LD          B,(IX+0xc)                              
    PUSH        BC                                      
    RST         RST28                                   
    dw          19E5h                                   
    POP         BC                                      
    PUSH        HL                                      
    PUSH        BC                                      
    RST         RST28                                   
    dw          1655h                                   
    LD          IX,(X_PTR)                              
    INC         HL                                      
    LD          C,(IX+0xf)                              
    LD          B,(IX+0x10)                             
    ADD         HL,BC                                   
    LD          (VARS),HL                               
    LD          H,(IX+0xe)                              
    LD          A,H                                     
    AND         0xc0                                    
    JR          NZ,LOADPRG1                             
    LD          L,(IX+0xd)                              
    LD          (NEWPPC),HL                             
    LD          (IY+0xa),0x0                            
LOADPRG1                      
    POP         DE                                      
    POP         IX                                      
    JP          LOADBLOCK                               
MERGECONT                     
    LD          C,(IX+0xb)                              
    LD          B,(IX+0xc)                              
    PUSH        BC                                      
    INC         BC                                      
    RST         RST28                                   
    dw          30h                                     
    LD          (HL),0x80                               
    EX          DE,HL                                   
    POP         DE                                      
    PUSH        HL                                      
    PUSH        HL                                      
    POP         IX                                      
    CALL        LOADBLOCK                               
    CALL        DSKSTP                                  
    POP         HL                                      
    PUSH        HL                                      
    LD          HL,0x8ce                                
    EX          (SP),HL                                 
    JP          STANDROM                                
LOAR01                        
    PUSH        HL                                      
    PUSH        IX                                      
    ; LD          A,(IX-0x11)=>DAT_ram_ffef               
    LD A,(IX-0x11)
    LD          (IX+0x0),A                              
    CALL        FINTYP                                  
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JR          NZ,TSTSNP                               
    LD          (SVADRA),HL                             
    POP         IX                                      
    PUSH        IX                                      
    POP         DE                                      
    LDIR                                                
    ; LD          L,(IX-0x11)=>DAT_ram_ffef               
    LD L,(IX-0x11)
    LD          (IX+0x0),L                              
    XOR         A                                       
    LD          (VARIA3),A                              
    POP         HL                                      
    RET                                                 
TSTSNP                        
    LD          A,(EXTE1)                               
    CP          'P'                                     
    JP          NZ,REPORTS                              
    LD          A,'S'                                   
    LD          (EXTE1),A                               
    CALL        FIRSTMASK                               
    JP          NZ,REPORTS                              
    LD          (SVADRA),HL                             
    JP          SNPLOA                                  
LOADBLOCK                     
    LD          (STARTADR),IX                           
    LD          (LENDAT),DE                             
    CALL        SETACT                                  
    LD          HL,(STARTADR)                           
    LD          DE,(LENDAT)                             
    CALL        LOAFND                                  
LOADBEND                      
    LD          IX,(STARTADR)                           
    LD          DE,(LENDAT)                             
    ADD         IX,DE                                   
    XOR         A                                       
    SCF                                                 
    RET                                                 
FINTYP                        
    LD          A,(IX+0x0)                              
    LD          HL,0x10db                               
    CALL        ADDHLA                                  
    ; LD          A,(HL=>EXTTAB)                          
    LD A,(HL)
    LD          (EXTE1),A                               
    RET                                                 
SAVESETPAR                    
    CALL        FINTYP                                  
    LD          L,(IX+0xd)                              
    LD          H,(IX+0xe)                              
    LD          (VALSYX),HL                             
    LD          L,(IX+0xf)                              
    LD          H,(IX+0x10)                             
    LD          (VALSYY),HL                             
    LD          E,(IX+0xb)                              
    LD          D,(IX+0xc)                              
    RET                                                 
SAVECONTR                     
    LD          (STARTADR),HL                           
    CALL        SAVESETPAR                              
SAVRUN                        
    PUSH        DE                                      
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    JR          NZ,SAVNODEL                             
    CALL        GETATR                                  
    BIT         0x2,A                                   
    JR          NZ,SAVRUN1                              
; REPORTF
WPRTER                       
    LD          A,0x2e                                  
    JP          ERRR                                    
SAVRUN1                       
    LD          A,(SNAPINF)                             
    AND         A                                       
    JR          NZ,SAVNOASK                             
    LD          A,(AIFASK)                              
    AND         A                                       
    JR          NZ,SAVNOASK                             
    PUSH        HL                                      
    PUSH        DE                                      
    LD          DE,0x3af                                
    LD          A,0xbe                                  
    CALL        KEYMSG                                  
    POP         DE                                      
    POP         HL                                      
    JP          NC,REPORTF                              
SAVNOASK                      
    CALL        DFILER                                  
SAVNODEL                      
    POP         DE                                      
    LD          HL,(STARTADR)                           
    CALL        SAVEFILE                                
    JP          LOADBEND                                
SLMASTR                       
    CALL        DIVSTRING                               
    CALL        SETWDNM                                 
    CALL        ANALWDNM                                
    JR          Z,SLMNODR                               
    INC         A                                       
SLMNODR                       
    ; EX          AF,AF_                                  
    EX AF,AF'
    CALL        ARRANGNM                                
    JP          NZ,REPORTF                              
    JP          C,REPORTF                               
    RET                                                 
COPYF                         
    CALL        SETCOPYNM                               
    PUSH        AF                                      
    LD          HL,0x3e80                               
    LD          DE,0x3e95                               
    LD          BC,0x15                                 
    LDIR                                                
    CALL        SETCOPYNM                               
    PUSH        AF                                      
    LD          HL,0x3e80                               
    LD          DE,0x3e95                               
    LD          BC,0xa                                  
    CALL        VERIFY                                  
    JR          NZ,COPYF2                               
    POP         AF                                      
    JP          C,REPORTF                               
    POP         AF                                      
    JP          C,REPORTF                               
    LD          HL,0x3e8a                               
    LD          DE,0x3e9f                               
    LD          BC,0xa                                  
    CALL        VERIFY                                  
    JP          Z,REPORTF                               
    LD          A,(EXTE1)                               
    ; LD          HL,0x3ea9                               
    LD HL,EXTE2
    ; CP          (HL=>EXTE2)                             
    CP (HL)
    JP          NZ,REPORTF                              
    LD          B,0xff                                  
    JR          COPYF4                                  
COPYF2                        
    POP         AF                                      
    LD          B,0x0                                   
    JR          C,COPYF3                                
    POP         AF                                      
    JR          C,COPYF4                                
    DEC         B                                       
    JR          COPYF4                                  
COPYF3                        
    POP         AF                                      
    JP          NC,REPORTF                              
COPYF4                        
    LD          C,0x0                                   
    NOP                                                 
    NOP                                                 
    NOP                                                 
    NOP                                                 
    PUSH        BC                                      
    LD          DE,(STKEND)                             
    LD          HL,(RAMTOP)                             
    DEC         H                                       
    SBC         HL,DE                                   
    JR          NC,COPYF5                               
REPORT4                       
    LD          A,0x3                                   
    JP          ERRR                                    
COPYF5                        
    LD          A,H                                     
    SRL         A                                       
    JR          Z,REPORT4                               
    LD          (VALSYX),A                              
    LD          (VALSYY),DE                             
    LD          A,0xff                                  
    LD          (VALSYX1),A                             
COPYLOOP                      
    CALL        SETACT                                  
    LD          A,(VALSYX1)                             
    CALL        NEXTMASK                                
    LD          (VALSYX1),A                             
    JP          NZ,ENDCOPY                              
    CALL        GETATR                                  
    BIT         0x3,A                                   
    JP          Z,REPORTE                               
    LD          DE,0x3eb4                               
    LD          BC,0x20                                 
    LDIR                                                
    ; LD          HL,0x3ec5                               
    LD HL,SVFSC
    ; LD          E,(HL=>SVFSC)                           
    LD E,(HL)
    INC         HL                                      
    ; LD          D,(HL=>DAT_ram_3ec6)                    
    LD D,(HL)
    LD          (STARTADR),DE                           
    CALL        CHNGDRNM                                
    POP         BC                                      
    PUSH        BC                                      
    INC         B                                       
    JR          Z,COPYF6                                
    ; LD          HL,0x3eb4                               
    LD HL,SVHEAD
    ; LD          A,(HL=>SVHEAD)                          
    LD A,(HL)
    LD          (EXTE1),A                               
    INC         HL                                      
    LD          DE,0x3e8a                               
    LD          BC,0xa                                  
    LDIR                                                
COPYF6                        
    CALL        SETACT                                  
    CALL        ERAVAR                                  
    CALL        DELALLFIL                               
    CALL        FIRSTEMPTY                              
    JP          NZ,REPORTV                              
    POP         BC                                      
    PUSH        BC                                      
    PUSH        HL                                      
    EX          DE,HL                                   
    INC         B                                       
    JR          Z,COPYFONE                              
    LD          HL,0x3eb4                               
    LD          BC,0x20                                 
    LDIR                                                
    JR          COPYFILE                                
COPYFONE                      
    LD          A,(EXTE1)                               
    ; LD          (DE=>DAT_ram_3ec6),A                    
    LD (DE),A
    INC         DE                                      
    LD          HL,0x3e8a                               
    LD          BC,0xa                                  
    LDIR                                                
    LD          HL,0x3ebf                               
    LD          BC,0x15                                 
    LDIR                                                
COPYFILE                      
    LD          HL,0x0                                  
    CALL        FIEMPTYFAT                              
    JP          NZ,RETREP                               
    LD          (LENDAT),HL                             
    LD          DE,0xc00                                
    CALL        WRTOFAT                                 
    EX          DE,HL                                   
    POP         HL                                      
    LD          A,0x11                                  
    CALL        ADDHLA                                  
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    CALL        WSCADR                                  
    CALL        WFATIFCH                                
COPYRD                        
    CALL        CHNGDRNM                                
    CALL        SETACT                                  
    CALL        ERAVAR                                  
    LD          DE,(VALSYY)                             
    LD          HL,(STARTADR)                           
    LD          A,(VALSYX)                              
COPYRDSK                      
    PUSH        AF                                      
    PUSH        HL                                      
    CALL        LOGFYZ                                  
    EX          DE,HL                                   
    LD          DE,0x100                                
    CALL        BREADA                                  
    EX          (SP),HL                                 
    CALL        GETWTEST                                
    BIT         0x3,D                                   
    JR          NZ,CPYRDLST                             
    EX          DE,HL                                   
    POP         DE                                      
    POP         AF                                      
    DEC         A                                       
    JR          NZ,COPYRDSK                             
    LD          (STARTADR),HL                           
    JR          CPYFULB                                 
CPYRDLST                      
    PUSH        DE                                      
    CALL        CHNGDRNM                                
    CALL        SETACT                                  
    CALL        ERAVAR                                  
    POP         DE                                      
    POP         AF                                      
    POP         AF                                      
    PUSH        DE                                      
    LD          B,A                                     
    LD          A,(VALSYX)                              
    SUB         B                                       
    INC         A                                       
    JR          COPYBUF                                 
CPYFULB                       
    CALL        CHNGDRNM                                
    CALL        SETACT                                  
    CALL        ERAVAR                                  
    LD          HL,0x8c00                               
    PUSH        HL                                      
    LD          A,(VALSYX)                              
COPYBUF                       
    LD          DE,(VALSYY)                             
    LD          HL,(LENDAT)                             
    PUSH        AF                                      
COPYWSC                       
    PUSH        HL                                      
    CALL        LOGFYZ                                  
    EX          DE,HL                                   
    LD          DE,0x100                                
    LD          A,(WORKDR)                              
    CALL        BWRITE                                  
    POP         DE                                      
    POP         AF                                      
    DEC         A                                       
    JR          Z,COPYIFALL                             
    PUSH        AF                                      
    EX          DE,HL                                   
    PUSH        DE                                      
    PUSH        HL                                      
    CALL        FIEMPTYFAT                              
    JR          NZ,COPYNOEM                             
    POP         DE                                      
    EX          DE,HL                                   
    CALL        WRTOFAT                                 
    EX          DE,HL                                   
    POP         DE                                      
    JR          COPYWSC                                 
COPYIFALL                     
    EX          DE,HL                                   
    POP         DE                                      
    BIT         0x7,D                                   
    RES         0x7,D                                   
    JR          NZ,CPYNOEND                             
    CALL        WRTOFAT                                 
    CALL        WFATIFCH                                
    CALL        CHNGDRNM                                
    POP         BC                                      
    INC         C                                       
    PUSH        BC                                      
    JP          COPYLOOP                                
ENDCOPY                       
    LD          A,0xfe                                  
    RST         RST28                                   
    dw          1601h                                   
    LD          A,0xd                                   
    RST         RST10                                   
    POP         BC                                      
    LD          B,0x0                                   
    CALL        BCPRT                                   
    XOR         A                                       
    LD          DE,0x1c44                               
    CALL        PRTMES                                  
    RET                                                 
COPYNOEM                      
    POP         HL                                      
    LD          DE,0xc00                                
    CALL        WRTOFAT                                 
    CALL        WFATIFCH                                
    JP          RETREP                                  
CPYNOEND                      
    PUSH        HL                                      
    CALL        FIEMPTYFAT                              
    JR          NZ,COPYNOEM                             
    POP         DE                                      
    EX          DE,HL                                   
    CALL        WRTOFAT                                 
    EX          DE,HL                                   
    LD          DE,0xc00                                
    CALL        WRTOFAT                                 
    LD          (LENDAT),HL                             
    CALL        WFATIFCH                                
    JP          COPYRD                                  
TXTMOVE                       
    db          0FFh                                     
    db          " File(s) copied.",08Dh                  
CHNGDRNM                      
    LD          HL,0x3e80                               
    LD          DE,0x3e95                               
    LD          BC,0x15                                 
    PUSH        AF                                      
CHANGDR1                      
    ; LD          A,(DE=>DNZONE2)                         
    LD A,(DE)
    LDI                                                 
    DEC         HL                                      
    ; LD          (HL=>DNZONE1),A                         
    LD (HL),A
    INC         HL                                      
    JP          PE,CHANGDR1                             
    POP         AF                                      
    RET                                                 
SETCOPYNM                     
    CALL        DIVSTRING                               
    CALL        SETWDNM                                 
    CALL        ANALWDNM                                
    JR          C,SETCOPYN1                             
    LD          A,0x2a                                  
    JP          ERRR                                    
SETCOPYN1                     
    INC         A                                       
    JP          Z,REPORTX                               
    CALL        ARRANGNM                                
    PUSH        AF                                      
    LD          A,(EXTE1)                               
    CP          0x3f                                    
    JR          NZ,SETCOPYN2                            
    POP         AF                                      
    SCF                                                 
    RET                                                 
SETCOPYN2                     
    POP         AF                                      
    RET                                                 
SETACT                        
    PUSH        BC                                      
    PUSH        DE                                      
    PUSH        HL                                      
    PUSH        AF                                      
    XOR         A                                       
    LD          (VARIA1),A                              
    LD          (VARIA2),A                              
    DEC         A                                       
    LD          (VARIA3),A                              
    CALL        ANALWDNM                                
    JR          NZ,OKANALW                              
    LD          A,0x3b                                  
    JP          ERRR                                    
OKANALW                       
    JR          C,SETNAME                               
    INC         A                                       
    JR          NZ,SETDRIVE                             
    LD          A,0x20                                  
    JP          ERRR                                    
SETDRIVE                      
    DEC         A                                       
    LD          (WORKDR),A                              
    JP          GETPAR1                                 
SETNAME                       
    CALL        SETDRV                                  
    JR          Z,SETRET                                
    CALL        INITALLDR                               
    CALL        SETDRV                                  
    JR          Z,SETRET                                
    LD          DE,0x3af                                
    LD          A,0x3c                                  
    CALL        KEYMSG                                  
    JR          C,SETNAME                               
    LD          A,0x2c                                  
    JP          ERRR                                    
CMPDSK                        
    PUSH        BC                                      
    PUSH        DE                                      
    PUSH        HL                                      
    PUSH        AF                                      
    CALL        RDBOOT                                  
    CALL        NAMEDISK                                
    LD          DE,0x3ac0                               
    LD          BC,0xc                                  
    CALL        VERIFY                                  
    JP          NZ,SETPARAM                             
SETRET                        
    POP         AF                                      
    POP         HL                                      
    POP         DE                                      
    POP         BC                                      
    CP          A                                       
    RET                                                 
GETWTEST                      
    CALL        GETFAT                                  
    PUSH        AF                                      
    LD          A,D                                     
    CP          0xd                                     
    JR          Z,REPORT1                               
    OR          E                                       
    JR          Z,REPORT1                               
    POP         AF                                      
    RET                                                 
REPORT1                       
    LD          A,0x34                                  
    JP          ERRR                                    
GETFAT                        
    PUSH        HL                                      
    CALL        READFATSC                               
    JR          C,IFODD                                 
    LD          E,(HL)                                  
    INC         HL                                      
    LD          A,(HL)                                  
    AND         0xf0                                    
    RRCA                                                
    RRCA                                                
    RRCA                                                
    RRCA                                                
    LD          D,A                                     
    POP         HL                                      
    RET                                                 
IFODD                         
    LD          A,(HL)                                  
    AND         0xf                                     
    LD          D,A                                     
    INC         HL                                      
    LD          E,(HL)                                  
    POP         HL                                      
    RET                                                 
WRTOFAT                       
    PUSH        HL                                      
    PUSH        DE                                      
    CALL        READFATSC                               
    LD          A,0xff                                  
    LD          (CHNGFLAG),A                            
    POP         DE                                      
    PUSH        DE                                      
    JR          C,WISODD                                
    LD          (HL),E                                  
    INC         HL                                      
    LD          A,D                                     
    RRCA                                                
    RRCA                                                
    RRCA                                                
    RRCA                                                
    LD          D,A                                     
    LD          A,(HL)                                  
    AND         0xf                                     
    OR          D                                       
    LD          (HL),A                                  
    POP         DE                                      
    POP         HL                                      
    RET                                                 
WISODD                        
    LD          A,(HL)                                  
    AND         0xf0                                    
    OR          D                                       
    LD          (HL),A                                  
    INC         HL                                      
    LD          (HL),E                                  
    POP         DE                                      
    POP         HL                                      
    RET                                                 
READFATSC                     
    PUSH        BC                                      
    LD          BC,0x6a9                                
    AND         A                                       
    SBC         HL,BC                                   
    JR          C,NOHIGHER                              
    LD          A,0x3b                                  
    JP          ERRR                                    
NOHIGHER                      
    ADD         HL,BC                                   
    LD          C,0x0                                   
    LD          DE,0x155                                
    AND         A                                       
CALCSCFAT                     
    INC         C                                       
    SBC         HL,DE                                   
    JR          NC,CALCSCFAT                            
    ADD         HL,DE                                   
    LD          D,H                                     
    LD          E,L                                     
    ADD         HL,HL                                   
    ADD         HL,DE                                   
    SRL         H                                       
    RR          L                                       
    PUSH        AF                                      
    LD          A,(FATDR)                               
    LD          B,A                                     
    LD          A,(WORKDR)                              
    CP          B                                       
    JR          NZ,MUSTREAD                             
    LD          A,(FATSC)                               
    CP          C                                       
    JR          Z,RDFATPOL                              
MUSTREAD                      
    PUSH        HL                                      
    PUSH        BC                                      
    CALL        WFATIFCH                                
    POP         BC                                      
    LD          A,C                                     
    LD          (FATSC),A                               
    LD          B,0x0                                   
    LD          DE,0x101                                
    LD          HL,0x3c00                               
    CALL        BREADA                                  
    POP         HL                                      
    LD          A,(WORKDR)                              
    LD          (FATDR),A                               
RDFATPOL                      
    LD          DE,0x3c00                               
    ADD         HL,DE                                   
    POP         AF                                      
    POP         BC                                      
    RET                                                 
WFATIFCH                      
    PUSH        BC                                      
    PUSH        DE                                      
    PUSH        HL                                      
    PUSH        AF                                      
    LD          A,(CHNGFLAG)                            
    AND         A                                       
    JR          Z,NOWFAT                                
    LD          A,(FATSC)                               
    LD          C,A                                     
    LD          A,(FATDR)                               
    LD          DE,0x101                                
    LD          HL,0x3c00                               
    LD          B,0x0                                   
    CALL        BWRITE                                  
    XOR         A                                       
    LD          (CHNGFLAG),A                            
NOWFAT                        
    POP         AF                                      
    POP         HL                                      
    POP         DE                                      
    POP         BC                                      
    RET                                                 
FREECOUNT                     
    LD          BC,0x0                                  
    LD          HL,0xe                                  
FRCOUNT1                      
    CALL        GETFAT                                  
    INC         HL                                      
    LD          A,D                                     
    CP          0xd                                     
    JR          NZ,NOSYS                                
    LD          A,E                                     
    CP          0xdd                                    
    RET         Z                                       
    OR          D                                       
NOSYS                         
    OR          E                                       
    JR          NZ,FRCOUNT1                             
    INC         BC                                      
    JR          FRCOUNT1                                
SECPERDISK                    
    LD          B,(IX+0x2)                              
    BIT         0x4,(IX+0x1)                            
    JR          Z,SECPD1                                
    RLC         B                                       
SECPD1                        
    LD          C,0x0                                   
FYZLOG                        
    PUSH        DE                                      
    LD          E,(IX+0x3)                              
    LD          D,0x0                                   
    LD          H,D                                     
    LD          L,C                                     
    INC         B                                       
    JR          CALCLOG1                                
CALCLOG                       
    ADD         HL,DE                                   
CALCLOG1                      
    DJNZ        CALCLOG                                 
    POP         DE                                      
    RET                                                 
LOGFYZ                        
    PUSH        DE                                      
    LD          E,(IX+0x3)                              
    LD          D,0x0                                   
    LD          B,0xff                                  
    AND         A                                       
CALCLF                        
    INC         B                                       
    SBC         HL,DE                                   
    JR          NC,CALCLF                               
    ADD         HL,DE                                   
    LD          C,L                                     
    POP         DE                                      
    RET                                                 
READADR                       
    INC         A                                       
    BIT         0x7,A                                   
    RET         NZ                                      
    PUSH        AF                                      
    PUSH        BC                                      
    PUSH        DE                                      
    LD          B,A                                     
    AND         0xf                                     
    LD          C,A                                     
    PUSH        BC                                      
    LD          A,B                                     
    AND         0x70                                    
    RLCA                                                
    RLA                                                 
    PUSH        AF                                      
    RLCA                                                
    RLCA                                                
    LD          B,A                                     
    POP         AF                                      
    LD          A,B                                     
    RLA                                                 
    LD          HL,0x6                                  
    CALL        ADDHLA                                  
    CALL        LOGFYZ                                  
    LD          A,(WORKDR)                              
    LD          H,A                                     
    LD          A,(ADRDR)                               
    CP          H                                       
    JR          NZ,RDSFDR                               
    LD          HL,(ADRSCTR)                            
    SBC         HL,BC                                   
    JR          Z,RDADRCALC                             
RDSFDR                        
    LD          A,(WORKDR)                              
    LD          (ADRDR),A                               
    LD          (ADRSCTR),BC                            
    LD          HL,0x3800                               
    LD          DE,0x101                                
    CALL        BREADA                                  
RDADRCALC                     
    POP         BC                                      
    LD          A,C                                     
    RLCA                                                
    RLCA                                                
    RLCA                                                
    RLCA                                                
    LD          D,0x0                                   
    RLA                                                 
    LD          E,A                                     
    RL          D                                       
    LD          HL,0x3800                               
    ADD         HL,DE                                   
    POP         DE                                      
    POP         BC                                      
    POP         AF                                      
    CP          A                                       
    RET                                                 
WSCADR                        
    PUSH        AF                                      
    PUSH        BC                                      
    PUSH        DE                                      
    PUSH        HL                                      
    LD          A,(ADRDR)                               
    LD          BC,(ADRSCTR)                            
    LD          DE,0x101                                
    LD          HL,0x3800                               
    CALL        BWRITE                                  
    POP         HL                                      
    POP         DE                                      
    POP         BC                                      
    POP         AF                                      
    RET                                                 
RDBOOT                        
    LD          HL,0x3a00                               
    LD          DE,0x101                                
    LD          BC,0x0                                  
    CALL        BREADA                                  
    LD          HL,0x3acc                               
    LD          DE,0xf10                                
    LD          BC,0x4                                  
    CALL        VERIFY                                  
    RET         Z                                       
    LD          A,0xff                                  
    LD          (FATDR),A                               
    LD          A,0x20                                  
    JP          ERRR                                    
GETPAR                        
    PUSH        BC                                      
    PUSH        DE                                      
    PUSH        HL                                      
    PUSH        AF                                      
GETPAR1                       
    CALL        DRVSYS                                  
    CALL        RDBOOT                                  
SETPARAM                      
    LD          A,(IX+0x5)                              
    LD          (IX+0x1),A                              
    BIT         0x4,(IX+0x5)                            
    JR          NZ,DSIDE                                
    LD          A,(DAT_ram_3ab1)                        
    BIT         0x4,A                                   
    ; JR          NZ,REPORTX
    JR NZ,SETDSE                              
DSIDE                         
    LD          A,(DAT_ram_3ab2)                        
    CP          (IX+0x6)                                
    JR          Z,TRACKOK                               
    JR          C,TRACKOK                               
    SUB         (IX+0x6)                                
    CP          0x8                                     
    ; JR          NC,REPORTX
    JR NC,SETDSE
    LD          A,(DAT_ram_3ab2)                        
TRACKOK                       
    LD          (IX+0x2),A                              
    ADD         A,A                                     
    CP          (IX+0x6)                                
    JR          NZ,NOLINH                               
    SET         0x5,(IX+0x1)                            
NOLINH                        
    LD          A,(DAT_ram_3ab1)                        
    AND         0x13                                    
    LD          B,A                                     
    LD          A,(IX+0x1)                              
    AND         0xec                                    
    OR          B                                       
    LD          (IX+0x1),A                              
    LD          A,(DAT_ram_3ab3)                        
    LD          (IX+0x3),A                              
    CALL        NAMEDISK                                
    EX          DE,HL                                   
    LD          HL,0x3ac0                               
    LD          BC,0xc                                  
    LDIR                                                
    POP         AF                                      
    LD          L,A                                     
    OR          0xff                                    
    LD          A,L                                     
    POP         HL                                      
    POP         DE                                      
    POP         BC                                      
    RET                                                 
; REPORTX 
SETDSE  ; error Bad device type
    LD          A,0x20                                  
    JP          ERRR                                    
VERIFY                        
    LD          A,(DE)                                  
    INC         DE                                      
    CPI                                                 
    RET         NZ                                      
    RET         PO                                      
    JR          VERIFY                                  
SETDRV                        
    XOR         A                                       
FINDNMDR                      
    PUSH        AF                                      
    LD          (WORKDR),A                              
    CALL        DRVCMP                                  
    JR          Z,NEXTNM                                
    CALL        NAMEDISK                                
    LD          DE,0x3e80                               
    LD          BC,0xa                                  
    CALL        VERIFY                                  
    JR          NZ,NEXTNM                               
    LD          A,(WORKDR)                              
    CALL        TESTDR                                  
    JR          Z,NEXTNM                                
    CALL        CMPDSK                                  
    JR          Z,FINDNMOK                              
NEXTNM                        
    POP         AF                                      
    INC         A                                       
    CP          0x4                                     
    JR          C,FINDNMDR                              
    OR          A                                       
    RET                                                 
FINDNMOK                      
    POP         AF                                      
    LD          (WORKDR),A                              
    CP          A                                       
    RET                                                 
INITALLDR                     
    XOR         A                                       
INITDR                        
    PUSH        AF                                      
    CALL        DRVCMP                                  
    JR          Z,NOINITDR                              
    POP         AF                                      
    PUSH        AF                                      
    CALL        TESTDR                                  
    JR          Z,NOINITDR                              
    POP         AF                                      
    PUSH        AF                                      
    LD          (WORKDR),A                              
    CALL        GETPAR                                  
NOINITDR                      
    POP         AF                                      
    INC         A                                       
    CP          0x4                                     
    JR          C,INITDR                                
    RET                                                 
DELALLFIL                     
    CALL        SETACT                                  
    CALL        FIRSTMASK                               
    RET         NZ                                      
DELFIND                       
    PUSH        AF                                      
    CALL        GETATR                                  
    BIT         0x0,A                                   
    JR          NZ,NODELPR                              
    LD          A,0x30                                  
    JP          ERRR                                    
NODELPR                       
    CALL        DFILER                                  
    POP         AF                                      
    CALL        NEXTMASK                                
    JR          Z,DELFIND                               
    CALL        WFATIFCH                                
    XOR         A                                       
    RET                                                 
DFILER                        
    LD          (HL),0xe5                               
    CALL        WSCADR                                  
    LD          DE,0x11                                 
    ADD         HL,DE                                   
    LD          A,(HL)                                  
    INC         HL                                      
    LD          H,(HL)                                  
    LD          L,A                                     
DFILER1                       
    CALL        GETWTEST                                
    PUSH        DE                                      
    LD          DE,0x0                                  
    CALL        WRTOFAT                                 
    POP         HL                                      
    BIT         0x3,H                                   
    RET         NZ                                      
    JR          DFILER1                                 
LOAFND                        
    PUSH        HL                                      
    LD          HL,(SVADRA)                             
    JR          LOADFND1                                
LOAWITHF                      
    PUSH        HL                                      
    CALL        FIRSTMASK                               
    JR          Z,LOADFND1                              
REPORTS                       
    LD          A,0x1b                                  
    JP          ERRR                                    
LOADFND1                      
    CALL        GETATR                                  
    BIT         0x3,A                                   
    JR          NZ,LOAFND2                              
REPORTE                       
    LD          A,0x2d                                  
    JP          ERRR                                    
LOAFND2                       
    LD          A,0x11                                  
    CALL        ADDHLA                                  
    LD          A,(HL)                                  
    INC         HL                                      
    LD          H,(HL)                                  
    LD          L,A                                     
LOAFNDLP                      
    PUSH        HL                                      
    CALL        LOGFYZ                                  
    POP         HL                                      
    PUSH        BC                                      
    CALL        COUNTCSEC                               
    EX          DE,HL                                   
    BIT         0x3,H                                   
    LD          D,B                                     
    LD          E,0x0                                   
    POP         BC                                      
    JR          NZ,LOAFND4                              
    EX          (SP),HL                                 
    CALL        BREADA                                  
    EX          (SP),HL                                 
    JR          LOAFNDLP                                
LOAFND4                       
    BIT         0x1,H                                   
    JR          Z,LFNDNULL                              
    LD          A,H                                     
    AND         0x1                                     
    LD          H,A                                     
    LD          A,H                                     
    OR          L                                       
    JR          NZ,LOAFND3                              
    POP         HL                                      
    CALL        BREADA                                  
    CALL        ERAVAR                                  
    RET                                                 
LOAFND3                       
    DEC         D                                       
    JR          Z,LOAFNDLS                              
    EX          (SP),HL                                 
    CALL        BREADA                                  
    EX          (SP),HL                                 
LOAFNDLS                      
    PUSH        HL                                      
    LD          HL,(SVFRSC)                             
    CALL        LOGFYZ                                  
    LD          HL,0x3a00                               
    LD          DE,0x101                                
    CALL        BREADA                                  
    POP         BC                                      
    POP         DE                                      
    LD          HL,0x3a00                               
    LDIR                                                
LOAFNDEND                     
    CALL        ERAVAR                                  
    RET                                                 
LFNDNULL                      
    POP         HL                                      
    JR          LOAFNDEND                               
TRANSTOSEC                    
    LD          A,D                                     
    AND         0xfe                                    
    RRCA                                                
    LD          B,A                                     
    LD          A,D                                     
    AND         0x1                                     
    LD          D,A                                     
    LD          A,D                                     
    OR          E                                       
    RET         Z                                       
    INC         B                                       
    RET                     
FINDANDFILL                   
    CALL        FIRSTEMPTY                              
    JR          Z,IFFIND                                
REPORTV                       
    LD          A,0x1e                                  
    JP          ERRR                                    
IFFIND                        
    LD          A,(EXTE1)                               
    LD          (HL),A                                  
    INC         HL                                      
    LD          DE,0x3e8a                               
    LD          BC,0xa                                  
    EX          DE,HL                                   
    LDIR                                                
    EX          DE,HL                                   
    RET                                                 
SAVEFILE                      
    PUSH        HL                                      
    PUSH        DE                                      
    CALL        FINDANDFILL                             
    POP         DE                                      
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    INC         HL                                      
    LD          BC,(VALSYX)                             
    LD          (HL),C                                  
    INC         HL                                      
    LD          (HL),B                                  
    INC         HL                                      
    LD          BC,(VALSYY)                             
    LD          (HL),C                                  
    INC         HL                                      
    LD          (HL),B                                  
    INC         HL                                      
    PUSH        HL                                      
    INC         HL                                      
    INC         HL                                      
    LD          A,(HEAD20)                              
    LD          (HL),A                                  
    INC         HL                                      
    LD          (HL),0xf                                
    INC         HL                                      
    LD          (HL),0x0                                
    CALL        TRANSTOSEC                              
    OR          B                                       
    LD          A,D                                     
    JR          NZ,SAVEFILE1                            
    LD          A,0xc                                   
    INC         B                                       
    JR          SAVEFILE2                               
SAVEFILE1                     
    OR          0xe                                     
SAVEFILE2                     
    LD          D,A                                     
    ; CALL        FIEMPTYFAT
    CALL SEACHN
    JR          Z,SAVEFILE3                             
    LD          HL,0x0                                  
    CALL        FIEMPTYFAT                              
    JR          NZ,RETREP                               
SAVEFILE3                     
    EX          DE,HL                                   
    EX          (SP),HL                                 
    LD          (HL),E                                  
    INC         HL                                      
    LD          (HL),D                                  
    CALL        WSCADR                                  
    EX          DE,HL                                   
    POP         DE                                      
    PUSH        HL                                      
    CALL        SAVETOFAT                               
    INC         B                                       
    DEC         B                                       
    JR          NZ,RETREP                               
    POP         HL                                      
SAVEFILE4                     
    PUSH        HL                                      
    CALL        LOGFYZ                                  
    POP         HL                                      
    PUSH        BC                                      
    CALL        COUNTCSEC                               
    PUSH        DE                                      
    LD          D,B                                     
    LD          E,0x0                                   
    POP         HL                                      
    POP         BC                                      
    EX          (SP),HL                                 
    LD          A,(WORKDR)                              
    CALL        BWRITE                                  
    EX          (SP),HL                                 
    BIT         0x3,H                                   
    JR          Z,SAVEFILE4                             
    POP         HL                                      
    CALL        ERAVAR                                  
    RET                                                 
RETREP                        
    CALL        ERAVAR                                  
    LD          A,0x1d                                  
    JP          ERRR                                    
COUNTCSEC                     
    LD          B,0x0                                   
    PUSH        HL                                      
COUNTSEC1                     
    LD          (SVFRSC),HL                             
    CALL        GETWTEST                                
    DEC         DE                                      
    AND         A                                       
    SBC         HL,DE                                   
    ADD         HL,DE                                   
    INC         DE                                      
    INC         HL                                      
    PUSH        AF                                      
    INC         B                                       
    POP         AF                                      
    JR          Z,COUNTSEC1                             
    POP         HL                                      
    RET                                                 
SAVETOFAT                     
    PUSH        DE                                      
SAVE2FLP                      
    PUSH        HL                                      
    DEC         B                                       
    JR          Z,SAVETOF1                              
    CALL        FIEMPTYFAT                              
    JR          NZ,SAVETOF1                             
    EX          DE,HL                                   
    POP         HL                                      
    CALL        WRTOFAT                                 
    EX          DE,HL                                   
    JR          SAVE2FLP                                
SAVETOF1                      
    POP         HL                                      
    POP         DE                                      
    CALL        WRTOFAT                                 
    CALL        WFATIFCH                                
    RET                                                 
FIEMPTYFAT                    
    PUSH        DE                                      
FINDEFAT1                     
    INC         HL                                      
    CALL        GETFAT                                  
    LD          A,D                                     
    OR          E                                       
    JR          Z,IFFATEMPTY                            
    LD          DE,0x6a8                                
    SBC         HL,DE                                   
    ADD         HL,DE                                   
    JR          C,FINDEFAT1                             
IFFATEMPTY                    
    AND         A                                       
    POP         DE                                      
    RET                                                 
; FIEMPTYFAT
;A try to find the contiguous FAT chain
SEACHN
    PUSH        DE                                      
    PUSH        BC                                      
    LD          HL,0x0                                  
FINDBE1                       
    CALL        FIEMPTYFAT                              
    JR          NZ,FINDBERR                             
    PUSH        HL                                      
FINDBE2                       
    DEC         B                                       
    JR          Z,FINDBEOK                              
    INC         HL                                      
    CALL        GETFAT                                  
    LD          A,D                                     
    OR          E                                       
    JR          Z,FINDBE2                               
    JR          FINDBNFL                                
FINDBEOK                      
    POP         HL                                      
FINDBERR                      
    POP         BC                                      
    POP         DE                                      
    RET                                                 
FINDBNFL                      
    POP         BC                                      
    POP         BC                                      
    PUSH        BC                                      
    JR          FINDBE1                                 
FIRSTMASK                     
    LD          A,0xff                                  
NEXTMASK                      
    CALL        RDNOEMPTY                               
    RET         NZ                                      
    CALL        TESTMSK                                 
    JR          NZ,NEXTMASK                             
    RET                                                 
TESTMSK                       
    PUSH        HL                                      
    PUSH        BC                                      
    PUSH        DE                                      
    LD          C,A                                     
    LD          A,(EXTE1)                               
    CP          '?'                                     
    ; JR          Z,TESTNM
    JR Z,TESTMSK2
    CP          (HL)                                    
    JR          NZ,NONAME                               
; TESTNM
TESTMSK2
    INC         HL                                      
    LD          B,0xa                                   
    ; LD          DE,0x3e8a 
    LD DE,FNZONE1
TSTNMLOOP                     
    ; LD          A,(DE=>FNZONE1)                         
    LD A,(DE)
    CP          0x3f                                    
    JR          Z,NEXTTEST                              
    CP          (HL)                                    
    JR          NZ,NONAME                               
NEXTTEST                      
    INC         DE                                      
    INC         HL                                      
    DJNZ        TSTNMLOOP                               
NONAME                        
    LD          A,C                                     
    POP         DE                                      
    POP         BC                                      
    POP         HL                                      
    RET                                                 
FIRSTEMPTY                    
    LD          A,0xff                                  
NXTEMPT                       
    CALL        READADR                                 
    RET         NZ                                      
    PUSH        BC                                      
    LD          B,A                                     
    LD          A,(HL)                                  
    CP          0xe5                                    
    LD          A,B                                     
    POP         BC                                      
    JR          NZ,NXTEMPT                              
    RET                                                 
RDNOEMPTY                     
    CALL        READADR                                 
    RET         NZ                                      
    PUSH        BC                                      
    LD          B,A                                     
    LD          A,(HL)                                  
    CP          0xe5                                    
    LD          A,B                                     
    POP         BC                                      
    JR          Z,RDNOEMPTY                             
    CP          A                                       
    RET                                                 
ERAVAR                        
    XOR         A                                       
    LD          (FATSC),A                               
    LD          (CHNGFLAG),A                            
    LD          (ADRSCTR),A                             
    LD          (ADRSCTR+1),A                           
    LD          (VARIA1),A                              
    LD          (VARIA2),A                              
    DEC         A                                       
    LD          (VARIA3),A                              
    LD          (FATDR),A                               
    LD          (ADRDR),A                               
    RET                                                 
NAMEDISK                      
    PUSH        IX                                      
    POP         HL                                      
    LD          DE,0x30                                 
    ADD         HL,DE                                   
    RET                                                 
DRVSYS                        
    PUSH        BC                                      
    PUSH        AF                                      
    LD          A,(WORKDR)                              
    CALL        DRVCMP                                  
    POP         AF                                      
    POP         BC                                      
    RET                                                 
DRVCMP                        
    RLCA                                                
    RLCA                                                
    LD          C,A                                     
    RLCA                                                
    ADD         A,C                                     
    LD          C,A                                     
    LD          B,0x0                                   
    ; LD          IX,0x3e00
    LD IX,DRPARZN                            
    ADD         IX,BC                                   
    ; BIT         0x0,(IX+0x0)=>DRPARZN
    BIT 0,(IX+0)
    RET                                                 
KEYMSG                        
    PUSH        HL                                      
    PUSH        BC                                      
    LD          HL,(CURCHL)                             
    PUSH        HL                                      
    PUSH        AF                                      
    PUSH        DE                                      
    LD          A,0xfd                                  
    RST         RST28                                   
    dw          1601h                                   
    POP         DE                                      
    POP         AF                                      
    PUSH        AF                                      
    AND         0x7f                                    
    INC         A                                       
    CALL        PRTMES                                  
    POP         AF                                      
    AND         0x80                                    
    RLCA                                                
    LD          DE,0x21fb                               
    CALL        PRTMES                                  
    SET         0x5,(IY+0x2)                            
    RST         RST28                                   
    dw          15D4h                                   
    POP         HL                                      
    LD          (CURCHL),HL                             
    POP         BC                                      
    POP         HL                                      
    LD          A,(LAST_K)                              
    AND         0xdf                                    
    CP          'R'                                     
    SCF                                                 
    RET         Z                                       
    CP          'P'                                     
    SCF                                                 
    RET         Z                                       
    AND         A                                       
    RET                                                 
TXTQUE                        
    db          80h                                     
    db          " (Retry = R",0A9h                       
    db          " (Proceed = P",0A9h                     
HWINIT                        
    LD          A,0xd0                                  
    OUT         (DAT_io_0081),A                         
    XOR         A                                       
HWINI0                        
    PUSH        AF                                      
    CALL        DRVCMP                                  
    PUSH        IX                                      
    POP         HL                                      
    INC         HL                                      
    LD          E,L                                     
    LD          D,H                                     
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    INC         HL                                      
    LD          BC,0x3                                  
    LDIR                                                
    RES         0x0,(IX+0x0)                            
    RES         0x7,(IX+0x0)                            
    LD          A,(IX+0x2)                              
    AND         A                                       
    JR          Z,HWINI1                                
    POP         AF                                      
    PUSH        AF                                      
    CALL        DRVSEL                                  
    CALL        HOME                                    
    OUT         (0x87),A                                
    AND         0x4                                     
    JR          Z,HWINI1                                
    SET         0x0,(IX+0x0)                            
    LD          (IX+0x4),0x0                            
    LD          A,0x36                                  
    LD          D,0x10                                  
    CALL        SEEK                                    
    LD          A,0x2                                   
    LD          D,0x10                                  
    CALL        SEEK                                    
    AND         0x4                                     
    LD          A,0x28                                  
    JR          NZ,TRK40                                
    LD          A,0x50                                  
TRK40                         
    LD          (IX+0x6),A                              
    LD          (IX+0x3),A                              
    CALL        HOME                                    
HWINI1                        
    POP         AF                                      
    INC         A                                       
    CP          0x2                                     
    JR          C,HWINI0                                
    CALL        DSKSTP                                  
    LD          A,0xc7                                  
    LD          (NMI),A                                 
    RET                                                 
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    db          0FFh                                     
    RET                                                 
BWRITE                        
    PUSH        HL                                      
LAB_ram_2297                  
    LD          HL,0x23be                               
    JR          BRWR0                                   
BFORMA                        
    PUSH        HL                                      
    LD          HL,0x23d8                               
    JR          BRWR0                                   
BREADA                        
    LD          A,(WORKDR)                              
BREAD                         
    PUSH        HL                                      
LAB_ram_22a6                  
    LD          HL,0x236a                               
BRWR0                         
    LD          (MODJPA2),HL                            
    ; LD          HL,0x3e63
    LD HL,MODJP1                               
    ; LD          (HL=>MODJP1),0xc3                       
    LD (HL),0xc3
    POP         HL                                      
BRWL0                         
    PUSH        BC                                      
    PUSH        AF                                      
    PUSH        DE                                      
    PUSH        HL                                      
    CALL        MODJP1                                  
    INC         C                                       
    DEC         C                                       
    JR          Z,BREAD1                                
    DEC         B                                       
    JR          NZ,BREAD2                               
    BIT         0x7,C                                   
    JR          Z,BREAD3                                
BREA71                        
    LD          A,0x36                                  
BREA72                        
    LD          DE,0x3af                                
BREAD6                        
    CALL        KEYMSG                                  
    JR          C,BREAD4                                
    LD          A,0x29                                  
    JP          ERRR                                    
BREAD3                        
    LD          A,C                                     
    AND         0x18                                    
    JR          NZ,BREA31                               
ERR45                         
    LD          A,0x3b                                  
    JP          ERRR                                    
BREA31                        
    LD          A,0x37                                  
    JR          BREA72                                  
BREAD4                        
    POP         HL                                      
    POP         DE                                      
    POP         AF                                      
    POP         BC                                      
    JR          BRWL0                                   
BREAD1                        
    POP         HL                                      
    POP         DE                                      
    POP         AF                                      
    LD          BC,0x200                                
    ADD         HL,BC                                   
    POP         BC                                      
    PUSH        AF                                      
    INC         C                                       
    LD          A,(IX+0x3)                              
    CP          C                                       
    JR          NZ,BREA11                               
    LD          C,0x0                                   
    INC         B                                       
BREA11                        
    POP         AF                                      
    DEC         D                                       
    JP          NZ,BRWL0                                
    RET                                                 
BREAD2                        
    DEC         B                                       
    JR          NZ,BREAD7                               
    LD          A,C                                     
    AND         0x9d                                    
    JR          Z,BREAD1                                
BREA81                        
    BIT         0x7,C                                   
    JR          NZ,BREA71                               
    BIT         0x4,C                                   
    JR          Z,BREAD8                                
    LD          A,0x38                                  
    JR          BREA72                                  
BREAD8                        
    BIT         0x3,C                                   
    JR          Z,ERR45                                 
    LD          A,0x39                                  
    JR          BREA72                                  
BREAD7                        
    DEC         B                                       
    JR          NZ,BREAD9                               
    LD          A,C                                     
    AND         0xdd                                    
    BIT         0x6,C                                   
    JR          Z,BREA81                                
    LD          A,0x3a                                  
    JR          BREA72                                  
BREAD9                        
    BIT         0x0,C                                   
    JR          Z,BREA91                                
    LD          A,0x22                                  
    JP          ERRR                                    
BREA91                        
    BIT         0x1,C                                   
    JR          Z,ERR45                                 
REPORTX                       
    LD          A,0x20                                  
    JP          ERRR                                    
    OR          0x1                                     
    EI                                                  
    RET                                                 
SEEK                          
    OUT         (DAT_io_0087),A                         
    AND         A                                       
    JR          Z,HOME                                  
    CALL        DELAY                                   
    LD          A,D                                     
    JR          TRACKSEEK                               
HOME                          
    LD          A,0x8                                   
TRACKSEEK                     
    LD          B,A                                     
    LD          A,(IX+0x1)                              
    AND         0xc0                                    
    RLCA                                                
    RLCA                                                
    OR          B                                       
    OUT         (DAT_io_0081),A                         
    CALL        DELAY                                   
WAITBUSY                      
    IN          A,(DAT_io_0081)                         
    BIT         0x0,A                                   
    JR          NZ,WAITBUSY                             
    LD          BC,0xf                                  
WAITHOME                      
    DJNZ        WAITHOME                                
    DEC         C                                       
    JR          NZ,WAITHOME                             
    RET                                                 
DREAD                         
    CALL        FINDTRACK                               
    JR          NC,DOOPRET                              
    LD          A,0x88                                  
    LD          B,0x2                                   
    LD          IX,0x25ea                               
DOWDCOM                       
    PUSH        AF                                      
    LD          A,(SELSTA1)                             
    SET         0x6,A                                   
    CALL        OUTTODR                                 
    POP         AF                                      
    PUSH        HL                                      
    ; LD          HL,0x3eeb  
    LD HL,SVSIDE                             
    ; OR          (HL=>SVSIDE)
    OR (HL)
    POP         HL                                      
DOWDCREP                      
    PUSH        AF                                      
    PUSH        HL                                      
    PUSH        DE                                      
    PUSH        BC                                      
    LD          C,0x87                                  
    LD          D,0x1                                   
    LD          B,C                                     
    OUT         (DAT_io_0081),A                         
DOWDL1                        
    IN          A,(DAT_io_0081)                         
    LD          B,C                                     
    AND         D                                       
    JR          Z,DOWDL1                                
DOWDL2                        
    IN          A,(DAT_io_0081)                         
    LD          B,C                                     
    AND         D                                       
    JR          NZ,DOWDL2                               
    LD          A,(SELSTA1)                             
    RES         0x6,A                                   
    CALL        OUTTODR                                 
    IN          A,(DAT_io_0081)                         
    POP         BC                                      
    POP         DE                                      
    POP         HL                                      
    LD          D,A                                     
    IN          A,(DAT_io_0085)                         
    DEC         A                                       
    OUT         (DAT_io_0085),A                         
    POP         AF                                      
    BIT         0x3,D                                   
    JR          Z,DONOCRC                               
    DEC         E                                       
    JR          NZ,DOWDCREP                             
DONOCRC                       
    LD          C,D                                     
DOOPRET                       
    CALL        DISKRET                                 
    RET                                                 
DWRITE                        
    CALL        FINDTRACK                               
    JR          NC,DONOCRC                              
    BIT         0x5,(IX+0x1)                            
    JR          Z,DWRITE1                               
ERR40IN80                     
    LD          BC,0x402                                
    JR          DOOPRET                                 
DWRITE1                       
    LD          IX,0x25ed                               
    LD          A,0xa8                                  
    LD          B,0x3                                   
    JR          DOWDCOM                                 
DFORMA                        
    CALL        FORFINDTR                               
    JR          NC,DOOPRET                              
    BIT         0x5,(IX+0x1)                            
    JR          NZ,ERR40IN80                            
    PUSH        BC                                      
    LD          HL,VRAM_ATTR                              
    LD          A,(ATTR_P)                              
    AND         0x38                                    
    LD          B,A                                     
    RRCA                                                
    RRCA                                                
    RRCA                                                
    OR          B                                       
    LD          BC,0x3                                  
FSECOLOR                      
    ; LD          (HL=>DAT_ram_5800),A
    LD (HL),a                    
    INC         HL                                      
    DJNZ        FSECOLOR                                
    DEC         C                                       
    JR          NZ,FSECOLOR                             
    ; LD          HL,0x4000
    LD HL,VRAM
    IN          A,(DAT_io_0083)                         
    OUT         (DAT_io_00fe),A                         
    AND         0x1                                     
    RLCA                                                
    RLCA                                                
    INC         A                                       
    LD          E,A                                     
    LD          D,0x0                                   
MKFDATA                       
    LD          A,0x4e                                  
    LD          B,0xa                                   
    CALL        FILLCONST                               
    LD          A,0x0                                   
    LD          B,0xc                                   
    CALL        FILLCONST                               
    LD          A,0xf5                                  
    LD          B,0x3                                   
    CALL        FILLCONST                               
    LD          A,0xfe                                  
    ; LD          (HL=>DAT_ram_4000),A
    LD (HL),A
    INC         HL                                      
    IN          A,(DAT_io_0083)                         
    ; LD          (HL=>DAT_ram_4001),A                    
    LD (HL),A
    INC         HL                                      
    LD          A,(SVSIDE)                              
    ; LD          (HL=>DAT_ram_4002),A
    LD (HL),A
    INC         HL                                      
    LD          A,E                                     
    ; LD          (HL=>DAT_ram_4003),A
    LD (HL),A
    INC         HL                                      
    LD          A,0x2                                   
    ; LD          (HL=>DAT_ram_4004),A
    LD (HL),A
    INC         HL                                      
    LD          A,0xf7                                  
    ; LD          (HL=>DAT_ram_4005),A
    LD (HL),A
    INC         HL                                      
    LD          A,0x4e                                  
    LD          B,0x16                                  
    CALL        FILLCONST                               
    LD          A,0x0                                   
    LD          B,0xc                                   
    CALL        FILLCONST                               
    LD          A,0xf5                                  
    LD          B,0x3                                   
    CALL        FILLCONST                               
    LD          A,0xfb                                  
    ; LD          (HL=>DAT_ram_4006),A
    LD (HL),A
    INC         HL                                      
    LD          A,0xe5                                  
    LD          B,0x0                                   
    CALL        FILLCONST                               
    CALL        FILLCONST                               
    LD          A,0xf7                                  
    ; LD          (HL=>DAT_ram_4007),A 
    LD (HL),A                   
    INC         HL                                      
    LD          A,0x4e                                  
    LD          B,0x28                                  
    CALL        FILLCONST                               
    LD          A,E                                     
    INC         E                                       
    CP          (IX+0x3)                                
    JR          C,MAKENEXT                              
    LD          E,0x1                                   
MAKENEXT                      
    INC         D                                       
    LD          A,D                                     
    CP          (IX+0x3)                                
    JR          NZ,MKFDATA                              
    LD          A,0x4e                                  
    LD          B,0x0                                   
    CALL        FILLCONST                               
    CALL        FILLCONST                               
    POP         BC                                      
    LD          HL,0x4000                               
    LD          IX,0x25ed                               
    LD          A,0xf0                                  
    LD          B,0x3                                   
    JP          DOWDCOM                                 
FILLCONST                     
    LD          (HL),A                                  
    INC         HL                                      
    DJNZ        FILLCONST                               
    RET                                                 
FINDTRACK                     
    PUSH        HL                                      
    PUSH        DE                                      
    PUSH        BC                                      
    LD          D,0x1c                                  
FINDTRACK1                    
    LD          A,(WORKDR)                              
    CALL        DRVSEL                                  
    BIT         0x0,(IX+0x0)                            
    LD          BC,0x401                                
    JR          Z,FINDTRRET                             
    LD          HL,0x0                                  
    LD          A,(WORKDR)                              
    CALL        TESTDR                                  
    JR          NZ,FINDTRRD                             
    LD          BC,0x180                                
FINDTRRET                     
    POP         HL                                      
    POP         HL                                      
    POP         HL                                      
    RET                                                 
FINDTRRD                      
    POP         BC                                      
    INC         C                                       
    LD          A,C                                     
    OUT         (DAT_io_0085),A                         
    XOR         A                                       
    BIT         0x4,(IX+0x1)                            
    JR          Z,FINDTRSVS                             
    RR          B                                       
    RLA                                                 
    RLCA                                                
FINDTRSVS                     
    LD          (SVSIDE),A                              
    BIT         0x5,(IX+0x1)                            
    JR          Z,NOD40IN80                             
    LD          D,0x18                                  
    SLA         B                                       
    IN          A,(DAT_io_0083)                         
    ADD         A,A                                     
    OUT         (DAT_io_0083),A                         
NOD40IN80                     
    BIT         0x7,(IX+0x0)                            
    JR          Z,FNDTRNOC                              
    IN          A,(DAT_io_0083)                         
    CP          B                                       
    JR          Z,FINDTROK                              
FNDTRNOC                      
    LD          A,B                                     
    LD          E,A                                     
    CALL        SEEK                                    
    AND         0x98                                    
    JR          Z,FINDTROK                              
    CALL        HOME                                    
    LD          A,E                                     
    CALL        SEEK                                    
    LD          C,A                                     
    AND         0x98                                    
    JR          Z,FINDTROK                              
    RES         0x7,(IX+0x0)                            
    POP         DE                                      
    POP         HL                                      
    LD          B,0x1                                   
    RET                                                 
FINDTROK                      
    BIT         0x5,(IX+0x1)                            
    JR          Z,NOD40IN801                            
    IN          A,(DAT_io_0083)                         
    RRCA                                                
    OUT         (DAT_io_0083),A                         
NOD40IN801                    
    DI                                                  
    LD          (DOSIX2),IX                             
    POP         DE                                      
    POP         HL                                      
    SCF                                                 
    RET                                                 
FORFINDTR                     
    PUSH        HL                                      
    PUSH        DE                                      
    PUSH        BC                                      
    LD          D,0x18                                  
    JP          FINDTRACK1                              
DISKRET                       
    LD          IX,(DOSIX2)                             
    IN          A,(DAT_io_0083)                         
    LD          (IX+0x4),A                              
    XOR         A                                       
    LD          (INTCNT),A                              
    EI                                                  
    LD          A,C                                     
    AND         A                                       
    RET         Z                                       
    RES         0x7,(IX+0x0)                            
    RET                                                 
DSKSTP                        
    XOR         A                                       
    CALL        OUTTODR                                 
    CALL        DRVCMP                                  
    RES         0x7,(IX+0x0)                            
    LD          A,0x1                                   
    CALL        DRVCMP                                  
    RES         0x7,(IX+0x0)                            
    RET                                                 
DRVSEL                        
    PUSH        AF                                      
    PUSH        BC                                      
    PUSH        HL                                      
    CALL        DRVCMP                                  
    BIT         0x2,(IX+0x1)                            
    LD          A,0x5                                   
    JR          Z,DRVSELOUT                             
    RLCA                                                
DRVSELOUT                     
    LD          C,A                                     
    LD          A,(SELSTA1)                             
    AND         0xfc                                    
    OR          C                                       
    CALL        OUTTODR                                 
    LD          A,(IX+0x4)                              
    OUT         (DAT_io_0083),A                         
    POP         HL                                      
    POP         BC                                      
    POP         AF                                      
    RET                                                 
TESTDR                        
    EI                                                  
    BIT         0x7,(IX+0x0)                            
    RET         NZ                                      
    PUSH        BC                                      
    PUSH        HL                                      
    CALL        DRVSEL                                  
    LD          HL,0x25b6                               
    LD          (TERADR),HL                            
    LD          A,0x64                                  
    LD          (INTCNT),A                              
    CALL        TESTRDR                                 
    SET         0x7,(IX+0x0)                            
    JR          NZ,TESTDRRET                            
    CALL        OUTTODR                                 
    LD          (IX+0x30),A                             
    RES         0x7,(IX+0x0)                            
TESTDRRET                     
    POP         HL                                      
    POP         BC                                      
    RET                                                 
TESTRDR                       
    LD          A,0xd0                                  
    OUT         (DAT_io_0081),A                         
    LD          (HERRSP2),SP                            
    LD          B,0x2                                   
LOOPISDRQ                     
    CALL        TESTDRQ                                 
    JR          NZ,LOOPISDRQ                            
LPNOTDRQ                      
    CALL        TESTDRQ                                 
    JR          Z,LPNOTDRQ                              
    DJNZ        LOOPISDRQ                               
    XOR         A                                       
    LD          (INTCNT),A                              
    DEC         A                                       
    SCF                                                 
    RET                                                 
INVALRET                      
    LD          SP,(HERRSP2)                            
    XOR         A                                       
    RET                                                 
OUTTODR                       
    OUT         (DAT_io_0089),A                         
    LD          (SELSTA1),A                             
    RET                                                 
TESTDRQ                       
    IN          A,(DAT_io_0081)                         
    AND         0x2                                     
    RET                                                 
DELAY                         
    PUSH        BC                                      
    LD          B,0xa                                   
DELAYLOOP                     
    DJNZ        DELAYLOOP                               
    POP         BC                                      
    RET                                                 
INTERRUPT                     
    PUSH        AF                                      
    LD          A,(INTCNT)                              
    AND         A                                       
    JR          Z,OKINTERR                              
    DEC         A                                       
    LD          (INTCNT),A                              
    JR          NZ,OKINTERR                             
    LD          HL,(TERADR)                            
    LD          A,H                                     
    OR          L                                       
    JR          NZ,GOINTERR                             
OKINTERR                      
    POP         AF                                      
ENDINTERR                     
    EI                                                  
    RETI                                                
GOINTERR                      
    POP         AF                                      
    EX          (SP),HL                                 
    JR          ENDINTERR                               
REANMI                        
    INI                                                 
    RET                                                 
WRINMI                        
    OUTI                                                
    RET                                                 

    org 0x3800
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
DAT_io_0081 equ 081h
DAT_io_0083 equ 083h
DAT_io_0085 equ 085h
DAT_io_0087 equ 087h
DAT_io_0089 equ 089h
DAT_io_00fe equ 0xfe
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
    SAVEBIN "mdos10.bin",0,16384

/*
ram:25f0         -> ram:37ff         [UNDEFINED BYTES REMOVED]

                            DIRBUF                        
ram:3800                        undefined1  ??                                      
                            DIRBUF_1                      
ram:3801                        undefined1  ??                                      

ram:3802         -> ram:39ff         [UNDEFINED BYTES REMOVED]

                            AUXBUF                        
ram:3a00                        undefined1  ??                                      
                            DAT_ram_3a01                  
ram:3a01                        undefined1  ??                                      

ram:3a02         -> ram:3ab0         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3ab1                  
ram:3ab1                        undefined1  ??                                      
                            DAT_ram_3ab2                  
ram:3ab2                        undefined1  ??                                      
                            DAT_ram_3ab3                  
ram:3ab3                        undefined1  ??                                      

ram:3ab4         -> ram:3abf         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3ac0                  
ram:3ac0                        undefined1  ??                                      
                            DAT_ram_3ac1                  
ram:3ac1                        undefined1  ??                                      

ram:3ac2         -> ram:3bff         [UNDEFINED BYTES REMOVED]

                            FATBUF                        
ram:3c00                        undefined1  ??                                      
                            FATBUF1                       
ram:3c01                        undefined1  ??                                      
                            DAT_ram_3c02                  
ram:3c02                        undefined1  ??                                      

ram:3c03         -> ram:3c7f         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3c80                  
ram:3c80                        undefined1  ??                                      
                            DAT_ram_3c81                  
ram:3c81                        undefined1  ??                                      

ram:3c82         -> ram:3cbf         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3cc0                  
ram:3cc0                        undefined1  ??                                      
                            DAT_ram_3cc1                  
ram:3cc1                        undefined1  ??                                      

ram:3cc2         -> ram:3dff         [UNDEFINED BYTES REMOVED]

                            DRPARZN                       
ram:3e00                        undefined1  ??                                      
                            DAT_ram_3e01                  
ram:3e01                        undefined1  ??                                      
                            DAT_ram_3e02                  
ram:3e02                        undefined1  ??                                      

ram:3e03         -> ram:3e0b         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3e0c                  
ram:3e0c                        undefined1  ??                                      

ram:3e0d         -> ram:3e0d         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3e0e                  
ram:3e0e                        undefined1  ??                                      

ram:3e0f         -> ram:3e2f         [UNDEFINED BYTES REMOVED]

                            DRNAMES                       
ram:3e30                        undefined1  ??                                      

ram:3e31         -> ram:3e5f         [UNDEFINED BYTES REMOVED]

                            DEBUG                         
ram:3e60                        undefined1  ??                                      
                            SNPCOUNT                      
ram:3e61                        undefined1  ??                                      
                            AIFASK                        
ram:3e62                        undefined1  ??                                      
                            MODJP1                        
ram:3e63                        undefined1  ??                                      

ram:3e64         -> ram:3e65         [UNDEFINED BYTES REMOVED]

                            SAVE_DE                       
ram:3e66                        undefined2  ??                                      

ram:3e68         -> ram:3e6a         [UNDEFINED BYTES REMOVED]

                            WORKDR                        
ram:3e6b                        undefined1  ??                                      
                            CHNGFLAG                      
ram:3e6c                        undefined1  ??                                      
                            FATSC                         
ram:3e6d                        undefined1  ??                                      
                            FATDR                         
ram:3e6e                        undefined1  ??                                      
                            ADRSCTR                       
ram:3e6f                        undefined2  ??                                      
                            ADRDR                         
ram:3e71                        undefined1  ??                                      
                            SVADRA                        
ram:3e72                        undefined2  ??                                      
                            STARTADR                      
ram:3e74                        undefined2  ??                                      
                            LENDAT                        
ram:3e76                        undefined2  ??                                      
                            VALSYX                        
ram:3e78                        undefined1  ??                                      

ram:3e79         -> ram:3e79         [UNDEFINED BYTES REMOVED]

                            VALSYY                        
ram:3e7a                        undefined2  ??                                      
                            HEAD20                        
ram:3e7c                        undefined1  ??                                      

ram:3e7d         -> ram:3e7d         [UNDEFINED BYTES REMOVED]

                            SVFRSC                        
ram:3e7e                        undefined2  ??                                      
                            DNZONE1                       
ram:3e80                        undefined1  ??                                      
                            DAT_ram_3e81                  
ram:3e81                        undefined1  ??                                      
                            DAT_ram_3e82                  
ram:3e82                        undefined1  ??                                      

ram:3e83         -> ram:3e89         [UNDEFINED BYTES REMOVED]

                            FNZONE1                       
ram:3e8a                        undefined1  ??                                      
                            DAT_ram_3e8b                  
ram:3e8b                        undefined1  ??                                      
                            DAT_ram_3e8c                  
ram:3e8c                        undefined1  ??                                      
                            DAT_ram_3e8d                  
ram:3e8d                        undefined1  ??                                      

ram:3e8e         -> ram:3e93         [UNDEFINED BYTES REMOVED]

                            EXTE1                         
ram:3e94                        undefined1  ??                                      
                            DNZONE2                       
ram:3e95                        undefined1  ??                                      
                            DAT_ram_3e96                  
ram:3e96                        undefined1  ??                                      

ram:3e97         -> ram:3e9e         [UNDEFINED BYTES REMOVED]

                            FNZONE2                       
ram:3e9f                        undefined1  ??                                      
                            DAT_ram_3ea0                  
ram:3ea0                        undefined1  ??                                      

ram:3ea1         -> ram:3ea8         [UNDEFINED BYTES REMOVED]

                            EXTE2                         
ram:3ea9                        undefined1  ??                                      
                            ACDRIVE                       
ram:3eaa                        undefined1  ??                                      
                            DAT_ram_3eab                  
ram:3eab                        undefined1  ??                                      

ram:3eac         -> ram:3eb3         [UNDEFINED BYTES REMOVED]

                            SVHEAD                        
ram:3eb4                        undefined1  ??                                      
                            DAT_ram_3eb5                  
ram:3eb5                        undefined1  ??                                      
                            DAT_ram_3eb6                  
ram:3eb6                        undefined1  ??                                      

ram:3eb7         -> ram:3ebe         [UNDEFINED BYTES REMOVED]

                            SVINF                         
ram:3ebf                        undefined1  ??                                      
                            DAT_ram_3ec0                  
ram:3ec0                        undefined1  ??                                      

ram:3ec1         -> ram:3ec4         [UNDEFINED BYTES REMOVED]

                            SVFSC                         
ram:3ec5                        undefined1  ??                                      
                            DAT_ram_3ec6                  
ram:3ec6                        undefined1  ??                                      
                            DAT_ram_3ec7                  
ram:3ec7                        undefined1  ??                                      
                            DAT_ram_3ec8                  
ram:3ec8                        undefined1  ??                                      

ram:3ec9         -> ram:3ed3         [UNDEFINED BYTES REMOVED]

                            SV24NM                        
ram:3ed4                        undefined1  ??                                      
                            DAT_ram_3ed5                  
ram:3ed5                        undefined1  ??                                      
                            DAT_ram_3ed6                  
ram:3ed6                        undefined1  ??                                      

ram:3ed7         -> ram:3ed9         [UNDEFINED BYTES REMOVED]

                            ASCIINM                       
ram:3eda                        undefined1  ??                                      
                            DAT_ram_3edb                  
ram:3edb                        undefined1  ??                                      

ram:3edc         -> ram:3ee1         [UNDEFINED BYTES REMOVED]

                            INTCNT                        
ram:3ee2                        undefined1  ??                                      
                            TERADR2                       
ram:3ee3                        undefined2  ??                                      
                            HERRSP2                       
ram:3ee5                        undefined2  ??                                      
                            DOSIX2                        
ram:3ee7                        undefined2  ??                                      
                            SELSTA1                       
ram:3ee9                        undefined1  ??                                      

ram:3eea         -> ram:3eea         [UNDEFINED BYTES REMOVED]

                            SVSIDE                        
ram:3eeb                        undefined1  ??                                      
                            IREG2                         
ram:3eec                        undefined2  ??                                      
                            SNAPINF                       
ram:3eee                        undefined1  ??                                      
                            SYSMRK                        
ram:3eef                        undefined1  ??                                      
                            DAT_ram_3ef0                  
ram:3ef0                        undefined1  ??                                      
                            DAT_ram_3ef1                  
ram:3ef1                        undefined1  ??                                      

ram:3ef2         -> ram:3ef6         [UNDEFINED BYTES REMOVED]

                            SYSFLAG                       
ram:3ef7                        undefined1  ??                                      

ram:3ef8         -> ram:3f7d         [UNDEFINED BYTES REMOVED]

                            DAT_ram_3f7e                  
ram:3f7e                        undefined2  ??                                      

ram:3f80         -> ram:3fe7         [UNDEFINED BYTES REMOVED]

                            SVREG                         
ram:3fe8                        undefined2  ??                                      
                            DAT_ram_3fea                  
ram:3fea                        undefined2  ??                                      
                            DAT_ram_3fec                  
ram:3fec                        undefined2  ??                                      
                            DAT_ram_3fee                  
ram:3fee                        undefined2  ??                                      
                            DAT_ram_3ff0                  
ram:3ff0                        undefined2  ??                                      
                            DAT_ram_3ff2                  
ram:3ff2                        undefined2  ??                                      
                            DAT_ram_3ff4                  
ram:3ff4                        undefined2  ??                                      
                            DAT_ram_3ff6                  
ram:3ff6                        undefined2  ??                                      
                            DAT_ram_3ff8                  
ram:3ff8                        undefined2  ??                                      
                            DAT_ram_3ffa                  
ram:3ffa                        undefined2  ??                                      
                            DAT_ram_3ffc                  
ram:3ffc                        undefined2  ??                                      
                            SAVE_SP                       
ram:3ffe                        undefined1  ??                                      

ram:3fff         -> ram:3fff         [UNDEFINED BYTES REMOVED]

                            DAT_ram_4000                  
ram:4000                        undefined1  ??                                      
                            DAT_ram_4001                  
ram:4001                        undefined1  ??                                      
                            DAT_ram_4002                  
ram:4002                        undefined1  ??                                      
                            DAT_ram_4003                  
ram:4003                        undefined1  ??                                      
                            DAT_ram_4004                  
ram:4004                        undefined1  ??                                      
                            DAT_ram_4005                  
ram:4005                        undefined1  ??                                      
                            DAT_ram_4006                  
ram:4006                        undefined1  ??                                      
                            DAT_ram_4007                  
ram:4007                        undefined1  ??                                      

ram:4008         -> ram:57ff         [UNDEFINED BYTES REMOVED]

                            DAT_ram_5800                  
ram:5800                        undefined1  ??                                      
                            DAT_ram_5801                  
ram:5801                        undefined1  ??                                      
                            DAT_ram_5802                  
ram:5802                        undefined1  ??                                      

ram:5803         -> ram:5c07         [UNDEFINED BYTES REMOVED]

                            LAST_K                        
ram:5c08                        undefined1  ??                                      

ram:5c09         -> ram:5c39         [UNDEFINED BYTES REMOVED]

                            ERR_NR                        
ram:5c3a                        undefined1  ??                                      

ram:5c3b         -> ram:5c3c         [UNDEFINED BYTES REMOVED]

                            ERR_SP                        
ram:5c3d                        undefined2  ??                                      

ram:5c3f         -> ram:5c4a         [UNDEFINED BYTES REMOVED]

                            VARS                          
ram:5c4b                        undefined2  ??                                      

ram:5c4d         -> ram:5c4e         [UNDEFINED BYTES REMOVED]

                            CHANS                         
ram:5c4f                        undefined2  ??                                      
                            CURCHL                        
ram:5c51                        undefined2  ??                                      
                            PROG                          
ram:5c53                        undefined2  ??                                      

ram:5c55         -> ram:5c58         [UNDEFINED BYTES REMOVED]

                            E_LINE                        
ram:5c59                        undefined2  ??                                      

ram:5c5b         -> ram:5c5c         [UNDEFINED BYTES REMOVED]

                            CH_ADD                        
ram:5c5d                        undefined2  ??                                      
                            X_PTR                         
ram:5c5f                        undefined2  ??                                      

ram:5c61         -> ram:5c64         [UNDEFINED BYTES REMOVED]

                            STKEND                        
ram:5c65                        undefined2  ??                                      

ram:5c67         -> ram:5c73         [UNDEFINED BYTES REMOVED]

                            T_ADDR                        
ram:5c74                        undefined2  ??                                      

ram:5c76         -> ram:5c8c         [UNDEFINED BYTES REMOVED]

                            ATTR_P                        
ram:5c8d                        undefined1  ??                                      

ram:5c8e         -> ram:5cb1         [UNDEFINED BYTES REMOVED]

                            RAMTOP                        
ram:5cb2                        undefined2  ??                                      

ram:5cb4         -> ram:fffe         [UNDEFINED BYTES REMOVED]

*/