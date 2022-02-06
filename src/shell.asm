;**************************************************
;
; BETTER WORKING POWER C
; FOR THE COMMODORE 64/128
;
; SHELL.C
;
;**************************************************
; **** ZP ABSOLUTE ADRESSES **** 
;
a01 = $01
a1A = $1A
a1B = $1B
a20 = $20
a21 = $21
a29 = $29
a2A = $2A
a2B = $2B
a4B = $4B
a4C = $4C
a4D = $4D
a4E = $4E
a4F = $4F
a50 = $50
a51 = $51
a52 = $52
a53 = $53
a54 = $54
a55 = $55
a56 = $56
a57 = $57
a58 = $58
a59 = $59
a5A = $5A
a5B = $5B
a5C = $5C
a99 = $99
aCB = $CB
aFB = $FB
aFC = $FC
aFD = $FD
aFE = $FE
;
; **** ZP POINTERS **** 
;
p1A = $1A
p20 = $20
p2A = $2A
p57 = $57
pFB = $FB
pFD = $FD
;
; **** FIELDS **** 
;
f0100 = $0100
f033C = $033C
f174A = $174A
f17DC = $17DC
f17E7 = $17E7
;
; **** ABSOLUTE ADRESSES **** 
;
a0286 = $0286
a0288 = $0288
a028D = $028D
a0318 = $0318
a0319 = $0319
a033D = $033D
a033E = $033E
a033F = $033F
a16C9 = $16C9
a16CA = $16CA
a174B = $174B
a179B = $179B
a179C = $179C
a179D = $179D
a179E = $179E
a179F = $179F
a17A0 = $17A0
a17AF = $17AF
a17B0 = $17B0
a17C8 = $17C8
a17DD = $17DD
a17F7 = $17F7
a17F8 = $17F8
a17FA = $17FA
a17FB = $17FB
a17FC = $17FC
a17FD = $17FD
a17FE = $17FE
a17FF = $17FF
;
; **** POINTERS **** 
;
p9B00 = $9B00
pD800 = $D800
;
; **** EXTERNAL JUMPS **** 
;
e1800 = $1800
eBBA2 = $BBA2
eBDDD = $BDDD
eFE72 = $FE72
;
; **** PREDEFINED LABELS **** 
;
RESET_VECTOR    = $FCE2
ROM_CINT        = $FF81
ROM_IOINIT      = $FF84
ROM_READST      = $FFB7
ROM_SETLFS      = $FFBA
ROM_SETNAM      = $FFBD
ROM_OPEN        = $FFC0
ROM_CLOSE       = $FFC3
ROM_CHKIN       = $FFC6
ROM_CHKOUT      = $FFC9
ROM_CLRCHN      = $FFCC
ROM_CHRIN       = $FFCF
ROM_CHROUT      = $FFD2
ROM_LOAD        = $FFD5
ROM_STOP        = $FFE1

        * = $0801

        .BYTE $0C,$08
        .BYTE $0A,$00,$9E,$20,$32,$30   ; 10 SYS 2062 ($080E)
        .BYTE $36,$32,$00,$00,$00

j080E:
START:  JMP j0826
        JMP j0928
        JMP j0933
        JMP j0957
        JMP j0960
        JMP j0941
        JMP j0CD4
        JMP j0926

        ; ================= initialize the shell

j0826   LDA a0318               ; NMI
        STA a0922
        LDA a0319               ; NMI
        STA a0923
        TSX 
        STX a0924

        LDA #$0B
        STA $D020               ; Border Color
        LDA #$0C
        STA $D021               ; Background Color 0
        LDA #$05                ; WHITE
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        LDA #$93                ; CLEAR
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        LDA #$0D
        JSR ROM_CHROUT          ; $FFD2 - output character

        LDA #$08                ; system drive?
        STA a17FA
        STA a17FC

        LDA #$00
        STA a17FB
        STA a17FD
        STA a16C9
        STA a0925
        STA a17C8

j0868   LDA #<p08B9             ; save new NMI vector
        STA a0318               ; NMI
        LDA #>p08B9
        STA a0319               ; NMI

        LDA $D018               ; VIC Memory Control Register
        ORA #$02                ; Where VIC will get character data
        STA $D018               ; VIC Memory Control Register

j087A   JSR s0886
        JSR s0890
        JSR s0D34
        JMP j087A

        ; ================= Print Prompt

s0886   LDA #$24                ; '$'
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        LDA #$20                ; ' '
        JMP ROM_CHROUT          ; $FFD2 - output character                 

        ; ================ Get Input

s0890   LDY #$00
b0892   JSR ROM_CHRIN           ; $FFCF - input character                  
        CMP #$0D                ; RETURN?
        BEQ b089F               ; Skip ahead if so
        STA f1678,Y             ; Store in buffer
        INY 
        BNE b0892               ; Get another
b089F   JSR ROM_CHROUT          ; $FFD2 - output character                 
        LDA #$00
        STA f1678,Y
        RTS 

        ; ================ Print a string (pointed to by X/Y)

s08A8   STX a2A
        STY a2B
        LDY #$00
b08AE   LDA (p2A),Y
        BEQ b08B8
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        INY 
        BNE b08AE
b08B8   RTS 

        ; new NMI code

p08B9   PHA 
        LDA a0925
        BEQ b08C1
        PLA 
        RTI 

b08C1   TXA 
        PHA 
        TYA 
        PHA 
        LDA #$7F
        STA $DD0D               ; CIA2: CIA Interrupt Control Register
        LDY $DD0D               ; CIA2: CIA Interrupt Control Register
        BPL b08D2
        JMP eFE72               ; RS-232 NMI Routine

b08D2   JSR ROM_STOP            ; $FFE1 - check stop key                   
        BEQ b08DA
        JMP eFE72               ; RS-232 NMI Routine

        ; stop key pressed
