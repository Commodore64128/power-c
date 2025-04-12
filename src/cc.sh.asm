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
; ============ Zero Page Addresses ============
a01 = $01      ; Processor port (data direction)
a4B = $4B      ; Temporary ZP pointer low byte
a4C = $4C      ; Temporary ZP pointer high byte
a4D = $4D      ; Additional temporary pointer low
a4E = $4E      ; Scratch byte
aFE = $FE      ; Stores a result/status temporarily
;
; **** ZP POINTERS **** 
;
p4B = $4B
p4D = $4D
;
; **** ABSOLUTE ADRESSES **** 
;
a033C = $033C  ; Argument count
a033E = $033E  ; Pointer to argument list (low byte)
a033F = $033F  ; Pointer to argument list (high byte)
a03FF = $03FF  ; Status/config byte
a17FA = $17FA  ; Logical file number 1 (source drive)
a17FB = $17FB  ; Logical file number 2 (destination drive)
a17FC = $17FC  ; Logical file number 3 (log or temporary file)
a17FD = $17FD  ; Logical file number 4 (secondary drive or working drive)
;
; **** EXTERNAL JUMPS **** 
;
e2000 = $2000 ; Address to jump into loaded compiler/translator code
;
; ============ KERNAL Routines ============
ROM_SETLFS  = $FFBA ; Set logical file parameters
ROM_SETNAM  = $FFBD ; Set file name
ROM_OPEN    = $FFC0 ; Open file
ROM_CLOSE   = $FFC3 ; Close file
ROM_CHKIN   = $FFC6 ; Open channel for input
ROM_CHKOUT  = $FFC9 ; Open channel for output
ROM_CLRCHN  = $FFCC ; Reset channels to default
ROM_CHRIN   = $FFCF ; Input a character
ROM_CHROUT  = $FFD2 ; Output a character
ROM_LOAD    = $FFD5 ; Load a file
ROM_GETIN   = $FFE4 ; Get byte from input

        * = $1800

        JMP j1806

        JMP j1A5D

;--------------------------------------------------
; ENTRY POINT AND ARGUMENT PARSING
;--------------------------------------------------
j1806   LDA a033E         ; Load address from argument pointer
        STA a4B           ; Store low byte in ZP $4B
        LDA a033F         ; Load high byte from argument pointer
        STA a4C           ; Store high byte in ZP $4C
        LDA #$01          ; Set default flag in a1C27
        STA a1C27
        LDA #$52          ; Set default mode in a03FF
        STA a03FF

; Argument processing loop
j181A   DEC a033C         ; Decrement argument count
        BEQ b1869         ; Exit loop if no arguments remain
        CLC
        LDA a4B
        ADC #$02          ; Advance argument pointer by 2 bytes
        STA a4B
        BCC b182A
        INC a4C           ; Adjust high byte if carry set

; Load argument address to p4D
b182A   LDY #$01
        LDA (p4B),Y       ; High byte of argument address
        STA a4E
        DEY
        LDA (p4B),Y       ; Low byte of argument address
        STA a4D

        LDA (p4D),Y       ; Check argument for '-' (options)
        CMP #$2D
        BNE b1869         ; Skip if not an option

; Option parsing loop
j183B   INY
        LDA (p4D),Y
        BEQ b1866         ; End of options
        CMP #$50          ; Option 'P'
        BNE b184C
        LDA #$00
        STA a1C27         ; Clear flag in a1C27 if 'P' is set
        JMP j183B         ; Continue parsing options

b184C   CMP #$41          ; Option 'A'
        BNE b1856
        STA a03FF         ; Set mode to 'A'
        JMP j183B

b1856   CMP #$53          ; Option 'S'
        BNE b1860
        STA a03FF         ; Set mode to 'S'
        JMP j183B

b1860   JMP j1AF5         ; Invalid option, jump to error

        JMP j183B

b1866   JMP j181A         ; Process next argument

; Check if exactly one filename argument remains
b1869   LDA a033C
        CMP #$01
        BEQ b1873         ; Exactly one filename is expected
        JMP j1AF5         ; Error if more or less than one

; Load filename into buffer at f1C13
b1873   LDY #$00
        LDX #$02
