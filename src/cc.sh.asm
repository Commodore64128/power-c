;**************************************************
;
; BETTER WORKING POWER C
; FOR THE COMMODORE 64/128
;
; SHELL.SH
;
;**************************************************
;
; **** ZP ABSOLUTE ADRESSES **** 
;
a01 = $01
a4B = $4B
a4C = $4C
a4D = $4D
a4E = $4E
aFE = $FE
;
; **** ZP POINTERS **** 
;
p4B = $4B
p4D = $4D
;
; **** ABSOLUTE ADRESSES **** 
;
a033C = $033C
a033E = $033E
a033F = $033F
a03FF = $03FF
a17FA = $17FA
a17FB = $17FB
a17FC = $17FC
a17FD = $17FD
;
; **** EXTERNAL JUMPS **** 
;
e2000 = $2000
;
; **** PREDEFINED LABELS **** 
;
ROM_SETLFS = $FFBA
ROM_SETNAM = $FFBD
ROM_OPEN = $FFC0
ROM_CLOSE = $FFC3
ROM_CHKIN = $FFC6
ROM_CHKOUT = $FFC9
ROM_CLRCHN = $FFCC
ROM_CHRIN = $FFCF
ROM_CHROUT = $FFD2
ROM_LOAD = $FFD5
ROM_GETIN = $FFE4

        * = $1800

        JMP j1806

        JMP j1A5D

j1806   LDA a033E
        STA a4B
        LDA a033F
        STA a4C
        LDA #$01
        STA a1C27
        LDA #$52
        STA a03FF
j181A   DEC a033C
        BEQ b1869
        CLC 
        LDA a4B
        ADC #$02
        STA a4B
        BCC b182A
        INC a4C
b182A   LDY #$01
        LDA (p4B),Y
        STA a4E
        DEY 
        LDA (p4B),Y
        STA a4D
        LDA (p4D),Y
        CMP #$2D
        BNE b1869
j183B   INY 
        LDA (p4D),Y
        BEQ b1866
        CMP #$50
        BNE b184C
        LDA #$00
        STA a1C27
        JMP j183B

b184C   CMP #$41
        BNE b1856
        STA a03FF
        JMP j183B

b1856   CMP #$53
        BNE b1860
        STA a03FF
        JMP j183B

b1860   JMP j1AF5

        JMP j183B

b1866   JMP j181A

b1869   LDA a033C
        CMP #$01
        BEQ b1873
        JMP j1AF5

b1873   LDY #$00
        LDX #$02
b1877   LDA (p4D),Y
        STA f1C13,X
        BEQ b1882
        INY 
        INX 
        BNE b1877
b1882   STX a1C12
        DEY 
        LDA (p4D),Y
        CMP #$43
        BNE b1893
        DEY 
        LDA (p4D),Y
        CMP #$2E
        BEQ b189A
b1893   LDX #$9D
        LDY #$1B
        JMP j1AF9

b189A   LDA a17FD
        CLC 
        ADC #$30
        STA f1C13
        STA a1BD2
        STA a1BDE
        STA a1BED
        LDA a17FB
        ADC #$30
        STA a1BCD
        STA a1BFC
        STA a1C06
        LDA #$02
        LDX a17FA
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$0A
        LDX #$FC
        LDY #$1B
        JSR ROM_SETNAM ;$FFBD - set file name                    
        LDA #$00
        JSR ROM_LOAD ;$FFD5 - load after call SETLFS,SETNAM    
        BCC b18DA
        LDX #$27
        LDY #$1B
        JMP j1AF9

b18DA   LDA a17FC
        STA aFE
        JSR e2000
        LDA #$02
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDA #$0F
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDA aFE
        BEQ b18F8
        JSR s1A29
        LDA #$0F
        JMP ROM_CLOSE ;$FFC3 - close a logical file             