b08DA   INC a0925
        LDA a01
        ORA #$07
        STA a01                 ; swap RAM/ROM
        LDA #$04
        STA a0288
        LDA a0286
        PHA 
        LDA $D020               ; Border Color
        PHA 
        LDA $D021               ; Background Color 0
        PHA 
        JSR ROM_IOINIT          ; $FF84 - initialize CIA & IRQ             
        JSR ROM_CINT            ; $FF81 - init VIC & screen editor         
        PLA 
        STA $D021               ; Background Color 0
        PLA 
        STA $D020               ; Border Color
        PLA 
        STA a0286
        LDX a0924
        TXS 
        CLI 
        LDX #$0F
b090D   TXA 
        PHA 
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        PLA 
        TAX 
        DEX 
        BNE b090D
        LDA #$0D
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        DEC a0925
        JMP j0868

a0922   .BYTE $00
a0923   .BYTE $00
a0924   .BYTE $00
a0925   .BYTE $00

j0926   LDA #$00
j0928   LDY #$00
        STA (p1A),Y
        INC a1A
        BNE b0932
        INC a1B
b0932   RTS 

j0933   LDA a1A
        BNE b0939
        DEC a1B
b0939   DEC a1A
        LDY #$00
        LDA (p1A),Y
        TAX 
        RTS 

j0941   JSR j0933
        LDA f033C,X             ; Cassette buffer
        STA aFB
        INX 
        LDA f033C,X             ; Cassette buffer
        STA aFC
        INX 
        STX a4C
        LDA #$00
        JMP j097F

j0957   JSR j0933
        STX a4C
        LDA #$02
        BNE b096A
j0960   JSR j0933
        LDA f033C,X     ; Cassette buffer
        INX 
        INX 
        STX a4C
b096A   CMP #$02
        BNE b0979
        LDX a17FF
        BNE b0979
        JSR ROM_CLRCHN  ; $FFCC - restore default devices          
        JMP j097D

b0979   TAX 
        JSR ROM_CHKOUT  ; $FFC9 - open channel for output

j097D   LDA #$01
j097F   STA a4D
        LDX a4C
        LDA f033C,X     ; Cassette buffer
        INX 
        STA aFD
        LDA f033C,X     ; Cassette buffer
        INX 
        STA aFE
        STX a4C
        LDY #$FF
j0993   INY 
        LDA (pFD),Y
        BNE b09A1
        LDY a4D
        BNE b099E
        STA (pFB),Y
b099E   JMP ROM_CLRCHN  ; $FFCC - restore default devices          

b09A1   CMP #$25        ; '%'
        BNE b0A08
        JSR s0C33
        LDA (pFD),Y
        CMP #$44        ; 'd'
        BNE b09B4
        JSR s0A3F
        JMP j0C9F

b09B4   CMP #$55        ; 'u'
        BNE b09BE
        JSR s0A3B
        JMP j0C9F

b09BE   CMP #$58        ; 'x'
        BNE b09C8
        JSR s0B7F
        JMP j0C9F

b09C8   CMP #$4F        ; 'o'
        BNE b09D2
        JSR s0BBE
        JMP j0C9F

b09D2   CMP #$43        ; 'c'
        BNE b09DC
        JSR s0BFB
        JMP j0C9F

b09DC   CMP #$53        ; 'r'
        BNE b09E6
        JSR s0C0A
        JMP j0C9F

b09E6   CMP #$46        ; 'f'
        BNE b09F0
        JSR s0AEA
        JMP j0C9F

b09F0   CMP #$47        ; 'g'
        BNE b09FA
        JSR s0AB2
        JMP j0C9F

b09FA   CMP #$00
        BEQ b0A04
        JSR s0A0E
        JMP j0993

b0A04   DEY 
        JMP j0993

b0A08   JSR s0A0E
        JMP j0993

        ; ================ 

s0A0E   STY a51
        LDY a4D
        BEQ b0A19
        LDY a51
        JMP ROM_CHROUT          ; $FFD2 - output character                 

b0A19   STA (pFB),Y
        INC aFB
        BNE b0A21
        INC aFC
b0A21   LDY a51
        RTS 

        ; ================ 

s0A24   STY a4B
        LDX a4C
        LDA f033C,X     ; Cassette buffer
        STA a5A
        INX 
        LDA f033C,X     ; Cassette buffer
        STA a5B
        INX 
        STX a4C
        LDA #$00
        STA a58
        RTS 

        ; ================ 

s0A3B   LDA #$01
        BNE b0A41
s0A3F   LDA #$00
b0A41   STA a51
        JSR s0A24
        STA a54
        LDA a5B
        BPL b0A67
        LDY a51
        BNE b0A67
        EOR #$FF
        STA a5B
        LDA a5A
        EOR #$FF
        STA a5A
        INC a5A
        BNE b0A60
        INC a5B
b0A60   LDA #$2D
        STA a16CA
        INC a54
b0A67   LDX #$04
b0A69   LDY #$00
b0A6B   LDA a5A
        SEC 
        SBC f0AA8,X
        STA a51
        LDA a5B
        SBC f0AAD,X
        BCC b0A83
        STA a5B
        LDA a51
        STA a5A
        INY 
        BNE b0A6B
b0A83   TYA 
        BEQ b0A88
        STA a58
b0A88   LDA a58
        BEQ b0A96
        LDA f0BAE,Y
        LDY a54
        STA a16CA,Y
        INC a54
b0A96   DEX 
        BPL b0A69
        LDX a54
j0A9B   LDY a4B
        LDA a58
        BNE b0AA7
        LDA #$30
        STA a16CA,X
        INX 
b0AA7   RTS 

f0AA8   .BYTE $01,$0A,$64,$E8,$10
f0AAD   .BYTE $00,$00,$00,$03,$27

        ; ================ 