b1877   LDA (p4D),Y
        STA f1C13,X       ; Store filename character
        BEQ b1882         ; End of filename
        INY
        INX
        BNE b1877
b1882   STX a1C12         ; Store filename length

; Validate filename extension as ".C"
        DEY
        LDA (p4D),Y
        CMP #$43          ; Check for 'C'
        BNE b1893
        DEY
        LDA (p4D),Y
        CMP #$2E          ; Check for '.'
        BEQ b189A         ; Filename valid, continue

b1893   LDX #$9D          ; Error: Invalid filename
        LDY #$1B
        JMP j1AF9



;--------------------------------------------------
; LOAD COMPILER FILE
;--------------------------------------------------
b189A   LDA a17FD              ; Get drive number (ASCII conversion)
        CLC 
        ADC #$30               ; Convert to ASCII digit
        STA f1C13              ; Store in filename buffer
        STA a1BD2              ; Also store in temp filename buffers
        STA a1BDE
        STA a1BE

        LDA a17FB              ; Secondary drive number
        ADC #$30               ; Convert to ASCII
        STA a1BCD              ; Store for drive commands
        STA a1BFC
        STA a1C06

       ; Set parameters and load COMPILER
        LDA #$02
        LDX a17FA
        TAY 
        JSR ROM_SETLFS        ; $FFBA - set file parameters 

        LDA #$0A              ; Length of filename "COMPILER"
        LDX #$FC
        LDY #$1B
        JSR ROM_SETNAM        ;$FFBD - set file name 

        LDA #$00
        JSR ROM_LOAD           ;$FFD5 - load after call SETLFS,SETNAM    
        BCC b18DA              ; Proceed if load successful
        
        ; Handle load failure
        LDX #$27
        LDY #$1B
        JMP j1AF9              ; Display error message

b18DA   LDA a17FC              ; Store logical file number
        STA aFE
        JSR e2000              ; Execute compiler code

        ; Close files
        LDA #$02
        JSR ROM_CLOSE           ;$FFC3 - close a logical file             
        LDA #$0F
        JSR ROM_CLOSE           ;$FFC3 - close a logical file             

        ; Check execution success
        LDA aFE
        BEQ b18F8
        JSR s1A29
        LDA #$0F
        JMP ROM_CLOSE           ;$FFC3 - close a logical file             

;--------------------------------------------------
; LOAD TRANSLATOR FILE
;--------------------------------------------------
b18F8   LDX #$71
        LDY #$1B
        JSR s1AE4               ; Display waiting message
        JSR s1A29               ; Prepare compiler disk if needed

        LDA #$02
        LDX a17FA
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters 

        LDA #$0C                ; Length of filename "TRANSLATOR"
        LDX #$06
        LDY #$1C
        JSR ROM_SETNAM          ;$FFBD - set file name  

        LDA #$00
        JSR ROM_LOAD            ;$FFD5 - load after call SETLFS,SETNAM    
        BCC b1936

        ; Handle load failure
        LDX #$0F
        JSR ROM_CHKIN           ;$FFC6 - open channel for input           
b1920   JSR ROM_CHRIN           ;$FFCF - input character                  
        PHA 
        JSR ROM_CHROUT          ;$FFD2 - output character                 
        PLA 
        CMP #$0D
        BNE b1920
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        LDX #$27
        LDY #$1B
        JMP j1AF9

b1936   LDX #$88
        LDY #$1B
        JSR s1AE4               ; Display "TRANSLATING" message

        LDX #$0F
        JSR ROM_CHKOUT          ;$FFC9 - open channel for output          
        LDX #$D1
        LDY #$1B
        JSR j1AF9
        JSR s1AD0

        ; Set output filename suffix to "O"
        LDX a1C12
        DEX 
        LDA #$4F
        STA f1C13,X

        LDA #$53                ; Append character 'S'
        JSR ROM_CHROUT          ;$FFD2 - output character                 
        
        LDX #$13
        LDY #$1C
        JSR j1AF9

        LDA #$0D
        JSR ROM_CHROUT          ;$FFD2 - output character                 
        
       JSR s1AD0
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        LDA #$02
        LDX a17FC
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        LDA #$0E
        LDX #$DE
        LDY #$1B
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        LDX #$0F
        JSR ROM_CHKIN           ;$FFC6 - open channel for input           
        JSR ROM_CHRIN           ;$FFCF - input character                  
        CMP #$30
        BNE b1992
        JSR ROM_CHRIN           ;$FFCF - input character                  
        CMP #$30