b18F8   LDX #$71
        LDY #$1B
        JSR s1AE4
        JSR s1A29
        LDA #$02
        LDX a17FA
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$0C
        LDX #$06
        LDY #$1C
        JSR ROM_SETNAM ;$FFBD - set file name                    
        LDA #$00
        JSR ROM_LOAD ;$FFD5 - load after call SETLFS,SETNAM    
        BCC b1936
        LDX #$0F
        JSR ROM_CHKIN ;$FFC6 - open channel for input           
b1920   JSR ROM_CHRIN ;$FFCF - input character                  
        PHA 
        JSR ROM_CHROUT ;$FFD2 - output character                 
        PLA 
        CMP #$0D
        BNE b1920
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        LDX #$27
        LDY #$1B
        JMP j1AF9

b1936   LDX #$88
        LDY #$1B
        JSR s1AE4
        LDX #$0F
        JSR ROM_CHKOUT ;$FFC9 - open channel for output          
        LDX #$D1
        LDY #$1B
        JSR j1AF9
        JSR s1AD0
        LDX a1C12
        DEX 
        LDA #$4F
        STA f1C13,X
        LDA #$53
        JSR ROM_CHROUT ;$FFD2 - output character                 
        LDX #$13
        LDY #$1C
        JSR j1AF9
        LDA #$0D
        JSR ROM_CHROUT ;$FFD2 - output character                 
        JSR s1AD0
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        LDA #$02
        LDX a17FC
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$0E
        LDX #$DE
        LDY #$1B
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JSR ROM_OPEN ;$FFC0 - open log.file after SETLFS,SETNAM
        LDX #$0F
        JSR ROM_CHKIN ;$FFC6 - open channel for input           
        JSR ROM_CHRIN ;$FFCF - input character                  
        CMP #$30
        BNE b1992
        JSR ROM_CHRIN ;$FFCF - input character                  
        CMP #$30
b1992   PHP 
b1993   JSR ROM_CHRIN ;$FFCF - input character                  
        CMP #$0D
        BNE b1993
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        PLP 
        BEQ b19B1
        LDX #$B3
        LDY #$1B
        JSR j1AF9
        LDA #$02
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDA #$0F
        JMP ROM_CLOSE ;$FFC3 - close a logical file             

b19B1   LDA #$03
        LDX a17FC
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$0E
        LDX #$ED
        LDY #$1B
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JSR ROM_OPEN ;$FFC0 - open log.file after SETLFS,SETNAM
        JSR e2000
        LDA #$03
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDA #$02
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDX #$0F
        JSR ROM_CHKOUT ;$FFC9 - open channel for output          
        LDA aFE
        BEQ b19DF
        JMP j1A17

b19DF   LDA #$43
        JSR ROM_CHROUT ;$FFD2 - output character                 
        LDX #$13
        LDY #$1C
        JSR j1AF9
        LDA #$3D
        JSR ROM_CHROUT ;$FFD2 - output character                 
        LDX #$00
b19F2   LDA a1BED,X
        JSR ROM_CHROUT ;$FFD2 - output character                 
        INX 
        CPX #$0A
        BNE b19F2
        LDA #$2C
        JSR ROM_CHROUT ;$FFD2 - output character                 
        LDX #$00
b1A04   LDA a1BDE,X
        JSR ROM_CHROUT ;$FFD2 - output character                 
        INX 
        CPX #$0A
        BNE b1A04
        LDA #$0D
        JSR ROM_CHROUT ;$FFD2 - output character                 
        JSR s1AD0
j1A17   LDX #$D1
        LDY #$1B
        JSR j1AF9
        JSR s1AD0
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        LDA #$0F
        JMP ROM_CLOSE ;$FFC3 - close a logical file             