s0AB2   LDA a01
        PHA 
        ORA #$01
        STA a01                 ; Swap in ROM
        STY a4B
        CLC 
        LDA #$3C
        ADC a4C
        LDY #$03
        JSR eBBA2               ; Move mem (A/Y) to FAC (unpacked)
        JSR eBDDD               ; Convert FAC1 to ASCII string result (A/Y)
        LDY #$00
        LDX #$00
j0ACC   LDA f0100,Y
        BEQ b0ADD
        CMP #$20
        BEQ b0AD9
        STA a16CA,X
        INX 
b0AD9   INY 
        JMP j0ACC

b0ADD   CLC 
        LDA a4C
        ADC #$05
        STA a4C
        LDY a4B
        PLA 
        STA a01                 ; Swap out ROM
        RTS 

        ; ================ 

s0AEA   LDA a01
        PHA 
        ORA #$01
        STA a01                 ; Swap in ROM
        STY a4B
        CLC 
        LDA #$3C
        ADC a4C
        LDY #$03
        JSR eBBA2               ; Move mem (A/Y) to FAC (unpacked)
        JSR eBDDD               ; Convert FAC1 to ASCII string result (A/Y)
        LDA #$00
        STA a56
        STA a55
        STA a53
        LDA a50
        BNE b0B0E
        INC a56
b0B0E   BPL b0B14
        LDA #$06
        STA a50
b0B14   LDY #$00
        LDX #$00
j0B18   LDA f0100,Y
        BEQ b0B52
        CMP #$20
        BEQ b0B4E
        CMP #$45
        BNE b0B30
        JSR s0B5E
        LDA #$00
        STA a55
        INC a53
        LDA #$45
b0B30   STA a51
        LDA a55
        BEQ b0B3C
        LDA a50
        BEQ b0B4E
        DEC a50
b0B3C   LDA a51
        CMP #$2E
        BNE b0B48
        LDA a56
        BNE b0B52
        INC a55
b0B48   LDA a51
        STA a16CA,X
        INX 
b0B4E   INY 
        JMP j0B18

b0B52   CLC 
        LDA a4C
        ADC #$05
        STA a4C
        LDY a4B
        PLA 
        STA a01                 ; Swap out ROM
s0B5E   LDA a56
        BNE b0B7E
        LDA a53
        BNE b0B7E
        LDA a55
        BNE b0B70
        LDA #$2E
        STA a16CA,X
        INX 
b0B70   LDA a50
        BEQ b0B7E
        LDA #$30
b0B76   STA a16CA,X
        INX 
        DEC a50
        BNE b0B76
b0B7E   RTS 

s0B7F   JSR s0A24
        LDX #$00
        LDA #$04
        STA a5C
b0B88   LDA a5B
        LSR 
        LSR 
        LSR 
        LSR 
        TAY 
        BNE b0B95
        LDA a58
        BEQ b0B9E
b0B95   LDA f0BAE,Y
        STA a16CA,X
        INX 
        STX a58
b0B9E   LDY #$04
b0BA0   ASL a5A
        ROL a5B
        DEY 
        BNE b0BA0
        DEC a5C
        BNE b0B88
        JMP j0A9B

f0BAE   .TEXT "0123456789ABCDEF"

        ; ================ 

s0BBE   JSR s0A24
        LDX #$00
        LDA a5B
        BPL b0BCF
        LDA #$31
        STA a16CA
        INX 
        STX a58
b0BCF   LDA #$05
        STA a5C
b0BD3   LDA a5B
        LSR 
        LSR 
        LSR 
        LSR 
        AND #$07
        TAY 
        BNE b0BE2
        LDA a58
        BEQ b0BEB
b0BE2   LDA f0BAE,Y
        STA a16CA,X
        INX 
        STX a58
b0BEB   LDY #$03
b0BED   ASL a5A
        ROL a5B
        DEY 
        BNE b0BED
        DEC a5C
        BNE b0BD3
        JMP j0A9B

        ; ================ 

s0BFB   LDX a4C
        LDA f033C,X     ; Cassette buffer
        STA a16CA
        INX 
        INX 
        STX a4C
        LDX #$01
        RTS 

s0C0A   STY a4B
        LDX a4C
        LDA f033C,X     ; Cassette buffer
        STA a20
        INX 
        LDA f033C,X     ; Cassette buffer
        STA a21
        INX 
        STX a4C
        LDY #$00
b0C1E   LDA a50
        BEQ b0C2E
        LDA (p20),Y
        BEQ b0C2E
        STA a16CA,Y
        INY 
        DEC a50
        BNE b0C1E
b0C2E   TYA 
        TAX 
        LDY a4B
        RTS 

        ; ================ 

s0C33   LDA #$00
        STA a4E
        INY 
        LDA (pFD),Y
        CMP #$2D
        BNE b0C41
        INC a4E
        INY 
b0C41   LDA (pFD),Y
        CMP #$30
        BEQ b0C49
        LDA #$20
b0C49   STA a52
        JSR s0C69
        STA a4F
        LDA (pFD),Y
        CMP #$2E
        BNE b0C5D
        INY 
        JSR s0C69
        JMP j0C5F

b0C5D   LDA #$FF
j0C5F   STA a50
        LDA (pFD),Y
        CMP #$4C
        BNE b0C68
        INY 
b0C68   RTS 

        ; ================ 

s0C69   LDA (pFD),Y
        CMP #$2A
        BNE b0C7A
        LDX a4C
        LDA f033C,X     ; Cassette buffer
        INX 
        INX 
        STX a4C
        INY 
        RTS 

b0C7A   LDA #$00
        STA a5A
b0C7E   LDA (pFD),Y
        CMP #$3A
        BCS b0C9C
        CMP #$30
        BCC b0C9C
        SBC #$30
        STA a5B
        LDA a5A
        ASL a5A
        ASL a5A
        ADC a5A
        ASL 
        ADC a5B
        STA a5A
        INY 
        BNE b0C7E