b1992   PHP 
b1993   JSR ROM_CHRIN           ;$FFCF - input character                  
        CMP #$0D
        BNE b1993
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        PLP 
        BEQ b19B1
        LDX #$B3
        LDY #$1B
        JSR j1AF9
        LDA #$02
        JSR ROM_CLOSE           ;$FFC3 - close a logical file             
        LDA #$0F
        JMP ROM_CLOSE           ;$FFC3 - close a logical file             

;Success Path for File Operations
b19B1   LDA #$03          ; Set logical file number 3
        LDX a17FC         ; Load device number from a17FC
        TAY               ; Set secondary address to match device number
        JSR ROM_SETLFS    ; Set file parameters

        LDA #$0E          ; Filename length
        LDX #$ED          ; Filename pointer low byte
        LDY #$1B          ; Filename pointer high byte
        JSR ROM_SETNAM    ; Set filename

        JSR ROM_OPEN      ; Open file

        JSR e2000         ; External call, likely compilation/translation routine

        LDA #$03
        JSR ROM_CLOSE     ; Close logical file #3

        LDA #$02
        JSR ROM_CLOSE     ; Close logical file #2

        LDX #$0F
        JSR ROM_CHKOUT    ; Open channel for output on logical file #15

        LDA aFE           ; Check status byte aFE
        BEQ b19DF         ; If zero, skip conditional handling
        JMP j1A17         ; Otherwise, jump to alternate handling

b19DF   LDA #$43          ; Output character 'C'
        JSR ROM_CHROUT

        LDX #$13
        LDY #$1C
        JSR j1AF9         ; Print message from text table

        LDA #$3D          ; Output '=' character
        JSR ROM_CHROUT

        LDX #$00
b19F2   LDA a1BED,X        ; Output "XXXTEMP2" filename
        JSR ROM_CHROUT
        INX
        CPX #$0A
        BNE b19F2

        LDA #$2C          ; Output ','
        JSR ROM_CHROUT

        LDX #$00
b1A04   LDA a1BDE,X        ; Output "XXXTEMP1" filename
        JSR ROM_CHROUT
        INX
        CPX #$0A
        BNE b1A04

        LDA #$0D          ; Output newline
        JSR ROM_CHROUT

        JSR s1AD0         ; Flush remaining input

j1A17   LDX #$D1
        LDY #$1B
        JSR j1AF9         ; Print additional messages

        JSR s1AD0         ; Flush remaining input again

        JSR ROM_CLRCHN    ; Restore default channels

        LDA #$0F          ; Close logical file #15
        JMP ROM_CLOSE

;--------------------------------------------------
; PREPARE COMPILER DISK - Check if Source and Destination Drives differ
;--------------------------------------------------
s1A29   LDX a17FA
        CPX a17FC
        BEQ b1A4B               ; If same, skip disk preparation
        LDA #$0F
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        LDA #$01
        LDX #$CC
        LDY #$1B
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        LDA #$0F
        JSR ROM_CLOSE           ;$FFC3 - close a logical file             
        LDX a17FC

; If drives are same, simply open the log file
b1A4B   LDA #$0F
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        LDA #$01
        LDX #$CC
        LDY #$1B
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JMP ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM

;--------------------------------------------------
; ENTRY POINT FOR TRANSLATION PHASE (j1A5D)
;--------------------------------------------------
j1A5D   LDA a01                 ; Save processor status register
        PHA 
        ORA #$07                ; Enable BASIC/KERNAL ROM
        STA a01
        CLI                     ; Enable interrupts

        ; Display initial message
        LDX #$5B
        LDY #$1B
        JSR s1AE4               ; Display prompt or message depending on a1C27 flag

        ; Prepare temporary drive filename
        LDA a1BD2               ; Get drive number from stored temporary
        STA a1BCD

        ; Open log file on logical file 15
        LDA #$0F
        LDX a17FC
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters              
        
        LDA #$03                ; Filename length
        LDX #$CC
        LDY #$1B
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM

       ; Set up logical file for object output
        LDA #$02
        LDX a17FC
        TAY 
        JSR ROM_SETLFS          ;$FFBA - set file parameters 

        LDX #$13
        LDY #$1C
        LDA a1C12               ; Get filename length stored earlier
        JSR ROM_SETNAM          ;$FFBD - set file name                    
        JSR ROM_OPEN            ;$FFC0 - open log.file after SETLFS,SETNAM
        
       BCS b1AC1                ; Branch if OPEN failed

       ; Check compilation results in log file
        LDX #$0F
        JSR ROM_CHKIN           ;$FFC6 - open channel for input           
        JSR ROM_CHRIN           ;$FFCF - input character                  
        CMP #$30
        BNE b1AAE
        JSR ROM_CHRIN           ;$FFCF - input character                  
b1AAE   PHA                     ; Temporarily store result byte
b1AAF   JSR ROM_CHRIN           ; Read through to end of line                 
        CMP #$0D
        BNE b1AAF
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        PLA                     ; Restore result byte
        CMP #$30
        BNE b1AC1
        CLC                     ; Success, clear carry
        BCC b1ACB

; On file open or compilation failure, close object file and display error
b1AC1   LDA #$02
        JSR ROM_CLOSE           ;$FFC3 - close a logical file             
        LDX #$43
        LDY #$1B
        SEC                     ; Set carry indicating failure

; Restore processor status
b1ACB   SEI 
        PLA 
        STA a01                 ; Restore processor port (ROM/RAM configuration)
        RTS 

; Subroutine to consume and discard the rest of the current input line
s1AD0   LDX #$0F
        JSR ROM_CHKIN           ;$FFC6 - open channel for input           
b1AD5   JSR ROM_CHRIN           ;$FFCF - input character                  
        CMP #$0D
        BNE b1AD5
        JSR ROM_CLRCHN          ;$FFCC - restore default devices          
        LDX #$0F
        JMP ROM_CHKOUT          ;$FFC9 - open channel for output          

; Subroutine to conditionally wait for key press
s1AE4   LDA a1C27
        BNE b1AEA
        RTS 

b1AEA   JSR j1AF9               ; Output message or prompt
b1AED   JSR ROM_GETIN           ;$FFE4 - get a byte from channel          
        CMP #$0D
        BNE b1AED               ; Loop until RETURN pressed
        RTS 

; Display error or informational messages
j1AF5   LDX #<p1B0A
        LDY #>p1B0A
j1AF9   STX a4B
        STY a4C
        LDY #$00
b1AFF   LDA (p4B),Y
        BEQ b1B09
        JSR ROM_CHROUT          ;$FFD2 - output character                 
        INY 
        BNE b1AFF
b1B09   RTS 

; Messages for usage, disk and file errors
p1B0A   .TEXT "USAGE:  CC [-PAS] FILENAME", $0D, $0D, $00
        .TEXT "COMPILER DISK NOT PRESENT", $0D, $0D, $00
        .TEXT "SOURCE FILE NOT FOUND", $0D, $0D, $00
        .TEXT $0D, "INSERT SOURCE DISK", $0D, $0D, $00
        .TEXT $0D, "INSERT COMPILER DISK", $0D, $00
        .TEXT "INSERT OBJECT DISK", $0D, $0D, $00
        .TEXT "NOT A ", $C3, " SOURCE FILE", $0D, $0D, $00
        .TEXT "CAN'T OPEN OBJECT FILE", $0D, $0D, $00

; Pre-formatted filenames and messages
a1BCD   .TEXT "0",":", $0D, $00, "S"
a1BD2   .TEXT "0:XXXTEMP*", $0D, $00
a1BDE   .TEXT "0:XXXTEMP1,S,W", $00
a1BED   .TEXT "0:XXXTEMP2,S,W", $00
a1BFC   .TEXT "0:COMPILER"
a1C06   .TEXT "0:TRANSLATOR"
a1C12   .TEXT $00

; Filename buffer area
f1C13   .TEXT "0:"
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00

; Configuration flag area
a1C27   .BYTE $00