s1A29   LDX a17FA
        CPX a17FC
        BEQ b1A4B
        LDA #$0F
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$01
        LDX #$CC
        LDY #$1B
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JSR ROM_OPEN ;$FFC0 - open log.file after SETLFS,SETNAM
        LDA #$0F
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDX a17FC
b1A4B   LDA #$0F
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$01
        LDX #$CC
        LDY #$1B
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JMP ROM_OPEN ;$FFC0 - open log.file after SETLFS,SETNAM

j1A5D   LDA a01
        PHA 
        ORA #$07
        STA a01
        CLI 
        LDX #$5B
        LDY #$1B
        JSR s1AE4
        LDA a1BD2
        STA a1BCD
        LDA #$0F
        LDX a17FC
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDA #$03
        LDX #$CC
        LDY #$1B
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JSR ROM_OPEN ;$FFC0 - open log.file after SETLFS,SETNAM
        LDA #$02
        LDX a17FC
        TAY 
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        LDX #$13
        LDY #$1C
        LDA a1C12
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JSR ROM_OPEN ;$FFC0 - open log.file after SETLFS,SETNAM
        BCS b1AC1
        LDX #$0F
        JSR ROM_CHKIN ;$FFC6 - open channel for input           
        JSR ROM_CHRIN ;$FFCF - input character                  
        CMP #$30
        BNE b1AAE
        JSR ROM_CHRIN ;$FFCF - input character                  
b1AAE   PHA 
b1AAF   JSR ROM_CHRIN ;$FFCF - input character                  
        CMP #$0D
        BNE b1AAF
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        PLA 
        CMP #$30
        BNE b1AC1
        CLC 
        BCC b1ACB
b1AC1   LDA #$02
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        LDX #$43
        LDY #$1B
        SEC 
b1ACB   SEI 
        PLA 
        STA a01
        RTS 

s1AD0   LDX #$0F
        JSR ROM_CHKIN ;$FFC6 - open channel for input           
b1AD5   JSR ROM_CHRIN ;$FFCF - input character                  
        CMP #$0D
        BNE b1AD5
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        LDX #$0F
        JMP ROM_CHKOUT ;$FFC9 - open channel for output          

s1AE4   LDA a1C27
        BNE b1AEA
        RTS 

b1AEA   JSR j1AF9
b1AED   JSR ROM_GETIN ;$FFE4 - get a byte from channel          
        CMP #$0D
        BNE b1AED
        RTS 

j1AF5   LDX #<p1B0A
        LDY #>p1B0A
j1AF9   STX a4B
        STY a4C
        LDY #$00
b1AFF   LDA (p4B),Y
        BEQ b1B09
        JSR ROM_CHROUT ;$FFD2 - output character                 
        INY 
        BNE b1AFF
b1B09   RTS 

p1B0A   .TEXT "USAGE:  CC [-PAS] FILENAME", $0D, $0D, $00, "COMPILER DI"
        .TEXT "SK NOT PRESENT", $0D, $0D, $00, "SOURCE FILE NOT FOUND", $0D, $0D
        .TEXT $00, $0D, "INSE"
        .TEXT "RT SOURCE DISK", $0D, $0D, $00, $0D, "INSERT COMPILE"
        .TEXT "R DISK", $0D, $00, "INSERT OBJECT DISK", $0D, $0D, $00, "NOT A ", $C3, " SOU"
        .TEXT "RCE FILE", $0D, $0D, $00, "CAN'T OPEN OBJ"
        .TEXT "ECT FILE", $0D, $0D, $00, "I"
a1BCD   .TEXT "0"
        .TEXT ":", $0D, $00, "S"
a1BD2   .TEXT "0:XXXTEMP*", $0D, $00
a1BDE   .TEXT "0:XXXTEMP1,S,W", $00
a1BED   .TEXT "0:XXXTEMP2,S,W", $00
a1BFC   .TEXT "0:COMPILER"
a1C06   .TEXT "0:TRANSLATOR"
a1C12   .TEXT $00
f1C13   .TEXT "0:"
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00
a1C27   .BYTE $00