b0C9C   LDA a5A
        RTS 

j0C9F   STX a54
        LDA a4E
        BNE b0CA8
        JSR s0CC1
b0CA8   LDX #$00
b0CAA   CPX a54
        BEQ b0CB7
        LDA a16CA,X
        JSR s0A0E
        INX 
        BNE b0CAA
b0CB7   LDA a4E
        BEQ b0CBE
        JSR s0CC1
b0CBE   JMP j0993

        ; ================ 

s0CC1   SEC 
        LDA a4F
        SBC a54
        BCC b0CD3
        TAX 
        BEQ b0CD3
b0CCB   LDA a52
        JSR s0A0E
        DEX 
        BNE b0CCB
b0CD3   RTS 

j0CD4   TAY 
        DEY 
        LDA f17E7,Y
        BEQ b0CDD
        SEC 
        RTS 

b0CDD   LDA a99
        BEQ b0CEE
        JSR ROM_CHRIN           ; $FFCF - input character                  
        PHA 
        JSR ROM_READST          ; $FFB7 - read I/O status byte             
        STA f17E7,Y
        PLA 
        CLC 
        RTS 

b0CEE   LDX a17F7
        CPX a17F8
        BNE b0D2B
        STY a0D33
        TAY 
b0CFA   JSR ROM_CHRIN           ; $FFCF - input character                  
        STA f174A,Y
        INY 
        CMP #$0D
        BNE b0CFA
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        STY a17F8
        STY a17F7
        LDA f174A
        CMP #$2E
        BNE b0D26
        LDA a174B
        CMP #$0D
        BNE b0D26
        LDY a0D33
        LDA #$01
        STA f17E7,Y
        SEC 
        RTS 

b0D26   LDX #$00
        STX a17F7
b0D2B   LDA f174A,X
        INC a17F7
        CLC 
        RTS 

a0D33   .BYTE $00

        ; ================ 

s0D34   LDY #$00
        STY a29                 ; clear number of arguments
        STY a17FE
        STY a17FF
        LDX #$FF
b0D40   INX 
        LDA f1678,X
        BNE b0D49
        JMP j0DCE

b0D49   CMP #$20
        BEQ b0D4F
        CMP #$A0
b0D4F   BEQ b0D40
        CMP #$3C
        BNE b0D67
        JSR s0F7F
        BCC b0D64
        LDX #$B1
        LDY #$0E
        JSR s08A8               ; Print string "CAN'T OPEN INPUT FILE"
        JMP j0E8C               ; close open files

b0D64   JMP b0D40

b0D67   CMP #$3E
        BNE b0D98
        INX 
        LDA f1678,X
        CMP #$3E
        BNE b0D85
        JSR s1080
        BCC b0D82
        LDX #$E0
        LDY #$0E
        JSR s08A8               ; Print string "PRINTER NOT PRESENT"
        JMP j0E8C               ; close open files

b0D82   JMP b0D40

b0D85   DEX 
        JSR s0FAA
        BCC b0D95
        LDX #$C8
        LDY #$0E
        JSR s08A8               ; Print string "CAN'T OPEN OUTPUT FILE"
        JMP j0E8C               ; close open files

b0D95   JMP b0D40

b0D98   INC a29                 ; increase number of arguments
        CMP #$22
        BNE b0DB5
        INX 
        JSR s0F6E
        DEX 
b0DA3   INX 
        LDA f1678,X
        BEQ j0DCE
        CMP #$22
        BNE b0DA3
        LDA #$00
        STA f1678,X
        JMP b0D40

b0DB5   JSR s0F6E
b0DB8   INX 
        LDA f1678,X
        BEQ j0DCE
        CMP #$20
        BEQ b0DC4
        CMP #$A0
b0DC4   BNE b0DB8
        LDA #$00
        STA f1678,X
        JMP b0D40

j0DCE   LDA a29                 ; number of arguments
        BNE b0DD5
        JMP j0E8C               ; close open files

b0DD5   LDA a179B
        STA a2A
        LDA a179C
        STA a2B
        LDY #$00
b0DE1   LDA (p2A),Y
        BEQ b0DF0
        CMP #$41
        BCC b0DED
        CMP #$5B
        BCC b0DF3
b0DED   INY 
        BNE b0DE1
b0DF0   JMP j0E8C               ; close open files

b0DF3   JSR s10F3
        JSR s0E01
        BCS b0DFE
        JSR s0E3B
b0DFE   JMP j0E8C               ; close open files

        ; ================ 

s0E01   LDA #<a17C8
        STA a57
        LDA #>a17C8
        STA a58
        JSR s118A
        BNE b0E10
        CLC 
        RTS 

b0E10   LDX a17FC
        LDY a17FD
        JSR s0EF5
        BCC b0E2F
        LDX a17FA
        LDY a17FB
        JSR s0EF5
        BCC b0E2F
        LDX #$9E                ; Load xy to error messages
        LDY #$0E
        JSR s08A8               ; Print string "COMMAND NOT FOUND"
        SEC 
        RTS 

b0E2F   LDY #$13
b0E31   LDA (p2A),Y
        STA a17C8,Y
        DEY 
        BPL b0E31
        CLC 
        RTS 

        ; ================ 

s0E3B   LDA a29                 ; number of arguments
        STA f033C               ; Cassette buffer
        LDA #<p9B00
        STA a033D
        LDA #>p9B00
        STA a033E
        LDA #$17
        STA a033F
        LDA a0286
        STA a0E89
        LDA $D020               ; Border Color
        STA a0E8A
        LDA $D021               ; Background Color 0
        STA a0E8B
        JSR e1800
        LDA a0E8A
        STA $D020               ; Border Color
        LDA a0E8B
        STA $D021               ; Background Color 0
        LDA a0E89
        STA a0286
        LDX #>pD800             ; Color RAM pointer
        LDY #<pD800             ; Color RAM pointer
        STY a2A
b0E7C   STX a2B
b0E7E   STA (p2A),Y
        INY 
        BNE b0E7E
        INX 
        CPX #$DC
        BNE b0E7C
        RTS 

a0E89   .BYTE $00
a0E8A   .BYTE $00
a0E8B   .BYTE $00

        ; close open files
j0E8C   LDA #$01
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        LDA #$02
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        LDA #$0F
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        JMP ROM_CLRCHN          ; $FFCC - restore default devices          

        ; error messages
d0E9E   .TEXT "command not found", $0D, $00
d0EB1   .TEXT "CAN'T OPEN INPUT FILE",$0D, $00
        .TEXT "CAN'T OPEN OUTPUT FILE", $0D, $00
        .TEXT "PRINTER NOT PRESENT", $0D, $00

        ; ================ 

s0EF5   STX a0F6D               ; store device #
        TYA 
        CLC 
        ADC #$30
        STA a17AF
        LDA #$3A
        STA a17B0
        LDY #$00
        LDX #$02
b0F08   LDA (p2A),Y
        BEQ b0F13
        STA a17AF,X
        INY 
        INX 
        BNE b0F08
b0F13   LDA #$2E
        STA a17AF,X
        INX 
        LDA #$53
        STA a17AF,X
        INX 
        LDA #$48
        STA a17AF,X
        INX 
        TXA 
        LDX #$AF
        LDY #$17
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        LDX a0F6D               ; get device #
        LDA #$04                ; logival file #4
        TAY 
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        LDA #$00
        JSR ROM_LOAD            ; $FFD5 - load after call SETLFS,SETNAM    
        BCC b0F6C
        CMP #$05
        BNE b0F42
        RTS 

b0F42   LDA #$0F                ; logic file number
        LDX a0F6D               ; get device #
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        LDA #$00
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        BCS b0F63
        LDX #$0F
        JSR ROM_CHKIN           ;$FFC6 - open channel for input           
        BCS b0F63
b0F5C   JSR ROM_CHRIN           ;$FFCF - input character                  
        CMP #$0D
        BNE b0F5C
b0F63   LDA #$0F
        JSR ROM_CLOSE           ;$FFC3 - close a logical file             
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        SEC 
b0F6C   RTS 

a0F6D   .BYTE $00               ; device number

        ; ================ 

s0F6E   CLC 
        TXA 
        ADC #$78
        STA a179B,Y
        INY 
        LDA #$00
        ADC #$16
        STA a179B,Y
        INY 
        RTS 

        ; ================ 

s0F7F   LDA #$01
        STA a17FE
        STY a2B
        JSR s1047
        BCC b0F8C
        RTS 

b0F8C   TYA 
        LDX #$AF
        LDY #$17
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        LDA #$01
        LDX a17FC
        LDY #$02
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        BCC b0FA4
        RTS 

b0FA4   LDA a17FC
        JMP j0FF5

        ; ================ 

s0FAA   LDA #$01
        STA a17FF
        STY a2B
        JSR s1047
        BCC b0FB7
        RTS 

b0FB7   DEY 
        DEY 
        LDA a17AF,Y
        INY 
        INY 
        CMP #$2C
        BEQ b0FCE
        LDA #$2C
        STA a17AF,Y
        INY 
        LDA #$53
        STA a17AF,Y
        INY 
b0FCE   LDA #$2C
        STA a17AF,Y
        INY 
        LDA #$57
        STA a17AF,Y
        INY 
        TYA 
        LDX #$AF
        LDY #$17
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        LDA #$02
        LDX a17FC
        LDY #$03
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        BCC b0FF2
        RTS 

b0FF2   LDA a17FC
j0FF5   PHA 
        LDA #$00
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        PLA 
        TAX 
        LDA #$0F
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        LDX #$0F
        JSR ROM_CHKIN           ;$FFC6 - open channel for input           
        LDY #$00
b100D   JSR ROM_CHRIN           ;$FFCF - input character                  
        STA f17DC,Y
        INY 
        CMP #$0D
        BNE b100D
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        LDA f17DC
        CMP #$30
        BNE b102F
        LDA a17DD
        CMP #$30
        BNE b102F
        CLC 
        LDX a2A
        LDY a2B
        RTS 

b102F   LDY #$00
b1031   LDA f17DC,Y
        CMP #$0D
        BEQ b103E
        JSR ROM_CHROUT          ;$FFD2 - output character                 
        INY 
        BNE b1031
b103E   JSR ROM_CHROUT          ;$FFD2 - output character                 
        SEC 
        LDX a2A
        LDY a2B
        RTS 

        ; ================ 

s1047   CLC 
        LDA a17FD
        ADC #$30
        STA a17AF
        LDA #$3A
        STA a17B0
b1055   INX 
        LDA f1678,X
        BNE b105D
        SEC 
        RTS 

b105D   CMP #$20
        BEQ b1063
        CMP #$A0
b1063   BEQ b1055
        LDY #$02
b1067   LDA f1678,X
        BEQ b107B
        CMP #$20
        BEQ b107B
        CMP #$A0
        BEQ b107B
        STA a17AF,Y
        INY 
        INX 
        BNE b1067
b107B   DEX 
        STX a2A
        CLC 
        RTS 

        ; ================ 

s1080   STX a2A
        STY a2B
        LDA #$01
        STA a17FF
        LDA #$02
        LDX #$04
        LDY #$07
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        LDA #$00
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        BCS b10A1
        LDX #$02
        JSR ROM_CHKOUT          ;$FFC9 - open channel for output          
b10A1   PHP 
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        PLP 
        LDX a2A
        LDY a2B
        RTS 

a10AB   .BYTE $00

        ; ================ 

s10AC   STX a1313
        LDX a10AB
        STA f033C,X             ; Cassette buffer
        INC a10AB
        CMP #$0D
        BEQ b10C0
        LDX a1313
        RTS 

b10C0   LDA a17FF
        BEQ b10CD
        JSR ROM_CLRCHN          ; $FFCC - restore default devices          
        LDX #$02
        JSR ROM_CHKOUT          ; $FFC9 - open channel for output          
b10CD   LDX #$00
b10CF   CPX a10AB
        BEQ b10DD
        LDA f033C,X             ; Cassette buffer
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        INX 
        BNE b10CF
b10DD   LDA a17FF
        BEQ b10EA
        JSR ROM_CLRCHN          ; $FFCC - restore default devices          
        LDX #$04
        JSR ROM_CHKIN           ; $FFC6 - open channel for input           
b10EA   LDX a1313
s10ED   LDA #$00
        STA a10AB
        RTS 

        ; ================ Lookup an internal command

s10F3   LDA #<p1199             ; set up $57/$58 as pointers to the command table
        STA a57
        LDA #>p1199
        STA a58
        LDA #$00
        STA a59
b10FF   LDY #$00                
        LDA (p57),Y             ; get 1st character
        BNE b1106               ; command table isnt empty, skip ahead
        RTS                     ; command table is empty, return

b1106   JSR s118A               ; lookup entered command in command table
        BEQ b111A
        CLC                     ; skip 5 bytes (length of a command)
        LDA a57                 ; ..to point to next command in
        ADC #$05                ; ..command table
        STA a57                 ; end of skip
        BCC b1116               ; if we crossed a border ( > FF)
        INC a58                 ; ...increase the hi byte
b1116   INC a59                 ; increase command counter
        BNE b10FF               ; go look again
b111A   PLA 
        PLA 
        LDX a59
        BNE b1132               ; if command counter != 0, skip ahead
        JSR j0E8C               ; close open files
        LDA a0922               ; set up standard NMI vector
        STA a0318               ; NMI
        LDA a0923
        STA a0319               ; NMI
        JMP RESET_VECTOR        ; reset...

b1132   DEX 
        BNE b114E
        LDA a29                 ; load number of arguments
        CMP #$02                ; 2?
        BNE b114B               ; if no, skip ahead
        LDA a179D               ; get pointer to filename from a179D/a179E
        STA a2A                 ; store pointer in $2a/$2b
        LDA a179E
        STA a2B
        JSR s0E01               ; load?
        JMP j0E8C               ; close open files

b114B   JMP j1572               ; jmp wrong number of arguments

b114E   DEX 
        BNE b115A
        LDX a17FA
        LDY a17FB
        JMP j11CB               ; ls file

b115A   DEX 
        BNE b1166
        LDX a17FC
        LDY a17FD
        JMP j11CB               ; l

b1166   DEX 
        BNE b116C
        JMP j1373               ; scratch a file

b116C   DEX 
        BNE b1172
        JMP j13DD               ; rename a file

b1172   DEX 
        BNE b1178
        JMP j1484               ; print file

b1178   DEX 
        BNE b117E
        JMP j1330               ; disk

b117E   DEX 
        BNE b1184
        JMP j152A               ; do WORK command

b1184   DEX 
        BNE s118A               ; lookup entered command in command table
        JMP j154E               ; do SYS command

        ; ============ Compare entered input to command table
s118A   LDY #$00
b118C   LDA (p2A),Y     ; look up the chars for the entered line
        CMP (p57),Y     ; same as in the command table?
        BEQ b1193       ; yes, skip ahead
        RTS 

b1193   INY             ; increase char index
        CMP #$00        ; end?
        BNE b118C       ; no, go back and look at next char
        RTS             ; yes, return

p1199   .TEXT "BYE", $00, $00, "LOAD", $00, "LS", $00, $00, $00, "L", $00, $00, $00, $00
        .TEXT "RM", $00, $00, $00, "MV", $00, $00, $00, "PR", $00, $00, $00, "DISK", $00, "WORK", $00, "SYS", $00
        .TEXT $00

j11CB   TXA 
        PHA 
        TYA 
        CLC 
        ADC #$30
        STA a12A2
        LDX #$03
        LDA a29                 ; load number of arguments
        CMP #$02
        BNE b11F6
        LDA a179D
        STA a2A
        LDA a179E
        STA a2B
        LDY #$00
b11E8   LDA (p2A),Y
        BEQ b11F3
        STA f12A1,X
        INY 
        INX 
        BNE b11E8
b11F3   JMP j1204

b11F6   CMP #$01
        BEQ b11FE
        PLA 
        JMP j1572               ; jmp wrong number of arguments

b11FE   LDA #$2A
        STA f12A1,X
        INX 
j1204   TXA 
        LDX #$A1
        LDY #$12
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        PLA 
        PHA 
        TAX 
        LDA #$04
        LDY #$00
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        JSR ROM_OPEN            ; $FFC0 - open log.file after SETLFS,SETNAM
        BCC b121F
        PLA 
        JMP j1507

b121F   PLA 
        JSR j0FF5
        BCC b122D
        LDA #$04
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        JMP j0E8C               ; close open files

b122D   JSR s10ED
        LDX #$04
        JSR ROM_CHKIN           ; $FFC6 - open channel for input           
        JSR ROM_CHRIN           ; $FFCF - input character                  
        JSR ROM_CHRIN           ; $FFCF - input character                  
        LDA #$0D
        JSR s10AC
        LDA #$00
        STA a132F
j1245   JSR s1319
        BCS b1294
        JSR s1319
        BCS b1294
        JSR s1319
        BCS b1294
        PHA 
        JSR s1319
        TAY 
        PLA 
        TAX 
        JSR s12B4
        LDX #$00
b1260   LDA f1315,X
        CMP #$20
        BEQ b126F
        JSR s10AC
        INX 
        CPX #$03
        BNE b1260
b126F   LDA #$20
        JSR s10AC
j1274   JSR s1319
        BCS b1294
        CMP #$00
        BEQ b1283
        JSR s10AC
        JMP j1274

b1283   LDA #$0D
        JSR s10AC
b1288   LDA aCB                 ; Matrix coord of current key pressed
        EOR #$40
        ORA a028D
        BNE b1288
        JMP j1245

b1294   LDA #$0D
        JSR s10AC
        LDA #$04
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        JMP j0E8C               ; close open files

f12A1   .BYTE $24
a12A2   .BYTE $30
        .BYTE $3A
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00

        ; ================ 

s12B4   STX a1311
        STY a1312
        LDX #$03
        LDA #$20
b12BE   STA f1315,X
        DEX 
        BPL b12BE
        LDX #$00
        LDY #$03
b12C8   LDA #$00
        STA a1314
b12CD   SEC 
        LDA a1311
        SBC f1309,Y
        STA a1313
        LDA a1312
        SBC f130D,Y
        BCC b12ED
        STA a1312
        LDA a1313
        STA a1311
        INC a1314
        BNE b12CD
b12ED   LDA a1314
        BNE b12F6
        CPX #$00
        BEQ b12FD
b12F6   CLC 
        ADC #$30
        STA f1315,X
        INX 
b12FD   DEY 
        BPL b12C8
        TXA 
        BNE b1308
        LDA #$30
        STA f1315
b1308   RTS 

f1309   .BYTE $01,$0A,$64,$E8
f130D   .BYTE $00,$00,$00,$03
a1311   .BYTE $00
a1312   .BYTE $00
a1313   .BYTE $00
a1314   .BYTE $00
f1315   .BYTE $00,$00,$00,$00

        ; ================ 

s1319   LDA a132F
        CMP #$00
        BEQ b1322
        SEC 
        RTS 

b1322   JSR ROM_CHRIN           ; $FFCF - input character                  
        PHA 
        JSR ROM_READST          ; $FFB7 - read I/O status byte             
        STA a132F
        PLA 
        CLC 
        RTS 

a132F   .BYTE $00

j1330   LDA a29                 ; load number of arguments
        CMP #$02                ; 2?
        BEQ b1339               ; yes, skip ahead
        JMP j1572               ; jmp wrong number of arguments

b1339   LDA a179D
        STA a2A
        LDA a179E
        STA a2B
        LDA #$0F                ; logical file #15
        LDX a17FC
        TAY 
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        LDA #$00
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        JSR ROM_OPEN            ; $FFC0 - open log.file after SETLFS,SETNAM
        LDX #$0F                ; Command channel #15
        JSR ROM_CHKOUT          ; $FFC9 - open channel for output          
        LDY #$00
b135B   LDA (p2A),Y
        BEQ b1365
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        INY 
        BNE b135B
b1365   LDA #$0D                ; RETURN
        JSR ROM_CHROUT          ; $FFD2 - output character                 
        LDA a17FC
        JSR j0FF5
        JMP j0E8C               ; close open files

        ; check number of arguments and scratch a file

j1373   LDA a29                 ; load number of arguments
        CMP #$02                ; 2?
        BEQ b137C               ; yes, skip ahead
        JMP j1572               ; jmp wrong number of arguments

        ; scratch a file
b137C   CLC 
        LDA a17FD
        ADC #$30
        STA a13C7
        LDA a179D
        STA a2A
        LDA a179E
        STA a2B
        LDX #$03
        LDY #$00
b1393   LDA (p2A),Y
        BEQ b139E
        STA f13C6,X             ; store char in scratch filename buffer
        INY 
        INX 
        BNE b1393
b139E   LDA #$0D
        STA f13C6,X             ; store char in scratch filename buffer
        INX 
        TXA 
        LDX #$C6
        LDY #$13
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        LDA #$0F
        TAY 
        LDX a17FC
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        JSR ROM_OPEN            ; $FFC0 - open log.file after SETLFS,SETNAM
        BCC b13BD
        JMP j1507

b13BD   LDA a17FC
        JSR j0FF5
        JMP j0E8C               ; close open files

f13C6   .TEXT "S"
a13C7   .TEXT "0:"
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00

        ; check number of arguments and rename a file

j13DD   LDA a29                 ; load number of arguments
        CMP #$03
        BEQ b13E6
        JMP j1572               ; jmp wrong number of arguments

        ; rename a file
b13E6   CLC 
        LDA a17FD
        ADC #$30
        STA a145A
        PHA 
        LDA a179F
        STA a2A
        LDA a17A0
        STA a2B
        LDX #$03
        LDY #$00
b13FE   LDA (p2A),Y
        BEQ b1409
        STA f1459,X             ; store char in rename filename buffer
        INY 
        INX 
        BNE b13FE
b1409   LDA #$3D
        STA f1459,X             ; store char in rename filename buffer
        INX 
        PLA 
        STA f1459,X             ; store char in rename filename buffer
        INX 
        LDA #$3A
        STA f1459,X             ; store char in rename filename buffer
        INX 
        LDA a179D
        STA a2A
        LDA a179E
        STA a2B
        LDY #$00
b1426   LDA (p2A),Y
        BEQ b1431
        STA f1459,X
        INY 
        INX 
        BNE b1426
b1431   LDA #$0D
        STA f1459,X
        INX 
        TXA 
        LDX #$59                ; rename string
        LDY #$14
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        LDA #$0F                ; Command channel #15
        TAY 
        LDX a17FC
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        JSR ROM_OPEN            ; $FFC0 - open log.file after SETLFS,SETNAM
        BCC b1450
        JMP j1507

b1450   LDA a17FC
        JSR j0FF5
        JMP j0E8C               ; close open files

f1459   .TEXT "R"
a145A   .TEXT "0:"
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00

j1484   LDA a29                 ; load number of arguments
        CMP #$02                ; 2?
        BEQ b148D               ; yes, skip ahead
        JMP j1572               ; jmp wrong number of arguments

b148D   LDA a179D
        STA a2A
        LDA a179E
        STA a2B
        LDY #$00
b1499   LDA (p2A),Y
        BEQ b14A0
        INY 
        BNE b1499
b14A0   TYA 
        LDX a2A
        LDY a2B
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        LDA #$04
        LDX a17FC
        TAY 
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        JSR ROM_OPEN            ; $FFC0 - open log.file after SETLFS,SETNAM
        BCC b14B9
        JMP j1507

b14B9   LDA a17FC
        JSR j0FF5
        BCC b14C9
        LDA #$04
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        JMP j0E8C               ; close open files

b14C9   JSR s10ED
        LDX #$04
        JSR ROM_CHKIN           ; $FFC6 - open channel for input           
b14D1   JSR ROM_CHRIN           ; $FFCF - input character                  
        TAX 
        JSR ROM_READST          ; $FFB7 - read I/O status byte             
        PHA 
        TXA 
        JSR s10AC
        PLA 
        BEQ b14D1
        JSR b10C0
        LDA #$04
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        JMP j0E8C               ; close open files

        LDX #$F5
        LDY #$14
        JSR s08A8               ; Print string "CAN'T OPEN FILE"
        JMP j0E8C               ; close open files

        .TEXT "CAN'T OPEN FILE", $0D
        .TEXT $0D
        .TEXT $00

j1507   LDA #$04
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        LDX #$16
        LDY #$15
        JSR s08A8               ; Print string "DEVICE NOT PRESENT"
        JMP j0E8C               ; close open files

        .TEXT "DEVICE NOT PRESENT", $0D, $00

        ; ----------------- do WORK command
j152A   LDA a29                 ; load number of arguments
        CMP #$01
        BNE b1539
        LDX a17FC
        LDY a17FD
        JMP j1598               ; display work device and drive

b1539   CMP #$03
        BEQ b1540
        JMP j1572               ; jmp wrong number of arguments

b1540   JSR s15DD
        BCS b154B
        STX a17FC
        STY a17FD
b154B   JMP j0E8C               ; close open files

        ; ---------------- do SYS command
j154E   LDA a29                 ; load number of arguments
        CMP #$01
        BNE b155D
        LDX a17FA
        LDY a17FB
        JMP j1598               ; display sys device and drive

b155D   CMP #$03
        BEQ b1564
        JMP j1572               ; jmp wrong number of arguments

b1564   JSR s15DD
        BCS b156F
        STX a17FA
        STY a17FB
b156F   JMP j0E8C               ; close open files

        ; -------------- wrong number of args
j1572   LDX #$7C
        LDY #$15
        JSR s08A8               ; Print string "WRONG NUMBER OF ARGUMENTS"
        JMP j0E8C               ; close open files

        .TEXT "WRONG NUMBER OF ARGUMENTS", $0D
        .TEXT $0D
        .TEXT $00

        ; ------------- format and display "WORK" command result
j1598   LDA #$20
        STA a15CF
        TXA 
        LDX #$00
        CMP #$0A
        BCC b15AF
        PHA 
        LDA #$31
        STA a15CE
        PLA 
        SEC 
        SBC #$0A
        INX 
b15AF   CLC 
        ADC #$30
        STA a15CE,X
        CLC 
        TYA 
        ADC #$30
        STA a15D9
        LDX #$C6
        LDY #$15
        JSR s08A8               ; Print string "DEVICE: x DRIVE:x"
        JMP j0E8C               ; close open files

        .TEXT "DEVICE: "
a15CE   .TEXT $00
a15CF   .TEXT $00, "  DRIVE: "
a15D9   .TEXT $00, $0D, $0D, $00

s15DD   LDA a179D
        STA a2A
        LDA a179E
        STA a2B
        LDX #$00
        LDY #$00
        LDA (p2A),Y
        CMP #$31
        BNE b15FB
        LDX #$0A
        INY 
        LDA (p2A),Y
        BNE b15FB
        JMP j1658               ; drive not present

b15FB   TXA 
        CLC 
        ADC (p2A),Y
        SEC 
        SBC #$30
        STA a15CE
        INY 
        LDA (p2A),Y
        BEQ b160D
        JMP j1658               ; drive not present

b160D   LDA a179F
        STA a2A
        LDA a17A0
        STA a2B
        LDY #$00
        LDA (p2A),Y
        CMP #$30
        BCC b1629
        CMP #$32
        BCS b1629
        TAX 
        INY 
        LDA (p2A),Y
        BEQ b162C
b1629   JMP j1658               ; drive not present

b162C   TXA 
        SEC 
        SBC #$30
        STA a15D9
        LDA #$0F
        LDX a15CE
        TAY 
        JSR ROM_SETLFS          ; $FFBA - set file parameters              
        LDX #$75
        LDY #$16
        LDA #$03
        JSR ROM_SETNAM          ; $FFBD - set file name                    
        JSR ROM_OPEN            ; $FFC0 - open log.file after SETLFS,SETNAM
        PHP 
        LDA #$0F
        JSR ROM_CLOSE           ; $FFC3 - close a logical file             
        PLP 
        BCS j1658               ; drive not present
        LDX a15CE
        LDY a15D9
        RTS 

        ; drive not present

j1658   LDX #$61
        LDY #$16
        JSR s08A8               ; Print string "DRIVE NOT PRESENT"
        SEC 
        RTS 

        .TEXT "DRIVE NOT PRESENT", $0D, $0D, $00, "M-R"

f1678 = *
