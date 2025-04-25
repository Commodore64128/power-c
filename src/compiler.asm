;**************************************************
;
; BETTER WORKING POWER C
; FOR THE COMMODORE 64/128
;
; COMPILER
;
;**************************************************
;
; **** ZP FIELDS **** 
;
f00 = $00
f26 = $26
;
; **** ZP ABSOLUTE ADRESSES **** 
;
a01 = $01
a14 = $14
a15 = $15
a16 = $16
a17 = $17
a18 = $18
a1A = $1A
a1B = $1B
a1C = $1C
a1D = $1D
a1E = $1E
a1F = $1F
a20 = $20
a21 = $21
a26 = $26
a27 = $27
a28 = $28
a29 = $29
a2B = $2B
a2C = $2C
a2D = $2D
a2E = $2E
a2F = $2F
a30 = $30
a31 = $31
a32 = $32
a33 = $33
a34 = $34
a35 = $35
a36 = $36
a37 = $37
a38 = $38
a39 = $39
a3A = $3A
a3B = $3B
a3C = $3C
a3D = $3D
a3E = $3E
a3F = $3F
a40 = $40
a41 = $41
a42 = $42
a43 = $43
a44 = $44
a45 = $45
a46 = $46
a47 = $47
a48 = $48
a49 = $49
a4A = $4A
a4B = $4B
a4C = $4C
a7A = $7A
a7B = $7B
a9E = $9E
aFC = $FC
aFE = $FE
;
; **** ZP POINTERS **** 
;
p14 = $14
p1A = $1A
p1C = $1C
p1E = $1E
p20 = $20
p26 = $26
p2B = $2B
p32 = $32
p34 = $34
p38 = $38
p3A = $3A
p3C = $3C
p3E = $3E
p40 = $40
p44 = $44
p46 = $46
p49 = $49
;
; **** FIELDS **** 
;
f7C31 = $7C31
f866B = $866B
f8778 = $8778
f87E6 = $87E6
f87FA = $87FA
f8C27 = $8C27
f8D81 = $8D81
f8DB3 = $8DB3
;
; **** ABSOLUTE ADRESSES **** 
;
a03FF = $03FF
a17FD = $17FD
a7C32 = $7C32
a864D = $864D
a864E = $864E
a864F = $864F
a8678 = $8678
a8679 = $8679
a867A = $867A
a867B = $867B
a8779 = $8779
a8782 = $8782
a87AA = $87AA
a87AB = $87AB
a87AC = $87AC
a87C9 = $87C9
a880E = $880E
aB400 = $B400
aB401 = $B401
;
; **** POINTERS **** 
;
p0D27 = $0D27
p7C59 = $7C59
p7E4D = $7E4D
p87C8 = $87C8
p8827 = $8827
p8C81 = $8C81
p8EB3 = $8EB3
pAC00 = $AC00
pB800 = $B800
pBDDC = $BDDC
pD000 = $D000
pD800 = $D800
pE000 = $E000
pFF01 = $FF01
;
; **** EXTERNAL JUMPS **** 
;
e0079 = $0079
e04ED = $04ED
e1803 = $1803
eB391 = $B391
eBBD4 = $BBD4
eBCF3 = $BCF3
;
; **** PREDEFINED LABELS **** 
;
ROM_READST = $FFB7
ROM_SETLFS = $FFBA
ROM_SETNAM = $FFBD
ROM_OPEN = $FFC0
ROM_CLOSE = $FFC3
ROM_CHKIN = $FFC6
ROM_CHKOUT = $FFC9
ROM_CLRCHN = $FFCC
ROM_CHRIN = $FFCF
ROM_CHROUT = $FFD2
ROM_GETIN = $FFE4

        * = $2000
;--------------------------------------------------
; Startup Initialization at $2000
;--------------------------------------------------
; Disable interrupts and configure system flags, then initialize
; compiler working areas and I/O before beginning compilation.

        SEI              ; disable interrupts
        LDA a01
        AND #$F8        ; mask bits 0-2
        STA a01         ; set system flags
        LDA aFE
        STA a2051       ; clear compiler state
        JSR s2052       ; init workspace buffers — sets up scratch memory by copying zero-page work area
        JSR s319D       ; clear variable table — resets compiler’s symbol entries/variable definitions
        JSR s523E       ; setup I/O table — hooks KERNAL CHRIN/CHROUT/GETIN routines for compiler's console I/O
        JSR s24B4       ; init code-pointer table — set a1E/a1F to point at token dispatch table in memory
        JSR s20EC       ; init conditional directive state — reset IF-level counter and prepare unmatched-IF error message buffer

;--------------------------------------------------
; Label j201B ($201B) - Entry to parsing main loop
;--------------------------------------------------
j201B   JSR s26E7       ; initialize scanner/parser starting state (reset buffers & pointers)
        JSR s26FA       ; process initial directives and setup I/O conditions
        JSR s20A8       ; handle conditional directives (#IF state or file open ops)
j2024   LDX #$0F        ; continue main loop setup
        JSR s2140       ; open output channel — set compiler’s output to current device (CHROUT)
        LDA #$49        ; 'I'
        JSR s2152       ; output character via CHROUT
        LDA #$30        ; '0'
        JSR s2152       ; output character via CHROUT
        LDA #$0D        ; carriage return
        JSR s2152       ; output character via CHROUT
        JSR s2164       ; restore default I/O devices
        JSR s205D       ; restore workspace buffers — copy original zero-page work area back from backup
        JSR s207E       ; print compiler banner — output initial header message from f208D via CHROUT
        LDA a01
        ORA #$07
        STA a01
        CLI               ; reenable interrupts
        LDA #<p8EB3       ; setup return pointer low byte
        STA a4B
        LDA #>p8EB3       ; setup return pointer hi byte
        STA a4C
        RTS               ; return to caller

a2051   .BYTE $00

        ; Copy 250 bytes back and forth between two zero‑page buffers
        ; used to clear or restore state.
s2052   LDX #$FA
b2054   LDA f00,X
        STA f7ACD,X
        DEX 
        BNE b2054
        RTS 

        ; Copy 250 bytes back and forth between two zero‑page buffers
        ; used to clear or restore state.
s205D   LDX #$FA
b205F   LDA f7ACD,X
        STA f00,X
        DEX 
        BNE b205F
        RTS 

;--------------------------------------------------
; Routine s2068 ($2068) - Token Scanner Loop
;--------------------------------------------------
s2068   STX a2B           ; save X as low byte of dispatch table pointer
        STY a2C           ; save Y as high byte of dispatch table pointer
        LDY #$00          ; start index at zero to read first character
j206E   LDA (p2B),Y       ; load next PETSCII character from input buffer
        BEQ b207D         ; if character = $00, end of input; exit scanner
        JSR s2152         ; dispatch or echo character via CHROUT
        INY               ; increment low-byte index
        BNE b207A         ; if no wrap, stay on same page
        INC a2C           ; on wrap, advance high-byte page for pointer
b207A   JMP j206E         ; repeat loop for next character

b207D   RTS               ; return when scan complete

;--------------------------------------------------
; Routine s207E ($207E) - Banner/Text Printer Loop
;--------------------------------------------------
s207E   LDY #$00          ; start index at zero to read banner text
j2080   LDA f208D,Y       ; load next byte from banner table f208D
        BEQ b208C         ; if zero, end of banner; exit printer
        JSR s2152         ; output character via CHROUT
        INY               ; advance to next byte in banner
        JMP j2080         ; loop to print entire banner

b208C   RTS               ; return after banner printed

;--------------------------------------------------
; Data Block f208D (Banner Graphics)
;--------------------------------------------------
; f208D: 32-byte PETSCII pattern table used as the compiler banner graphic.
; Consists of a sequence of PETSCII graphic characters (value $11 = solid block, $13 = half-block) to draw a decorative
; line or box at the top of the banner, followed by a terminating $00.
; The printer routine s207E iterates through this table to render the banner's graphic border before text.
;
; Example values:
;   $13 : left half block
;   $11 : full block
;   $00 : terminator
;
f208D   .BYTE $13,$11,$11,$11,$11,$11,$11,$11
        .BYTE $11,$11,$11,$11,$11,$11,$11,$11
        .BYTE $11,$11,$11,$11,$11,$11,$11,$11
        .BYTE $11,$11,$00


;--------------------------------------------------
; Routine s20A8 ($20A8) - Conditional Directive & File Setup
;--------------------------------------------------
s20A8   LDA a59EB        ; check nested conditional/file state flag
        BEQ b20B4        ; if zero, first pass: open default file/context
        LDX #$D3         ; else, prepare to resume scan: set prompt delimiter
        LDY #$20
        JMP j20F8        ; jump back into main scanner loop

b20B4   LDA #$00         ; channel 0
        JSR s21D3        ; SETLFS to channel 0
        LDA #<pE000      ; low byte of input buffer address
        STA a14          ; set LFS low
        LDA #>pE000      ; high byte of input buffer address
        STA a15          ; set LFS high
        LDA #$71         ; record length or E: >$70 command
        JSR s21D3        ; SETNAM/OPEN to initialize file read
        LDA a26E0        ; low byte of record count
        JSR s21D3        ; transfer to record counter
        LDA a26E1        ; high byte of record count
        JSR s21D3        ; transfer to record counter
        RTS              ; return to caller after file setup

        .TEXT " *** #IF WITHOUT #ENDIF", $0D, $00

;--------------------------------------------------
; Routine s20EC ($20EC) - Initialize #IF Directive State
;--------------------------------------------------
; Sets up state for conditional compilation directives.
s20EC
       LDA #$00           ; clear nesting counter (no unmatched #IF yet)
       STA aFE            ; store zero in conditional state flag
       TSX                ; transfer current stack pointer to X for depth tracking
       INX                ; adjust X to account for local variables saved on stack
       INX                ; further adjust X to arrive at return stack depth
       STX a20F7          ; save computed return SP offset in a20F7 for later use
       RTS                ; return to caller, conditional directives initialized

a20F7   .BYTE $00

;--------------------------------------------------
; Routine j20F8 ($20F8) - Main Input Loop Entry
;--------------------------------------------------
j20F8   LDA #$01          ; set input-ready flag in aFE
        STA aFE
        STX a2B           ; initialize pointer low-byte to input buffer start
        STY a2C           ; initialize pointer high-byte to input buffer start

; Wait for at least one record to be read into buffer (a5603 holds pending record count)
j2100   LDA a5603        ; load remaining record count
        CMP #$02         ; compare to threshold for 'end-of-file'
        BEQ b2110        ; if 2 means data available, proceed to scan
        JSR s215B        ; close current file handle to refill buffer
        DEC a5603        ; decrement record count
        JMP j2100        ; loop until data ready

b2110   LDA #$0D         ; load carriage return to signal end-of-line
        JSR s2152        ; output CR to console
        LDX a2B          ; restore buffer pointer low-byte
        LDY a2C          ; restore buffer pointer high-byte
        JSR s2068        ; call scanner loop to process buffer
        LDX a20F7        ; load saved return stack offset
        TXS              ; restore return address for nested directives
        JMP j2024        ; return to main loop for next iteration

;--------------------------------------------------
; Routines s2123 ($2123), j212D ($212D), and s2137 ($2137) - I/O Mode Control
;--------------------------------------------------
; s2123: Disable echo and enter critical section
s2123   PHA              ; save A
        LDA a01          ; load system port settings
        ORA #$06         ; enable serial disable and linefeed inhibit
        STA a01          ; update system port (disable screen output)
        PLA              ; restore A
        CLI              ; clear interrupt disable to allow I/O
        RTS              ; return to caller

; j212D: Enable interrupts and restore echo
j212D   SEI              ; disable interrupts
        PHA              ; save A
        LDA a01          ; load system port settings
        AND #$F8         ; clear serial-disable and linefeed-inhibit bits
        STA a01          ; restore normal screen output
        PLA              ; restore A
        RTS              ; return to caller

; s2137: Open input channel in protected mode
s2137   JSR s2123        ; disable echo and set low-level I/O flags
        JSR ROM_CHKIN    ; $FFC6 - open channel for input (CHRIN)
        JMP j212D        ; branch to restore echo and enable interrupts


s2140   JSR s2123
        JSR ROM_CHKOUT ;$FFC9 - open channel for output          
        JMP j212D

s2149   JSR s2123
        JSR ROM_CHRIN ;$FFCF - input character                  
        JMP j212D

s2152   JSR s2123
        JSR ROM_CHROUT ;$FFD2 - output character                 
        JMP j212D

s215B   JSR s2123
        JSR ROM_CLOSE ;$FFC3 - close a logical file             
        JMP j212D

s2164   JSR s2123
        JSR ROM_CLRCHN ;$FFCC - restore default devices          
        JMP j212D

s216D   JSR s2123
        JSR ROM_GETIN ;$FFE4 - get a byte from channel          
        JMP j212D

;--------------------------------------------------
; Routine s2176 ($2176) - Read a Line from File into Buffer
;--------------------------------------------------
s2176   JSR s2123        ; disable echo and set low-level I/O flags
        JSR ROM_OPEN     ; open file after SETLFS and SETNAM
        LDX #$0F
        JSR ROM_CHKIN    ; open channel for input
        LDY #$00
b2183   JSR ROM_CHRIN    ; read character from input channel into A
        STA f7C31,Y      ; store character into line buffer f7C31
        INY
        CMP #$0D         ; check for carriage return (end-of-line)
        BNE b2183       ; loop until CR
        LDA #$00
        STA f7C31,Y      ; null-terminate the string
        LDA f7C31       ; peek first character of the line
        CMP #$30        ; compare to '0' (PETSCII $30)
        BNE b21A5       ; if '0', treat as special case
        LDA a7C32
        CMP #$30        ; check ROM GET buffer first byte
        BNE b21A5       ; if '0', special case
        CLC
        JMP j212D       ; normal return: restore echo and interrupts

b21A5   LDA #$0F
        JSR ROM_CLOSE   ; close the input file
        JSR ROM_CLRCHN  ; restore default I/O devices
        SEC
        LDX #$31
        LDY #$7C
        JMP j212D       ; return with carry set for special case

;--------------------------------------------------
; Routine s21B5 ($21B5) - Read I/O Status Byte
;--------------------------------------------------
s21B5   JSR s2123        ; disable echo and set I/O flags
        JSR ROM_READST   ; read the I/O status byte from KERNAL
        JMP j212D        ; restore echo and return


s21BE   JSR s2123
        JSR ROM_SETLFS ;$FFBA - set file parameters              
        JMP j212D

s21C7   JSR s2123
        JSR ROM_SETNAM ;$FFBD - set file name                    
        JMP j212D

;--------------------------------------------------
; Routine s21D0 ($21D0) - Invoke Name Descriptor Emitter
;--------------------------------------------------
s21D0   JMP j24BD        ; jump into binary writer routine at j24BD to emit current name and file pointers into output stream

;--------------------------------------------------
; Routine s21D3 ($21D3) - Push and Test Name Length
;--------------------------------------------------
s21D3   PHA              ; save accumulator (character or length count)
        JSR s58F5        ; normalize input character (convert lowercase to uppercase, skip control)
        BCC b21DB        ; if no carry, character valid for name length counting
        PLA              ; restore accumulator on error
        RTS              ; return without storing length

b21DB   PLA              ; restore original accumulator
        STY a21F6        ; store Y (length or flag) into a21F6 for name descriptor
        LDY #$00
        STA (p14),Y      ; write name descriptor header byte at *p14
        INC a14          ; advance pointer low-byte
        BNE b21F2        ; if no wrap
        INC a15          ; on wrap, increment pointer high-byte
        BNE b21F2
        LDX #$F7
        LDY #$21
        JMP j20F8
b21F2   LDY a21F6        ; reload length/flag into Y
        RTS              ; return to caller


a21F6   .TEXT $00
        .TEXT " *** PROGRAM TOO BIG", $0D, $00

;--------------------------------------------------
; Routine s220D ($220D) - 'Program Too Big' Error Emitter
;--------------------------------------------------
s220D   STX a2B           ; save current buffer pointer low-byte for error text source
        STY a2C           ; save current buffer pointer high-byte
        JSR s58F5         ; normalize first error character (uppercase conversion)
        BCC b2217         ; if non-printable/control, skip to buffer copy loop
        RTS               ; otherwise, abort error emit if unexpected character

b2217   LDY #$00          ; start index for copying error message characters
b2219   LDA (p2B),Y       ; load error text byte from source buffer
        BEQ b2224         ; if zero terminator, end of message copy
        STA (p14),Y       ; store into output buffer (descriptor area)
        INY               ; increment copy index
        CPY #$0A          ; limit to 10 characters max
        BNE b2219         ; continue until max or terminator reached
b2224   LDA #$00          ; null-terminate the copied error text
        STA (p14),Y       ; write terminator
        INY               ; advance pointer
        CLC               ; prepare for pointer addition
        TYA               ; get copy length in A
        ADC a14           ; add to output buffer pointer low-byte
        STA a14           ; store updated pointer low-byte
        BCC b223C         ; if no carry, skip
        INC a15           ; increment high-byte on carry
        BNE b223C
        LDX #$F7
        LDY #$21
        JMP j20F8
b223C   RTS               ; return after error message emitted


;--------------------------------------------------
; Routine j223D ($223D) - Primary Expression Evaluator Entry
;--------------------------------------------------
j223D   JSR s58B3        ; skip whitespace and get next token, sets carry clear if operator follows
        BCC b2248        ; branch to operator-specific handler if valid operator
        JSR s24ED        ; emit current symbol or operator token into output stream
        JMP j5649        ; jump to expression finalizer/cleanup

;--------------------------------------------------
; Routine b2248 ($2248) - Operator-Specific Handling
;--------------------------------------------------
b2248   INC a18           ; increment expression nesting depth counter
        LDY #$00          ; reset index for reading operator length
        LDA (p49),Y       ; load operator code from input buffer
        INY
        CMP #$01
        BEQ b2265        ; if operator code = 1 (e.g., '+'), handle unary/binary plus
        CMP #$02
        BEQ b2265        ; handle other operators similarly
        CMP #$03
        BEQ b2265
        CMP #$07
        BEQ b2265
        CMP #$08
        BEQ b2265
        CMP #$05
b2265   BNE b2269        ; if none match, skip special multi-byte operator handling
        INY               ; advance past 2-byte operator prefix
        INY               ; advance past prefix bytes
b2269   LDA (p49),Y       ; load following byte for full operator code
        CMP #$0A
        BNE b2284        ; dispatch to operator handlers based on code
        LDA #$0C
        JSR s21D3        ; push operator code as name descriptor
        STY a238F        ; save current index in a238F
        LDX #$78
        LDY #$87
        JSR s220D        ; emit error if operator not supported or overflow
        LDY a238F        ; restore index
        JMP j2330        ; continue expression loop

;--------------------------------------------------
; Routine b2284 ($2284) - Handling Multi-Character Operators
;--------------------------------------------------
b2284   LDY #$00          ; reset index into operator lookup sequence
        LDA (p49),Y       ; fetch first operator prefix byte
        INY               ; advance input pointer
        CMP #$01          ; check for prefix code $01 (start of three-byte operator)
        BNE b22A1         ; if not $01 prefix, branch to two-byte operator handling
        LDA #$04          ; token code for three-byte operators starting with $01
        JSR s21D3         ; push operator prefix descriptor
        LDA (p49),Y       ; fetch second operator byte
        INY               ; advance input pointer
        JSR s21D3         ; push second-byte operator descriptor
        LDA (p49),Y       ; fetch third operator byte
        INY               ; advance input pointer
        JSR s21D3         ; push third-byte operator descriptor
        JMP j2330         ; continue expression loop after multi-byte operator

;--------------------------------------------------
; Routine b22A1 ($22A1) - Handling Two-Byte Operators (e.g., '==', '>=', etc.)
;--------------------------------------------------
b22A1   CMP #$02          ; check for '=' prefix (equality/comparison)
        BEQ b22A7         ; branch if match
        CMP #$03          ; check for alternative two-byte operator prefix
b22A7   BNE b22BD         ; if no variant match, exit to next handler
        LDA #$07          ; token code for two-byte operators
        JSR s21D3         ; push first operator byte descriptor
        LDA (p49),Y       ; fetch second operator byte
        INY               ; advance input pointer
        JSR s21D3         ; push second operator descriptor
        LDA (p49),Y       ; fetch optional third byte for extended sequence
        INY               ; advance input pointer
        JSR s21D3         ; push third-byte operator descriptor
        JMP j2330         ; continue expression loop after handling two-byte operator

;--------------------------------------------------
; Routine b22BD ($22BD) - '!=' and two-byte comparator handlers
;--------------------------------------------------
b22BD   CMP #$04          ; check for '!=' or '<>' operator prefix code (04)
        BNE b22D6         ; if not comparator, fallback to single-character operator handler
        LDA #$08          ; token code for '!=' operator descriptor
        JSR s21D3         ; emit '!' descriptor into name stream
        STY a238F         ; save current Y index for resuming copy after error emit
        LDX #$78          ; high-byte for error emitter buffer page
        LDY #$87          ; low-byte for error emitter buffer page
        JSR s220D         ; emit error message if operator sequence invalid or buffer overflow
        LDY a238F         ; restore Y index to correct continuation point
        JMP j2330         ; resume expression parsing after handling '!='

b22D6   CMP #$05        ; check if incoming operator code is $05 (start of comparator sequence)
        BNE b22E9       ; if not, jump to next operator handler
        LDA #$1E        ; load internal token code for this comparator operator
        JSR s21D3       ; push comparator descriptor onto output stream
        LDA (p49),Y     ; fetch next input byte for comparator operand
        INY             ; advance input pointer past the byte
        INY             ; skip over any extra byte in this multi-byte op sequence
        JSR s21D3       ; emit second-byte descriptor for comparator
        JMP j2330       ; resume main expression parsing loop

b22E9   CMP #$07        ; check if operator code equals $07 (another two-byte operator)
        BNE b2301       ; if not, continue to other handlers
        LDA #$09        ; load token code for this two-byte operator
        JSR s21D3       ; emit first byte descriptor
        LDA (p49),Y     ; fetch second operator character
        INY             ; advance pointer
        JSR s21D3       ; emit second-byte descriptor
        LDA (p49),Y     ; fetch optional third byte in sequence
        INY             ; advance pointer
        JSR s21D3       ; emit third-byte descriptor
        JMP j2330       ; finish operator handling and loop

b2301   CMP #$09        ; check if operator code equals $09 (prefix for error-driven handler)
        BNE b231A       ; if not match, skip to next handler
        LDA #$0A        ; load token code $0A for this operator descriptor
        JSR s21D3       ; push operator descriptor onto output stream
        STY a238F       ; save current Y index for error recovery
        LDX #$78        ; set high-byte for error emitter buffer page
        LDY #$87        ; set low-byte for error emitter buffer page
        JSR s220D       ; invoke error emitter (s220D) if sequence invalid or overflow
        LDY a238F       ; restore Y index after error emit
        JMP j2330       ; resume main expression parsing loop       ; finish operator handling and loop

b231A   CMP #$0A        ; compare operator code to $0A (start of specific operator sequence)
        BNE j2330       ; if not equal, jump to default handler at j2330
        LDA #$0B        ; load token code $0B for this operator descriptor
        JSR s21D3       ; push operator descriptor onto output stream
        STY a238F       ; save Y (index) for error recovery
        LDX #$78        ; set X to high-byte of error buffer page
        LDY #$87        ; set Y to low-byte of error buffer page
        JSR s220D       ; call error emitter to report unsupported operator or overflow
        LDY a238F       ; restore Y index after error emission

j2330   STY a238F       ; re-store Y index for subsequent parsing
j2333   LDA (p49),Y     ; fetch next input byte at pointer p49 + Y
        CMP #$09        ; compare to $09 (operator code boundary)
        BCC b2343       ; if less, branch to single-byte handler at b2343
        CMP #$0B        ; else compare to $0B (extended operator code boundary)
        BNE b233F       ; if not equal, go to skip step at b233F
        INY             ; skip an additional byte for extended sequence
        INY             ; skip another byte for extended sequence

b233F   INY             ; advance pointer past current operator code
        JMP j2333       ; loop back to classification at j2333

b2343   CMP #$07        ; compare operator code to $07 (multi-character operator indicator)
        BCC b2349       ; if code < $07, branch to single-character handler
        INY             ; skip one extra byte for multi-character prefix
        INY             ; skip second extra byte for multi-character prefix

b2349   LDA (p49),Y     ; load next operator byte from input buffer
        JSR s21D0       ; emit this operator byte via name descriptor emitter
        CPY a238F       ; compare Y index to saved index (end of operator sequence)
        BEQ b2357       ; if at saved index, operator fully emitted, continue at b2357
        DEY             ; otherwise, decrement Y to reprocess remaining bytes
        JMP b2349       ; loop to emit all parts of the multi-byte operator

b2357   JSR s58F5       ; normalize next error character (skip control), sets carry if non-printable
        BCS b2385       ; if carry set, skip extended operator handling
        LDY a238F       ; restore saved input buffer index
        LDA (p49),Y     ; load operator byte at restored position
        CMP #$0B        ; check for extended operator code $0B
        BNE b2385       ; if not $0B, skip extension
        LDY #$00        ; reset Y index for extension sequence
        LDA (p49),Y     ; load first byte of extension sequence
        CMP #$07        ; compare to multi-character operator indicator
        BEQ b236F       ; if match, branch to error handler
        CMP #$05        ; compare to alternative variant code $05
b236F   BEQ b2385       ; if match, skip error emission
        JSR s24CE       ; emit descriptor for first extension byte
        JSR s24CE       ; emit descriptor for second extension byte
        JSR s24CE       ; emit descriptor for third extension byte
        LDA #$09        ; load fallback token code for unsupported operator
        JSR s21D0       ; emit fallback operator descriptor
        LDA #$00        ; load terminator
        JSR s21D0       ; emit terminator descriptor
        RTS             ; return to expression parsing

;--------------------------------------------------
; b2385 ($2385) - Two-byte comparator continuation handler (e.g., '>=' second byte)
;--------------------------------------------------
b2385   LDA #$09       ; Load token code 0x09 for this two-byte comparator into A
        JSR s21D0      ; Emit name descriptor: push token code onto output stream
        LDA #$01       ; Prepare terminator code (0x01) for descriptor sequence
        JMP s21D0      ; Emit terminator via name descriptor routine and return to parser

; Temporary zero-page storage used by expression parser to remember Y offset

a238F   .BYTE $00      ; Stores Y index across multi-byte operator parsing

;--------------------------------------------------
; j2390 ($2390) - Primary expression evaluator entry
;--------------------------------------------------
j2390   JSR s58B3      ; Skip whitespace and fetch next token, leave carry clear if operator follows
        BCC b239B      ; If operator detected, branch to operator-specific handling

        JSR s24ED      ; Otherwise, emit current symbol/operator token into output stream
        JMP j5649      ; Jump to expression finalizer/cleanup routine

b239B   INC a18         ; increment expression nesting depth counter
        JSR s694C      ; normalize accumulator for descriptor emission
        LDA a36        ; load current token class or operator code
        CMP #$0C       ; compare to special operator identifier (0x0C)
        BEQ b23B7      ; if match, branch to multi-compare handler
        LDA #$02       ; load default descriptor code (e.g., value placeholder)
        JSR s21D0      ; push descriptor into output stream
        LDA #$01       ; load continuation flag or small literal
        JSR s21D0      ; push continuation descriptor
        LDX #$D7       ; set return address pointer low byte for dispatch
        LDY #$23       ; set return address pointer high byte for dispatch
        JMP j562D      ; jump back to expression evaluator loop

;--------------------------------------------------
; Label b23B7 ($23B7) - Handle specific operator/identifier sequence and emit descriptors
;--------------------------------------------------
b23B7   LDA #$0C        ; Load accumulator with token code $0C for multi-byte operator/identifier start
        JSR s21D3       ; Push and test name length: emit descriptor for the loaded code into name stream
        LDX #$78        ; Prepare high-byte of error emitter buffer page for overflow check
        LDY #$87        ; Prepare low-byte of error emitter buffer page
        JSR s220D       ; Call 'Program Too Big' error emitter if descriptor overflow occurs
        LDA #$02        ; Load A with next descriptor code $02
        JSR s21D0       ; Emit name descriptor for code $02
        LDA #$0A        ; Load A with descriptor code $0A
        JSR s21D0       ; Emit name descriptor for code $0A
        LDA #$09        ; Load A with descriptor code $09
        JSR s21D0       ; Emit name descriptor for code $09
        LDA #$01        ; Load A with descriptor code $01 to terminate sequence
        JMP s21D0       ; Jump to push-and-emit name descriptor (final byte)

        .TEXT " *"
        .TEXT "** UNDECLARED IDENTIFIER", $0D, $00

;--------------------------------------------------
; Routine j23F3 ($23F3) - Handle Primary Expression Error or Symbol Emit
;--------------------------------------------------
j23F3   JSR s692A        ; attempt to parse next symbol/token, sets carry if error encountered
        BCC b23FC        ; if carry clear (no error), jump to emit path
        LDA #$02         ; error code 2 (invalid primary expression)
        STA a9E          ; store error code in a9E
b23FC   JSR s58B3        ; skip whitespace and fetch next token into A
        BCC b240A        ; if carry clear (valid token), continue with symbol emission
        LDX a8678        ; on error/resume, restore saved low pointer from a8678
        LDY a8679        ; restore saved high pointer from a8679
        JMP s24ED        ; emit descriptor for saved symbol and return

;--------------------------------------------------
; Label b240A ($240A) - Emit Identifier or Constant Descriptor
;--------------------------------------------------
b240A   INC a18          ; increment expression nesting depth counter
        LDA #$05         ; descriptor code for identifier/constant start
        JSR s21D3        ; push descriptor byte
        LDA a8678        ; fetch low byte of symbol pointer
        JSR s21D3        ; emit low byte descriptor
        LDA a8679        ; fetch high byte of symbol pointer
        JSR s21D3        ; emit high byte descriptor
        LDA #$02         ; descriptor code for identifier type
        JSR s21D0        ; push type descriptor into output stream
        LDA #$00         ; null terminator for descriptor
        JSR s21D0        ; emit terminator
        RTS              ; return from primary expression handler

; Routine j2428 ($2428) - Prefix Expression or Operator Handler
j2428   JSR s58B3       ; skip whitespace and get next token (carry clear if operator follows)
        BCC b2433       ; if no operator token, branch to value handler
        JSR s24ED       ; emit operator token into output
        JMP j5649       ; finalize expression and return

; Handler b2433 ($2433) - Process prefix operator sequence
b2433   INC a18         ; increment expression nesting depth
        LDA #$0D        ; descriptor code for prefix operator
        JSR s21D3       ; push prefix operator descriptor
        LDX #$00        ; index=0 to emit 4-byte operand address
b243C   LDA a8678,X     ; load low/high bytes of operand address
        JSR s21D3       ; emit each address byte as descriptor
        INX             ; advance to next byte
        CPX #$04        ; loop through 4 bytes
        BNE b243C
        LDA #$03        ; descriptor for pointer size (3 = 2-byte address + alignment)
        JSR s21D0       ; emit size descriptor
        LDA #$00        ; terminator descriptor
        JSR s21D0       ; emit terminator
        RTS             ; return to expression evaluator

;--------------------------------------------------
; Routine j2452/b245C (lines 600–620): Prefix-Operator Handling
;--------------------------------------------------

j2452   JSR s692A        ; skip whitespace & fetch next token into A (sets carry on unexpected characters)
        BCC b245C        ; if no carry (valid prefix), proceed to emit

        ; unsupported prefix operator encountered
        LDA #$05         ; load error code for illegal operator
        STA a9E          ; record error in error state
        RTS              ; return to caller

b245C   INC a18          ; increment expression nesting depth
        LDA #$0E         ; load token code for recognized prefix operator
        JSR s21D3        ; emit prefix-operator descriptor into name stream

        LDX #$00         ; reset index X for operand bytes in temp buffer
b2465   LDA a8678,X      ; fetch next byte of prefix operand
        JSR s21D3        ; emit operand descriptor byte
        INX              ; advance operand index
        CPX #$05         ; compare to total operand length (5 bytes)
        BNE b2465        ; loop until all operand bytes emitted

        LDA #$05         ; load end-of-expression descriptor code
        JSR s21D0        ; finalize expression descriptor
        LDA #$00         ; load terminator (zero)
        JSR s21D0        ; emit terminator descriptor
        RTS              ; return from prefix-handler

;--------------------------------------------------
; Routine j247B ($247B) - Identifier or Constant Handler
;--------------------------------------------------
j247B   JSR s692A        ; lookup symbol: normalize case and search symbol table
        BCC b2485        ; if carry clear (symbol found), branch to emit
        LDA #$01         ; else set error flag for undefined identifier
        STA a9E          ; store undefined-identifier indicator in zero-page
        RTS              ; return to caller, abort expression parsing

;--------------------------------------------------
; Continuation at b2485 ($2485) - Emit Identifier or Constant
;--------------------------------------------------
b2485   JSR s58B3        ; skip whitespace and fetch next token (sets carry for operators)
        BCC b2490        ; if no operator follows, branch to emit name descriptor
        JSR s24ED        ; otherwise emit current symbol/token into output stream
        JMP j5649        ; jump to expression finalizer/cleanup

;--------------------------------------------------
; Routine b2490 ($2490) - Identifier Token Emitter
;--------------------------------------------------

b2490   INC a18         ; increment expression nesting depth counter
        LDA #$0F        ; load name-length token code (0x0F) into A
        JSR s21D3       ; push name-length descriptor to name stream
        LDX #$00        ; clear X to start reading identifier characters

b2499   LDA a8678,X     ; load next byte of identifier from name buffer a8678
        JSR s21D3       ; emit character as name descriptor
        INX             ; advance to next character index
        CMP #$00        ; check for null-terminator (end of string)
        BNE b2499       ; repeat until terminator encountered

        LDA #$01        ; load token type for identifier into A
        JSR s21D0       ; emit identifier token to output stream
        LDA #$09        ; load code for end-of-identifier marker
        JSR s21D0       ; emit end marker
        LDA #$00        ; load zero terminator
        JSR s21D0       ; emit final terminator byte
        RTS             ; return from identifier emitter

; Initialize pointer to token-dispatch table
s24B4   LDA #<p7E4D    ; load low byte of address of p7E4D (token dispatch table)
        STA a1E         ; store low byte into a1E (dispatch table pointer low)
        LDA #>p7E4D    ; load high byte of address of p7E4D
        STA a1F         ; store high byte into a1F (dispatch table pointer high)
        RTS             ; return from subroutine

; Write two-byte header for name-descriptor emitter and advance table pointer
j24BD   STY a24EB      ; save current Y index in a24EB for later restoration
        LDY #$00       ; reset Y index to 0
        STA (p1E),Y    ; store Y (0) into memory pointed by p1E/p1F (writes header byte)
        INC a1E        ; increment dispatch table pointer low byte
        BNE b24CA      ; if did not wrap, skip high-byte increment
        INC a1F        ; on wrap from $FF→$00, increment high byte of dispatch table pointer
b24CA   LDY a24EB      ; restore original Y index from a24EB
        RTS            ; return from header-write routine

; Routine s24CE ($24CE) - Pop next dispatch table address and fetch byte
s24CE   STX a24EB       ; Save original X (low index) into temporary a24EB
        STY a24EC       ; Save original Y (high index) into temporary a24EC
        LDY a1F         ; Load current pointer high-byte from a1F
        LDX a1E         ; Load current pointer low-byte from a1E
        BNE b24DB       ; If low-byte != 0, skip wrap handling
        DEY             ; If low-byte = 0, decrement high-byte to handle borrow
b24DB   DEX             ; Decrement low-byte of pointer
        STX a1E         ; Store updated low-byte back to a1E
        STY a1F         ; Store updated high-byte back to a1F
        LDY #$00        ; Index Y = 0 for table fetch
        LDA (p1E),Y     ; Fetch byte from dispatch table via pointer at p1E
        LDX a24EB       ; Restore original X from temporary a24EB
        LDY a24EC       ; Restore original Y from temporary a24EC
        RTS             ; Return with A = fetched dispatch byte

a24EB   .BYTE $00
a24EC   .BYTE $00

;--------------------------------------------------
; Routine s24ED ($24ED) - Write two-byte value into dispatch table and advance pointer
;--------------------------------------------------
; Inputs:
;   A contains low byte of value to emit (was Y before transfer)
;   X contains high byte of value to emit
;   (p1E) points to the current write location in the output buffer
; Outputs:
;   Writes low byte at (p1E), high byte at (p1E+1)
;   Advances the zero-page pointer a1E:a1F by 2

s24ED   TYA              ; transfer Y (low index/offset) into A to emit low byte
        LDY #$00         ; reset Y for first store
        STA (p1E),Y      ; store low byte at *p1E
        TXA              ; transfer X (high index/offset) into A
        INY              ; set Y=1 for second store
        STA (p1E),Y      ; store high byte at *p1E+1
        CLC              ; clear carry for pointer adjustment
        LDA a1E          ; load low byte of buffer pointer
        ADC #$02         ; add 2 (two bytes emitted)
        STA a1E          ; save updated low byte
        BCC b2501        ; if no carry, skip high-byte increment
        INC a1F          ; on carry, increment high byte of buffer pointer
b2501   RTS              ; return to caller

;--------------------------------------------------
; Routine s2502 ($2502) - Back up pointer by two and fetch 16-bit value
;   Inputs: a1E (low), a1F (high) = current pointer into buffer
;   Outputs: X = high byte, Y = low byte of word at new pointer
;   Clobbers: C flag, A, X, Y
;--------------------------------------------------
s2502   SEC             ; set carry for subtraction
        LDA a1E          ; load low byte of pointer
        SBC #$02         ; subtract 2 (pointer -= 2)
        STA a1E          ; store updated low byte
        BCS b250D        ; if carry set (no borrow), skip high-byte decrement
        DEC a1F          ; borrow: decrement high byte of pointer
b250D   LDY #$01         ; index = 1 -> point to high byte of word
        LDA (p1E),Y      ; load high byte from memory at pointer+1
        TAX              ; transfer high byte into X
        DEY              ; index = 0 -> point to low byte of word
        LDA (p1E),Y      ; load low byte from memory at pointer
        TAY              ; transfer low byte into Y
        RTS              ; return (X: high, Y: low)

; Routine b251D ($251D) - Copy 10 Bytes Backward and Advance Pointer

        STX a2B        ; save X into low byte of destination pointer
        STY a2C        ; save Y into high byte of destination pointer
        LDY #$09       ; start index at 9 (will copy bytes 9 down to 0)
b251D   LDA (p2B),Y    ; load byte from source buffer at offset Y
        STA (p1E),Y    ; store byte into destination buffer at same offset
        DEY            ; decrement index
        BPL b251D      ; if Y >= 0, repeat copy for next lower offset
        CLC            ; clear carry for pointer increment
        LDA a1E        ; load low byte of current output pointer
        ADC #$0A       ; add 10 to skip past the just-written bytes
        STA a1E        ; store updated low byte
        BCC b252F      ; if no carry, high byte unchanged
        INC a1F        ; else increment high byte of output pointer
b252F   RTS            ; return to caller

; Routine: subtract 10 from 16-bit pointer at a1F:a1E and return in X:Y
;--------------------------------------------------
        SEC             ; set carry for subtraction to 1 (enables borrow)
        LDA a1E         ; load pointer low-byte into A
        SBC #$0A        ; subtract 10 from low-byte
        STA a1E         ; store adjusted low-byte back
        BCS b253B       ; if carry set, no borrow occurred—skip decrement of high-byte
        DEC a1F         ; borrow occurred, so decrement high-byte to complete 16-bit subtraction
b253B   LDX a1E         ; load result low-byte into X for return
        LDY a1F         ; load result high-byte into Y for return
        RTS             ; return to caller with pointer in X:Y

;--------------------------------------------------
; Routine s2540 ($2540) - 32-bit Shift-Accumulate Loop
;--------------------------------------------------
s2540   LDA #$00        ; clear low part of accumulator (a26D0)
        STA a26D0       ; store 0 into a26D0
        STA a26D1       ; store 0 into a26D1 (high byte)
        STA a26D4       ; clear loop counter or flag
        JSR s2502       ; bump pointer down by 2 bytes (reverse copy)
        TYA             ; get signed high bit of pointer offset
        BPL b255F       ; if positive, skip two's-complement adjust
        EOR #$FF        ; take one's complement of A
        TAY             ; restore complemented value into Y
        TXA             ; move X into A
        EOR #$FF        ; one's complement of X
        TAX             ; restore into X
        INX             ; increment X (two's-complement adjust)
        BNE b255C       ; if not wrapped, skip increment Y
        INY             ; increment Y when X wrapped
b255C   INC a26D4       ; increment inner loop count
b255F   STX a26CC       ; store computed X into a26CC (low part of divisor)
        STY a26CD       ; store computed Y into a26CD (high part of divisor)
        JSR s2502       ; adjust pointer again
        TYA             ; test signed Y
        BPL b2579       ; if positive, skip two's-complement adjust
        EOR #$FF        ; complement Y
        TAY             ; restore complemented Y
        TXA             ; move X into A
        EOR #$FF        ; complement A
        TAX             ; restore complemented X
        INX             ; increment X
        BNE b2576       ; if not wrapped, skip increment Y
        INY             ; increment Y when X wrapped
b2576   INC a26D4       ; increment loop counter again
b2579   STX a26CE       ; store X into a26CE (shift amount low)
        STY a26CF       ; store Y into a26CF (shift amount high)
        LDX #$10        ; set bit-iteration count (16)
b2581   LDA a26CE       ; test LSB of shift count
        AND #$01        ; isolate bit 0
        BEQ b259B       ; if bit clear, skip addition step
        CLC             ; clear carry for add
        LDA a26D0       ; load low accumulator
        ADC a26CC       ; add divisor low
        STA a26D0       ; store result back
        LDA a26D1       ; load high accumulator
        ADC a26CD       ; add divisor high + carry
        STA a26D1       ; store result back
b259B   LSR a26D1       ; shift accumulator right: high byte
        ROR a26D0       ; rotate low byte through carry
        ROR a26CF       ; rotate shift-count high
        ROR a26CE       ; rotate shift-count low
        DEX             ; decrement iteration count
        BNE b2581       ; loop until all bits processed
        LDX a26CE       ; reload shift-count low
        LDY a26CF       ; reload shift-count high
        LDA a26D4       ; load final loop counter
        LSR             ; divide counter by 2 (logical)
        BCC b25C2       ; if no borrow, proceed
        TYA             ; prepare Y complement
        EOR #$FF        ; one's complement
        TAY             ; back into Y
        TXA             ; prepare X complement
        EOR #$FF        ; one's complement
        TAX             ; back into X
        INX             ; adjust X
        BNE b25C2       ; if no wrap, skip Y
        INY             ; adjust Y
b25C2   JMP s24ED       ; return to pointer copy routine

;--------------------------------------------------
; Routine s25C5 ($25C5) - Rotate-Right-Word
;--------------------------------------------------
s25C5   JSR s25FF       ; zero and adjust counters
        LDX a26D2       ; load low part of offset
        LDY a26D3       ; load high part of offset
        ROR a26D4       ; rotate carry into counter
        BCC b25DF       ; if no borrow, skip complement adjust
        TXA             ; prepare X complement
        EOR #$FF        ; one's complement
        TAX             ; restore X
        TYA             ; prepare Y complement
        EOR #$FF        ; one's complement
        TAY             ; restore Y
        INX             ; increment X
        BNE b25DF       ; if no wrap, skip Y
        INY             ; increment Y
b25DF   JMP s24ED       ; loop until pointer copy completes

;--------------------------------------------------
; Routine j25E2 ($25E2) - Rotate-Right-Double-Word
;--------------------------------------------------
j25E2   JSR s25FF       ; clear counters and flags
        LDX a26CE       ; load 16-bit shift count low
        LDY a26CF       ; load 16-bit shift count high
        ROR a26D6       ; rotate highest accumulator byte
        BCC b25FC       ; if no borrow, skip complement adjust
        TXA
        EOR #$FF
        TAX
        TYA
        EOR #$FF
        TAY
        INX             ; adjust X
        BNE b25FC       ; if no wrap, skip Y
        INY             ; adjust Y
b25FC   JMP s24ED      ; return to copy routine

;--------------------------------------------------
; Routine s25FF ($25FF) - Clear Accumulators & Setup
;--------------------------------------------------
s25FF   LDA #$00       ; clear all 4 accumulator bytes and counters
        STA a26D4
        STA a26D5
        STA a26D6
        STA a26D2
        STA a26D3
        JSR s2502      ; adjust pointer back by 2
        TYA
        BPL b2627      ; if Y>=0, skip
        INC a26D5      ; increment mid counters on wrap
        INC a26D4
        EOR #$FF       ; complement Y
        TAY
        TXA
        EOR #$FF
        TAX
        INX
        BNE b2627
        INY
b2627   STX a26CC     ; store new divisor low
        STY a26CD     ; store new divisor high
        JSR s2502     ; adjust pointer again
        TYA
        BPL b2644
        INC a26D6
        INC a26D4
        EOR #$FF
        TAY
        TXA
        EOR #$FF
        TAX
        INX
        BNE b2644
        INY
b2644   STX a26CE     ; store shift-count low
        STY a26CF     ; store shift-count high
        LDX #$01      ; start one-bit rotation
j264C   LDA a26CD     ; test bit 6 of high count
        AND #$40
        BNE b265D     ; if set, go to subtract-path
        ASL a26CC     ; else shift divisor left
        ROL a26CD
        INX           ; increment X for next test
        JMP j264C

b265D   ASL a26D2     ; start shifting accumulator left
        ROL a26D3
        SEC           ; prepare for subtraction
        LDA a26CE     ; load shift-count low
        SBC a26CC     ; subtract divisor low
        TAY           ; store borrow flag in Y
        LDA a26CF     ; load shift-count high
        SBC a26CD     ; subtract divisor high + carry
        BCC b267C     ; if no borrow after subtract, skip restore
        STY a26CE     ; restore shift-count from Y
        STA a26CF
        INC a26D2     ; correct accumulator on borrow
b267C   LSR a26CD     ; finish rotation: shift-count high right
        ROR a26CC     ; rotate divisor low
        DEX           ; decrement loop count
        BNE b265D     ; repeat until all bits done
        RTS           ; return to caller

        ;--------------------------------------------------
        ; j2686 ($2686) - 16‑bit Value Accumulator
        ;--------------------------------------------------
j2686   JSR s2502        ; backup pointer by 2, load bytes at (p1E): X=high1, Y=low1
        STX a26CC         ; save high1 into a26CC
        STY a26CD         ; save low1 into a26CD
        JSR s2502        ; backup pointer by 2 again, load next bytes: X=high2, Y=low2
        CLC               ; clear carry for 16‑bit addition
        TXA               ; transfer high2 into A
        ADC a26CC         ; add saved high1 (with carry=0) → high_sum
        TAX               ; store high_sum back into X
        TYA               ; transfer low2 into A
        ADC a26CD         ; add saved low1 + carry → low_sum + adjust high if overflow
        TAY               ; store low_sum back into Y
        JMP s24ED         ; jump to byte‑write routine (writes Y then X) and advance pointer

j26A0   JSR s2502        ; backup pointer into X (low) and Y (high)
        STX a26CC        ; save low byte of backed-up pointer
        STY a26CD        ; save high byte of backed-up pointer
        JSR s2502        ; backup pointer again (new value for subtraction)
        SEC              ; prepare for subtraction (set carry)
        TXA              ; move low byte into A
        SBC a26CC        ; subtract saved low byte (compute low difference)
        TAX              ; store low result in X
        TYA              ; move high byte into A
        SBC a26CD        ; subtract saved high byte with borrow (compute high difference)
        TAY              ; store high result in Y
        JMP s24ED        ; emit 16-bit difference via output helper

j26BA   JSR s2502         ; Pop 16-bit value from pointer stack: loads low byte into X, high byte into Y
        TXA               ; Transfer low byte (X) into A
        EOR #$FF          ; Invert all bits of low byte (one's complement)
        TAX               ; Store inverted low byte back into X
        TYA               ; Transfer high byte (Y) into A
        EOR #$FF          ; Invert all bits of high byte
        TAY               ; Store inverted high byte back into Y
        INX               ; Add 1 to low byte (complete two's-complement negation)
        BNE b26C9         ; If no overflow, skip high-byte carry
        INY               ; Else, add carry to high byte
b26C9   JMP s24ED         ; Emit negated 16-bit value back into output buffer and advance pointer

; workspace for multi-precision operations and scanning routines
; Used by s2540–j26BA and related routines for arithmetic, shifting, and buffer management

; Result and operand registers
 a26CC   .BYTE $00    ; Low byte of arithmetic result or shifting accumulator
 a26CD   .BYTE $00    ; High byte of arithmetic result or carry flag holder
 a26CE   .BYTE $00    ; Original low operand or input register for multi-byte ops
 a26CF   .BYTE $00    ; Original high operand or input register for multi-byte ops

; Intermediate registers for bitwise and rotate loops
 a26D0   .BYTE $00    ; Low intermediate for rotate/shift
 a26D1   .BYTE $00    ; High intermediate for rotate/shift
 a26D2   .BYTE $00    ; Low operand for rotate/shift source
 a26D3   .BYTE $00    ; High operand for rotate/shift source

; Loop counters and indices
 a26D4   .BYTE $00    ; Primary loop counter or bit index
 a26D5   .BYTE $00    ; Auxiliary loop counter
 a26D6   .BYTE $00    ; Secondary auxiliary counter
 a26D7   .BYTE $00    ; Saved X index for multi-byte routines
 a26D8   .BYTE $00    ; Saved Y index for multi-byte routines

; Descriptor and token-state bytes
 a26D9   .BYTE $00    ; Current name/token length or descriptor index
 a26DA   .BYTE $00    ; Token scan flag or class code

; Temporary storage for multi-byte carry propagation
 a26DB   .BYTE $00    ; Temp low byte for carry propagation
 a26DC   .BYTE $00    ; Temp high byte for carry propagation

; Pointers and offsets for buffer pointers
 a26DD   .BYTE $00    ; Offset low for buffer pointer operations
 a26DE   .BYTE $00    ; Offset high for buffer pointer operations

; Decimal digit adjustment bytes
 a26DF   .BYTE $00    ; Low decimal adjustment value
 a26E0   .BYTE $00    ; High decimal adjustment value
 a26E1   .BYTE $00    ; Unused/reserved or further adjust byte

; Scan-state and pointer registers
 a26E2   .BYTE $00    ; Input scan counter or token state
 a26E3   .BYTE $00    ; Buffer pointer low byte
 a26E4   .BYTE $00    ; Buffer pointer high byte
 a26E5   .BYTE $00    ; Secondary buffer pointer low byte
 a26E6   .BYTE $00    ; Secondary buffer pointer high byte

;--------------------------------------------------
; Routine s26E7 ($26E7) - Scanner/Parser Initialization
;--------------------------------------------------
s26E7   LDA #$00        ; Load 0 into A
        STA a2D         ;   Clear scanner dispatch low-byte pointer
        STA a37         ;   Clear nesting-level counter/register
        LDY #$7B        ; Load Y with high byte of dispatch table base ($7B)
        LDX #$CD        ; Load X with low byte of dispatch table base ($CD)
        BNE b26F4       ; Always taken (X != 0) to skip the next DEY
        DEY             ; (never executed) would decrement Y if branch not taken
b26F4   DEX             ; Decrement X to adjust start pointer (now $CC)
        STX a34         ; Store adjusted low byte into pointer a34
        STY a35         ; Store high byte into pointer a35
        RTS             ; Return to caller

;--------------------------------------------------
; Routine s26FA ($26FA) - Initial Directive Processing Loop
; Entry: Called once at startup to process compiler directives (#INCLUDE, #DEFINE, etc.)
;--------------------------------------------------
s26FA   JSR s2753        ; fetch next character into A (handles buffering & normalization)
        JSR s2767        ; compute pointer into classification/jump table based on A

j2700   JSR s2753        ; fetch next character (loop head)
        JSR s278E        ; load classification code from directive table
        BCC b270F        ; if carry clear (normal directive char), branch to handle
        LDX #$40         ; otherwise, prepare default scan state for non-directive
        LDY #$27         ; (X,Y hold return vector for j20F8)
        JMP j20F8        ; return to main scanner loop (exit directive mode)

b270F   CMP #$01         ; check for directive-start marker (e.g. '#')
        BNE b2719        ; if not '#', skip to next classification
        JSR s2767        ; re-map '#' into table pointer
        JMP j273C        ; jump around directive-body handlers

b2719   JSR s2764        ; increment nested-directive counter (enter directive body)
        JSR s280E        ; prepare directive argument parsing (set up pointers)
        BCC b2728        ; if no error, continue processing body
        LDX #$40         ; on error, reset scan state
        LDY #$27
        JMP j20F8        ; exit to main loop

b2728   LDA a34         ; load accumulated directive code index
        CMP #$CD         ; compare against end-of-directive sentinel
        BNE j273C        ; if not end, loop back to parse next char
        LDA a35         ; confirm high byte of sentinel
        CMP #$7B         ; ensure sentinel matched fully
        BNE j273C        ; otherwise continue parsing
        LDY #$00         ; complete directive: reset index
        LDA (p34),Y     ; fetch first byte of directive payload
        CMP #$54         ; compare to 'T' (example token)
        BEQ b273F        ; branch if matched specific directive
j273C   JMP j2700        ; loop back to j2700 for next character

b273F   RTS              ; return after directive handled, back to main scanner

; Syntax-Error Directive Handlers
;--------------------------------
; Define the syntax-error message string (zero-terminated)

.TEXT " *** SYNTAX ERROR", $0D, $00   ; Message printed on syntax error

;--------------------------------------------------
; Routine s2753 ($2753) - Syntax-Error Entry
;--------------------------------------------------
s2753   LDA a37           ; Load nesting counter (a37)
        BNE b275F         ; If non-zero, skip initial setup
        JSR s3587         ; Save parser state (f3E/f3F) for error context
        STA a36           ; Store current token/char in a36
        JMP j2763         ; Jump to return

b275F   LDA a36           ; Load saved token/char into A
        DEC a37           ; Decrement nesting counter, entering error state
j2763   RTS               ; Return from error-entry setup

; Routine s2764 ($2764) - Increment Directive Nesting Counter
s2764   INC a37          ; a37 holds nesting counter for conditional directives (#IF depth)
        RTS              ; return

; Routine s2767 ($2767) - Advance Parse Dispatch Pointer and Compute Jump Table Offset
s2767   INC a34          ; increment low byte of current dispatch pointer
        BNE b276D        ; if no wrap, skip high-byte increment
        INC a35          ; on wrap, increment high byte of dispatch pointer
b276D   LDA a36          ; load current token code (index into jump-table base)
        LDY #$00
        STA (p34),Y      ; write low byte of jump-target vector at *p34
        LDA a36          ; reload token code
        SEC              ; prepare for subtract
        SBC #$01         ; subtract 1 to make zero-based index
        STA a278C        ; store in temp low-byte (a278C)
        ASL              ; a278C <<= 1
        ADC a278C        ; a278C = temp*2 + original = temp*3 (entry_size)
        ADC #$BC         ; add base low-byte of jump-table address ($BC)
        STA a278C        ; final low-byte of target address
        LDA #$00
        ADC #$46         ; compute high-byte: base high + carry
        STA a278D        ; store in temp high-byte (a278D)

        .BYTE $4C        ; JMP opcode ('JMP' low in data)
a278C   .BYTE $FF
a278D   .BYTE $FF

; Label s278E ($278E) - Dispatch to Next Parse Routine from Jump Table
s278E   LDY #$00         ; start index into jump-table word (2-byte entries)
        LDA (p34),Y      ; fetch low-byte of dispatch pointer
        STA a31          ; save in a31
        DEC a31          ; adjust offset index (entry size = 2 bytes)
        LDX a36          ; reload token code
        DEX              ; index = token_code - 1
        LDY #$7E         ; high-byte of script area (fixed)
        JSR s27E4        ; compute vector table page/offset in a2B:a2C
        CLC              ; clear carry for addition
        TXA              ; transfer index (token_code-1)
        ADC a31          ; add offset within table entry
        BCC b27A5        ; if no carry into Y, skip adjust
        INY              ; else increment high-byte page
b27A5   PHA              ; save accumulator
        AND #$03         ; mask to get byte-count (low 2 bits)
        STA a31          ; store length in a31
        LDA #$03         ; full entry size in low
        SEC              ; subtract length
        SBC a31          ; compute remaining bytes to skip
        STA a27E3        ; save in a27E3
        PLA              ; restore accumulator
        STY a31          ; restore Y (high-byte of page)
        LSR a31          ; divide length by 2 twice to get shift count
        ROR              ; adjust for word alignment
        LSR a31
        ROR              ; residual
        CLC              ; clear carry for addition
        ADC #$85         ; add low-byte of vector base ($85)
        STA a2B          ; set dispatch pointer low-byte
        LDA a31          ; get high-byte of pointer
        ADC #$3C         ; add high-byte offset ($3C)
        STA a2C          ; set dispatch pointer high-byte

        LDY #$00         ; prepare to read next char
        LDA (p2B),Y      ; peek next input character (token following)
        LDX a27E3        ; number of prefix bytes to skip
        BEQ b27D4        ; if none, skip strip loop
b27CF   LSR              ; strip first half of table data
        LSR              ; strip second half
        DEX              ; decrement count
        BNE b27CF        ; repeat for each extra byte
b27D4   AND #$03         ; mask page offset to correct alignment
        BNE b27DA        ; if extra adjust needed, skip return
        SEC              ; no extra => set carry so return via JMP ($...) uses a2B:a2C
        RTS              ; return via indirect table jump

    ;--------------------------------------------------
    ; b27DA: decide if we handle a 3-byte dispatch or return
b27DA   CMP #$03        ; compare parsed-byte count (in A) to 3
        BEQ b27E0       ; if equal, go to extended-length handler
        CLC             ; otherwise clear carry (set 'no special case')
        RTS             ; return to caller

b27E0   JMP j7995       ; jump into dispatch table for 3-byte sequence

    ; temporary storage for computed offset

a27E3   .BYTE $00      ; holds carry-accumulated bits count

    ;--------------------------------------------------
    ; s27E4: compute a rotated-offset for dispatch using bit-rotation algorithm
s27E4   STX a280B       ; save low-byte of rotation word
        STY a280C       ; save high-byte of rotation word
        LDA #$00
        STA a280D       ; clear rotation-bit accumulator
        LDX #$08       ; loop for 8 bits (one byte width)

b27F1   ASL             ; shift high-byte left, MSB -> carry
        ROL a280D       ; rotate carry into LSB of accumulator
        ASL a280B       ; shift low-byte left, carry->high byte
        BCC b2803       ; if no carry from low-byte, skip overflow handling
        CLC             ; clear carry for ADC operation
        ADC a280C       ; add carry overflow back into high-byte
        BCC b2803       ; if still no overflow, skip bit-count increment
        INC a280D       ; count an extra bit for overflow

b2803   DEX             ; decrement bit counter
        BNE b27F1       ; loop until all bits processed

        TAX             ; use X = low-byte of computed offset
        LDY a280D       ; use Y = bit-count (rotation depth)
        RTS             ; return, with X:Y = rotated index

; Data scratch bytes for shift routine

a280B	.BYTE $00	; scratch high-order accumulator (initially 0)
a280C	.BYTE $00	; scratch mid-order accumulator (initially 0)
a280D	.BYTE $00	; scratch low-order accumulator (initially 0)

;--------------------------------------------------
; Routine s280E ($280E) – Rotate/Multi-Precision Shift Setup
;--------------------------------------------------
s280E:
    LDA #$00       ; clear accumulator A
    LDY #$01       ; set index Y=1 for second byte operations
    STA (p34),Y    ; store 0 into buffer at address pointed by p34+Y
    LDA #$06       ; load shift count (6 bits) into A
    STA a31        ; save shift count into a31
    DEC a31        ; decrement to prepare loop (will execute 6 times)

j281A:
    SEC            ; set carry for subtraction
    LDA a34        ; load low-byte of the value to shift
    SBC a31        ; subtract loop counter from low-byte
    STA a2B        ; store result as low byte of pointer (p2B)
    LDX a35        ; load high-byte of the value into X
    BCS b2826      ; if no borrow from subtraction, skip X decrement
    DEX            ; adjust high byte when borrow occurred

b2826:
    STX a2C        ; store X as high byte of pointer (p2C)
    CPX #$7B       ; compare high byte against buffer limit ($7B)
    BCS b2831      ; if pointer >= end, branch to end of loop
    DEC a31        ; decrement shift-count counter
    JMP j281A      ; repeat subtraction/store until counter reaches zero

;--------------------------------------------------
; Section b2831–b2849: Case-Label Range Loop and Dispatch
;--------------------------------------------------

b2831   BNE b283E        ; if X (after CPX #$7B) != '{' ($7B), branch to dispatch handler
        LDA a2B          ; load low byte of computed pointer into A
        CMP #$CD         ; compare pointer low byte to end-marker ($CD)
        BCS b283E        ; if pointer >= end-marker, branch to dispatch
        DEC a31          ; decrement remaining count (a31)
        JMP j281A        ; repeat loop at j281A for next element

b283E   JSR s28A6        ; call routine to load/update range table pointers
        BCS b2849        ; if carry set (successful range match), skip decrement
        DEC a31          ; on range lookup failure, decrement remaining count
        BPL j281A        ; if remaining count >= 0, loop back to j281A
        SEC              ; set carry to signal loop termination
        RTS              ; return (carry indicates no more ranges)

;---- Section b2849–b2865: Restore pointer, scan dispatch table, and handle extended cases ----

b2849   LDA a2B       ; Load low byte of computed dispatch pointer into A
        STA a34       ; Restore pointer low byte to a34 for next lookup
        LDA a2C       ; Load high byte of computed dispatch pointer into A
        STA a35       ; Restore pointer high byte to a35
        LDY #$00      ; Reset index Y = 0 to start table scan

j2853   LDA (p32),Y   ; Fetch byte from dispatch table via pointer p32+Y
        BEQ b285B     ; If byte == 0, end of table—branch to C0 check
        INY           ; Otherwise, increment Y to advance through table
        JMP j2853     ; Repeat scan until end-of-table marker

b285B   INY           ; Skip past the zero terminator to first actual entry
        LDA (p32),Y   ; Fetch the dispatch code at current index
        CMP #$C0      ; Compare against 0xC0 threshold (extended-case marker)
        BCC b2865     ; If below 0xC0, branch to normal-case handler at b2865
        JMP j51CC     ; Else jump to j51CC for extended-case dispatch

b2865   LDY #$00          ; start with index 0 for address pointer adjustment
        STA (p34),Y     ; write 0 at buffer pointer (zero out first byte)
        SEC             ; set carry for subtraction
        LDA a38         ; load high byte of original address
        SBC #$24        ; subtract low page offset (0x24)
        STA a2B         ; store adjusted low byte to pointer p2B
        LDA a39         ; load low byte of original address
        SBC #$2C        ; subtract high page offset (0x2C)
        STA a2C         ; store adjusted high byte to pointer p2C
        LSR             ; shift carry into A, dividing previous high-byte result by 2
        STA a31         ; store result in a31 (used for carry propagate)
        LDA a2B         ; reload low byte of adjusted pointer
        ROR             ; rotate right through carry to incorporate bit0 of a31
        CLC             ; clear carry for addition
        ADC a2B         ; add original low pointer
        STA a2B         ; update low pointer
        LDA a2C         ; reload high pointer
        ADC a31         ; add bit carried from low byte
        STA a2C         ; update high pointer
        CLC             ; clear carry for next addition
        LDA a2B         ; reload adjusted low pointer
        ADC #$78        ; add page offset 0x78 to wrap back into table region
        STA a2B         ; update low pointer
        LDA a2C         ; reload adjusted high pointer
        ADC #$2D        ; add high offset 0x2D for table base hi-byte
        STA a2C         ; update high pointer
        LDY #$01        ; set index to 1 for fetching data bytes
        LDA (p2B),Y     ; fetch first byte from data table at pointer+1
        STA a28A2       ; store into temporary storage a28A2
        INY             ; increment index
        LDA (p2B),Y     ; fetch second byte from table
        STA a28A3       ; store into a28A3
                     
        .BYTE $20       ; literal byte 0x20 inserted here (separator or terminator)
 a28A2  .BYTE $FF       ; default fill value for table start
 a28A3  .BYTE $FF,$18,$60  ; default bytes, followed by reserved data
       
 s28A6   LDA #<p2C24     ; load low byte of lookup-table address p2C24
         STA a2936       ; store into a2936 (low)
         LDA #>p2C24     ; load high byte of p2C24
         STA a2937       ; store into a2937 (high)
         LDA #<p2D76     ; load low byte of secondary table p2D76
         STA a2938       ; store into a2938
         LDA #>p2D76     ; load high byte of secondary table
         STA a2939       ; store into a2939
 j28BA   LDA a2939       ; load high pointer of secondary table
         CMP a2937       ; compare to high pointer of primary table
         BCS b28C3       ; if above or equal, branch to table rollover handler
         RTS             ; else return to caller

;--------------------------------------------------
; Section: Compute new pointer based on table offsets and ensure alignment
;--------------------------------------------------
b28C3   BNE b28CE        ; if HIGH_OFFSET != HIGH_BOUND, skip bounds check
        LDA a2938        ; load current offset low-byte (index into table)
        CMP a2936        ; compare with table start low-byte
        BCS b28CE        ; if offset >= table start, skip exit
        RTS              ; out-of-bounds: return immediately

b28CE   CLC              ; begin 16-bit addition of table pointers
        LDA a2936        ; load table start low-byte
        ADC a2938        ; add current offset low-byte
        STA a38          ; store updated pointer low-byte
        LDA a2937        ; load table start high-byte
        ADC a2939        ; add current offset high-byte and carry
        LSR              ; divide result by 2 to adjust format
        ROR a38          ; rotate carry into pointer low-byte
        STA a39          ; store updated pointer high-byte
        LDA #$24         ; load alignment mask constant
        AND #$01         ; test LSB of mask
        BNE b28F1        ; if mask bit set, skip alignment fix
        LDA a38          ; otherwise, clear LSB for even alignment
        AND #$FE         ; clear lowest bit
        STA a38          ; update pointer low-byte
        JMP j28F7        ; return to main scanner loop

b28F1   LDA a38        ; load address high byte into A (current pointer page)
        ORA #$01       ; set bit0 to ensure odd alignment when needed
        STA a38        ; store adjusted high byte back to a38 for alignment
j28F7   LDY #$00       ; initialize Y index to 0 for pointer dereference
        LDA (p38),Y    ; fetch low byte of target pointer from address p38
        CLC            ; clear carry for addition
        ADC #$3A       ; add low-byte offset (0x3A) to pointer low
        STA a32        ; store resulting low byte into a32 (dispatch table low)
        INY            ; increment Y to fetch high byte
        LDA (p38),Y    ; fetch high byte of target pointer
        ADC #$29       ; add high-byte offset (0x29) plus any carry
        STA a33        ; store resulting high byte into a33 (dispatch table high)
        LDX #$FF       ; set X = -1 to start reverse search through buffer
        JSR s3A84      ; call scanner helper to compare buffer at p2B and p32
        BNE b2910      ; if not matched (Zero flag clear), branch to b2910
        SEC            ; on match, set Carry for return status = success
        RTS            ; return to caller

;--------------------------------------------------
; Section b2910–j2933: Adjust lookup pointer and loop back
;--------------------------------------------------

b2910   BCS b2924        ; if previous compare set carry (>=), use forward adjustment
        SEC               ; clear carry for subtraction sequence
        LDA a38           ; load Y-offset high byte of current pointer
        SBC #$02          ; subtract 2 to move lookup window backward
        STA a2938         ; store adjusted high byte
        LDA a39           ; load Y-offset low byte
        SBC #$00          ; subtract 0 (no change), maintain low byte
        STA a2939         ; store adjusted low byte
        JMP j2933         ; jump to common loop continuation

b2924   CLC               ; clear carry for addition sequence
        LDA a38           ; load Y-offset high byte
        ADC #$02          ; add 2 to move lookup window forward
        STA a2936         ; store adjusted high byte
        LDA a39           ; load low byte
        ADC #$00          ; add 0 (no change to low)
        STA a2937         ; store adjusted low byte

j2933   JMP j28BA         ; re-enter lookup loop at b28BA

; ----------------------------------------------------------------------------
; Offset Tables and Dispatch Vector for Tokens $00–$7F (0–127)
; ----------------------------------------------------------------------------

; --- Offset Tables (a2936–a2938) ---
a2936   .BYTE $00        ; Table X low-byte
a2937   .BYTE $00        ; Table Y low-byte
a2938   .BYTE $00        ; Flags / count low-byte


; --- Lookup Entries (a2939) ---
; Each entry provides X,Y offsets for token lengths 0–3
; Defines 64 entries for tokens $00–$3F before dispatch vector

a2939   .BYTE $00,$01,$02,$00,$60,$01,$74,$02  ; entries 0–3  
        .BYTE $00,$60,$05,$7D,$00,$7D,$09,$7D  ; entries 4–7
        .BYTE $00,$7D,$0C,$0D,$00,$FF,$0C,$58  ; entries 8–11
        .BYTE $0D,$00,$57,$0C,$5A,$0D,$00,$7E  ; entries 12–15
        .BYTE $0C,$5A,$60,$0D,$00,$7E,$0C,$5F  ; entries 16–19
        .BYTE $0D,$00,$5F,$0C,$60,$0D,$00,$60  ; entries 20–23
        .BYTE $0C,$70,$0D,$00,$7D,$0D,$00,$6C  ; entries 24–27
        .BYTE $0E,$00,$60,$0E,$5F,$00,$5F,$0E  ; entries 28–31
        .BYTE $60,$00,$60,$0E,$7D,$00,$7D,$11  ; entries 32–35
        .BYTE $7D,$00,$7D,$14,$7D,$00,$7D,$15  ; entries 36–39
        .BYTE $7D,$00,$7D,$1C,$00,$FE,$2B,$2C  ; entries 40–43
        .BYTE $00,$64,$2B,$55,$65,$2C,$00,$64  ; entries 44–47
        .BYTE $2B,$62,$13,$2C,$00,$63,$2B,$62  ; entries 48–51
        .BYTE $2C,$00,$63,$2B,$65,$2C,$00,$64  ; entries 52–55
        .BYTE $2D,$7D,$00,$7D,$2F,$00,$5B,$30  ; entries 56–59
        .BYTE $00,$5B,$31,$00,$5B,$32,$00,$5B  ; entries 60–63
        .BYTE $33,$00,$5B,$34,$00,$5C,$35,$00  ; entries 64–67
        .BYTE $5C,$35,$36,$00,$5C,$36,$00,$5C  ; entries 68–71
        .BYTE $37,$00,$5C,$37,$36,$00,$5C,$37  ; entries 72–75
        .BYTE $39,$00,$5C,$38,$00,$5C,$38,$36  ; entries 76–79
        .BYTE $00,$5C,$39,$00,$5C,$3A,$00,$5C  ; entries 80–83
        .BYTE $3B,$2B,$55,$2C,$00,$61,$3B,$4B  ; entries 84–87
        .BYTE $2B,$55,$2C,$00,$61,$3B,$4E,$00  ; entries 88–91
        .BYTE $61,$3C,$2B,$55,$2C,$00,$61,$3C  ; entries 92–95
        .BYTE $4B,$2B,$55,$2C,$00,$61,$3C,$4E  ; entries 96–99
        .BYTE $00,$61,$3D,$0C,$70,$0D,$00,$67  ; entries 100–103
        .BYTE $3D,$3D,$70,$00,$54,$3E,$0C,$70  ; entries 104–107
        .BYTE $0D,$00,$68,$40,$66,$00,$69,$41  ; entries 108–111
        .BYTE $0C,$1C,$00,$6A,$41,$0C,$70,$1C  ; entries 112–115
        .BYTE $00,$6A,$42,$0C,$70,$0D,$00,$6D  ; entries 116–119
        .BYTE $43,$74,$00,$6E,$44,$1B,$66,$00  ; entries 120–123
        .BYTE $66,$45,$1C,$00,$66,$46,$1C,$00  ; entries 124–127

       ; portion of code chatgpt failed to continue
         .BYTE $66,$47,$1C,$00,$66,$47,$70,$1C
         .BYTE $00,$66,$48
         .BYTE $4B,$00,$6F,$49,$7D,$00,$7D,$49
         .BYTE $7E,$00,$7D,$4B,$00,$7D,$4B,$1B
         .BYTE $66,$00,$66,$4B,$57,$55,$64,$00
         .BYTE $56,$4B,$57,$64,$00,$56,$4C,$00
         .BYTE $7D,$4D,$00,$5F,$4E,$00,$5C,$4F
         .BYTE $00,$7D,$50,$00,$7D,$51,$00,$7D
         .BYTE $52,$00,$7D,$53,$00,$58,$55,$00
         .BYTE $54,$55,$56,$00,$55,$55,$59,$00
         .BYTE $55,$56,$00,$55,$58,$13,$53,$00
         .BYTE $58,$59,$00,$55,$5A,$1C,$00,$59
         .BYTE $5A,$5D,$1C,$00,$59,$5A,$5D,$57
         .BYTE $55,$64,$00,$56,$5A,$5D,$57,$64
         .BYTE $00,$56,$5B
         .BYTE $00,$5A,$5B,$5C,$00,$5A,$5C,$00
         .BYTE $5A,$5D,$13,$5E,$00,$5D,$5E,$00
         .BYTE $5D,$5F,$00,$5E,$5F,$01,$02,$00
         .BYTE $5F,$5F,$01,$74,$02,$00,$5F,$5F
         .BYTE $0C,$0D,$00,$5F,$5F,$21,$2B,$62
         .BYTE $13,$2C,$00,$5E,$5F,$21,$2B,$62
         .BYTE $2C,$00,$5E,$5F,$21,$74,$00,$5E
         .BYTE $60,$01,$02
         .BYTE $00,$60,$60,$01,$74,$02,$00,$60
         .BYTE $60,$0C,$0D,$00
         .BYTE $60,$61,$00,$5C,$62,$13,$63,$00
         .BYTE $62
         .BYTE $63,$00,$62,$64,$00,$66,$65,$59
         .BYTE $00,$65,$65,$66,$00,$65,$66,$00
         .BYTE $65,$67,$66,$00,$66,$67,$66,$3F
         .BYTE $66,$00,$66
         .BYTE $68,$66,$00,$66,$69,$3E,$0C,$70
         .BYTE $0D,$1C,$00,$66,$6A,$6B,$6C,$66
         .BYTE $00,$66,$6D,$66,$00,$66,$6E,$1B
         .BYTE $66,$00,$66,$6F,$1C,$00,$66,$70
         .BYTE $0D,$00,$6C,$70,$13,$71,$00,$70
         .BYTE $70,$1C,$00,$FD,$71,$00,$70,$72
         .BYTE $00,$71,$73,$00,$72,$73,$27,$73
         .BYTE $1B,$73,$00,$72,$73,$29,$74,$00
         .BYTE $73,$74,$00,$FC,$74,$0A
         .BYTE $75,$00,$74,$75,$00,$74,$75,$28
         .BYTE $76,$00,$75,$76,$00,$75,$76,$03
         .BYTE $77,$00,$76,$77,$00,$76,$77,$09
         .BYTE $78,$00,$77,$78,$00,$77,$78,$06
         .BYTE $79,$00,$78,$78,$22,$79,$00,$78
         .BYTE $79,$00,$78,$79,$1D,$7A,$00,$79
         .BYTE $79,$1F,$7A,$00,$79,$79,$23,$7A
         .BYTE $00,$79,$79,$25,$7A,$00,$79,$7A
         .BYTE $00,$79,$7A,$1E,$7B,$00,$7A,$7A
         .BYTE $24,$7B,$00,$7A,$7B,$00,$7A,$7B
         .BYTE $10,$7C,$00,$7B,$7B,$14,$7C,$00
         .BYTE $7B,$7C,$00,$7B,$7C,$07,$7D,$00
         .BYTE $7C,$7C,$0E,$7D,$00,$7C,$7C,$19
         .BYTE $7D,$00,$7C,$7D,$00,$7C,$7D,$01
         .BYTE $74
         .BYTE $02,$00,$7D,$7D,$04,$71,$00,$71
         .BYTE $7D,$08,$71,$00,$71,$7D,$0B,$71
         .BYTE $00,$71,$7D,$0C,$0D,$00,$7D,$7D
         .BYTE $0C,$70,$0D,$00,$7D,$7D,$0F,$71
         .BYTE $00,$71,$7D,$11,$00,$7D,$7D,$12
         .BYTE $71,$00,$71,$7D,$15,$00,$7D,$7D
         .BYTE $16,$71,$00,$71,$7D,$17,$4C,$00
         .BYTE $7D,$7D,$18,$4C,$00,$7D,$7D,$1A
         .BYTE $71,$00,$71,$7D,$20,$71,$00,$71
         .BYTE $7D,$21,$71,$00,$71,$7D,$26,$71
         .BYTE $00,$71,$7D,$2A,$71,$00,$71,$7E
         .BYTE $7D,$00,$7D
 p2C24   .BYTE $00,$00,$04,$00,$09,$00,$0D,$00
         .BYTE $11,$00,$15,$00
         .BYTE $1A,$00,$1F,$00,$25,$00,$2A,$00
         .BYTE $2F,$00,$34,$00,$37,$00,$3A,$00
         .BYTE $3E,$00,$42,$00,$46,$00,$4A,$00
         .BYTE $4E,$00,$52,$00,$55,$00,$59,$00
         .BYTE $5F,$00,$65,$00,$6A,$00,$6F,$00
         .BYTE $73,$00,$76,$00,$79,$00,$7C,$00
         .BYTE $7F,$00,$82,$00,$85,$00,$88,$00
         .BYTE $8C,$00,$8F,$00,$92,$00,$96,$00
         .BYTE $9A,$00,$9D,$00,$A1,$00,$A4,$00
         .BYTE $A7,$00,$AD,$00,$B4,$00,$B8,$00
         .BYTE $BE,$00,$C5,$00,$C9,$00,$CF,$00
         .BYTE $D4,$00,$DA,$00,$DE,$00,$E3,$00
         .BYTE $E9,$00,$EF,$00,$F3,$00,$F8,$00
         .BYTE $FC,$00,$00,$01,$04,$01,$09,$01
         .BYTE $0D,$01,$11,$01,$15,$01,$18,$01
         .BYTE $1D,$01,$23,$01,$28,$01,$2B,$01
         .BYTE $2E,$01,$31,$01,$34,$01,$37,$01
         .BYTE $3A,$01,$3D,$01,$40,$01,$43,$01
         .BYTE $47,$01,$4B,$01,$4E,$01,$53,$01
         .BYTE $56,$01,$5A,$01,$5F,$01,$66,$01
         .BYTE $6C,$01,$6F,$01,$73,$01,$76,$01
         .BYTE $7B,$01,$7E,$01,$81,$01,$86,$01
         .BYTE $8C,$01,$91,$01,$99,$01,$A0,$01
         .BYTE $A5,$01,$AA,$01,$B0,$01,$B5,$01
         .BYTE $B8,$01,$BD,$01,$C0,$01,$C3,$01
         .BYTE $C7,$01,$CB,$01,$CE,$01,$D2,$01
         .BYTE $D8,$01,$DC,$01,$E4,$01,$EA,$01
         .BYTE $EE,$01,$F3,$01,$F7,$01,$FB,$01
         .BYTE $00,$02,$04,$02,$07,$02,$0A,$02
         .BYTE $0D,$02,$14,$02,$19,$02,$1C,$02
         .BYTE $21,$02,$24,$02,$29,$02,$2C,$02
         .BYTE $31,$02,$34,$02,$39,$02,$3C,$02
         .BYTE $41,$02,$46,$02,$49,$02,$4E,$02
         .BYTE $53,$02,$58,$02,$5D,$02,$60,$02
         .BYTE $65,$02,$6A,$02,$6D,$02,$72,$02
         .BYTE $77,$02,$7A,$02,$7F,$02,$84,$02
         .BYTE $89,$02,$8C,$02,$92,$02,$97,$02
         .BYTE $9C,$02,$A1,$02,$A6,$02,$AC,$02
         .BYTE $B1,$02,$B5,$02,$BA,$02,$BE,$02
         .BYTE $C3,$02,$C8,$02,$CD,$02,$D2,$02
         .BYTE $D7,$02,$DC,$02,$E1,$02
 p2D76   .BYTE $E6,$02

       ; end portion
; ----------------------------------------------------------------------------
; Dispatch Vector for Tokens $40–$7F (64–127): one JMP per code
; Maps each token value to its handler routine
; ----------------------------------------------------------------------------

        ; $40 '@'  (64)
        JMP j3472   ; Handle '@'
        ; $41 'A'  (65)
        JMP j3489   ; Handle 'A'
        ; $42 'B'  (66)
        JMP j7324   ; Handle 'B'
        ; $43 'C'  (67)
        JMP j30B3   ; Handle 'C'
        ; $44 'D'  (68)
        JMP j2F76   ; Default/unused
        ; $45 'E'  (69)
        JMP j2F76
        ; $46 'F'  (70)
        JMP j64F0
        ; $47 'G'  (71)
        JMP j64F0
        ; $48 'H'  (72)
        JMP j2F76
        ; $49 'I'  (73)
        JMP j2F76
        ; $4A 'J'  (74)
        JMP j2F76
        ; $4B 'K'  (75)
        JMP j3134
        ; $4C 'L'  (76)
        JMP j3458
        ; $4D 'M'  (77)
        JMP j3458
        ; $4E 'N'  (78)
        JMP j3458
        ; $4F 'O'  (79)
        JMP j724F
        ; $50 'P'  (80)
        JMP j73AA
        ; $51 'Q'  (81)
        JMP j306F
        ; $52 'R'  (82)
        JMP j7425
        ; $53 'S'  (83)
        JMP j2F76
        ; $54 'T'  (84)
        JMP j2F76
        ; $55 'U'  (85)
        JMP j2F76
        ; $56 'V'  (86)
        JMP j7911
        ; $57 'W'  (87)
        JMP j790D
        ; $58 'X'  (88)
        JMP j2F76
        ; $59 'Y'  (89)
        JMP j7375
        ; $5A 'Z'  (90)
        JMP j33C1

        JMP j33C6

        JMP j33CB

        JMP j33D0

        JMP j33D5

        JMP j33DA

        JMP j33DF

        JMP j33DF

        JMP j33DF

        JMP j33DF

        JMP j33DF

        ; $5B '['  (91)
        JMP j33E9
        ; $5C '\' (92)
        JMP j33E4

        JMP j33E4

        JMP j33E9

        ; $5D ']'  (93)
        JMP j33E9
        ; $5E '^'  (94)
        JMP j2F76
        ; $5F '_'  (95)
        JMP j343B
        ; $60 '`'  (96)
        JMP j2F76

        JMP j2F76

        JMP j343B

        JMP j2F76

        ; $61 'a'  (97)
        JMP j5B27
        ; $62 'b'  (98)
        JMP j5957
        ; $63 'c'  (99)
        JMP j5B8E
        ; $64 'd' (100)
        JMP j5BF5
        ; $65 'e' (101)
        JMP j2F8F
        ; $66 'f' (102)
        JMP j2F89
        ; $67 'g' (103)
        JMP j6B04
        ; $68 'h' (104)
        JMP j6B62
        ; $69 'i' (105)
        JMP j2F76
        ; $6A 'j' (106)
        JMP j6A7D
        ; $6B 'k' (107)
        JMP j6ABA
        ; $6C 'l' (108)
        JMP j5893
        ; $6D 'm' (109)
        JMP j5860
        ; $6E 'n' (110)
        JMP j6C41
        ; $6F 'o' (111)
        JMP j652C
        ; $70 'p' (112)
        JMP j6527
        ; $71 'q' (113)
        JMP j2390
        ; $72 'r' (114)
        JMP j2F76
        ; $73 's' (115)
        JMP j2F7A
        ; $74 't' (116)
        JMP j2F80
        ; $75 'u' (117)
        JMP j223D
        ; $76 'v' (118)
        JMP j2F95
        ; $77 'w' (119)
        JMP j33EE
        ; $78 'x' (120)
        JMP j23F3
        ; $79 'y' (121)
        JMP j2428
        ; $7A 'z' (122)
        JMP j2452
        ; $7B '{' (123)
        JMP j247B
        ; $7C '|' (124)
        JMP j321C
        ; $7D '}' (125)
        JMP j2F76

   JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j321C

        JMP j2F76

        JMP j3B67

        JMP j6221

        JMP j2F77

        JMP j2F7D

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j3017

        JMP j3472

        JMP j3489

        JMP j3465

        JMP j774F

        JMP j7749

        JMP j7743

        JMP j3472

        JMP j3489

        JMP j3465

        JMP j313A

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        ; $7E '~' (126)
        JMP j5B6C
        ; $7F DEL (127)
        JMP j5B7D

      JMP j5BD4

        JMP j5C09

        JMP j2F83

        JMP j6B93

        JMP j2F76

        JMP j2F76

        JMP j312E

        JMP j64D9

        JMP j5B0E

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j643A

        JMP j63FE

        JMP j7755

        JMP j63C2

        JMP j2F76

        JMP j638F

        JMP j2F76

        JMP j635C

        JMP j2F76

        JMP j6329

        JMP j2F76

        JMP j62D9

        JMP j6289

        JMP j2F76

        JMP j662E

        JMP j66D8

        JMP j6683

        JMP j672D

        JMP j2F76

        JMP j65FB

        JMP j65C8

        JMP j2F76

        JMP j600D

        JMP j6080

        JMP j2F76

        JMP j5FD2

        JMP j5F44

        JMP j5F8B

        JMP j5F43

        JMP j70BC

        JMP j65B6

        JMP j659E

        JMP j65B0

        JMP j7027

        JMP j7014

        JMP j6592

        JMP j74A0

        JMP j6586

        JMP j751B

        JMP j658C

        JMP j2F76

        JMP j719B

        JMP j6598

        JMP j65AA

        JMP j6460

        JMP j65A4

        JMP j65BC

        JMP j654F

; ----------------------------------------------------------------------------
; Dispatch Vector Tail Handlers (continuation from previous section)
; Tokens $44–$4F and select control codes map here to their handling routines
; ----------------------------------------------------------------------------

j2F76   RTS              ; Token 0x44–0x47 default: return immediately (no-op)

j2F77   JMP j580A        ; Token 0x45: error—unexpected dispatch, goto general fault handler
j2F7A   JMP j580A        ; Token 0x46: likewise
j2F7D   JMP j580A        ; Token 0x47: likewise
j2F80   JMP j580A        ; Token 0x48: likewise

; Special control‐sequence entries:
j2F83   JSR s31E1        ; Token 0x49: clear storage‐class flag
        JMP j6A0B        ; then resume compilation at post‐token handler

j2F89   JSR s31DB        ; Token 0x4A: set 'extern' indicator
        JMP j6978        ; then jump to extern‐resolution routine

j2F8F   JSR s31DB        ; Token 0x4B: same as above (alias)
        JMP j697B        ; slight variation in return path

; ----------------------------------------------------------------------------
; End of Dispatch Tail - next comes multi-byte literal and identifier parsing
; ----------------------------------------------------------------------------

;--------------------------------------------------
; Routine j2F95 ($2F95) - Copy Literal/Identifier Bytes
; Copies up to 12 bytes from the name buffer into a temporary buffer,
; then normalizes the next character and checks for errors.
;--------------------------------------------------
j2F95   LDX #$0C        ; Set X = 12 (number of bytes to copy)

b2F97   LDA a8678,X     ; Load byte from name buffer at a8678+X (last character first)
        STA f866B,X     ; Store the byte into temp buffer at f866B+X
        DEX             ; Decrement X to move to previous byte
        BPL b2F97       ; Repeat until X < 0 (all 12 bytes copied)

        JSR s31D3       ; Call normalization routine (e.g., test next character)
        BCC b2FA6       ; If carry clear (no error), branch to continuation
        RTS             ; Otherwise return (error detected)

; b2FA6-b2FEC: Post-parse operator/terminator check and state save
b2FA6   LDA a3C           ; Load low byte of saved buffer pointer
        STA a3014         ; Save low byte to a3014
        LDA a3D           ; Load high byte of saved buffer pointer
        STA a3015         ; Save high byte to a3015
        LDA a59EB         ; Load nested conditional/file state flag
        STA a3016         ; Save state flag to a3016
        LDA a36           ; Load current token/character code

j2FB8   CMP #$2E         ; Compare to '.' (end-of-statement marker)
        BEQ b2FEC         ; If '.', jump to common terminator handler
        CMP #$1C         ; Compare to control code $1C (Record Separator)
        BEQ b2FEC         ; Same handler for record separator
        CMP #$21         ; Compare to '!' (logical NOT or operator start)
        BEQ b2FEC         ; Handle as terminator
        CMP #$2B         ; Compare to '+' (binary plus/operator start)
        BEQ b2FCA        ; If '+', branch to operator setup
        CMP #$4E         ; Compare to 'N' (start of 'NE' operator sequence)

b2FCA   BNE b2FD5        ; If not one of the above, go to default continuation
        JSR s31B9        ; Clear undefined identifier flag (reset a3217)
        JSR s3005        ; Store identifier/constant descriptor into f8778 buffer
        JMP b2FEC        ; Jump to common terminator handling

;--------------------------------------------------
; b2FD5 ($2FD5) - Handle identifier continuation characters
;  Checks if current character falls within the range '/' (0x2F) to '<' (0x3C).
;  If so, calls routines to append it to the identifier buffer and then loops to process next char.
;--------------------------------------------------
b2FD5   CMP #$2F        ; Compare A to '/' (start of continuation range)
        BCC b2FE6       ; If A < '/', skip continuation handling
        CMP #$3D        ; Compare A to '=' (one past '<')
        BCS b2FE6       ; If A >= '=', skip continuation handling
        JSR s31B9       ; Else: save parser state (push A=0 into error flag)
        JSR s3005       ; Copy saved identifier chars into secondary buffer
        JMP b2FEC       ; Jump to post-processing loop

b2FE6   JSR s3587       ; No continuation: restore parser state (save A3C/A3D)
        JMP j2FB8       ; Return to scanning loop at j2FB8

;--------------------------------------------------
; b2FEC ($2FEC) - Wait for next valid character
;  Loops until the current character matches the saved start-of-identifier char.
;--------------------------------------------------
b2FEC   LDA a59EB       ; Load saved high byte of start char
        CMP a3016       ; Compare with most recently read char
        BEQ b2FFA       ; If equal, exit loop
        JSR s3587       ; Otherwise, restore parser state and try again
        JMP b2FEC       ; Loop until match

;--------------------------------------------------
; b2FFA ($2FFA) - Restore initial identifier pointers
;  On exit from loop, update pointer registers to resume parsing after identifier.
;--------------------------------------------------
b2FFA   LDA a3014       ; Load saved pointer low byte
        STA a3E         ; Restore buffer pointer low
        LDA a3015       ; Load saved pointer high byte
        STA a3F         ; Restore buffer pointer high
        RTS             ; Return to caller
;--------------------------------------------------- stopped

s3005   LDY #$09
        LDX #$07
b3009   LDA f866B,X
        STA f8778,Y
        DEY 
        DEX 
        BPL b3009
        RTS 

a3014   .BYTE $00
a3015   .BYTE $00
a3016   .BYTE $00
j3017   JSR s31BF
        BCS b301F
        JSR s692A
b301F   BCC b3027
        JSR s3140
        JMP j4E45

b3027   LDA a26DD
        BNE b303B
        LDA a26DA
        CMP #$01
        BNE b3038
        LDA #$02
        STA a26DA
b3038   JMP j303E

b303B   LDA a864D
j303E   STA a58A4
        LDA a26D9
        PHA 
        LDA #$04
        STA a26D9
        LDX a26DD
        BEQ b305A
b304F   DEX 
        LDA a864D,X
        INX 
        STA a864D,X
        DEX 
        BNE b304F
b305A   LDA #$0A
        STA a864D
        INC a26DD
        JSR s3140
        JSR s4E4B
        PLA 
        STA a26D9
        JMP j57B2

j306F   LDY a35
        LDX a34
        BNE b3076
        DEY 
b3076   DEX 
        STX a2B
        STY a2C
        LDY #$00
        LDA (p2B),Y
        CMP #$7B
        BNE b30B0
        LDA a36
        CMP #$0E
        BEQ b308F
        CMP #$19
        BEQ b308F
        CMP #$07
b308F   BNE b30A5
        LDY #$00
        LDA #$14
        STA (p34),Y
        INY 
        LDA #$7C
        STA (p34),Y
        INC a34
        BNE b30A2
        INC a35
b30A2   JMP j5F43

b30A5   LDA a2B
        STA a34
        LDA a2C
        STA a35
        JMP j6080

b30B0   JMP j72E6

j30B3   LDY a35
        LDX a34
        BNE b30BA
        DEY 
b30BA   DEX 
        STX a2B
        STY a2C
        LDY #$00
        LDA (p2B),Y
        CMP #$77
        BNE b30E0
        JSR s30E3
        BCC b30CF
        JMP j5F43

b30CF   LDA a2B
        STA a34
        LDA a2C
        STA a35
        JSR s5C9D
        JSR s5CFA
        JMP j6329

b30E0   JMP j72B6

s30E3   LDA a36
        CMP #$22
        BEQ b30FB
        CMP #$06
        BEQ b30FB
        CMP #$1D
        BEQ b30FB
        CMP #$23
        BEQ b30FB
        CMP #$1F
        BEQ b30FB
        CMP #$25
b30FB   BEQ b310F
        CMP #$24
        BEQ b310F
        CMP #$1E
        BEQ b310F
        CMP #$10
        BEQ b310F
        CMP #$14
        BEQ b310F
        CMP #$0E
b310F   BEQ b3117
        CMP #$19
        BEQ b3117
        CMP #$07
b3117   BEQ b311B
        CLC 
        RTS 

b311B   LDY #$00
        LDA #$09
        STA (p34),Y
        INY 
        LDA #$7C
        STA (p34),Y
        INC a34
        BNE b312C
        INC a35
b312C   SEC 
        RTS 

j312E   JSR s31E1
        JMP j69F3

j3134   JSR s31E1
        JMP j69F6

j313A   JSR s58C7
        JMP j3209

s3140   LDY #$00
        JSR s3A97
        STA (p3A),Y
        INY 
        LDA a48
        STA (p3A),Y
        LDX #$07
        LDY #$09
b3150   LDA f866B,X
        STA (p3A),Y
        DEY 
        DEX 
        BPL b3150
        LDY #$0A
        LDA a44
        STA (p3A),Y
        INY 
        LDA a45
        STA (p3A),Y
        LDA a3A
        STA a16
        LDA a3B
        STA a17
        CLC 
        LDA a3A
        ADC #$0C
        STA a3A
        BCC b3184
        INC a3B
        LDA a3B
        CMP #$D8
        BNE b3184
        LDX #$85
        LDY #$31
        JMP j20F8

b3184   RTS 

        .TEXT "*** TOO MANY VARIABLES", $0D, $00
s319D   LDA #$00
        STA a3217
        STA a3218
        STA a3219
        STA a321A
        STA a321B
        JMP j68B5

j31B1   LDA #$01
        STA a3217
        JMP j6938

s31B9   LDA #$00
        STA a3217
        RTS 

s31BF   CLC 
        LDA a3217
        BEQ b31C6
        SEC 
b31C6   RTS 

s31C7   LDA #$01
        STA a3218
        RTS 

s31CD   LDA #$00
        STA a3218
        RTS 

s31D3   CLC 
        LDA a3218
        BEQ b31DA
        SEC 
b31DA   RTS 

s31DB   LDA #$01
        STA a3219
        RTS 

s31E1   LDA #$00
        STA a3219
        RTS 

s31E7   CLC 
        LDA a3219
        BEQ b31EE
        SEC 
b31EE   RTS 

s31EF   LDA #$01
        STA a321A
        RTS 

s31F5   LDA #$00
        STA a321A
        RTS 

s31FB   CLC 
        LDA a321A
        BEQ b3202
        SEC 
b3202   RTS 

s3203   LDA #$01
        STA a321B
        RTS 

j3209   LDA #$00
        STA a321B
        RTS 

s320F   CLC 
        LDA a321B
        BEQ b3216
        SEC 
b3216   RTS 

a3217   .BYTE $00
a3218   .BYTE $00
a3219   .BYTE $00
a321A   .BYTE $00
a321B   .BYTE $00
j321C   JSR s3A97
        LDY #$00
        STA (p46),Y
        LDA #$01
        INY 
        STA (p46),Y
        LDY #$09
        LDX #$07
b322C   LDA a8678,X
        STA (p46),Y
        DEY 
        DEX 
        BPL b322C
        CLC 
        LDA a46
        ADC #$0A
        STA a46
        BCC b3240
        INC a47
b3240   RTS 

s3241   LDA #$00
        STA a3348
        STA a3349
        LDA #<p7C59
        STA a2B
        LDA #>p7C59
        STA a2C
j3251   LDA a2B
        CMP a46
        BNE b3266
        LDA a2C
        CMP a47
        BNE b3266
        LDA #<p7C59
        STA a46
        LDA #>p7C59
        STA a47
        RTS 

b3266   LDA a42
        STA a32
        LDA a43
        STA a33
j326E   LDA a32
        CMP a3A
        BNE b327D
        LDA a33
        CMP a3B
        BNE b327D
        JMP j32D3

b327D   LDX #$0A
        JSR s3A84
        BNE b3287
        JMP j3295

b3287   CLC 
        LDA a32
        ADC #$0C
        STA a32
        BCC b3292
        INC a33
b3292   JMP j326E

j3295   LDY #$0A
        LDA (p32),Y
        STA a49
        INY 
        LDA (p32),Y
        STA a4A
        LDY #$01
        LDA (p49),Y
        STA a334A
        INY 
        LDA (p49),Y
        STA a334B
        LDY #$01
        LDA a3348
        STA (p49),Y
        INY 
        LDA a3349
        STA (p49),Y
        JSR s3364
        CLC 
        LDA a3348
        ADC a334A
        STA a3348
        LDA a3349
        ADC a334B
        STA a3349
        JMP j333A

j32D3   LDY #$09
b32D5   LDA (p2B),Y
        STA (p3A),Y
        DEY 
        BPL b32D5
        LDY #$0A
        LDA a44
        STA (p3A),Y
        INY 
        LDA a45
        STA (p3A),Y
        CLC 
        LDA a3A
        ADC #$0C
        STA a3A
        BCC b32F2
        INC a3B
b32F2   LDY #$00
        LDA #$07
        STA (p44),Y
        INY 
        LDA a3348
        STA (p44),Y
        INY 
        LDA a3349
        STA (p44),Y
        INY 
        LDA #$02
        STA (p44),Y
        INY 
        LDA a44
        STA a49
        LDA a45
        STA a4A
        CLC 
        TYA 
        ADC a44
        STA a44
        BCC b3329
        INC a45
        LDA a45
        CMP #$E0
        BNE b3329
        LDX #$4C
        LDY #$33
        JMP j20F8

b3329   JSR s3364
        CLC 
        LDA a3348
        ADC #$02
        STA a3348
        BCC j333A
        INC a3349
j333A   CLC 
        LDA a2B
        ADC #$0A
        STA a2B
        BCC b3345
        INC a2C
b3345   JMP j3251

a3348   .BYTE $00
a3349   .BYTE $00
a334A   .BYTE $00
a334B   .TEXT $00, "*** TOO MANY VARIABLES", $0D, $00
s3364   LDA a03FF
        CMP #$52
        BEQ b336C
        RTS 

b336C   LDA a26E2
        CMP #$10
        BCC b3374
        RTS 

b3374   LDY #$03
        LDA (p49),Y
        CMP #$02
        BEQ b3389
        CMP #$04
        BEQ b3389
        CMP #$09
        BEQ b3389
        CMP #$0B
        BEQ b3389
        RTS 

b3389   LDY #$00
        LDA #$05
        STA (p49),Y
        INY 
        LDA a26E2
        STA (p49),Y
        INY 
        LDA #$00
        STA (p49),Y
        LDA #$FF
        JSR s21D3
        LDA #$8E
        JSR s21D3
        LDA a3348
        JSR s21D3
        LDA #$FF
        JSR s21D3
        LDA #$09
        JSR s21D3
        LDA a26E2
        JSR s21D3
        INC a26E2
        INC a26E2
        RTS 

j33C1   LDA #$01
        JMP j34D7

j33C6   LDA #$02
        JMP j34D7

j33CB   LDA #$04
        JMP j34D7

j33D0   LDA #$05
        JMP j34D7

j33D5   LDA #$06
        JMP j34D7

j33DA   LDA #$01
        JMP j356E

j33DF   LDA #$02
        JMP j356E

j33E4   LDA #$04
        JMP j356E

j33E9   LDA #$05
        JMP j356E

j33EE   LDY #$01
j33F0   LDA (p49),Y
        CMP #$09
        BCC b3400
        INY 
        CMP #$0B
        BNE b33FD
        INY 
        INY 
b33FD   JMP j33F0

b3400   PHA 
        JSR j356E
        PLA 
        CMP #$07
        BEQ b340B
        CMP #$08
b340B   BNE b3420
        STY a334A
        PHA 
        INY 
        LDA (p49),Y
        TAX 
        INY 
        LDA (p49),Y
        TAY 
        PLA 
        JSR s3568
        LDY a334A
b3420   STY a334A
        LDY #$01
j3425   CPY a334A
        BEQ b3433
        LDA (p49),Y
        JSR s357D
        INY 
        JMP j3425

b3433   LDA a26DD
        STA a4E41
        RTS 

        .BYTE $00
j343B   LDA a3B62
        BEQ b3457
        LDA a3B63
        STA a32
        LDA a3B64
        STA a33
        LDY #$02
        LDA a26E5
        STA (p32),Y
        INY 
        LDA a26E6
        STA (p32),Y
b3457   RTS 

j3458   LDA #$01
        JSR s34A3
        LDA #$09
        JSR s357D
        JMP j34D0

j3465   LDA #$01
        JSR s34A3
        LDA #$0A
        JSR s357D
        JMP j34D0

j3472   LDA #$03
        JSR s34A3
        LDA #$0B
        JSR s357D
        LDA #$00
        JSR s357D
        LDA #$00
        JSR s357D
        JMP j34D0

j3489   LDA #$03
        JSR s34A3
        LDA #$0B
        JSR s357D
        JSR s2502
        TYA 
        PHA 
        TXA 
        JSR s357D
        PLA 
        JSR s357D
        JMP j34D0

s34A3   LDX a4E40
        STX a26DD
        PHA 
        CLC 
        ADC a4E41
        PHA 
        TAY 
        LDX a4E41
j34B3   CPX a4E40
        BEQ b34C3
        DEX 
        DEY 
        LDA a864D,X
        STA a864D,Y
        JMP j34B3

b34C3   PLA 
        STA a4E41
        PLA 
        CLC 
        ADC a4E40
        STA a4E40
        RTS 

j34D0   LDA a4E41
        STA a26DD
        RTS 

j34D7   LDX a3B65
        BEQ b34EE
        CMP #$08
        BEQ b34EE
        CMP #$0F
        BEQ b34EE
        LDX #$40
        LDY #$35
        JSR j562D
        LDA a3B66
b34EE   PHA 
        JSR s31FB
        PLA 
        BCC b3508
        CMP #$05
        BNE b34FB
        LDA #$07
b34FB   CMP #$07
        BEQ b3508
        LDX #$40
        LDY #$35
        JSR j562D
        LDA #$07
b3508   CMP #$01
        BEQ b350E
        CMP #$05
b350E   BNE b3524
        PHA 
        JSR s31D3
        BCS b3523
        LDX #$40
        LDY #$35
        JSR j562D
        PLA 
        LDA #$03
        JMP b3524

b3523   PLA 
b3524   CMP #$05
        BNE b3531
        LDX a26E2
        CPX #$1F
        BCC b3531
        LDA #$01
b3531   STA a26D9
        LDX #$00
        STX a26DD
        STX a4E40
        STX a4E41
        RTS 

        .TEXT " *** ILLEGAL STORAGE CLASS DECLARATION", $0D, $00
s3568   STX a26E5
        STY a26E6
j356E   STA a26DA
        LDA #$00
        STA a26DD
        STA a4E40
        STA a4E41
        RTS 

s357D   LDX a26DD
        STA a864D,X
        INC a26DD
        RTS 

s3587   JSR s3593
        LDX a3E
        STX a3C
        LDX a3F
        STX a3D
        RTS 

s3593   LDA a3E
        STA a3C
        LDA a3F
        STA a3D
b359B   JSR s37E2
        CMP #$20
        BEQ b359B
        CMP #$A0
        BEQ b359B
        CMP #$0D
        BEQ b359B
        CMP #$00
        BNE b35B1
        LDA #$2E
        RTS 

b35B1   CMP #$23
        BNE b35BB
        JSR s5375
        JMP b359B

b35BB   LDX a59EA
        BNE b35C3
        JMP b359B

b35C3   CMP #$41
        BCC b35D4
        CMP #$5B
        BCS b35D4
        JSR s3821
        BCC b35D3
        JMP s3593

b35D3   RTS 

b35D4   CMP #$C1
        BCC b35E5
        CMP #$DB
        BCS b35E5
        JSR s3821
        BCC b35E4
        JMP s3593

b35E4   RTS 

b35E5   CMP #$A4
        BNE b35F2
        JSR s3821
        BCC b35F1
        JMP s3593

b35F1   RTS 

b35F2   CMP #$30
        BCC b35FD
        CMP #$3A
        BCS b35FD
        JMP j4A85

b35FD   CMP #$27
        BNE b3604
        JMP j4C0A

b3604   CMP #$22
        BNE b360B
        JMP j4BB8

b360B   CMP #$5B
        BNE b3612
        LDA #$01
        RTS 

b3612   CMP #$5D
        BNE b3619
        LDA #$02
        RTS 

b3619   CMP #$5E
        BNE b362F
        JSR s37E2
        CMP #$3D
        BEQ b362C
        JSR s37E5
        LDA #$03
        JMP j362E

b362C   LDA #$04
j362E   RTS 

b362F   CMP #$21
        BNE b3645
        JSR s37E2
        CMP #$3D
        BEQ b3642
        JSR s37E5
        LDA #$05
        JMP j3644

b3642   LDA #$06
j3644   RTS 

b3645   CMP #$25
        BNE b365B
        JSR s37E2
        CMP #$3D
        BEQ b3658
        JSR s37E5
        LDA #$07
        JMP j365A

b3658   LDA #$08
j365A   RTS 

b365B   CMP #$26
        BNE b3676
        JSR s37E2
        CMP #$26
        BNE b3669
        LDA #$0A
        RTS 

b3669   CMP #$3D
        BNE b3670
        LDA #$0B
        RTS 

b3670   JSR s37E5
        LDA #$09
        RTS 

b3676   CMP #$28
        BNE b367D
        LDA #$0C
        RTS 

b367D   CMP #$29
        BNE b3684
        LDA #$0D
        RTS 

b3684   CMP #$2A
        BNE b369A
        JSR s37E2
        CMP #$3D
        BEQ b3697
        JSR s37E5
        LDA #$0E
        JMP j3699

b3697   LDA #$0F
j3699   RTS 

b369A   CMP #$2B
        BNE b36B5
        JSR s37E2
        CMP #$2B
        BNE b36A8
        LDA #$11
        RTS 

b36A8   CMP #$3D
        BNE b36AF
        LDA #$12
        RTS 

b36AF   JSR s37E5
        LDA #$10
        RTS 

b36B5   CMP #$2C
        BNE b36BC
        LDA #$13
        RTS 

b36BC   CMP #$2D
        BNE b36DE
        JSR s37E2
        CMP #$2D
        BNE b36CA
        LDA #$15
        RTS 

b36CA   CMP #$3D
        BNE b36D1
        LDA #$16
        RTS 

b36D1   CMP #$3E
        BNE b36D8
        LDA #$17
        RTS 

b36D8   JSR s37E5
        LDA #$14
        RTS 

b36DE   CMP #$2E
        BNE b36E5
        LDA #$18
        RTS 

b36E5   CMP #$2F
        BNE b3722
        JSR s37E2
        CMP #$2A
        BNE b3713
b36F0   JSR s37E2
        CMP #$00
        BNE b36FA
b36F7   JMP j3803

b36FA   CMP #$2A
        BNE b370E
        JSR s37E2
        CMP #$00
        BEQ b36F7
        CMP #$2F
        BEQ b370E
        PHP 
        JSR s37E5
        PLP 
b370E   BNE b36F0
        JMP s3593

b3713   CMP #$3D
        BEQ b371F
        JSR s37E5
        LDA #$19
        JMP j3721

b371F   LDA #$1A
j3721   RTS 

b3722   CMP #$3A
        BNE b3729
        LDA #$1B
        RTS 

b3729   CMP #$3B
        BNE b3730
        LDA #$1C
        RTS 

b3730   CMP #$3C
        BNE b375C
        JSR s37E2
        CMP #$3C
        BNE b374D
        JSR s37E2
        CMP #$3D
        BEQ b374A
        JSR s37E5
        LDA #$1E
        JMP j374C

b374A   LDA #$20
j374C   RTS 

b374D   CMP #$3D
        BEQ b3759
        JSR s37E5
        LDA #$1D
        JMP j375B

b3759   LDA #$1F
j375B   RTS 

b375C   CMP #$3D
        BNE b3772
        JSR s37E2
        CMP #$3D
        BEQ b376F
        JSR s37E5
        LDA #$21
        JMP j3771

b376F   LDA #$22
j3771   RTS 

b3772   CMP #$3E
        BNE b379E
        JSR s37E2
        CMP #$3E
        BNE b378F
        JSR s37E2
        CMP #$3D
        BEQ b378C
        JSR s37E5
        LDA #$24
        JMP j378E

b378C   LDA #$26
j378E   RTS 

b378F   CMP #$3D
        BEQ b379B
        JSR s37E5
        LDA #$23
        JMP j379D

b379B   LDA #$25
j379D   RTS 

b379E   CMP #$3F
        BNE b37A5
        LDA #$27
        RTS 

b37A5   CMP #$DF
        BNE b37C0
        JSR s37E2
        CMP #$DF
        BNE b37B3
        LDA #$29
        RTS 

b37B3   CMP #$3D
        BNE b37BA
        LDA #$2A
        RTS 

b37BA   JSR s37E5
        LDA #$28
        RTS 

b37C0   CMP #$DB
        BNE b37C7
        LDA #$2B
        RTS 

b37C7   CMP #$DD
        BNE b37CE
        LDA #$2C
        RTS 

b37CE   CMP #$AF
        BNE b37D5
        LDA #$2D
        RTS 

b37D5   STA a3800
        LDX #$E8
        LDY #$37
        JSR j562D
        JMP s3593

s37E2   JMP j3BAA

s37E5   JMP j3C53

        .TEXT " *** ILLEGAL CHARACTER: "
a3800   .TEXT $00, $0D, $00
j3803   LDX #$0A
        LDY #$38
        JMP j20F8

        .TEXT " *** UNCLOSED COMMENT", $0D, $00
s3821   STA a8678
        JSR s3C79
        STA a8782
        LDX #$01
j382C   STX a31
        JSR j3BAA
        CMP #$30
        BCS b3838
        JMP j386C

b3838   CMP #$3A
        BCC b3859
        CMP #$41
        BCS b3843
        JMP j386C

b3843   CMP #$5B
        BCC b3859
        CMP #$A4
        BEQ b3859
        CMP #$C1
        BCS b3852
        JMP j386C

b3852   CMP #$DB
        BCC b3859
        JMP j386C

b3859   LDX a31
        CPX #$FF
        BEQ b3869
        STA a8678,X
        JSR s3C79
        STA a8782,X
        INX 
b3869   JMP j382C

j386C   JSR j3C53
        LDA #$00
        LDX a31
        STA a8678,X
        STA a8782,X
        JSR s6DE0
        BCC b387F
        RTS 

b387F   LDA #<a8782
        STA a2B
        LDA #>a8782
        STA a2C
        LDA #<p3988
        STA a32
        LDA #>p3988
        STA a33
        LDA #$2F
        STA a31
b3893   LDX #$FF
        JSR s3A84
        BNE b389E
        LDA a31
        CLC 
        RTS 

b389E   LDA a32
        CLC 
        ADC #$09
        STA a32
        BCC b38A9
        INC a33
b38A9   INC a31
        LDA a31
        CMP #$4B
        BNE b3893
        LDX #$07
        LDY #$09
b38B5   LDA a8678,X
        STA f8778,Y
        DEY 
        DEX 
        BPL b38B5
        JSR s3A97
        STA f8778
        JSR s320F
        BCS b38CD
        JSR s58CD
b38CD   BCC b38D4
        LDA #$02
        JMP j38D6

b38D4   LDA #$01
j38D6   STA a8779
        LDA #$00
        CMP a3A
        BNE b38E8
        LDA #$D0
        CMP a3B
        BNE b38E8
        JMP j3972

b38E8   LDA #<f8778
        STA a2B
        LDA #>f8778
        STA a2C
j38F0   LDA #<pD000
        STA a32
        LDA #>pD000
        STA a33
j38F8   LDX #$0A
        JSR s3A84
        BNE b393A
        LDY #$0A
        LDA (p32),Y
        STA a49
        INY 
        LDA (p32),Y
        STA a4A
        LDY #$00
        LDA (p49),Y
        CMP #$06
        BNE b3916
        LDA #$4E
        CLC 
        RTS 

b3916   JSR s31BF
        BCS b391E
        JSR s31FB
b391E   BCC b3923
        JMP j3972

b3923   LDA a8779
        CMP #$01
        BNE b3936
        LDA a48
        CMP #$02
        BNE b3936
        INC a8779
        JMP j38F0

b3936   LDA #$4C
        CLC 
        RTS 

b393A   LDA a32
        CLC 
        ADC #$0C
        STA a32
        BCC b3945
        INC a33
b3945   LDA a33
        CMP a3B
        BNE b394F
        LDA a32
        CMP a3A
b394F   BEQ b3954
        JMP j38F8

b3954   LDA a8779
        CMP #$01
        BNE b3967
        LDA a48
        CMP #$02
        BNE b3967
        INC a8779
        JMP j38F0

b3967   DEC f8778
        BEQ b396F
        JMP j38F0

b396F   INC f8778
j3972   JSR s31BF
        BCC b397B
        LDA #$4D
        CLC 
        RTS 

b397B   JSR s31FB
        BCC b3984
        LDA #$53
        CLC 
        RTS 

b3984   LDA #$4B
        CLC 
        RTS 

p3988   .TEXT "AUTO", $00, $00, $00, $00, $00, "STATIC", $00, $00, $00, "EXTERN", $00, $00, $00, "REGISTER", $00, "TYPE"
        .TEXT "DEF", $00, $00, "CHAR", $00, $00, $00, $00, $00, "SHORT", $00, $00, $00, $00, "INT", $00, $00, $00, $00, $00, $00, "LONG", $00, $00, $00, $00
        .TEXT $00, "UNSIGNED", $00, "FLOAT", $00, $00, $00, $00, "DOUBLE", $00, $00, $00, "STRUCT", $00, $00, $00, "UNI"
        .TEXT "ON", $00, $00, $00, $00, "IF", $00, $00, $00, $00, $00, $00, $00, "WHILE", $00, $00, $00, $00, "ELSE", $00, $00, $00, $00, $00, "DO", $00, $00, $00, $00, $00
        .TEXT $00, $00, "FOR", $00, $00, $00, $00, $00, $00, "SWITCH", $00, $00, $00, "CASE", $00, $00, $00, $00, $00, "DEFAULT", $00, $00, "BR"
        .TEXT "EAK", $00, $00, $00, $00, "CONTINUE", $00, "RETURN", $00, $00, $00, "GOTO", $00, $00, $00, $00, $00, "SIZEOF"
        .TEXT $00, $00, $00, "ENTRY", $00, $00, $00, $00
s3A84   LDY #$00
b3A86   LDA (p2B),Y
        CMP (p32),Y
        BEQ b3A8D
        RTS 

b3A8D   CMP #$00
        BNE b3A92
        RTS 

b3A92   INY 
        DEX 
        BNE b3A86
        RTS 

s3A97   LDA a26D7
        RTS 

s3A9B   LDA a26D7
        JSR j24BD
        LDA a26D8
        STA a26D7
        INC a26D8
        RTS 

s3AAB   JSR s24CE
        STA a26D7
        RTS 

s3AB2   INC a3B65
        LDA a48
        JSR j24BD
        LDA #$02
        STA a48
        LDA a3B62
        BNE b3AC9
        JSR j24BD
        JMP j3AD7

b3AC9   LDX a3B63
        LDY a3B64
        JSR s24ED
        LDA #$01
        JSR j24BD
j3AD7   LDX a26DB
        LDY a26DC
        JSR s24ED
        LDA #$00
        STA a26DB
        STA a26DC
        LDX a26D9
        LDY a3B66
        JSR s24ED
        JSR s320F
        BCC b3AFB
        LDA #$08
        JMP j3AFD

b3AFB   LDA #$0F
j3AFD   STA a3B66
        JSR j34D7
        LDA a26DA
        JSR j24BD
        LDA #$02
        JSR j356E
        LDX a16
        LDY a17
        JSR s24ED
        JMP j7613

s3B18   JSR s761E
        DEC a3B65
        JSR s2502
        STX a16
        STY a17
        JSR s24CE
        STA a26DA
        JSR s2502
        STX a26D9
        STY a3B66
        JSR s2502
        LDA a26DB
        STA a26E5
        LDA a26DC
        STA a26E6
        STX a26DB
        STY a26DC
        JSR s24CE
        STA a3B62
        CMP #$00
        BEQ b3B5C
        JSR s2502
        STX a3B63
        STY a3B64
b3B5C   JSR s24CE
        STA a48
        RTS 

a3B62   .BYTE $00
a3B63   .BYTE $00
a3B64   .BYTE $00
a3B65   .BYTE $00
a3B66   .BYTE $00
j3B67   LDA a3B65
        BEQ b3B72
        LDA a3B66
        JMP j3BA1

b3B72   JSR s31FB
        BCC b3B7C
        LDA #$07
        JMP j3BA1

b3B7C   JSR s31D3
        BCS b3B86
        LDA #$03
        JMP j3BA1

b3B86   LDA a03FF
        CMP #$52
        BNE b3B92
        LDA #$05
        JMP j3BA1

b3B92   CMP #$41
        BNE b3B9B
        LDA #$01
        JMP j3BA1

b3B9B   CMP #$53
        BNE j3BA1
        LDA #$02
j3BA1   JSR j34D7
        LDA #$02
        JSR j356E
        RTS 

j3BAA   STX a3C2E
        STY a3C2F
j3BB0   LDA a3E
        CMP a40
        BNE b3BBA
        LDA a3F
        CMP a41
b3BBA   BEQ b3BD7
        LDY #$00
        LDA (p3E),Y
        BNE b3BCD
        LDX a621B
        BEQ b3BCD
        JSR s625B
        JMP j3BB0

b3BCD   JSR s3C35
        LDX a3C2E
        LDY a3C2F
        RTS 

b3BD7   LDX a5603
        DEX 
        DEX 
        LDA f3C30,X
        AND #$40
        BEQ b3BFB
        LDA a5603
        CMP #$02
        BEQ b3BF6
        LDA a5603
        JSR s215B
        DEC a5603
        JMP b3BD7

b3BF6   LDA #$00
        JMP j3C1D

b3BFB   LDX a5603
        JSR s2137
        BCS b3C1B
        JSR s2149
        PHA 
        JSR s21B5
        LDX a5603
        DEX 
        DEX 
        STA f3C30,X
        PLA 
        PHA 
        JSR s2152
        PLA 
        JMP j3C1D

b3C1B   LDA #$5D
j3C1D   LDY #$00
        STA (p40),Y
        JSR s3C35
        JSR s3C44
        LDX a3C2E
        LDY a3C2F
        RTS 

a3C2E   .BYTE $00
a3C2F   .BYTE $00
f3C30   .BYTE $00,$00,$00,$00,$00
s3C35   PHA 
        INC a3E
        BNE b3C42
        INC a3F
        LDA a3F
        AND #$F3
        STA a3F
b3C42   PLA 
        RTS 

s3C44   PHA 
        INC a40
        BNE b3C51
        INC a41
        LDA a41
        AND #$F3
        STA a41
b3C51   PLA 
        RTS 

j3C53   PHA 
        LDA a621B
        BNE b3C5E
        LDA #$B0
        JMP j3C60

b3C5E   LDA #$AC
j3C60   STA a3C78
        LDA a3E
        BNE b3C74
        DEC a3F
        LDA a3F
        CMP a3C78
        BCS b3C74
        ADC #$04
        STA a3F
b3C74   DEC a3E
        PLA 
        RTS 

a3C78   .BYTE $00
s3C79   CMP #$C1
        BCC b3C84
        CMP #$DB
        BCS b3C84
        SEC 
        SBC #$80
b3C84   RTS 

;**** Data Table at $3C86 ****
; Starting at address $3C86 in the compiler binary, you’ll find a large .BYTE block that holds a lookup table used by the tokenizer.
; Each byte corresponds to a PETSCII character or control code, mapping input characters to character classes or token-start indicators.
; The compiler uses this table to quickly classify and dispatch on characters when scanning source text.
; For example, entries for ASCII letters map to a value indicating "identifier character", digits map to "numeric", punctuation map to specific operator tokens, and whitespace/control codes map to "skip" or "delimiter".
; By indexing into this table with the current character’s PETSCII code, the scanner loop (s2068, s207E, etc.) can branch appropriately without long chains of CMP instructions.
;
; Typical layout:
;   .BYTE $00      ; non-printable / skip
;   .BYTE $01      ; letter
;   .BYTE $02      ; digit
;   .BYTE $03      ; underscore (identifier continuation)
;   .BYTE $04      ; operator start
;   ...
; These values are entirely hard-coded here so the scanner is extremely fast — a single lookup and branch per character.
;
;**** Usage of Data Table at $3C86 ****
; The compiler’s scanning routines index this table directly:
; - s2068 (label j206E) loads a character via LDA (p2B),Y, then uses that byte as an index into the table to classify it.
;   It sets up Y = PETSCII code, then LDA table,Y to fetch the class, branching on zero (end of token) or dispatching to identifier, number, or operator handlers.
; - Likewise, s207E repeatedly fetches inputs and uses the same table for classification in a tight loop.
; Internally, the base address $3C86 is loaded into a zero-page pointer (p2B/p2C) before entry to these routines, then each character lookup is:
;     LDY #$00
;     LDA (p2B),Y      ; fetch next PETSCII code
;     LDX #<DataTable
;     LDY #>DataTable
;     LDA (p2B),Y,X    ; classification byte
;     BEQ token_done
;     ... handle specific class ...
;
; This direct table lookup replaces lengthy comparisons and gives the compiler a high-speed scanner.
        .BYTE $20,$00,$01,$90,$80,$80,$00,$00
        .BYTE $00,$00,$02,$0A,$AA,$AA,$A0,$00
        .BYTE $00,$00,$0A,$AA,$A0,$00,$1A,$05
        .BYTE $80,$00,$00,$00,$00,$00,$00,$66
        .BYTE $00,$00,$08,$08,$08,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$A0,$AA,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$1A,$AA,$AA,$20
        .BYTE $00,$00,$80,$80,$80,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$0A,$0A,$A0,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$1A,$AA,$A2,$00
        .BYTE $00,$08,$08,$08,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$A0,$AA,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$0E,$45,$55
        .BYTE $55,$95,$55,$50,$56,$55,$55,$55
        .BYTE $56,$40,$00,$00,$00,$45,$04,$04
        .BYTE $40,$00,$00,$60,$80,$00,$02,$65
        .BYTE $15,$40,$00,$00,$00,$12,$00,$00
        .BYTE $08,$08,$08,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $A0,$AA,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$1A,$AA,$20,$00,$00
        .BYTE $80,$80,$80,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$0A
        .BYTE $0A,$A0,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$01,$A2,$00,$00,$08
        .BYTE $08,$08,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$A0
        .BYTE $AA,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$0E,$65,$55,$55,$95
        .BYTE $95,$90,$56,$55,$55,$55,$56,$40
        .BYTE $00,$00,$00,$45,$04,$04,$4A,$0A
        .BYTE $A0,$60,$80,$00,$02,$65,$15,$40
        .BYTE $00,$06,$AA,$B2,$00,$00,$08,$08
        .BYTE $08,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$A0,$AA
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $1A,$AA,$AA,$20,$00,$00,$80,$80
        .BYTE $80,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$0A,$0A,$A0
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$E6,$55,$55,$59,$55,$55
        .BYTE $05,$65,$55,$55,$55,$64,$AA,$AA
        .BYTE $AA,$05,$55,$40,$44,$EA,$AA,$06
        .BYTE $09,$A6,$D8,$26,$51,$54,$00,$2A
        .BYTE $AA,$A7,$20,$00,$01,$A0,$80,$80
        .BYTE $02,$00,$00,$00,$02,$0A,$AA,$AA
        .BYTE $A0,$00,$00,$00,$0A,$AA,$A8,$01
        .BYTE $1A,$0F,$80,$00,$04,$01,$AA,$AA
        .BYTE $AA,$A6,$55,$55,$59,$5D,$5D,$05
        .BYTE $65,$55,$55,$55,$64,$AA,$AA,$AA
        .BYTE $04,$50,$40,$44,$A2,$AA,$06,$09
        .BYTE $A0,$08,$26,$51,$54,$00,$00,$00
        .BYTE $1B,$20,$00,$00,$80,$80,$80,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$0A,$0A,$A0,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $E2,$00,$00,$08,$08,$08,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$A0,$AA,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$6A
        .BYTE $65,$55,$55,$95,$15,$10,$56,$55
        .BYTE $55,$55,$56,$40,$00,$00,$00,$45
        .BYTE $04,$04,$4A,$0A,$A0,$60,$80,$00
        .BYTE $02,$65,$15,$40,$00,$00,$00,$72
        .BYTE $00,$00,$08,$08,$08,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$A0,$AA,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$0E,$20
        .BYTE $00,$00,$80,$80,$80,$00,$00,$00
        .BYTE $00,$02,$00,$00,$00,$00,$00,$00
        .BYTE $00,$0A,$8A,$A8,$01,$00,$68,$18
        .BYTE $00,$00,$01,$AA,$AA,$AA,$A6,$55
        .BYTE $55,$59,$59,$59,$05,$65,$55,$55
        .BYTE $55,$64,$00,$00,$00,$04,$50,$40
        .BYTE $44,$A0,$AA,$06,$08,$00,$00,$26
        .BYTE $51,$54,$00,$00,$00,$6B,$65,$55
        .BYTE $55,$95,$15,$10,$56,$55,$55,$55
        .BYTE $56,$40,$00,$00,$00,$45,$04,$04
        .BYTE $4A,$0A,$A0,$60,$80,$00,$02,$65
        .BYTE $15,$40,$00,$00,$00,$72,$00,$00
        .BYTE $08,$08,$08,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $A0,$AA,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$0E,$20,$00,$00
        .BYTE $80,$80,$80,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$0A
        .BYTE $0A,$A0,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$62,$00,$00,$08
        .BYTE $08,$08,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$A0
        .BYTE $AA,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$06,$20,$00,$00,$80
        .BYTE $80,$80,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$0A,$0A
        .BYTE $A0,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$01,$A2,$00,$00,$08,$08
        .BYTE $08,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$A0,$AA
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$0E,$20,$00,$00,$80,$80
        .BYTE $80,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$01,$00,$0E,$0A,$A0
        .BYTE $00,$00,$00,$00,$00,$00,$10,$06
        .BYTE $AA,$AA,$A2,$00,$00,$1C,$08,$08
        .BYTE $00,$60,$00,$00,$00,$60,$AA,$AA
        .BYTE $AA,$00,$50,$05,$40,$AA,$AA,$06
        .BYTE $09,$A6,$88,$26,$51,$14,$5A,$AA
        .BYTE $AA,$AA,$20,$00,$00,$80,$80,$80
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$0A,$0A,$A0,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $6A,$A2,$00,$00,$08,$08,$08,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$A0,$AA,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$01
        .BYTE $AA,$20,$00,$00,$80,$80,$80,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$0A,$0A,$A0,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$6A
        .BYTE $A2,$00,$00,$08,$08,$08,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$A0,$AA,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$0E
        .BYTE $20,$00,$00,$80,$80,$80,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$0A,$8A,$A0,$00,$00,$0C
        .BYTE $00,$00,$00,$00,$00,$00,$00,$E2
        .BYTE $00,$00,$08,$08,$08,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$A0,$AA,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$1A,$AA,$20
        .BYTE $00,$00,$80,$80,$80,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$0A,$0A,$A0,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$6A,$A2,$00
        .BYTE $00,$08,$08,$08,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$A0,$AA,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$01,$AA,$20,$00
        .BYTE $00,$80,$80,$80,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $0A,$0A,$A0,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$6A,$A2,$00,$00
        .BYTE $08,$08,$08,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $A0,$AA,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$0E,$20,$00,$00
        .BYTE $80,$80,$80,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$0A
        .BYTE $0A,$A0,$00,$00,$00,$00,$00,$00
        .BYTE $00,$06,$AA,$AA,$A2,$00,$00,$08
        .BYTE $08,$08,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$A0
        .BYTE $AA,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$06,$AA,$AA,$20,$00,$00,$80
        .BYTE $80,$80,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$0A,$0A
        .BYTE $A0,$00,$00,$00,$00,$00,$00,$00
        .BYTE $06,$AA,$AA,$A2,$00,$00,$08,$08
        .BYTE $08,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$A0,$AA
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$0E,$00,$00,$00,$80,$04
        .BYTE $00,$06,$00,$40,$00,$06,$00,$00
        .BYTE $00,$05,$05,$00,$00,$04,$00,$00
        .BYTE $64,$80,$00,$02,$65,$01,$40,$00
        .BYTE $00,$00,$02,$00,$00,$08,$08,$48
        .BYTE $00,$20,$00,$00,$00,$60,$00,$00
        .BYTE $00,$00,$00,$00,$00,$A0,$AA,$06
        .BYTE $08,$00,$01,$A6,$00,$00,$00,$2A
        .BYTE $AA,$AA,$45,$55,$55,$95,$55,$50
        .BYTE $56,$55,$55,$55,$56,$40,$00,$00
        .BYTE $00,$45,$04,$04,$40,$00,$00,$60
        .BYTE $80,$00,$02,$65,$15,$40,$00,$00
        .BYTE $00,$1A,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .BYTE $AA,$00,$00,$01,$80,$00,$00,$02
        .BYTE $00,$00,$00,$06,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$64,$80
        .BYTE $00,$02,$60,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$18,$00,$00,$00,$20
        .BYTE $00,$00,$00,$60,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$06,$48,$00
        .BYTE $00,$26,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$01,$80,$00,$00,$02,$00
        .BYTE $00,$00,$06,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$64,$80,$00
        .BYTE $02,$60,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$18,$00,$00,$00,$20,$00
        .BYTE $00,$00,$60,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$06,$48,$00,$00
        .BYTE $26,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$01,$80,$00,$00,$02,$00,$00
        .BYTE $00,$06,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$64,$80,$00,$02
        .BYTE $60,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$18,$00,$00,$00,$20,$00,$00
        .BYTE $00,$60,$AA,$80,$00,$00,$00,$00
        .BYTE $00,$00,$00,$06,$48,$40,$00,$26
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $01,$80,$00,$00,$02,$00,$00,$00
        .BYTE $06,$0A,$A8,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$64,$84,$00,$02,$60
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $18,$00,$00,$00,$20,$00,$00,$00
        .BYTE $60,$AA,$84,$50,$00,$00,$00,$00
        .BYTE $00,$00,$06,$48,$40,$00,$26,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$01
        .BYTE $80,$00,$00,$02,$00,$00,$00,$06
        .BYTE $0A,$A8,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$64,$84,$00,$02,$60,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$18
        .BYTE $00,$00,$00,$20,$00,$00,$00,$60
        .BYTE $AA,$80,$00,$00,$00,$00,$00,$00
        .BYTE $00,$06,$48,$40,$00,$26,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$01,$80
        .BYTE $00,$00,$02,$00,$00,$00,$06,$0A
        .BYTE $A8,$04,$00,$00,$00,$00,$00,$00
        .BYTE $00,$64,$84,$00,$02,$60,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$18,$00
        .BYTE $00,$00,$20,$00,$00,$00,$60,$AA
        .BYTE $80,$00,$00,$00,$00,$00,$00,$00
        .BYTE $06,$48,$40,$00,$26,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$01,$80,$00
        .BYTE $00,$02,$00,$00,$00,$06,$0A,$A8
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $64,$84,$00,$02,$60,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$18,$00,$00
        .BYTE $00,$20,$00,$00,$00,$60,$AA,$80
        .BYTE $00,$00,$00,$00,$00,$00,$00,$06
        .BYTE $48,$40,$00,$26,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$80,$00,$00
        .BYTE $06,$00,$00,$00,$06,$00,$00,$00
        .BYTE $00,$45,$00,$00,$00,$00,$00,$60
        .BYTE $80,$00,$02,$65,$01,$40,$00,$00
        .BYTE $00,$00,$00,$00,$08,$00,$00,$00
        .BYTE $60,$00,$00,$00,$60,$00,$00,$00
        .BYTE $00,$50,$00,$00,$00,$00,$06,$08
        .BYTE $00,$00,$26,$54,$14,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$02
        .BYTE $00,$00,$00,$02,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$02,$30,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$08,$00,$00,$00,$60
        .BYTE $00,$00,$00,$60,$00,$00,$00,$00
        .BYTE $50,$00,$00,$00,$00,$06,$08,$00
        .BYTE $00,$26,$50,$14,$00,$00,$00,$00
        .BYTE $00,$00,$00,$80,$00,$00,$06,$00
        .BYTE $00,$00,$06,$00,$00,$00,$00,$05
        .BYTE $00,$00,$00,$00,$00,$60,$80,$00
        .BYTE $02,$65,$01,$40,$00,$00,$00,$00
        .BYTE $00,$00,$08,$00,$00,$00,$60,$00
        .BYTE $00,$00,$60,$00,$00,$00,$00,$50
        .BYTE $00,$00,$00,$00,$06,$08,$00,$00
        .BYTE $26,$50,$14,$00,$00,$00,$00,$00
        .BYTE $00,$00,$80,$00,$00,$06,$00,$00
        .BYTE $00,$06,$00,$00,$00,$00,$05,$00
        .BYTE $00,$00,$00,$00,$60,$80,$00,$02
        .BYTE $65,$01,$40,$00,$00,$00,$00,$00
        .BYTE $00,$08,$00,$00,$00,$60,$00,$00
        .BYTE $00,$60,$00,$00,$00,$00,$50,$00
        .BYTE $00,$00,$00,$06,$08,$00,$00,$26
        .BYTE $50,$14,$00,$00,$00,$00,$00,$00
        .BYTE $00,$80,$00,$00,$06,$00,$00,$00
        .BYTE $06,$00,$00,$00,$00,$05,$00,$00
        .BYTE $00,$00,$00,$60,$80,$00,$02,$65
        .BYTE $01,$40,$00,$00,$00,$00,$00,$00
        .BYTE $08,$00,$00,$00,$60,$00,$00,$00
        .BYTE $60,$00,$00,$00,$00,$50,$00,$00
        .BYTE $00,$00,$06,$08,$00,$00,$26,$50
        .BYTE $14,$00,$00,$00,$00,$00,$00,$00
        .BYTE $80,$00,$00,$06,$00,$00,$00,$06
        .BYTE $00,$00,$00,$00,$05,$00,$00,$00
        .BYTE $00,$00,$60,$80,$00,$02,$65,$01
        .BYTE $40,$00,$00,$00,$00,$00,$00,$08
        .BYTE $00,$00,$00,$60,$00,$00,$00,$60
        .BYTE $00,$00,$00,$00,$50,$00,$00,$00
        .BYTE $00,$06,$08,$00,$00,$26,$50,$14
        .BYTE $00,$00,$00,$00,$45,$55,$55,$95
        .BYTE $55,$50,$56,$55,$55,$55,$56,$40
        .BYTE $00,$00,$00,$45,$04,$04,$40,$00
        .BYTE $00,$60,$80,$00,$02,$65,$15,$40
        .BYTE $00,$00,$00,$10,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$45,$55,$55,$95,$55
        .BYTE $50,$56,$55,$55,$55,$56,$40,$00
        .BYTE $00,$05,$45,$04,$05,$40,$00,$00
        .BYTE $64,$80,$00,$02,$65,$15,$40,$00
        .BYTE $00,$00,$14,$55,$55,$59,$55,$55
        .BYTE $55,$65,$55,$55,$55,$64,$00,$00
        .BYTE $00,$04,$50,$40,$44,$00,$00,$06
        .BYTE $08,$00,$00,$26,$51,$54,$00,$00
        .BYTE $00,$01,$00,$00,$01,$10,$04,$00
        .BYTE $00,$00,$00,$00,$02,$0A,$AA,$AA
        .BYTE $A0,$00,$00,$00,$00,$20,$00,$00
        .BYTE $1A,$00,$80,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$18,$00,$00,$00
        .BYTE $20,$00,$00,$00,$60,$AA,$80,$00
        .BYTE $50,$00,$00,$00,$00,$00,$06,$48
        .BYTE $40,$00,$26,$00,$00,$00,$00,$00
        .BYTE $00,$45,$55,$55,$95,$55,$50,$56
        .BYTE $55,$55,$55,$56,$40,$00,$00,$00
        .BYTE $45,$04,$04,$40,$00,$00,$60,$80
        .BYTE $00,$02,$65,$15,$40,$00,$00,$00
        .BYTE $14,$55,$55,$59,$55,$55,$05,$65
        .BYTE $55,$55,$55,$64,$00,$00,$00,$04
        .BYTE $50,$40,$44,$00,$00,$06,$08,$00
        .BYTE $00,$26,$51,$54,$00,$00,$00,$01
        .BYTE $45,$55,$55,$95,$55,$50,$56,$55
        .BYTE $55,$55,$56,$40,$00,$00,$00,$45
        .BYTE $04,$04,$40,$00,$00,$60,$80,$00
        .BYTE $02,$65,$15,$40,$00,$00,$00,$14
        .BYTE $55,$55,$59,$55,$55,$05,$65,$55
        .BYTE $55,$55,$64,$00,$00,$00,$04,$50
        .BYTE $40,$44,$00,$00,$06,$08,$00,$00
        .BYTE $26,$51,$54,$00,$00,$00,$01,$00
        .BYTE $00,$01,$00,$04,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00
        JMP j47C1

        JMP j4A68

        JMP j5F37

        JMP j49B2

        JMP j2F76

        JMP j5F37

        JMP j5F37

        JMP j49B2

        JMP j6CFA

        JMP j48AF

        JMP j49B2

        JMP j6D0A

        JMP j6D6D

        JMP j6CDA

        JMP j49B2

        JMP j5F37

        JMP j2F76

        JMP j49B2

        JMP j49DC

        JMP j6CEA

        JMP j2F76

        JMP j49B2

        JMP j488D

        JMP j6CBF

        JMP j5F37

        JMP j49B2

        JMP j493C

        JMP j6CB1

        JMP j5F37

        JMP j5F37

        JMP j5F37

        JMP j49B2

        JMP j49A2

        JMP j5F37

        JMP j5F37

        JMP j5F37

        JMP j5F37

        JMP j49B2

        JMP j4917

        JMP j5F37

        JMP j48E3

        JMP j49B2

        JMP j481C

        JMP j4851

        JMP j2F76

        JMP j2F76

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j31B1

        JMP j486D

        JMP j487D

        JMP j2F76

        JMP j6C86

        JMP j6C61

        JMP j6C9E

        JMP j2F76

        JMP j2F76

        JMP j690A

        JMP j6B4B

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j58E9

        JMP j2F76

        JMP j47CA

        JMP j2F76

        JMP j6932

        JMP j47E7

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

        JMP j2F76

s47B5   JMP s21D3

s47B8   JMP j24BD

        JMP s24CE

s47BE   JMP s58B3

j47C1   JSR s47BE
        BCS b47C9
        JSR s5C9D
b47C9   RTS 

j47CA   JSR s320F
        BCS b47D2
        JSR s58CD
b47D2   BCC b47D7
        JMP j4A0A

b47D7   JSR s31D3
        BCS b47E4
        LDA #$02
        STA a58A4
        JMP j57B2

b47E4   JMP j6946

j47E7   JSR s320F
        BCC b4800
        LDY #$02
        LDA (p49),Y
        TAX 
        INY 
        LDA (p49),Y
        TAY 
        LDA #$07
        JSR s3568
        JSR j3209
        JMP j31B1

b4800   JSR s58CD
        BCC b4819
        LDY #$02
        LDA (p49),Y
        TAX 
        INY 
        LDA (p49),Y
        TAY 
        LDA #$08
        JSR s3568
        JSR s58C7
        JMP j31B1

b4819   JMP j31B1

j481C   JSR s320F
        BCS b4824
        JSR s58CD
b4824   BCC b4837
        JSR s31BF
        BCS b4834
        JSR s3AB2
        JSR j3209
        JSR s58C7
b4834   JMP j4850

b4837   JSR s31BF
        BCS j4850
        JSR s31FB
        BCC b484D
        JSR s3241
        JSR s31F5
        JSR s31C7
        JSR j3B67
b484D   JSR s3A9B
j4850   RTS 

j4851   LDA a3B65
        BEQ b4864
        JSR s31BF
        BCS b485E
        JSR s3B18
b485E   JSR j31B1
        JMP j486C

b4864   JSR s31BF
        BCS j486C
        JSR s3AAB
j486C   RTS 

j486D   JSR s31B9
        JSR s3203
        LDA #$00
        STA a3B62
        LDA #$07
        JMP j356E

j487D   JSR s31B9
        JSR s58C1
        LDA #$00
        STA a3B62
        LDA #$08
        JMP j356E

j488D   JSR s47BE
        BCS b48A8
        LDA #$14
        JSR s47B5
        LDA #$02
        JSR s47B5
        JSR s2502
        LDA #$01
        JSR s47B8
        LDA #$02
        STA a48
b48A8   LDA #$18
        LDY #$00
        STA (p34),Y
        RTS 

j48AF   JSR s47BE
        BCS b48E2
        JSR j5F37
        JSR s5EA2
        BCC b48C3
        LDX #$26
        LDY #$26
        JSR s5604
b48C3   LDA #$58
        JSR s47B5
        JSR s5AE2
        JSR s47B5
        LDA #$01
        JSR s47B5
        LDA #$29
        JSR s47B5
        LDA #$02
        JSR s47B5
        LDA #$00
        JSR s47B5
b48E2   RTS 

j48E3   JSR s47BE
        BCS b4916
        JSR j5F37
        JSR s5EA2
        BCC b48F7
        LDX #$DF
        LDY #$DF
        JSR s5604
b48F7   LDA #$59
        JSR s47B5
        JSR s5AE2
        JSR s47B5
        LDA #$01
        JSR s47B5
        LDA #$29
        JSR s47B5
        LDA #$02
        JSR s47B5
        LDA #$00
        JSR s47B5
b4916   RTS 

j4917   JSR s47BE
        BCS b493B
        JSR j5F37
        JSR s5EA2
        BCC b492B
        LDX #$3F
        LDY #$00
        JSR s5604
b492B   LDA #$62
        JSR s47B5
        JSR s5AE2
        JSR s47B5
        LDA #$01
        JSR s47B5
b493B   RTS 

j493C   JSR s6952
        BCC b495A
        JSR s5AC5
        STA a8779
        LDA #$78
        JSR s47B5
        LDX #$78
        LDY #$87
        INX 
        BNE b4954
        INY 
b4954   JSR s220D
        JMP s694C

b495A   JSR s47BE
        BCS b49A1
        LDA a18
        BEQ b49A1
        DEC a18
        JSR j5F37
        JSR s56B2
        JSR s5723
        LDA #$7B
        JSR s47B5
        TXA 
        JSR s47B5
        TYA 
        JSR s47B5
        JSR s56BD
        JSR s5704
        LDA #$63
        JSR s47B5
        JSR s5A7A
        JSR s47B5
        LDA #$02
        JSR s47B5
        LDA #$57
        JSR s47B5
        JSR s5A7A
        JSR s47B5
        LDA #$01
        JSR s47B5
b49A1   RTS 

j49A2   JSR s47BE
        BCS b49AF
        LDA #$65
        JSR s47B5
        JMP j49CF

b49AF   JMP j6133

j49B2   JSR s47BE
        BCS b49DB
        LDA #$77
        JSR s47B5
        LDA #$65
        JSR s47B5
        JSR s56B2
        JSR s5704
        JSR s5704
        JSR j5F37
        INC a18
j49CF   LDA a6C5A
        BEQ b49D8
        LDA #$01
        STA aFC
b49D8   INC a6C5A
b49DB   RTS 

j49DC   JSR s31FB
        BCS b4A09
        JSR s31BF
        BCS b4A09
        DEC a18
        JSR s68EB
        BCS b4A03
        JSR s56B2
        JSR s5723
        LDA #$29
        JSR s47B5
        TXA 
        JSR s47B5
        TYA 
        JSR s47B5
        JMP b4A09

b4A03   JSR j5F37
        JSR s56B2
b4A09   RTS 

j4A0A   LDA #$01
        STA a3B62
        LDA a44
        STA a3B63
        LDA a45
        STA a3B64
        JSR s3A97
        LDY #$00
        STA (p3A),Y
        LDA #$02
        INY 
        STA (p3A),Y
        LDX #$07
        LDY #$09
b4A29   LDA a8678,X
        STA (p3A),Y
        DEY 
        DEX 
        BPL b4A29
        LDY #$0A
        LDA a44
        STA (p3A),Y
        INY 
        LDA a45
        STA (p3A),Y
        CLC 
        LDA a3A
        ADC #$0C
        STA a3A
        BCC b4A48
        INC a3B
b4A48   LDY #$00
        LDA #$06
        STA (p44),Y
        INY 
        LDA a26DA
        STA (p44),Y
        INY 
        LDA #$00
        STA (p44),Y
        INY 
        STA (p44),Y
        INY 
        CLC 
        TYA 
        ADC a44
        STA a44
        BCC b4A67
        INC a45
b4A67   RTS 

j4A68   LDA a34
        CMP #$CD
        BNE b4A72
        LDA a35
        CMP #$7B
b4A72   BEQ b4A75
        RTS 

b4A75   JSR e1803
        BCC b4A7D
        JMP j20F8

b4A7D   LDX a20F7
        TXS 
        JMP j201B

        RTS 

j4A85   LDX #$00
        STX a4BB7
        CMP #$30
        BNE b4AA7
        JSR j3BAA
        JSR s3C79
        CMP #$58
        BNE b4A9D
        LDA #$01
        JMP j4AA2

b4A9D   JSR j3C53
        LDA #$02
j4AA2   LDX #$00
        JMP j4AAE

b4AA7   STA a8678
        LDA #$00
        LDX #$01
j4AAE   STA a4BB6
j4AB1   STX a31
        JSR j3BAA
        JSR s3C79
        CMP #$2E
        BNE b4AD0
        LDX a4BB6
        CPX #$03
        BEQ b4B11
        CPX #$01
        BEQ b4B11
        LDX #$03
        STX a4BB6
        JMP j4B08

b4AD0   CMP #$30
        BCC b4B11
        CMP #$3A
        BCC j4B08
        CMP #$45
        BNE b4AE5
        LDX a4BB6
        DEX 
        BEQ b4AE5
        JMP j4B72

b4AE5   CMP #$4C
        BNE b4AF9
        LDX a4BB6
        CPX #$03
        BEQ b4AF6
        INC a4BB7
        JSR j3BAA
b4AF6   JMP b4B11

b4AF9   CMP #$41
        BCC b4B11
        CMP #$47
        BCS b4B11
        LDX a4BB6
        CPX #$01
        BNE b4B11
j4B08   LDX a31
        STA a8678,X
        INX 
        JMP j4AB1

b4B11   JSR j3C53
        LDX a31
        LDA #$00
        STA a8678,X
        LDA a4BB6
        CMP #$03
        BNE b4B28
        JSR s4E00
        LDA #$51
        RTS 

b4B28   CMP #$00
        BNE b4B32
        JSR s4CD3
        JMP j4B3F

b4B32   CMP #$01
        BNE b4B3C
        JSR s4D29
        JMP j4B3F

b4B3C   JSR s4D79
j4B3F   LDX a867A
        BNE b4B47
        LDX a867B
b4B47   BEQ b4B50
        LDX #$53
        LDY #$4B
        JSR j562D
b4B50   LDA #$4F
        RTS 

        .TEXT " *** INTEGER CONSTANT TOO BIG", $0D, $00
j4B72   LDX #$03
        STX a4BB6
        LDX a31
        STA a8678,X
        INX 
        STX a31
        JSR j3BAA
        LDX a31
        CMP #$2B
        BNE b4B8F
        STA a8678,X
        INX 
        JMP j4B9D

b4B8F   CMP #$2D
        BNE b4B9A
        STA a8678,X
        INX 
        JMP j4B9D

b4B9A   JSR j3C53
j4B9D   STX a31
        JSR j3BAA
        CMP #$30
        BCC b4BB3
        CMP #$3A
        BCS b4BB3
        LDX a31
        STA a8678,X
        INX 
        JMP j4B9D

b4BB3   JMP b4B11

a4BB6   .BYTE $00
a4BB7   .BYTE $00
j4BB8   LDX #$00
b4BBA   STX a31
        LDA #$22
        JMP j4C25

j4BC1   CMP #$00
        BEQ b4BCF
        LDX a31
        STA a8678,X
        INX 
        BEQ b4BDA
        BNE b4BBA
b4BCF   LDX a31
        STA a8678,X
        JSR j3BAA
        LDA #$52
        RTS 

b4BDA   TXA 
        DEX 
        STA a8678,X
        LDX #$F4
        LDY #$4B
        JSR j562D
b4BE6   JSR j3BAA
        CMP #$00
        BEQ b4BF1
        CMP #$22
        BNE b4BE6
b4BF1   LDA #$52
        RTS 

        .TEXT " *** STRING TOO LONG", $0D, $00
j4C0A   LDA #$00
        STA a8679
        LDA #$27
        JMP j4C25

j4C14   STA a8678
b4C17   JSR j3BAA
        CMP #$00
        BEQ b4C22
        CMP #$27
        BNE b4C17
b4C22   LDA #$4F
        RTS 

j4C25   STA a4CD1
b4C28   JSR j3BAA
        CMP a4CD1
        BNE b4C38
        JSR j3C53
        LDA #$00
        JMP j4CC4

b4C38   CMP #$5C
        BEQ b4C3F
        JMP j4CC4

b4C3F   JSR j3BAA
        CMP #$0D
        BEQ b4C28
        JSR s3C79
        CMP #$4E
        BNE b4C52
        LDA #$0D
        JMP j4CC4

b4C52   CMP #$52
        BNE b4C5B
        LDA #$0D
        JMP j4CC4

b4C5B   CMP #$30
        BCC j4CC4
        CMP #$38
        BCS j4CC4
        SEC 
        SBC #$30
        STA a4CD2
        JSR j3BAA
        CMP #$30
        BCC b4CBE
        CMP #$38
        BCS b4CB5
        SEC 
        SBC #$30
        ASL a4CD2
        ASL a4CD2
        ASL a4CD2
        ORA a4CD2
        STA a4CD2
        JSR j3BAA
        CMP #$30
        BCC b4CAC
        CMP #$38
        BCS b4CA3
        SEC 
        SBC #$30
        ASL a4CD2
        ASL a4CD2
        ASL a4CD2
        ORA a4CD2
        JMP j4CA9

b4CA3   JSR j3C53
        LDA a4CD2
j4CA9   JMP j4CB2

b4CAC   JSR j3C53
        LDA a4CD2
j4CB2   JMP j4CBB

b4CB5   JSR j3C53
        LDA a4CD2
j4CBB   JMP j4CC4

b4CBE   JSR j3C53
        LDA a4CD2
j4CC4   LDX a4CD1
        CPX #$22
        BNE b4CCE
        JMP j4BC1

b4CCE   JMP j4C14

a4CD1   .BYTE $00
a4CD2   .BYTE $00
s4CD3   LDA #$00
        STA a4E36
        STA a4E37
        STA a4E38
        STA a4E39
        STA a4E3F
j4CE4   LDX a4E3F
        LDA a8678,X
        BEQ b4D10
        PHA 
        JSR s4DBF
        PLA 
        SEC 
        SBC #$30
        CLC 
        ADC a4E36
        STA a4E36
        BCC b4D0A
        INC a4E37
        BNE b4D0A
        INC a4E38
        BNE b4D0A
        INC a4E39
b4D0A   INC a4E3F
        JMP j4CE4

b4D10   LDA a4E36
        STA a8678
        LDA a4E37
        STA a8679
        LDA a4E38
        STA a867A
        LDA a4E39
        STA a867B
        RTS 

s4D29   LDA #$00
        STA a4E36
        STA a4E37
        STA a4E38
        STA a4E39
        STA a4E3F
j4D3A   LDX a4E3F
        LDA a8678,X
        BEQ b4D60
        PHA 
        JSR s4DEA
        PLA 
        CMP #$41
        BCC b4D51
        SEC 
        SBC #$37
        JMP j4D54

b4D51   SEC 
        SBC #$30
j4D54   ORA a4E36
        STA a4E36
        INC a4E3F
        JMP j4D3A

b4D60   LDA a4E36
        STA a8678
        LDA a4E37
        STA a8679
        LDA a4E38
        STA a867A
        LDA a4E39
        STA a867B
        RTS 

s4D79   LDA #$00
        STA a4E36
        STA a4E37
        STA a4E38
        STA a4E39
        STA a4E3F
j4D8A   LDX a4E3F
        LDA a8678,X
        BEQ b4DA6
        PHA 
        JSR s4DED
        PLA 
        SEC 
        SBC #$30
        ORA a4E36
        STA a4E36
        INC a4E3F
        JMP j4D8A

b4DA6   LDA a4E36
        STA a8678
        LDA a4E37
        STA a8679
        LDA a4E38
        STA a867A
        LDA a4E39
        STA a867B
        RTS 

s4DBF   LDX #$00
b4DC1   LDA a4E36,X
        STA f4E3A,X
        INX 
        CPX #$04
        BNE b4DC1
        JSR s4DF3
        JSR s4DF3
        CLC 
        PHP 
        LDX #$00
b4DD6   PLP 
        LDA a4E36,X
        ADC f4E3A,X
        STA a4E36,X
        PHP 
        INX 
        CPX #$04
        BNE b4DD6
        PLP 
        JMP s4DF3

s4DEA   JSR s4DF3
s4DED   JSR s4DF3
        JSR s4DF3
s4DF3   ASL a4E36
        ROL a4E37
        ROL a4E38
        ROL a4E39
        RTS 

s4E00   LDX #$04
b4E02   LDA f26,X
        STA f4E3A,X
        DEX 
        BPL b4E02
        LDA a01
        ORA #$07
        STA a01
        LDA #<a8678
        STA a7A
        LDA #>a8678
        STA a7B
        JSR e0079
        JSR eBCF3
        LDX #$78
        LDY #$86
        JSR eBBD4
        LDA a01
        AND #$F8
        STA a01
        LDX #$04
b4E2D   LDA f4E3A,X
        STA f26,X
        DEX 
        BPL b4E2D
        RTS 

a4E36   .BYTE $00
a4E37   .BYTE $00
a4E38   .BYTE $00
a4E39   .BYTE $00
f4E3A   .BYTE $00,$00,$00,$00,$00
a4E3F   .BYTE $00
a4E40   .BYTE $00
a4E41   .BYTE $00
s4E42   JMP s21D3

j4E45   JSR s31BF
        BCS s4E4B
        RTS 

s4E4B   JSR s6F52
        LDA a26DA
        CMP #$01
        BNE b4E66
        LDX a26D9
        CPX #$07
        BNE b4E66
        LDX a26DD
        BNE b4E66
        LDA #$04
        STA a26DA
b4E66   JSR s50C2
        LDA a26D9
j4E6C   LDY #$00
        STA (p44),Y
        INY 
        CMP #$01
        BNE b4E97
        LDA a26DE
        STA (p44),Y
        INY 
        LDA a26DF
        STA (p44),Y
        INY 
        CLC 
        LDA a26E3
        ADC a26DE
        STA a26DE
        LDA a26E4
        ADC a26DF
        STA a26DF
        JMP j501F

b4E97   CMP #$02
        BNE b4EFA
        JSR s692A
        BCS b4EB6
        LDA a26DD
        BNE b4EAF
        LDA a26DA
        CMP #$07
        BCS b4ED8
        JMP b4EB6

b4EAF   LDA a864D
        CMP #$0B
        BEQ b4ED8
b4EB6   LDA a26E0
        STA (p44),Y
        INY 
        LDA a26E1
        STA (p44),Y
        INY 
        CLC 
        LDA a26E3
        ADC a26E0
        STA a26E0
        LDA a26E4
        ADC a26E1
        STA a26E1
        JMP j501F

b4ED8   LDA #$01
        JSR s4E42
        LDX a16
        LDY a17
        JSR s220D
        LDA a26E3
        JSR s4E42
        LDA a26E4
        JSR s4E42
        LDY #$00
        LDA #$09
        STA (p44),Y
        INY 
        JMP j501F

b4EFA   CMP #$03
        BEQ b4F01
        JMP j4F8D

b4F01   LDA a26DD
        BEQ b4F12
        LDA a864D
        CMP #$0A
        BNE b4F12
        LDA #$04
        JMP j4E6C

b4F12   JSR s692A
        BCS b4F2D
        LDA a26DD
        BNE b4F26
        LDA a26DA
        CMP #$07
        BCS b4F6B
        JMP b4F2D

b4F26   LDA a864D
        CMP #$0B
        BEQ b4F6B
b4F2D   TYA 
        PHA 
        LDA #$03
        JSR s4E42
        LDX a16
        LDY a17
        JSR s220D
        LDA a26E0
        JSR s4E42
        LDA a26E1
        JSR s4E42
        PLA 
        TAY 
        LDA a26E0
        STA (p44),Y
        INY 
        LDA a26E1
        STA (p44),Y
        INY 
        CLC 
        LDA a26E3
        ADC a26E0
        STA a26E0
        LDA a26E4
        ADC a26E1
        STA a26E1
        JMP j501F

b4F6B   LDA #$02
        JSR s4E42
        LDX a16
        LDY a17
        JSR s220D
        LDA a26E3
        JSR s4E42
        LDA a26E4
        JSR s4E42
        LDY #$00
        LDA #$0A
        STA (p44),Y
        INY 
        JMP j501F

j4F8D   CMP #$05
        BNE b4FCC
        LDA a26DD
        BEQ b4FA5
        LDA a864D
        CMP #$09
        BEQ b4FA2
b4F9D   LDA #$01
        JMP j4E6C

b4FA2   JMP j4FB4

b4FA5   LDA a26DA
        CMP #$01
        BEQ j4FB4
        CMP #$02
        BEQ j4FB4
        CMP #$04
        BNE b4F9D
j4FB4   LDA a26E2
        STA (p44),Y
        INY 
        LDA #$00
        STA (p44),Y
        INY 
        CLC 
        LDA a26E3
        ADC a26E2
        STA a26E2
        JMP j501F

b4FCC   CMP #$07
        BNE b4FDF
        LDA a26E3
        STA (p44),Y
        INY 
        LDA a26E4
        STA (p44),Y
        INY 
        JMP j501F

b4FDF   CMP #$08
        BNE b4FFF
        CLC 
        LDA a26DB
        STA (p44),Y
        INY 
        ADC a26E3
        STA a26DB
        LDA a26DC
        STA (p44),Y
        INY 
        ADC a26E4
        STA a26DC
        JMP j501F

b4FFF   CMP #$0F
        BNE j501F
        LDA a26E4
        CMP a26DC
        BNE b5011
        LDA a26E3
        CMP a26DB
b5011   BCC j501F
        LDA a26E3
        STA a26DB
        LDA a26E4
        STA a26DC
j501F   LDX #$00
j5021   CPX a26DD
        BEQ b5030
        LDA a864D,X
        STA (p44),Y
        INY 
        INX 
        JMP j5021

b5030   LDA a26DA
        CMP #$01
        BNE b504B
        LDX a26DD
        BEQ b504B
        DEX 
        LDA a864D,X
        CMP #$0A
        BNE b5049
        LDA #$04
        JMP b504B

b5049   LDA #$01
b504B   STA (p44),Y
        INY 
        CMP #$07
        BCC b505E
        LDA a26E5
        STA (p44),Y
        INY 
        LDA a26E6
        STA (p44),Y
        INY 
b505E   CLC 
        TYA 
        ADC a44
        STA a44
        BCC b5075
        INC a45
        LDA a45
        CMP #$E0
        BNE b5075
        LDX #$A9
        LDY #$50
        JMP j20F8

b5075   LDA a3B65
        BEQ b5080
        JSR s7636
        JMP j5089

b5080   STA a7737
        STA a7738
        JSR s6924
j5089   LDX #$00
        LDY a4E40
b508E   CPY a4E41
        BEQ b509D
        LDA a864D,Y
        STA a864D,X
        INX 
        INY 
        BNE b508E
b509D   STX a26DD
        STX a4E41
        LDX #$00
        STX a4E40
        RTS 

        .TEXT " *** TOO MANY VARIABLES", $0D, $00
s50C2   JSR s692A
        BCC b50E0
        LDA a26DD
        BEQ b50E0
        LDA a864D
        CMP #$0B
        BNE b50E0
        LDA a864E
        BNE b50E0
        LDA a864F
        BNE b50E0
        JMP j5197

b50E0   LDX #$00
s50E2   LDA #$00
        STA a26E3
        STA a26E4
        CPX a26DD
        BEQ b50F2
        JMP j512C

b50F2   LDA a26DA
        CMP #$01
        BNE b50FF
        LDA #$01
        STA a26E3
        RTS 

b50FF   CMP #$02
        BEQ b5105
        CMP #$04
b5105   BNE b510D
        LDA #$02
        STA a26E3
        RTS 

b510D   CMP #$03
        BNE b5117
        LDA #$04
        STA a26E3
        RTS 

b5117   CMP #$05
        BNE b511F
        STA a26E3
        RTS 

b511F   LDA a26E5
        STA a26E3
        LDA a26E6
        STA a26E4
        RTS 

j512C   LDA a864D,X
        INX 
        CMP #$09
        BNE b513A
        LDA #$02
        STA a26E3
        RTS 

b513A   CMP #$0A
        BNE b513F
        RTS 

b513F   CMP #$0B
        BNE b5196
        LDA a26D9
        CMP #$07
        BNE b5150
        LDA #$02
        STA a26E3
        RTS 

b5150   LDA a864D,X
        INX 
        CMP #$00
        BNE b5167
        LDA a864D,X
        INX 
        CMP #$00
        BNE b5166
        LDA #$02
        STA a26E3
        RTS 

b5166   DEX 
b5167   JSR j24BD
        LDA a864D,X
        INX 
        JSR j24BD
        JSR s50E2
        JSR s24CE
        PHA 
        JSR s24CE
        TAX 
        PLA 
        TAY 
        JSR s24ED
        LDX a26E3
        LDY a26E4
        JSR s24ED
        JSR s2540
        JSR s2502
        STX a26E3
        STY a26E4
b5196   RTS 

j5197   SEC 
        LDA a28
        SBC a26E0
        PHA 
        TAX 
        LDA a29
        SBC a26E1
        PHA 
        TAY 
        JSR s24ED
        LDX #$03
        JSR s50E2
        LDX a26E3
        LDY a26E4
        JSR s24ED
        JSR s25C5
        JSR s2502
        STX a864E
        STY a864F
        PLA 
        STA a26E4
        PLA 
        STA a26E3
        RTS 

j51CC   TAX 
        INX 
        BNE b51F0
        JSR s31FB
        BCC b51DA
        LDA #$57
        JMP j51EA

b51DA   LDA a36
        CMP #$2B
        BNE b51E5
        LDA #$57
        JMP j51EA

b51E5   JSR j3465
        LDA #$60
j51EA   LDY #$00
        STA (p34),Y
        CLC 
        RTS 

b51F0   INX 
        BNE b5208
        JSR s31E7
        BCC b5200
        JSR s69B2
        LDA #$6B
        JMP j5202

b5200   LDA #$66
j5202   LDY #$00
        STA (p34),Y
        CLC 
        RTS 

b5208   INX 
        BNE b5223
        JSR s31E7
        BCC b5218
        JSR s698E
        LDA #$6B
        JMP j521D

b5218   JSR j5B0E
        LDA #$66
j521D   LDY #$00
        STA (p34),Y
        CLC 
        RTS 

b5223   JSR s31BF
        BCC b5236
        LDA a36
        CMP #$0D
        BEQ b5236
        JSR j7755
        LDA #$63
        JMP j5238

b5236   LDA #$73
j5238   LDY #$00
        STA (p34),Y
        CLC 
        RTS 

s523E   LDA s58B3
        STA a2B
        LDA j5649
        STA a2C
        LDA s24CE
        STA a2D
        LDA j24BD
        STA a2E
        LDA j562D
        STA a2F
        LDA s56B2
        STA a30
        LDA s5704
        STA a31
        LDA s21D3
        STA a32
        LDA s5723
        STA a33
        LDA #<pB800
        STA a1A
        LDA #>pB800
        STA a1B
        LDA #<pAC00
        STA a1C
        LDA #>pAC00
        STA a1D
        LDX #$02
        STX a5603
        DEX 
        STX a59EA
        DEX 
        STX a59EB
        LDA #$01
        STA a26D7
        STA a48
        LDA #$02
        STA a26D8
        LDA #<pD800
        STA a44
        LDA #>pD800
        STA a45
        LDA #<p7C59
        STA a46
        LDA #>p7C59
        STA a47
        LDA #$00
        STA a26E0
        STA a26E1
        STA a3B65
        STA a7737
        STA a7738
        LDA #<pAC00
        STA a6218
        LDA #>pAC00
        STA a6219
        LDA #$00
        STA a3E
        STA a40
        LDA #$B0
        STA a3F
        STA a41
        LDA #$00
        STA f3C30
        LDA #<pD000
        STA a3A
        LDA #>pD000
        STA a3B
        CLC 
        LDA #$00
        ADC #$03
        STA a14
        LDA #$E0
        STA a15
        BCC b52E7
        INC a15
b52E7   LDA #$00
        STA a18
        STA a6C5A
        STA aFC
        JSR s5A6A
        JMP j3B67

s52F6   JMP j3BAA

s52F9   JMP j3C53

j52FC   LDX #$03
        LDY #$53
        JMP j20F8

        .TEXT " *"
        .TEXT "** SYNTAX ERROR", $0D, $00
b5316   JSR s52F6
        CMP #$20
        BEQ b5316
        CMP #$A0
        BEQ b5316
        RTS 

s5322   STX a2B
        STY a2C
        JSR s5347
        BCS b532D
        SEC 
        RTS 

b532D   LDY #$00
b532F   STA (p2B),Y
        INY 
        JSR s52F6
        JSR s5363
        BCS b532F
        JSR s52F9
        LDA #$00
        STA (p2B),Y
        LDY #$08
        STA (p2B),Y
        CLC 
        RTS 

s5347   CMP #$A4
        BNE b534D
        SEC 
        RTS 

b534D   CMP #$41
        BCC b5357
        CMP #$5B
        BCS b5357
        SEC 
        RTS 

b5357   CMP #$C1
        BCC b5361
        CMP #$DB
        BCS b5361
        SEC 
        RTS 

b5361   CLC 
        RTS 

s5363   JSR s5347
        BCC b5369
        RTS 

b5369   CMP #$30
        BCC b5373
        CMP #$3A
        BCS b5373
        SEC 
        RTS 

b5373   CLC 
        RTS 

s5375   JSR b5316
        LDX #$00
        LDY #$B4
        JSR s5322
        BCC b5384
        JMP j52FC

b5384   LDA #<p53E8
        STA a32
        LDA #>p53E8
        STA a33
        LDA #$00
        STA a5430
b5391   LDX #$07
        JSR s3A84
        BEQ b53AD
        CLC 
        LDA a32
        ADC #$08
        STA a32
        BCC b53A3
        INC a33
b53A3   INC a5430
        LDA a5430
        CMP #$09
        BNE b5391
b53AD   LDX a5430
        BNE b53B5
        JMP j558F

b53B5   DEX 
        BNE b53BB
        JMP j5433

b53BB   DEX 
        BNE b53C1
        JMP j59F6

b53C1   DEX 
        BNE b53C7
        JMP j5902

b53C7   DEX 
        BNE b53CD
        JMP j5991

b53CD   DEX 
        BNE b53D3
        JMP j59A5

b53D3   DEX 
        BNE b53D9
        JMP j59C8

b53D9   DEX 
        BNE b53DF
        JMP j59DD

b53DF   DEX 
        BNE b53E5
        JMP j5A09

b53E5   JMP j52FC

p53E8   .TEXT "INCLUDE", $00, "DEFINE", $00, $00, "UNDEF", $00, $00, $00, "IF", $00, $00, $00, $00, $00, $00, "IFDEF", $00, $00, $00
        .TEXT "IFNDEF", $00, $00, "ELSE", $00, $00, $00, $00, "ENDIF", $00, $00, $00, "LINE", $00, $00, $00, $00
a5430   .TEXT $00
a5431   .TEXT $00
a5432   .BYTE $00
j5433   LDA a59EA
        BNE b543B
        JMP j5A09

b543B   LDA a1A
        CMP #$DC
        BNE b544E
        LDA a1B
        CMP #$BD
        BNE b544E
        LDX #$78
        LDY #$55
        JMP j20F8

b544E   JSR b5316
        LDX a1A
        LDY a1B
        JSR s5322
        BCC b545D
        JMP j52FC

b545D   LDA #$00
        STA a5431
        STA a5432
        JSR s52F6
        CMP #$28
        BNE b54A5
        INC a5431
        LDA #<pBDDC
        STA a2B
        LDA #>pBDDC
        STA a2C
j5477   JSR b5316
        CMP #$29
        BEQ b54A2
        CMP #$2C
        BNE b5485
        JSR b5316
b5485   LDX a2B
        LDY a2C
        JSR s5322
        BCC b5491
        JMP j52FC

b5491   INC a5432
        CLC 
        LDA a2B
        ADC #$08
        STA a2B
        BCC b549F
        INC a2C
b549F   JMP j5477

b54A2   JMP j54A8

b54A5   JSR s52F9
j54A8   LDA a5431
        STA aB400
        JSR b5316
        JSR s52F9
        LDX #$01
b54B6   JSR s52F6
        CMP #$5C
        BNE b54C9
        JSR s52F6
        CMP #$0D
        BEQ b54B6
        JSR s52F9
        LDA #$5C
b54C9   LDY a5431
        BEQ b5527
        JSR s5347
        BCC b5527
        TAY 
        TXA 
        PHA 
        CLC 
        ADC #$00
        TAX 
        TYA 
        LDY #$B4
        BCC b54E0
        INY 
b54E0   JSR s5322
        LDA #$00
        STA a5430
        LDA #<pBDDC
        STA a32
        LDA #>pBDDC
        STA a33
j54F0   LDA a5430
        CMP a5432
        BEQ b551C
        INC a5430
        LDX #$08
        JSR s3A84
        BNE b550E
        PLA 
        TAX 
        LDA a5430
        STA aB400,X
        INX 
        JMP b54B6

b550E   CLC 
        LDA a32
        ADC #$08
        STA a32
        BCC b5519
        INC a33
b5519   JMP j54F0

b551C   PLA 
        TAX 
b551E   INX 
        LDA aB400,X
        BNE b551E
        JMP b54B6

b5527   STA aB400,X
        INX 
        CMP #$0D
        BEQ b5532
        JMP b54B6

b5532   STX a5430
        SEC 
        LDA a1C
        SBC a5430
        STA a1C
        BCS b5541
        DEC a1D
b5541   LDA a1D
        CMP #$8E
        BNE b554B
        LDA a1C
        CMP #$B3
b554B   BCS b5554
        LDX #$78
        LDY #$55
        JMP j20F8

b5554   LDY #$00
b5556   LDA aB400,Y
        STA (p1C),Y
        INY 
        CPY a5430
        BNE b5556
        LDY #$08
        LDA a1C
        STA (p1A),Y
        INY 
        LDA a1D
        STA (p1A),Y
        CLC 
        LDA a1A
        ADC #$0A
        STA a1A
        BCC b5577
        INC a1B
b5577   RTS 

        .TEXT " *** TOO MANY DEFINES", $0D, $00
j558F   LDA a59EA
        BNE b5597
        JMP j5A09

b5597   JSR s52F6
        CMP #$0D
        BNE b55A1
        JMP j52FC

b55A1   CMP #$22
        BEQ b55A7
        CMP #$3C
b55A7   BNE j558F
        CLC 
        LDA a17FD
        ADC #$30
        STA aB400
        LDA #$3A
        STA aB401
        LDX #$02
j55B9   JSR s52F6
        CMP #$0D
        BNE b55C3
        JMP j52FC

b55C3   CMP #$22
        BEQ b55C9
        CMP #$3E
b55C9   BEQ b55D2
        STA aB400,X
        INX 
        JMP j55B9

b55D2   TXA 
        PHA 
b55D4   JSR s52F6
        CMP #$0D
        BNE b55D4
        PLA 
        LDX #$00
        LDY #$B4
        JSR s21C7
        INC a5603
        LDA a5603
        LDX a2051
        TAY 
        JSR s21BE
        JSR s2176
        BCC b55F8
        JMP j20F8

b55F8   LDX a5603
        DEX 
        DEX 
        LDA #$00
        STA f3C30,X
        RTS 

a5603   .BYTE $00
s5604   STX a56AB
        STY a56AC
        DEY 
        BPL b561F
        LDA #<p0D27
        STA a56AC
        LDA #>p0D27
        STA a56AD
        LDA #$00
        STA a56AE
        JMP j5629

b561F   LDA #<p0D27
        STA a56AD
        LDA #>p0D27
        STA a56AE
j5629   LDX #$96
        LDY #$56
j562D   LDA #$01
        STA aFE
        LDA #$0D
        JSR s2152
        JSR s2068
        JSR s2164
b563C   JSR s216D
        CMP #$00
        BEQ b563C
        LDX #$02
        JSR s2137
        RTS 

j5649   LDX #$57
        LDY #$56
        JMP j562D

s5650   LDX #$79
        LDY #$56
        JMP j562D

        .TEXT " *** ILLEGAL CONSTANT EXPRESSION", $0D, $00, " *** I"
        .TEXT "LLEGAL INITIALIZATION", $0D, $00, " *** ILLEGAL USE "
        .TEXT "OF '"
a56AB   .TEXT $00
a56AC   .BYTE $00
a56AD   .BYTE $00
a56AE   .BYTE $00,$00
a56B0   .BYTE $00
a56B1   .BYTE $00
s56B2   LDX #$AA
        LDY #$87
        JSR s56C8
        STA a56B0
        RTS 

s56BD   LDX #$C8
        LDY #$87
        JSR s56C8
        STA a56B1
        RTS 

s56C8   STX a2B
        STY a2C
        LDY #$00
        JSR s24CE
        STA (p2B),Y
        INY 
j56D4   JSR s24CE
        STA (p2B),Y
        INY 
        CMP #$09
        BCC b56F1
        CMP #$0B
        BNE b56EE
        JSR s24CE
        STA (p2B),Y
        INY 
        JSR s24CE
        STA (p2B),Y
        INY 
b56EE   JMP j56D4

b56F1   CMP #$07
        BCC b5701
        JSR s24CE
        STA (p2B),Y
        INY 
        JSR s24CE
        STA (p2B),Y
        INY 
b5701   DEY 
        TYA 
        RTS 

s5704   LDX #$AA
        LDY #$87
        LDA a56B0
        JMP j5715

s570E   LDX #$C8
        LDY #$87
        LDA a56B1
j5715   STX a2B
        STY a2C
        TAY 
b571A   LDA (p2B),Y
        JSR j24BD
        DEY 
        BPL b571A
        RTS 

s5723   LDX #$AA
        LDY #$87
        JMP j572E

        LDX #<p87C8
        LDY #>p87C8
j572E   STX a2B
        STY a2C
        LDA #$01
        STA a57B1
s5737   LDY a57B1
        INC a57B1
        LDA (p2B),Y
        CMP #$01
        BNE b5748
        LDX #$01
        LDY #$00
        RTS 

b5748   CMP #$02
        BEQ b5756
        CMP #$04
        BEQ b5756
        CMP #$09
        BEQ b5756
        CMP #$0A
b5756   BNE b575D
        LDX #$02
        LDY #$00
        RTS 

b575D   CMP #$03
        BNE b5766
        LDX #$00
        LDY #$00
        RTS 

b5766   CMP #$05
        BNE b576F
        LDX #$05
        LDY #$00
        RTS 

b576F   CMP #$07
        BEQ b5775
        CMP #$08
b5775   BNE b578A
        LDY a57B1
        INC a57B1
        LDA (p2B),Y
        TAX 
        LDY a57B1
        INC a57B1
        LDA (p2B),Y
        TAY 
        RTS 

b578A   CMP #$0B
        BNE b57B0
        LDY a57B1
        INC a57B1
        LDA (p2B),Y
        TAX 
        LDY a57B1
        INC a57B1
        LDA (p2B),Y
        TAY 
        JSR s24ED
        JSR s5737
        JSR s24ED
        JSR s2540
        JSR s2502
        RTS 

b57B0   RTS 

a57B1   .BYTE $00
j57B2   LDA a26D9
        CMP #$02
        BNE b57BE
        LDA #$67
        JMP j57C0

b57BE   LDA #$68
j57C0   JSR s21D3
        LDX #$78
        LDY #$87
        JSR s220D
        LDA #$69
        JSR s21D3
        LDA a14
        STA a58A5
        LDA a15
        STA a58A6
        LDA #$00
        JSR s21D3
        LDA #$00
        JSR s21D3
        LDA #$00
        JSR s21D3
        LDA #$04
        JSR s5AE2
        JSR s31EF
        JSR j3B67
        JSR s3A9B
        LDA a3A
        STA a42
        LDA a3B
        STA a43
        LDA #$00
        STA a26DE
        STA a26DF
        STA a26E2
        RTS 

j580A   LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$01
        JSR s21D3
        LDA a58A5
        STA a2B
        LDA a58A6
        STA a2C
        LDY #$00
        LDA a26E2
        STA (p2B),Y
        INY 
        LDA a26DE
        STA (p2B),Y
        INY 
        LDA a26DF
        STA (p2B),Y
        LDA #$6A
        JSR s21D3
        LDA a26E2
        JSR s21D3
        LDA a26DE
        JSR s21D3
        LDA a26DF
        JSR s21D3
        LDA a42
        STA a3A
        LDA a43
        STA a3B
        JSR s31CD
        JSR s3AAB
        JSR j3B67
        RTS 

j5860   DEC a18
        JSR j5F37
        JSR s56B2
        LDA a87AB
        CMP a58A4
        BEQ b5887
        LDA #$15
        JSR s21D3
        LDA a87AB
        JSR s21D3
        LDA a58A4
        JSR s21D3
        LDA a58A4
        STA a87AB
b5887   LDA #$70
        JSR s21D3
        JSR s5723
        TXA 
        JSR s21D3
j5893   LDA #$63
        JSR s21D3
        JSR s5AC5
        JSR s21D3
        LDA #$01
        JSR s21D3
        RTS 

a58A4   .BYTE $00
a58A5   .BYTE $00
a58A6   .BYTE $00
j58A7   LDA #$00
        STA a58FF
        STA a5900
        STA a5901
        RTS 

s58B3   JSR s31BF
        BCS b58C0
        JSR s6916
        BCS b58C0
        JSR s58E1
b58C0   RTS 

s58C1   LDA #$01
        STA a58FF
        RTS 

s58C7   LDA #$00
        STA a58FF
        RTS 

s58CD   CLC 
        LDA a58FF
        BEQ b58D4
        SEC 
b58D4   RTS 

j58D5   LDA #$01
        STA a5900
        RTS 

s58DB   LDA #$00
        STA a5900
        RTS 

s58E1   CLC 
        LDA a5900
        BEQ b58E8
        SEC 
b58E8   RTS 

j58E9   LDA #$01
        STA a5901
        RTS 

s58EF   LDA #$00
        STA a5901
        RTS 

s58F5   CLC 
        PHA 
        LDA a5901
        BEQ b58FD
        SEC 
b58FD   PLA 
        RTS 

a58FF   .BYTE $00
a5900   .BYTE $00
a5901   .BYTE $00
j5902   LDA a59EA
        BNE b590A
        JMP j59B6

b590A   LDA a3E
        STA a5953
        LDA a3F
        STA a5954
        LDA a40
        STA a5955
        LDA a41
        STA a5956
        LDX #$00
b5920   JSR j3BAA
        STA pAC00,X
        INX 
        CMP #$0D
        BNE b5920
        LDA #$00
        STA pAC00,X
        INX 
        LDA #$00
        STA a3E
        STX a40
        LDA #$AC
        STA a3F
        STA a41
        LDY #$01
        LDA #$3D
        STA (p34),Y
        INY 
        STA (p34),Y
        CLC 
        TYA 
        ADC a34
        STA a34
        BCC b5950
        INC a35
b5950   JMP j58D5

a5953   .BYTE $00
a5954   .BYTE $00
a5955   .BYTE $00
a5956   .BYTE $00
j5957   JSR s58DB
        LDA a5953
        STA a3E
        STA a3C
        LDA a5954
        STA a3F
        STA a3D
        LDA a5955
        STA a40
        LDA a5956
        STA a41
        LDA #$FF
        STA a37
        LDA a34
        BNE b597C
        DEC a35
b597C   DEC a34
        JSR s2502
        TXA 
        BNE b5985
        TYA 
b5985   BNE b598C
        LDA #$00
        JMP j598E

b598C   LDA #$01
j598E   JMP j59B6

j5991   LDA a59EA
        BEQ b59A2
        JSR s5A1B
        BCC b59A0
        LDA #$01
        JMP b59A2

b59A0   LDA #$00
b59A2   JMP j59B6

j59A5   LDA a59EA
        BEQ j59B6
        JSR s5A1B
        BCC b59B4
        LDA #$00
        JMP j59B6

b59B4   LDA #$01
j59B6   PHA 
        LDX a59EB
        LDA a59EA
        STA f59EC,X
        INC a59EB
        PLA 
        STA a59EA
        RTS 

j59C8   LDA a59EA
        BNE b59D7
        LDX a59EB
        DEX 
        LDA f59EC,X
        JMP j59D9

b59D7   LDA #$00
j59D9   STA a59EA
        RTS 

j59DD   DEC a59EB
        LDX a59EB
        LDA f59EC,X
        STA a59EA
        RTS 

a59EA   .BYTE $00
a59EB   .BYTE $00
f59EC   .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00
j59F6   LDA a59EA
        BNE b59FE
        JMP j5A09

b59FE   JSR s5A1B
        BCC b5A08
        LDA #$00
        TAY 
        STA (p32),Y
b5A08   RTS 

j5A09   JSR j3BAA
        CMP #$5C
        BNE b5A16
        JSR j3BAA
        JSR j3BAA
b5A16   CMP #$0D
        BNE j5A09
        RTS 

s5A1B   JSR j3BAA
        CMP #$20
        BEQ s5A1B
        CMP #$A0
        BEQ s5A1B
        CMP #$0D
        BNE b5A44
        LDX #$31
        LDY #$5A
        JMP j20F8

        .TEXT " *** SYNTAX ERROR", $0D, $00
b5A44   JSR j3C53
        LDX #$00
b5A49   JSR j3BAA
        CMP #$20
        BEQ b5A56
        CMP #$A0
        BEQ b5A56
        CMP #$0D
b5A56   BEQ b5A5E
        STA aB400,X
        INX 
        BNE b5A49
b5A5E   LDA #$00
        STA aB400,X
        LDX #$00
        LDY #$B4
        JMP j6D7D

s5A6A   LDA #<pFF01
        STA a5B0B
        LDA #>pFF01
        STA a5B0C
        JSR s6AEE
        JMP j6963

s5A7A   STX a5B0D
        LDX a5B0C
        LDA f87E6,X
        LDX a5B0D
        RTS 

s5A87   STX a5B0D
        LDX a5B0C
b5A8D   LDA f87FA,X
        CMP #$02
        BEQ b5A96
        CMP #$03
b5A96   BNE b5A9F
        LDA f87E6,X
        LDX a5B0D
        RTS 

b5A9F   DEX 
        BPL b5A8D
        LDA #$00
        LDX a5B0D
        RTS 

s5AA8   STX a5B0D
        LDX a5B0C
b5AAE   LDA f87FA,X
        CMP #$03
        BNE b5ABC
        LDA f87E6,X
        LDX a5B0D
        RTS 

b5ABC   DEX 
        BPL b5AAE
        LDA #$00
        LDX a5B0D
        RTS 

s5AC5   STX a5B0D
        LDX a5B0C
b5ACB   LDA f87FA,X
        CMP #$04
        BNE b5AD9
        LDA f87E6,X
        LDX a5B0D
        RTS 

b5AD9   DEX 
        BPL b5ACB
        LDA #$00
        LDX a5B0D
        RTS 

s5AE2   STX a5B0D
        INC a5B0C
        LDX a5B0C
        STA f87FA,X
        LDA a5B0B
        STA f87E6,X
        INC a5B0B
        LDX a5B0D
        RTS 

s5AFB   STX a5B0D
        LDX a5B0C
        LDA f87E6,X
        DEC a5B0C
        LDX a5B0D
        RTS 

a5B0B   .BYTE $00
a5B0C   .BYTE $00
a5B0D   .BYTE $00
j5B0E   DEC a18
        JSR j5F37
        JSR s56B2
        JSR s5723
        LDA #$29
        JSR s21D3
        TXA 
        JSR s21D3
        TYA 
        JSR s21D3
        RTS 

j5B27   DEC a18
        JSR j5F37
        JSR s5EA2
        BCC b5B38
        LDX #$4E
        LDY #$5B
        JSR j562D
b5B38   JSR s56B2
        LDA #$62
        JSR s21D3
        LDA #$01
        JSR s5AE2
        JSR s21D3
        LDA #$01
        JSR s21D3
        RTS 

        .TEXT " *** ILLEGAL 'IF' EXPRESSION", $0D, $00
j5B6C   LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$01
        JSR s21D3
        RTS 

j5B7D   LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$02
        JSR s21D3
        RTS 

j5B8E   DEC a18
        JSR j5F37
        JSR s5EA2
        BCC b5B9F
        LDX #$B3
        LDY #$5B
        JSR j562D
b5B9F   JSR s56B2
        LDA #$62
        JSR s21D3
        JSR s5A7A
        JSR s21D3
        LDA #$01
        JSR s21D3
        RTS 

        .TEXT " *** ILLEGAL 'WHILE' EXPRESSION", $0D, $00
j5BD4   LDA #$63
        JSR s21D3
        JSR s5A7A
        JSR s21D3
        LDA #$02
        JSR s21D3
        LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$01
        JSR s21D3
        RTS 

j5BF5   LDA #$57
        JSR s21D3
        JSR s5A7A
        JSR s21D3
        LDA #$02
        JSR s21D3
        JSR s68F6
        RTS 

j5C09   DEC a18
        JSR j5F37
        JSR s5EA2
        BCC b5C1A
        LDX #$B3
        LDY #$5B
        JSR j562D
b5C1A   JSR s56B2
        LDA #$66
        JSR s21D3
        JSR s5A7A
        JSR s21D3
        LDA #$03
        JSR s21D3
        LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$01
        JSR s21D3
        JSR s68FC
        RTS 

s5C41   JMP s21D3

s5C44   JMP s24CE

j5C47   JMP j24BD

s5C4A   LDX #$AA
        LDY #$87
        JMP j5C55

s5C51   LDX #<p87C8
        LDY #>p87C8
j5C55   STX a2B
        STY a2C
        LDY #$01
        LDA (p2B),Y
        CMP #$02
        BEQ b5C7D
        PHA 
        CMP #$06
        BCC b5C6D
        LDX #$7E
        LDY #$5C
        JSR j562D
b5C6D   LDA #$15
        JSR s5C41
        PLA 
        JSR s5C41
        LDA #$02
        JSR s5C41
        STA (p2B),Y
b5C7D   RTS 

        .TEXT " *** VALUE MUST BE ARITHMETIC", $0D, $00
s5C9D   JSR s5C44
        CMP #$01
        BEQ b5CA7
        JMP j5C47

b5CA7   JSR s58F5
        BCC b5CB4
        JSR s5C44
        LDA #$00
        JMP j5C47

b5CB4   JSR s5C44
        JSR s5C44
        CMP #$0A
        BEQ b5CC4
        CMP #$07
        BEQ b5CC4
        CMP #$08
b5CC4   BNE b5CD3
        JSR j5C47
        LDA #$09
        JSR j5C47
        LDA #$01
        JMP j5C47

b5CD3   CMP #$0B
        BNE b5CDF
        JSR s5C44
        JSR s5C44
        LDA #$09
b5CDF   JSR j5C47
        LDA #$00
        JSR j5C47
        JSR s56B2
        JSR s5723
        LDA #$14
        JSR s5C41
        TXA 
        JSR s5C41
        JSR s5704
        RTS 

s5CFA   JSR s5C44
        CMP #$00
        BEQ b5D07
        JSR j24BD
        LDA #$FF
        RTS 

b5D07   PHA 
        JSR s5C44
        CMP #$01
        BNE b5D2A
        LDA #$15
        JSR s5C41
        LDA #$01
        JSR s5C41
        LDA #$02
        JSR s5C41
        LDA #$02
        JSR j5C47
        PLA 
        JSR j5C47
        LDA #$02
        RTS 

b5D2A   TAX 
        JSR j5C47
        PLA 
        JSR j5C47
        TXA 
        RTS 

s5D34   JSR s56BD
        JSR s56B2
        LDA a87AA
        BNE b5D42
        LDA p87C8
b5D42   BEQ b5D49
        LDA #$FF
        JMP j5E84

b5D49   LDA a87C9
        CMP #$06
        BCC b5D57
        CMP #$09
        BEQ b5D57
        JMP j5E84

b5D57   LDA a87AB
        CMP #$06
        BCC b5D65
        CMP #$09
        BEQ b5D65
        JMP j5E84

b5D65   CMP #$09
        BNE b5D7A
        LDA a87C9
        CMP #$09
        BNE b5D75
        LDA #$0A
        JMP j5D77

b5D75   LDA #$09
j5D77   JMP j5E84

b5D7A   LDA a87AB
        CMP #$05
        BNE b5D9F
        LDA a87C9
        CMP #$05
        BEQ b5D9A
        PHA 
        LDA #$15
        JSR s5C41
        PLA 
        JSR s5C41
        LDA #$05
        STA a87C9
        JSR s5C41
b5D9A   LDA #$05
        JMP j5E84

b5D9F   LDA a87C9
        CMP #$05
        BNE b5DD2
        LDA #$27
        JSR s5C41
        LDA #$05
        JSR s5C41
        LDA #$15
        JSR s5C41
        LDA a87AB
        JSR s5C41
        LDA #$05
        STA a87AB
        JSR s5C41
        LDA #$28
        JSR s5C41
        LDA #$05
        JSR s5C41
        LDA #$05
        JMP j5E84

b5DD2   LDA a87AB
        CMP #$03
        BNE b5DF7
        LDA a87C9
        CMP #$03
        BEQ b5DF2
        PHA 
        LDA #$15
        JSR s5C41
        PLA 
        JSR s5C41
        LDA #$03
        STA a87C9
        JSR s5C41
b5DF2   LDA #$03
        JMP j5E84

b5DF7   LDA a87C9
        CMP #$03
        BNE b5E2A
        LDA #$27
        JSR s5C41
        LDA #$04
        JSR s5C41
        LDA #$15
        JSR s5C41
        LDA a87AB
        JSR s5C41
        LDA #$03
        STA a87AB
        JSR s5C41
        LDA #$28
        JSR s5C41
        LDA #$04
        JSR s5C41
        LDA #$03
        JMP j5E84

b5E2A   LDA a87AB
        CMP #$04
        BNE b5E4F
        LDA a87C9
        CMP #$04
        BEQ b5E4A
        PHA 
        LDA #$15
        JSR s5C41
        PLA 
        JSR s5C41
        LDA #$04
        STA a87C9
        JSR s5C41
b5E4A   LDA #$04
        JMP j5E84

b5E4F   LDA a87C9
        CMP #$04
        BNE b5E82
        LDA #$27
        JSR s5C41
        LDA #$02
        JSR s5C41
        LDA #$15
        JSR s5C41
        LDA a87AB
        JSR s5C41
        LDA #$04
        STA a87AB
        JSR s5C41
        LDA #$28
        JSR s5C41
        LDA #$02
        JSR s5C41
        LDA #$04
        JMP j5E84

b5E82   LDA #$02
j5E84   PHA 
        JSR s5704
        JSR s570E
        PLA 
        RTS 

s5E8D   JSR s56BD
        JSR s5C51
        JSR s56B2
        LDA a87AB
        PHA 
        JSR s5704
        JSR s570E
        PLA 
        RTS 

s5EA2   JSR s56B2
        LDA #$02
        JSR j5C47
        LDA #$00
        JSR j5C47
        LDA a87AA
        CMP #$01
        BNE b5EB8
        SEC 
        RTS 

b5EB8   LDA a87AB
        CMP #$03
        BNE b5EC6
        LDA #$5E
        JSR s5C41
        CLC 
        RTS 

b5EC6   CMP #$05
        BNE b5ED1
        LDA #$5F
        JSR s5C41
        CLC 
        RTS 

b5ED1   CMP #$06
        BCC b5EDB
        CMP #$09
        CLC 
        BEQ b5EDB
        SEC 
b5EDB   RTS 

s5EDC   JSR s56BD
        JSR s56B2
        LDA a87AA
        CMP #$01
        BEQ b5EF6
        LDA #$02
        JSR j5C47
        LDA #$00
        JSR j5C47
        LDA #$FF
        RTS 

b5EF6   LDA a87C9
        CMP #$06
        BCC b5F04
        CMP #$09
        BEQ b5F04
        JMP j5F1D

b5F04   LDA a87AC
        CMP a87C9
        BEQ j5F1D
        LDA #$15
        JSR s5C41
        LDA a87C9
        JSR s5C41
        LDA a87AC
        JSR s5C41
j5F1D   PHA 
        JSR s5704
        JSR s5C44
        JSR s5C44
        LDA #$00
        JSR j5C47
        PLA 
        RTS 

s5F2E   JMP s21D3

s5F31   JMP s24CE

s5F34   JMP j24BD

j5F37   JSR s58B3
        BCS b5F42
        JSR s5C9D
        JSR s5CFA
b5F42   RTS 

j5F43   RTS 

j5F44   JSR s58B3
        BCC b5F4C
        JMP s2540

b5F4C   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BNE b5F60
        LDA #$2C
        JSR s5F2E
        JMP s56B2

b5F60   CMP #$03
        BNE b5F6C
        LDA #$2D
        JSR s5F2E
        JMP s56B2

b5F6C   CMP #$04
        BNE b5F78
        LDA #$13
        JSR s5F2E
        JMP s56B2

b5F78   CMP #$05
        BNE b5F84
        LDA #$2E
        JSR s5F2E
        JMP s56B2

b5F84   LDX #$2A
        LDY #$00
        JMP j6120

j5F8B   JSR s58B3
        BCC b5F93
        JMP s25C5

b5F93   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BNE b5FA7
        LDA #$2F
        JSR s5F2E
        JMP s56B2

b5FA7   CMP #$03
        BNE b5FB3
        LDA #$30
        JSR s5F2E
        JMP s56B2

b5FB3   CMP #$04
        BNE b5FBF
        LDA #$31
        JSR s5F2E
        JMP s56B2

b5FBF   CMP #$05
        BNE b5FCB
        LDA #$32
        JSR s5F2E
        JMP s56B2

b5FCB   LDX #$2F
        LDY #$00
        JMP j6120

j5FD2   JSR s58B3
        BCC b5FDA
        JMP j25E2

b5FDA   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BNE b5FEE
        LDA #$33
        JSR s5F2E
        JMP s56B2

b5FEE   CMP #$03
        BNE b5FFA
        LDA #$34
        JSR s5F2E
        JMP s56B2

b5FFA   CMP #$04
        BNE b6006
        LDA #$35
        JSR s5F2E
        JMP s56B2

b6006   LDX #$25
        LDY #$00
        JMP j6120

j600D   JSR s58B3
        BCC b6015
        JMP j2686

b6015   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BEQ b6023
        CMP #$04
b6023   BNE b602D
        LDA #$06
        JSR s5F2E
        JMP s56B2

b602D   CMP #$03
        BNE b6039
        LDA #$36
        JSR s5F2E
        JMP s56B2

b6039   CMP #$05
        BNE b6045
        LDA #$37
        JSR s5F2E
        JMP s56B2

b6045   CMP #$09
        BNE b6079
        JSR s56B2
        JSR s5C4A
        JSR s56B2
        JSR s5704
        JSR s5704
        JSR s5F31
        JSR s56B2
        JSR s5723
        LDA #$05
        JSR s5F2E
        TXA 
        JSR s5F2E
        TYA 
        JSR s5F2E
        LDA #$13
        JSR s5F2E
        LDA #$06
        JSR s5F2E
        RTS 

b6079   LDX #$2B
        LDY #$00
        JMP j6120

j6080   JSR s58B3
        BCC b6088
        JMP j26A0

b6088   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BEQ b6096
        CMP #$04
b6096   BNE b60A0
        LDA #$38
        JSR s5F2E
        JMP s56B2

b60A0   CMP #$03
        BNE b60AC
        LDA #$39
        JSR s5F2E
        JMP s56B2

b60AC   CMP #$05
        BNE b60B8
        LDA #$3A
        JSR s5F2E
        JMP s56B2

b60B8   CMP #$09
        BNE b60EB
        JSR s56B2
        JSR s5C4A
        JSR s56B2
        JSR s5704
        JSR s5704
        JSR s5F31
        JSR s56B2
        JSR s5723
        LDA #$05
        JSR s5F2E
        TXA 
        JSR s5F2E
        TYA 
        JSR s5F2E
        LDA #$13
        JSR s5F2E
        LDA #$38
        JMP s5F2E

b60EB   CMP #$0A
        BNE b611C
        LDA #$38
        JSR s5F2E
        JSR s56B2
        JSR s5F31
        JSR s56B2
        JSR s5723
        LDA #$05
        JSR s5F2E
        TXA 
        JSR s5F2E
        TYA 
        JSR s5F2E
        LDA #$31
        JSR s5F2E
        LDA #$02
        JSR s5F34
        LDA #$00
        JMP s5F34

b611C   LDX #$2D
        LDY #$00
j6120   JSR s5604
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s5F34
        LDA #$00
        JMP s5F34

j6133   LDA a26D9
        CMP #$07
        BEQ b6148
        CMP #$08
        BEQ b6148
        CMP #$0F
        BEQ b6148
        CMP #$04
        BEQ b6148
        CMP #$06
b6148   BEQ b614D
        JMP j6189

b614D   JSR s5650
j6150   JSR j3BAA
        CMP #$00
        BEQ b6178
        CMP #$3B
        BEQ b6162
        CMP #$2C
        BNE b6162
        LDX a621A
b6162   BEQ b6178
        CMP #$28
        BNE b616E
        INC a621A
        JMP j6175

b616E   CMP #$29
        BNE j6175
        DEC a621A
j6175   JMP j6150

b6178   JSR j3C53
        LDA #$00
        STA a621A
        LDA a34
        BNE b6186
        DEC a35
b6186   DEC a34
        RTS 

j6189   CMP #$02
        BEQ b618F
        CMP #$03
b618F   BNE b61AA
        JSR s691E
        JSR s7636
        LDA #$00
        STA a7737
        STA a7738
        LDA a26E0
        STA a28
        LDA a26E1
        STA a29
        RTS 

b61AA   LDA a6218
        STA a2B
        LDA a6219
        STA a2C
        LDX #$02
        LDY #$00
b61B8   LDA f8778,X
        BEQ b61C3
        STA (p2B),Y
        INX 
        INY 
        BNE b61B8
b61C3   LDA #$3D
        STA (p2B),Y
        INY 
j61C8   JSR j3BAA
        CMP #$00
        BNE b61D0
        RTS 

b61D0   CMP #$3B
        BEQ b61DB
        CMP #$2C
        BNE b61DB
        LDX a621A
b61DB   BEQ b61F4
        STA (p2B),Y
        INY 
        CMP #$28
        BNE b61EA
        INC a621A
        JMP j61F1

b61EA   CMP #$29
        BNE j61F1
        DEC a621A
j61F1   JMP j61C8

b61F4   JSR j3C53
        LDA #$00
        STA a621A
        LDA #$3B
        STA (p2B),Y
        INY 
        CLC 
        TYA 
        ADC a2B
        STA a6218
        LDA a2C
        ADC #$00
        STA a6219
        LDA a34
        BNE b6215
        DEC a35
b6215   DEC a34
        RTS 

a6218   .BYTE $00
a6219   .BYTE $00
a621A   .BYTE $00
a621B   .BYTE $00
a621C   .BYTE $00
a621D   .BYTE $00
a621E   .BYTE $00
a621F   .BYTE $00,$00
j6221   JMP j3B67

s6224   LDA a3E
        STA a621C
        LDA a3F
        STA a621D
        LDA a40
        STA a621E
        LDA a41
        STA a621F
        LDA #<pAC00
        STA a3E
        LDA #>pAC00
        STA a3F
        LDA a6218
        STA a40
        LDA a6219
        STA a41
        LDA #$00
        TAY 
        STA (p40),Y
        INC a40
        BNE b6255
        INC a41
b6255   LDA #$01
        STA a621B
        RTS 

s625B   LDA a621C
        STA a3E
        STA a3C
        LDA a621D
        STA a3F
        STA a3D
        LDA a621E
        STA a40
        LDA a621F
        STA a41
        LDA #<pAC00
        STA a6218
        LDA #>pAC00
        STA a6219
        LDA #$00
        STA a621B
        RTS 

        JMP s24CE

s6286   JMP j24BD

j6289   JSR s58B3
        BCC b6291
        JMP j6846

b6291   DEC a18
        JSR j5F37
        JSR s5D34
        PHA 
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s6286
        LDA #$00
        JSR s6286
        PLA 
        CMP #$02
        BEQ b62B9
        CMP #$04
        BEQ b62B9
        CMP #$09
        BEQ b62B9
        CMP #$0A
b62B9   BNE b62C0
        LDA #$4F
        JMP s21D3

b62C0   CMP #$03
        BNE b62C9
        LDA #$50
        JMP s21D3

b62C9   CMP #$05
        BNE b62D2
        LDA #$51
        JMP s21D3

b62D2   LDX #$3D
        LDY #$3D
        JMP s5604

j62D9   JSR s58B3
        BCC b62E1
        JMP j6857

b62E1   DEC a18
        JSR j5F37
        JSR s5D34
        PHA 
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s6286
        LDA #$00
        JSR s6286
        PLA 
        CMP #$02
        BEQ b6309
        CMP #$04
        BEQ b6309
        CMP #$09
        BEQ b6309
        CMP #$0A
b6309   BNE b6310
        LDA #$52
        JMP s21D3

b6310   CMP #$03
        BNE b6319
        LDA #$53
        JMP s21D3

b6319   CMP #$05
        BNE b6322
        LDA #$54
        JMP s21D3

b6322   LDX #$21
        LDY #$3D
        JMP s5604

j6329   JSR s58B3
        BCC b6331
        JMP j6868

b6331   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BEQ b633F
        CMP #$04
b633F   BNE b6349
        LDA #$55
        JSR s21D3
        JMP s56B2

b6349   CMP #$03
        BNE b6355
        LDA #$56
        JSR s21D3
        JMP s56B2

b6355   LDX #$26
        LDY #$00
        JMP j64DA

j635C   JSR s58B3
        BCC b6364
        JMP j689A

b6364   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BEQ b6372
        CMP #$04
b6372   BNE b637C
        LDA #$5A
        JSR s21D3
        JMP s56B2

b637C   CMP #$03
        BNE b6388
        LDA #$5B
        JSR s21D3
        JMP s56B2

b6388   LDX #$5E
        LDY #$00
        JMP j64DA

j638F   JSR s58B3
        BCC b6397
        JMP j6881

b6397   DEC a18
        JSR j5F37
        JSR s5D34
        CMP #$02
        BEQ b63A5
        CMP #$04
b63A5   BNE b63AF
        LDA #$5C
        JSR s21D3
        JMP s56B2

b63AF   CMP #$03
        BNE b63BB
        LDA #$5D
        JSR s21D3
        JMP s56B2

b63BB   LDX #$DF
        LDY #$00
        JMP j64DA

j63C2   JSR s58B3
        BCC b63CD
        JSR s2502
        JMP j5649

b63CD   DEC a18
        JSR j5F37
        JSR s5EA2
        BCC b63DE
        LDX #$26
        LDY #$26
        JSR s5604
b63DE   JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s6286
        LDA #$00
        JSR s6286
        LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$01
        JMP s21D3

j63FE   JSR s58B3
        BCC b6409
        JSR s2502
        JMP j5649

b6409   DEC a18
        JSR j5F37
        JSR s5EA2
        BCC b641A
        LDX #$DF
        LDY #$DF
        JSR s5604
b641A   JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s6286
        LDA #$00
        JSR s6286
        LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$01
        JMP s21D3

j643A   JSR s58B3
        BCC b6448
        JSR s2502
        JSR s2502
        JMP j5649

b6448   DEC a18
        JSR j5F37
        JSR s56B2
        LDA #$57
        JSR s21D3
        JSR s5AFB
        JSR s21D3
        LDA #$02
        JMP s21D3

j6460   JSR s58B3
        BCC b646B
        JSR s2502
        JMP j5649

b646B   DEC a18
        DEC a6C5A
        JSR j5F37
        JSR s5EDC
        PHA 
        LDA #$64
        JSR s21D3
        PLA 
        CMP #$01
        BNE b6489
        LDA #$01
        JSR s21D3
        JMP s5CFA

b6489   CMP #$02
        BEQ b6493
        CMP #$04
        BEQ b6493
        CMP #$09
b6493   BNE b649A
        LDA #$02
        JMP s21D3

b649A   CMP #$03
        BNE b64A3
        LDA #$04
        JMP s21D3

b64A3   CMP #$05
        BNE b64AC
        LDA #$05
        JMP s21D3

b64AC   LDX #$C0
        LDY #$64
        JSR j562D
        JSR s56B2
        LDA #$02
        JSR s6286
        LDA #$00
        JMP s6286

        .TEXT " *** ILLEGAL ASSIGNMENT", $0D, $00
j64D9   RTS 

j64DA   JSR s5604
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s6286
        LDA #$00
        JMP s6286

s64ED   JMP s21D3

j64F0   LDA a26DA
        CMP #$07
        BEQ b64F9
        CMP #$08
b64F9   BNE b6507
        LDA a26E6
        JSR j24BD
        LDA a26E5
        JSR j24BD
b6507   LDA a26DA
        JSR j24BD
        LDX a26DD
        BEQ b651C
        DEX 
b6513   LDA a864D,X
        JSR j24BD
        DEX 
        BPL b6513
b651C   LDA #$00
        JSR j24BD
        LDA #$00
        STA a26DD
        RTS 

j6527   INC a18
        JMP j652F

j652C   JSR s5C9D
j652F   JSR s58EF
        JSR s56B2
        JSR s5723
        LDA #$05
        JSR s64ED
        TXA 
        JSR s64ED
        TYA 
        JSR s64ED
        LDA #$02
        JSR j24BD
        LDA #$00
        JMP j24BD

j654F   JSR s5C9D
        JSR s5CFA
        JSR s56BD
        JSR s56B2
        LDA a87AB
        CMP #$01
        BNE b6567
        LDA #$02
        STA a87AB
b6567   CMP a87C9
        BNE b656F
        JMP s5704

b656F   LDA #$15
        JSR s64ED
        LDA a87C9
        JSR s64ED
        LDA a87AB
        JSR s64ED
        JMP s5704

j6583   JMP j6460

j6586   JSR j600D
        JMP j6583

j658C   JSR j6080
        JMP j6583

j6592   JSR j5F44
        JMP j6583

j6598   JSR j5F8B
        JMP j6583

j659E   JSR j5FD2
        JMP j6583

j65A4   JSR j65C8
        JMP j6583

j65AA   JSR j65FB
        JMP j6583

j65B0   JSR j6329
        JMP j6583

j65B6   JSR j635C
        JMP j6583

j65BC   JSR j638F
        JMP j6583

s65C2   JMP j24BD

s65C5   JMP s21D3

j65C8   JSR s58B3
        BCC b65D0
        JMP j67A3

b65D0   DEC a18
        JSR j5F37
        JSR s5E8D
        CMP #$02
        BEQ b65DE
        CMP #$04
b65DE   BNE b65E8
        LDA #$3B
        JSR s65C5
        JMP s56B2

b65E8   CMP #$03
        BNE b65F4
        LDA #$3C
        JSR s65C5
        JMP s56B2

b65F4   LDX #$3E
        LDY #$3E
        JMP j6782

j65FB   JSR s58B3
        BCC b6603
        JMP j67C8

b6603   DEC a18
        JSR j5F37
        JSR s5E8D
        CMP #$02
        BEQ b6611
        CMP #$04
b6611   BNE b661B
        LDA #$3D
        JSR s65C5
        JMP s56B2

b661B   CMP #$03
        BNE b6627
        LDA #$3E
        JSR s65C5
        JMP s56B2

b6627   LDX #$3C
        LDY #$3C
        JMP j6782

j662E   JSR s58B3
        BCC b6636
        JMP j6808

b6636   DEC a18
        JSR j5F37
        JSR s5D34
        PHA 
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s65C2
        LDA #$00
        JSR s65C2
        PLA 
        CMP #$02
        BNE b6659
        LDA #$3F
        JMP s65C5

b6659   CMP #$03
        BNE b6662
        LDA #$40
        JMP s65C5

b6662   CMP #$04
        BEQ b666C
        CMP #$09
        BEQ b666C
        CMP #$0A
b666C   BNE b6673
        LDA #$41
        JMP s65C5

b6673   CMP #$05
        BNE b667C
        LDA #$42
        JMP s65C5

b667C   LDX #$3C
        LDY #$00
        JMP s5604

j6683   JSR s58B3
        BCC b668B
        JMP j6815

b668B   DEC a18
        JSR j5F37
        JSR s5D34
        PHA 
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s65C2
        LDA #$00
        JSR s65C2
        PLA 
        CMP #$02
        BNE b66AE
        LDA #$43
        JMP s65C5

b66AE   CMP #$03
        BNE b66B7
        LDA #$44
        JMP s65C5

b66B7   CMP #$04
        BEQ b66C1
        CMP #$09
        BEQ b66C1
        CMP #$0A
b66C1   BNE b66C8
        LDA #$45
        JMP s65C5

b66C8   CMP #$05
        BNE b66D1
        LDA #$46
        JMP s65C5

b66D1   LDX #$3E
        LDY #$00
        JMP s5604

j66D8   JSR s58B3
        BCC b66E0
        JMP j6827

b66E0   DEC a18
        JSR j5F37
        JSR s5D34
        PHA 
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s65C2
        LDA #$00
        JSR s65C2
        PLA 
        CMP #$02
        BNE b6703
        LDA #$47
        JMP s65C5

b6703   CMP #$03
        BNE b670C
        LDA #$48
        JMP s65C5

b670C   CMP #$04
        BEQ b6716
        CMP #$09
        BEQ b6716
        CMP #$0A
b6716   BNE b671D
        LDA #$49
        JMP s65C5

b671D   CMP #$05
        BNE b6726
        LDA #$4A
        JMP s65C5

b6726   LDX #$3C
        LDY #$3D
        JMP s5604

j672D   JSR s58B3
        BCC b6735
        JMP j6839

b6735   DEC a18
        JSR j5F37
        JSR s5D34
        PHA 
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s65C2
        LDA #$00
        JSR s65C2
        PLA 
        CMP #$02
        BNE b6758
        LDA #$4B
        JMP s65C5

b6758   CMP #$03
        BNE b6761
        LDA #$4C
        JMP s65C5

b6761   CMP #$04
        BEQ b676B
        CMP #$09
        BEQ b676B
        CMP #$0A
b676B   BNE b6772
        LDA #$4D
        JMP s65C5

b6772   CMP #$05
        BNE b677B
        LDA #$4E
        JMP s65C5

b677B   LDX #$3E
        LDY #$3D
        JMP s5604

j6782   JSR s5604
        JSR s56B2
        JSR s56B2
        LDA #$02
        JSR s65C2
        LDA #$00
        JMP s65C2

j6795   JSR s2502
        TXA 
        EOR #$FF
        TAX 
        TYA 
        EOR #$FF
        TAY 
        JMP s24ED

j67A3   JSR s2502
        STX a68B3
        STY a68B4
j67AC   LDA a68B3
        BNE b67BC
        LDA a68B4
        BNE b67B9
        JMP s24ED

b67B9   DEC a68B4
b67BC   DEC a68B3
        TYA 
        LSR 
        TAY 
        TXA 
        ROR 
        TAX 
        JMP j67AC

j67C8   JSR s2502
        STX a68B3
        STY a68B4
j67D1   LDA a68B3
        BNE b67E1
        LDA a68B4
        BNE b67DE
        JMP e04ED

b67DE   DEC a68B4
b67E1   DEC a68B3
        TXA 
        ASL 
        TAX 
        TYA 
        ROL 
        TAY 
        JMP j67D1

s67ED   JSR s2502
        STX a68B3
        TYA 
        EOR #$80
        STA a68B4
        JSR s2502
        TYA 
        EOR #$80
        CMP a68B4
        BNE b6807
        CPX a68B3
b6807   RTS 

j6808   JSR s67ED
        LDX #$00
        BCS b6810
        INX 
b6810   LDY #$00
        JMP s24ED

j6815   JSR s67ED
        BCC b6820
        BEQ b6820
        LDX #$01
        BNE b6822
b6820   LDX #$00
b6822   LDY #$00
        JMP s24ED

j6827   JSR s67ED
        BCC b6832
        BEQ b6832
        LDX #$00
        BEQ b6834
b6832   LDX #$01
b6834   LDY #$00
        JMP s24ED

j6839   JSR s67ED
        LDX #$00
        BCC b6841
        INX 
b6841   LDY #$00
        JMP s24ED

j6846   JSR s67ED
        BNE b6850
        LDX #$01
        JMP j6852

b6850   LDX #$00
j6852   LDY #$00
        JMP s24ED

j6857   JSR s67ED
        BEQ b6861
        LDX #$01
        JMP j6863

b6861   LDX #$00
j6863   LDY #$00
        JMP s24ED

j6868   JSR s2502
        STX a68B3
        STY a68B4
        JSR s2502
        TXA 
        AND a68B3
        TAX 
        TYA 
        AND a68B4
        TAY 
        JMP s24ED

j6881   JSR s2502
        STX a68B3
        STY a68B4
        JSR s2502
        TXA 
        ORA a68B3
        TAX 
        TYA 
        ORA a68B4
        TAY 
        JMP s24ED

j689A   JSR s2502
        STX a68B3
        STY a68B4
        JSR s2502
        TXA 
        EOR a68B3
        TAX 
        TYA 
        EOR a68B4
        TAY 
        JMP s24ED

a68B3   .BYTE $00
a68B4   .BYTE $00
j68B5   LDA #$00
        STA a695F
        STA a880E
        STA a695A
        STA a695B
        STA a695C
        STA a695D
        STA a695E
        JMP j58A7

j68CF   INC a695F
        LDX a695F
        LDA #$01
        STA a880E,X
        RTS 

j68DB   INC a695F
        LDX a695F
        LDA #$00
        STA a880E,X
        RTS 

j68E7   DEC a695F
        RTS 

s68EB   CLC 
        LDX a695F
        LDA a880E,X
        BEQ b68F5
        SEC 
b68F5   RTS 

s68F6   LDA #$01
        STA a695A
        RTS 

s68FC   LDA #$00
        STA a695A
        RTS 

s6902   CLC 
        LDA a695A
        BEQ b6909
        SEC 
b6909   RTS 

j690A   LDA #$01
        STA a695B
        RTS 

j6910   LDA #$00
        STA a695B
        RTS 

s6916   CLC 
        LDA a695B
        BEQ b691D
        SEC 
b691D   RTS 

s691E   LDA #$01
        STA a695C
        RTS 

s6924   LDA #$00
        STA a695C
        RTS 

s692A   CLC 
        LDA a695C
        BEQ b6931
        SEC 
b6931   RTS 

j6932   LDA #$01
        STA a695D
        RTS 

j6938   LDA #$00
        STA a695D
        RTS 

s693E   CLC 
        LDA a695D
        BEQ b6945
        SEC 
b6945   RTS 

j6946   LDA #$01
        STA a695E
        RTS 

s694C   LDA #$00
        STA a695E
        RTS 

s6952   CLC 
        LDA a695E
        BEQ b6959
        SEC 
b6959   RTS 

a695A   .BYTE $00
a695B   .BYTE $00
a695C   .BYTE $00
a695D   .BYTE $00
a695E   .BYTE $00
a695F   .BYTE $00
s6960   JMP s21D3

j6963   LDA #<p8827
        STA a6973
        LDA #>p8827
        STA a6974
        LDA #$00
        STA a6975
        RTS 

a6973   .BYTE $00
a6974   .BYTE $00
a6975   .BYTE $00
a6976   .BYTE $00
a6977   .BYTE $00
j6978   JSR j5B0E
j697B   LDA #$57
        JSR s6960
        LDA #$03
        JSR s5AE2
        JSR s6960
        LDA #$03
        JSR s6960
        RTS 

s698E   DEC a18
        JSR j5F37
        JSR s5EA2
        BCC b699F
        LDX #$D5
        LDY #$69
        JSR j562D
b699F   JSR s56B2
        LDA #$62
        JSR s6960
        JSR s5A7A
        JSR s6960
        LDA #$01
        JSR s6960
s69B2   LDA a14
        STA a6976
        LDA a15
        STA a6977
        LDA a6973
        STA a14
        LDX a6975
        STA f8C27,X
        LDA a6974
        STA a15
        INX 
        STA f8C27,X
        INX 
        STX a6975
        RTS 

        .TEXT " *** ILLEGAL 'FOR' CONDITION", $0D, $00
j69F3   JSR j5B0E
j69F6   LDA a14
        STA a6973
        LDA a15
        STA a6974
        LDA a6976
        STA a14
        LDA a6977
        STA a15
        RTS 

j6A0B   LDA #$57
        JSR s6960
        JSR s5A7A
        JSR s6960
        LDA #$02
        JSR s6960
        DEC a6975
        DEC a6975
        LDX a6975
        LDA f8C27,X
        STA a2B
        INX 
        LDA f8C27,X
        STA a2C
j6A2F   LDA a2B
        CMP a6973
        BNE b6A3D
        LDA a2C
        CMP a6974
        BEQ b6A4D
b6A3D   LDY #$00
        LDA (p2B),Y
        JSR s6960
        INC a2B
        BNE b6A4A
        INC a2C
b6A4A   JMP j6A2F

b6A4D   LDX a6975
        LDA f8C27,X
        STA a6973
        INX 
        LDA f8C27,X
        STA a6974
        LDA #$63
        JSR s6960
        JSR s5A7A
        JSR s6960
        LDA #$03
        JSR s6960
        LDA #$57
        JSR s6960
        JSR s5AFB
        JSR s6960
        LDA #$01
        JMP s6960

j6A7D   LDA #$63
        JSR s6960
        JSR s5A87
        CMP #$00
        BNE b6A90
        LDX #$98
        LDY #$6A
        JMP j562D

b6A90   JSR s6960
        LDA #$01
        JMP s6960

        .TEXT " *** NO ENCLOSING LOOP OR SWITCH", $0D, $00
j6ABA   LDA #$63
        JSR s6960
        JSR s5AA8
        CMP #$00
        BNE b6ACD
        LDX #$D6
        LDY #$6A
        JMP j562D

b6ACD   JSR s6960
        LDA #$02
        JSR s6960
        RTS 

        .TEXT " *** NO ENCLOSING LOOP"
        .TEXT $0D, $00
s6AEE   SEC 
        LDA #$59
        SBC #$04
        STA a20
        LDA #$8C
        SBC #$00
        STA a21
        LDA #<p8C81
        STA a26
        LDA #>p8C81
        STA a27
        RTS 

j6B04   DEC a18
        JSR j5F37
        JSR s56B2
        JSR s5C4A
        LDA #$FF
        JSR s6960
        LDA #$02
        JSR s6960
        LDA #$63
        JSR s6960
        LDA #$02
        JSR s5AE2
        JSR s6960
        LDA #$02
        JSR s6960
        CLC 
        LDA a20
        ADC #$04
        STA a20
        BCC b6B36
        INC a21
b6B36   LDY #$00
        TYA 
        STA (p20),Y
        INY 
        LDA #$04
        STA (p20),Y
        INY 
        LDA a26
        STA (p20),Y
        INY 
        LDA a27
        STA (p20),Y
        RTS 

j6B4B   LDA #$57
        JSR s6960
        JSR s5A7A
        JSR s6960
        LDA #$03
        JSR s6960
        LDY #$00
        LDA #$01
        STA (p20),Y
        RTS 

j6B62   LDA #$57
        JSR s6960
        JSR s5A7A
        JSR s6960
        LDY #$01
        LDA (p20),Y
        JSR s6960
        CLC 
        ADC #$01
        STA (p20),Y
        JSR s2502
        TYA 
        LDY #$01
        STA (p26),Y
        TXA 
        DEY 
        STA (p26),Y
        CLC 
        LDA a26
        ADC #$02
        STA a26
        BCC b6B90
        INC a27
b6B90   JMP j6910

j6B93   LDA #$63
        JSR s6960
        JSR s5AFB
        STA a6976
        JSR s6960
        LDA #$01
        JSR s6960
        LDA #$57
        JSR s6960
        LDA a6976
        JSR s6960
        LDA #$02
        JSR s6960
        LDY #$02
        LDA (p20),Y
        STA a2B
        INY 
        LDA (p20),Y
        STA a2C
        LDA #$04
        STA a31
j6BC5   LDY #$01
        LDA a31
        CMP (p20),Y
        BEQ b6C04
        LDA #$FF
        JSR s6960
        LDA #$50
        JSR s6960
        LDY #$00
        LDA (p2B),Y
        JSR s6960
        INY 
        LDA (p2B),Y
        JSR s6960
        LDA #$63
        JSR s6960
        LDA a6976
        JSR s6960
        LDA a31
        JSR s6960
        CLC 
        LDA a2B
        ADC #$02
        STA a2B
        BCC b6BFF
        INC a2C
b6BFF   INC a31
        JMP j6BC5

b6C04   LDY #$00
        LDA (p20),Y
        BEQ b6C1A
        LDA #$63
        JSR s6960
        LDA a6976
        JSR s6960
        LDA #$03
        JSR s6960
b6C1A   LDA #$57
        JSR s6960
        LDA a6976
        JSR s6960
        LDA #$01
        JSR s6960
        LDY #$02
        LDA (p20),Y
        STA a26
        INY 
        LDA (p20),Y
        STA a27
        SEC 
        LDA a20
        SBC #$04
        STA a20
        BCS b6C40
        DEC a21
b6C40   RTS 

j6C41   LDA #$79
        JSR s6960
        JSR s5AC5
        STA a8779
        LDX #$78
        LDY #$87
        INX 
        BNE b6C54
        INY 
b6C54   JSR s220D
        JMP s694C

a6C5A   .BYTE $00
s6C5B   JMP s24CE

s6C5E   JMP j24BD

j6C61   JSR s5AFB
        PHA 
        LDA #$63
        JSR s21D3
        LDA #$01
        JSR s5AE2
        JSR s21D3
        LDA #$02
        JSR s21D3
        LDA #$57
        JSR s21D3
        PLA 
        JSR s21D3
        LDA #$01
        JSR s21D3
        RTS 

j6C86   JSR s6902
        BCS b6C9D
        LDA #$57
        JSR s21D3
        LDA #$03
        JSR s5AE2
        JSR s21D3
        LDA #$02
        JSR s21D3
b6C9D   RTS 

j6C9E   LDA #$57
        JSR s21D3
        LDA #$03
        JSR s5AE2
        JSR s21D3
        LDA #$03
        JSR s21D3
        RTS 

j6CB1   JSR s31BF
        BCC b6CBC
        JSR s31B9
        JSR s6224
b6CBC   JMP j6938

j6CBF   JSR s58B3
        BCS b6CC8
        LDA #$02
        STA a48
b6CC8   RTS 

s6CC9   LDY a35
        LDX a34
        BNE b6CD0
        DEY 
b6CD0   DEX 
        STX a2B
        STY a2C
        LDY #$00
        LDA (p2B),Y
        RTS 

j6CDA   JSR s58B3
        BCS b6CE9
        JSR s6CC9
        CMP #$7C
        BNE b6CE9
        JSR j5F37
b6CE9   RTS 

j6CEA   JSR s58B3
        BCS b6CF9
        JSR s6CC9
        CMP #$7B
        BNE b6CF9
        JSR j5F37
b6CF9   RTS 

j6CFA   JSR s58B3
        BCS b6D09
        JSR s6CC9
        CMP #$77
        BNE b6D09
        JSR j5F37
b6D09   RTS 

j6D0A   JSR s6CC9
        CMP #$7D
        BNE b6D16
        JSR s58B3
        BCC b6D19
b6D16   JMP j68DB

b6D19   JSR s6C5B
        CMP #$01
        BNE b6D61
        JSR s6C5B
        CMP #$09
        BNE b6D56
        JSR s6C5B
        CMP #$0A
        BNE b6D46
        LDA #$12
        JSR s21D3
        LDA #$0A
        JSR s6C5E
        LDA #$09
        JSR s6C5E
        LDA #$01
        JSR s6C5E
        SEC 
        JMP j6D65

b6D46   JSR s6C5E
        LDA #$09
        JSR s6C5E
        LDA #$01
        JSR s6C5E
        JMP j6D64

b6D56   JSR s6C5E
        LDA #$01
        JSR s6C5E
        JMP j6D64

b6D61   JSR s6C5E
j6D64   CLC 
j6D65   BCC b6D6A
        JMP j68CF

b6D6A   JMP j68DB

j6D6D   JSR s58B3
        BCC b6D7A
        JSR s693E
        BCS b6D7A
        JSR s31B9
b6D7A   JMP j68E7

j6D7D   STX a2B
        STY a2C
        LDA #<pB800
        STA a32
        LDA #>pB800
        STA a33
j6D89   LDA a32
        CMP a1A
        BNE b6D97
        LDA a33
        CMP a1B
        BNE b6D97
        CLC 
        RTS 

b6D97   LDX #$08
        JSR s3A84
        BEQ b6DAC
        CLC 
        LDA a32
        ADC #$0A
        STA a32
        BCC b6DA9
        INC a33
b6DA9   JMP j6D89

b6DAC   SEC 
        RTS 

a6DAE   .BYTE $00
a6DAF   .BYTE $00
a6DB0   .BYTE $00
b6DB1   JSR j3BAA
        CMP #$20
        BEQ b6DB1
        CMP #$A0
        BEQ b6DB1
        CMP #$0D
        BEQ b6DB1
        RTS 

j6DC1   LDX #$C8
        LDY #$6D
        JMP j20F8

        .TEXT " *** ILLEGAL MACRO USE", $0D, $00
s6DE0   LDX #$78
        LDY #$86
        JSR j6D7D
        BCS b6DEA
        RTS 

b6DEA   LDY #$08
        LDA (p32),Y
        STA a2B
        INY 
        LDA (p32),Y
        STA a2C
        LDY #$00
        STY a6DAE
        STY a6DAF
        LDA (p2B),Y
        BEQ b6E59
        JSR b6DB1
        CMP #$28
        BEQ b6E0B
        JMP j6DC1

b6E0B   LDX #$00
b6E0D   INC a6DAE
        CLC 
        TYA 
        ADC #$DC
        STA f8D81,X
        INX 
        LDA #$00
        ADC #$BD
        STA f8D81,X
        INX 
b6E20   JSR j3BAA
        STA a6DB0
        LDA a6DAF
        BNE b6E36
        LDA a6DB0
        CMP #$2C
        BEQ b6E34
        CMP #$29
b6E34   BEQ b6E4D
b6E36   LDA a6DB0
        CMP #$28
        BNE b6E40
        INC a6DAF
b6E40   CMP #$29
        BNE b6E47
        DEC a6DAF
b6E47   STA pBDDC,Y
        INY 
        BNE b6E20
b6E4D   PHA 
        LDA #$00
        STA pBDDC,Y
        INY 
        PLA 
        CMP #$29
        BNE b6E0D
b6E59   LDA #<aB400
        STA a2B
        LDA #>aB400
        STA a2C
        LDY #$00
j6E63   LDA a3E
        CMP a40
        BNE b6E72
        LDA a3F
        CMP a41
        BNE b6E72
        JMP j6E8B

b6E72   LDA (p3E),Y
        STA (p2B),Y
        INC a3E
        BNE b6E82
        INC a3F
        LDA a3F
        AND #$F3
        STA a3F
b6E82   INC a2B
        BNE b6E88
        INC a2C
b6E88   JMP j6E63

j6E8B   LDA a2B
        STA a40
        LDA a2C
        STA a41
        LDY #$08
        LDA (p32),Y
        STA a2B
        INY 
        LDA (p32),Y
        STA a2C
        LDY #$00
        LDA #$20
        STA (p3C),Y
        LDY a3D
        LDX a3C
        INX 
        STX a32
        BNE b6EB2
        PHP 
        TYA 
        AND #$F3
        TAY 
b6EB2   STY a33
        LDY #$00
j6EB6   INC a2B
        BNE b6EBC
        INC a2C
b6EBC   LDA (p2B),Y
        CMP #$0D
        BEQ b6F01
        CMP #$1A
        BCS b6EFB
        TAX 
        LDA a2B
        PHA 
        LDA a2C
        PHA 
        DEX 
        TXA 
        CMP a6DAE
        BCC b6ED7
        JMP j6DC1

b6ED7   ASL 
        TAX 
        LDA f8D81,X
        STA a2B
        INX 
        LDA f8D81,X
        STA a2C
        LDY #$00
b6EE6   LDA (p2B),Y
        BEQ b6EF0
        JSR s6F3B
        INY 
        BNE b6EE6
b6EF0   PLA 
        STA a2C
        PLA 
        STA a2B
        LDY #$00
        JMP j6EFE

b6EFB   JSR s6F3B
j6EFE   JMP j6EB6

b6F01   JSR s6F3B
        LDA #<aB400
        STA a2B
        LDA #>aB400
        STA a2C
j6F0C   LDA a2B
        CMP a40
        BNE b6F1B
        LDA a2C
        CMP a41
        BNE b6F1B
        JMP j6F29

b6F1B   LDA (p2B),Y
        JSR s6F3B
        INC a2B
        BNE b6F26
        INC a2C
b6F26   JMP j6F0C

j6F29   LDA a32
        STA a40
        LDA a33
        STA a41
        LDA a3C
        STA a3E
        LDA a3D
        STA a3F
        SEC 
        RTS 

s6F3B   STY a6DB0
        LDY #$00
        STA (p32),Y
        INC a32
        BNE b6F4E
        INC a33
        LDA a33
        AND #$F3
        STA a33
b6F4E   LDY a6DB0
        RTS 

s6F52   LDA a26DD
        BEQ b6F75
        LDA a864D
        CMP #$0A
        BNE b6F75
        JSR s31D3
        BCS b6F75
        LDA a26D9
        CMP #$03
        BEQ b6F75
        CMP #$04
        BEQ b6F75
        LDX #$C2
        LDY #$6F
        JMP j562D

b6F75   LDX #$00
j6F77   CPX a26DD
        BNE b6F7D
        RTS 

b6F7D   LDA a864D,X
        INX 
        CMP #$0A
        BNE b6FAB
        CPX a26DD
        BNE b6F96
        LDA a26DA
        CMP #$07
        BEQ b6F93
        CMP #$08
b6F93   JMP j6F9F

b6F96   LDA a864D,X
        CMP #$0A
        BEQ j6F9F
        CMP #$0B
j6F9F   BNE b6FA8
        LDX #$C2
        LDY #$6F
        JMP j562D

b6FA8   JMP j6FBF

b6FAB   CMP #$0B
        BNE j6FBF
        INX 
        INX 
        LDA a864D,X
        CMP #$0A
        BNE j6FBF
        LDX #$E5
        LDY #$6F
        JMP j562D

j6FBF   JMP j6F77

        .TEXT " *** ILLEGAL FUNCTION DECLA"
        .TEXT "RATION", $0D, $00, " *** ILLEGAL A"
        .TEXT "RRAY DECLARATION", $0D, $00
s7005   JMP s21D3

s7008   JMP s24CE

j700B   JMP j24BD

s700E   JSR s5C9D
        JMP s5CFA

j7014   JSR s58B3
        BCC b701F
        JSR s2502
        JMP j5649

b701F   JSR s700E
        DEC a18
        JSR s56B2
j7027   JSR s58B3
        BCC b702F
        JMP j5649

b702F   JSR s58F5
        BCC b704E
        JSR s5C9D
        JSR s7008
        JSR s7008
        CMP #$0A
        BNE b7046
        LDA #$00
        JMP j700B

b7046   JSR j700B
        LDA #$00
        JSR j700B
b704E   JSR s7008
        CMP #$01
        BNE b706D
        JSR s7008
        CMP #$09
        BNE b7068
        JSR s7008
        CMP #$0A
        BEQ b707F
        JSR j700B
        LDA #$09
b7068   JSR j700B
        LDA #$01
b706D   JSR j700B
        LDX #$A0
        LDY #$70
        JSR j562D
        JSR s56B2
        LDA #$02
        JSR j700B
b707F   LDA #$00
        JSR j700B
        LDA #$10
        JSR s7005
        LDA #$11
        JSR s7005
        JSR s56B2
        JSR s5723
        TXA 
        JSR s7005
        TYA 
        JSR s7005
        JSR s5704
        RTS 

        .TEXT " *** ILLEGAL FUNCTION CALL", $0D, $00
j70BC   JSR s58B3
        BCC b70C7
        JSR s2502
        JMP j5649

b70C7   DEC a18
        JSR s700E
        JSR s56BD
        JSR s5C51
        JSR s58F5
        BCC b70FD
        JSR s5C9D
        JSR s7008
        JSR s7008
        CMP #$0B
        BNE b70F1
        JSR s2502
b70E7   LDA #$09
        JSR j700B
        LDA #$01
        JMP j700B

b70F1   CMP #$09
        BEQ b70E7
        JSR j700B
        LDA #$00
        JSR j700B
b70FD   JSR s7008
        CMP #$00
        BNE b711B
        JSR s7008
        CMP #$09
        BNE b7116
        JSR j700B
        LDA #$00
        JSR j700B
        JMP j7137

b7116   JSR j700B
        LDA #$00
b711B   JSR j700B
        LDX #$83
        LDY #$71
        JSR j562D
        JSR s56B2
        LDA #$02
        JSR j700B
        LDA #$09
        JSR j700B
        LDA #$00
        JSR j700B
j7137   LDA #$05
        JSR s7005
        JSR s7008
        JSR s56B2
        JSR s5723
        TXA 
        JSR s7005
        TYA 
        JSR s7005
        LDA #$13
        JSR s7005
        LDA #$06
        JSR s7005
        JSR s5704
        JSR s7008
        JSR s7008
        CMP #$0B
        BNE b7175
        JSR s7008
        JSR s7008
        LDA #$09
        JSR j700B
        LDA #$00
        JSR j700B
        RTS 

b7175   JSR j700B
        LDA #$09
        JSR j700B
        LDA #$01
        JSR j700B
        RTS 

        .TEXT " *** ILLEGAL SUBSCRIPT", $0D, $00
j719B   JSR s58B3
        BCC b71A3
        JMP j5649

b71A3   JSR s7008
        CMP #$01
        BNE b71B0
        JSR j700B
        JMP j71BA

b71B0   JSR j700B
        LDX #$33
        LDY #$72
        JSR j562D
j71BA   LDA #$01
        STA a48
        LDY #$00
        LDA (p49),Y
        INY 
        CMP #$08
        BNE b71DD
        LDA #$05
        JSR s7005
        LDA (p49),Y
        INY 
        JSR s7005
        LDA (p49),Y
        INY 
        JSR s7005
        LDA #$06
        JSR s7005
b71DD   STY a7232
        JSR s56B2
        LDY a7232
j71E6   LDA (p49),Y
        CMP #$09
        BCC b71F6
        CMP #$0B
        BNE b71F2
        INY 
        INY 
b71F2   INY 
        JMP j71E6

b71F6   CMP #$07
        BCC b71FC
        INY 
        INY 
b71FC   LDA (p49),Y
        JSR j700B
        CPY a7232
        BEQ b720A
        DEY 
        JMP b71FC

b720A   JSR s58F5
        BCS b7227
        CMP #$0B
        BNE b7227
        JSR s7008
        JSR s7008
        JSR s7008
        LDA #$09
        JSR j700B
        LDA #$00
        JSR j700B
        RTS 

b7227   LDA #$09
        JSR j700B
        LDA #$01
        JSR j700B
        RTS 

a7232   .TEXT $00, " *** NOT A STRUCT OR UNION", $0D, $00
j724F   JSR s58B3
        BCC b7257
        JMP j5649

b7257   JSR s5C9D
        JSR s7008
        CMP #$00
        BNE b7278
        JSR s7008
        CMP #$09
        BNE b7273
        JSR j700B
        LDA #$00
        JSR j700B
        JMP j7294

b7273   JSR j700B
        LDA #$00
b7278   JSR j700B
        LDX #$9C
        LDY #$72
        JSR j562D
        JSR s56B2
        LDA #$02
        JSR j700B
        LDA #$09
        JSR j700B
        LDA #$00
        JSR j700B
j7294   JSR s7008
        LDA #$01
        JMP j700B

        .TEXT " *** ILLEGAL INDI"
        .TEXT "RECTION", $0D, $00
j72B6   JSR s58B3
        BCC b72BE
        JMP j5649

b72BE   JSR s7008
        CMP #$01
        BNE b72CA
        LDA #$00
        JMP j700B

b72CA   JSR j700B
        LDX #$26
        LDY #$00
        JSR s5604
        JSR s56B2
        LDA #$02
        JSR j700B
        LDA #$09
        JSR j700B
        LDA #$00
        JMP j700B

j72E6   JSR s58B3
        BCC b72EE
        JMP j26BA

b72EE   JSR s700E
        CMP #$02
        BEQ b72F7
        CMP #$04
b72F7   BNE b72FE
        LDA #$16
        JMP s7005

b72FE   CMP #$03
        BNE b7307
        LDA #$17
        JMP s7005

b7307   CMP #$05
        BNE b7310
        LDA #$18
        JMP s7005

b7310   LDX #$2D
        LDY #$00
        JSR s5604
        JSR s56B2
        LDA #$02
        JSR j700B
        LDA #$00
        JMP j700B

j7324   JSR s58B3
        BCC b732C
        JMP j5649

b732C   JSR s700E
        CMP #$02
        BEQ b7339
        CMP #$04
        BEQ b7339
        CMP #$09
b7339   BNE b7340
        LDA #$19
        JMP s7005

b7340   CMP #$03
        BNE b7349
        LDA #$1A
        JMP s7005

b7349   CMP #$05
        BNE b7352
        LDA #$1B
        JMP s7005

b7352   LDX #$21
        LDY #$00
        JSR s5604
        JSR s56B2
        LDA #$02
        JSR j700B
        LDA #$00
        JMP j700B

j7366   JMP s21D3

s7369   JMP s24CE

s736C   JMP j24BD

s736F   JSR s5C9D
        JMP s5CFA

j7375   JSR s58B3
        BCC b737D
        JMP j6795

b737D   JSR s736F
        CMP #$02
        BEQ b7386
        CMP #$04
b7386   BNE b738D
        LDA #$1C
        JMP j7366

b738D   CMP #$03
        BNE b7396
        LDA #$1D
        JMP j7366

b7396   LDX #$AF
        LDY #$00
        JSR s5604
        JSR s56B2
        LDA #$02
        JSR s736C
        LDA #$00
        JMP s736C

j73AA   JSR s58B3
        BCC b73B2
        JMP j5649

b73B2   JSR s75C5
        JSR s7369
        JSR s7369
        JSR s7369
        PHA 
        CMP #$01
        BNE b73C5
        LDA #$02
b73C5   JSR s736C
        LDA #$00
        JSR s736C
        PLA 
        CMP #$01
        BNE b73D7
        LDA #$1F
        JMP j7366

b73D7   CMP #$02
        BEQ b73DD
        CMP #$04
b73DD   BNE b73E9
        LDA #$FF
        JSR j7366
        LDA #$69
        JMP j7366

b73E9   CMP #$03
        BNE b73F2
        LDA #$22
        JMP j7366

b73F2   CMP #$05
        BNE b73FB
        LDA #$23
        JMP j7366

b73FB   CMP #$09
        BNE b7418
        JSR s759C
j7402   LDA #$FF
        JSR j7366
        LDA #$74
        JSR j7366
        LDA a75C3
        JSR j7366
        LDA a75C4
        JMP j7366

b7418   CMP #$0B
        BNE b7422
        JSR s7596
        JMP j7402

b7422   JMP j75E4

j7425   JSR s58B3
        BCC b742D
        JMP j5649

b742D   JSR s75C5
        JSR s7369
        JSR s7369
        JSR s7369
        PHA 
        CMP #$01
        BNE b7440
        LDA #$02
b7440   JSR s736C
        LDA #$00
        JSR s736C
        PLA 
        CMP #$01
        BNE b7452
        LDA #$2B
        JMP j7366

b7452   CMP #$02
        BEQ b7458
        CMP #$04
b7458   BNE b7464
        LDA #$FF
        JSR j7366
        LDA #$6C
        JMP j7366

b7464   CMP #$03
        BNE b746D
        LDA #$26
        JMP j7366

b746D   CMP #$05
        BNE b7476
        LDA #$60
        JMP j7366

b7476   CMP #$09
        BNE b7493
        JSR s759C
j747D   LDA #$FF
        JSR j7366
        LDA #$77
        JSR j7366
        LDA a75C3
        JSR j7366
        LDA a75C4
        JMP j7366

b7493   CMP #$0B
        BNE b749D
        JSR s7596
        JMP j747D

b749D   JMP j75E4

j74A0   JSR s58B3
        BCC b74A8
        JMP j5649

b74A8   JSR s75C5
        JSR s7369
        JSR s7369
        JSR s7369
        PHA 
        CMP #$01
        BNE b74BB
        LDA #$02
b74BB   JSR s736C
        LDA #$00
        JSR s736C
        PLA 
        CMP #$01
        BNE b74CD
        LDA #$61
        JMP j7366

b74CD   CMP #$02
        BEQ b74D3
        CMP #$04
b74D3   BNE b74DF
        LDA #$FF
        JSR j7366
        LDA #$6A
        JMP j7366

b74DF   CMP #$03
        BNE b74E8
        LDA #$20
        JMP j7366

b74E8   CMP #$05
        BNE b74F1
        LDA #$21
        JMP j7366

b74F1   CMP #$09
        BNE b750E
        JSR s759C
j74F8   LDA #$FF
        JSR j7366
        LDA #$75
        JSR j7366
        LDA a75C3
        JSR j7366
        LDA a75C4
        JMP j7366

b750E   CMP #$0B
        BNE b7518
        JSR s7596
        JMP j74F8

b7518   JMP j75E4

j751B   JSR s58B3
        BCC b7523
        JMP j5649

b7523   JSR s75C5
        JSR s7369
        JSR s7369
        JSR s7369
        PHA 
        CMP #$01
        BNE b7536
        LDA #$02
b7536   JSR s736C
        LDA #$00
        JSR s736C
        PLA 
        CMP #$01
        BNE b7548
        LDA #$2A
        JMP j7366

b7548   CMP #$02
        BEQ b754E
        CMP #$04
b754E   BNE b755A
        LDA #$FF
        JSR j7366
        LDA #$6D
        JMP j7366

b755A   CMP #$03
        BNE b7563
        LDA #$24
        JMP j7366

b7563   CMP #$05
        BNE b756C
        LDA #$25
        JMP j7366

b756C   CMP #$09
        BNE b7589
        JSR s759C
j7573   LDA #$FF
        JSR j7366
        LDA #$78
        JSR j7366
        LDA a75C3
        JSR j7366
        LDA a75C4
        JMP j7366

b7589   CMP #$0B
        BNE b7593
        JSR s7596
        JMP j7573

b7593   JMP j75E4

s7596   JSR s7369
        JSR s7369
s759C   JSR s7369
        JSR s7369
        LDA #$00
        JSR s736C
        JSR s56B2
        JSR s5723
        STX a75C3
        STY a75C4
        JSR s5704
        JSR s7369
        LDA #$09
        JSR s736C
        LDA #$00
        JMP s736C

a75C3   .BYTE $00
a75C4   .BYTE $00
s75C5   JSR s7369
        CMP #$01
        BNE b75CF
        JMP s736C

b75CF   JSR s736C
        JSR s56B2
        LDA #$02
        JSR s736C
        LDA #$09
        JSR s736C
        LDA #$01
        JSR s736C
j75E4   LDX #$EB
        LDY #$75
        JMP j562D

        .TEXT " *** ILLEGAL INC"
        .TEXT "REMENT OR DECREMENT", $0D, $00
s7610   JMP s21D3

j7613   LDA a7738
        JSR j24BD
        LDA #$FF
        JMP j24BD

s761E   JSR s24CE
        CMP #$FF
        BNE b762C
        JSR s24CE
        STA a7738
        RTS 

b762C   TAX 
        LDA a7737
        JSR s798D
        JMP s761E

s7636   JSR s692A
        BCS b763C
        RTS 

b763C   LDA a26DA
        CMP #$07
        BNE b7671
        LDX a26DD
        JSR s50E2
        LDX a7737
        LDA #$07
        JSR s798D
        INX 
        LDA a26E3
        JSR s798D
        INX 
        LDA a26E4
        JSR s798D
        INX 
        LDA #$00
        JSR s798D
        INX 
        JSR s798D
        INX 
        JSR s798D
        INX 
        JMP j7688

b7671   LDX a26DD
        BEQ b767E
        DEX 
        LDA a864D,X
        CMP #$09
        BEQ b7681
b767E   LDA a26DA
b7681   LDX a7737
        JSR s798D
        INX 
j7688   LDA a26DD
        BEQ b7697
        LDA a864D
        CMP #$0B
        BNE b7697
        JSR s76B6
b7697   LDA a3B65
        BEQ b76A7
        TXA 
        INX 
        STX a7737
        STX a7738
        JMP j24BD

b76A7   LDA #$00
        JSR s798D
        INX 
        STX a7737
        STX a7738
        JMP s798D

s76B6   STX a7739
        LDX a26DD
        DEX 
        LDA a864D,X
        CMP #$09
        BEQ b76C5
        INX 
b76C5   STX a773A
j76C8   DEX 
        DEX 
        DEX 
        LDA a864D,X
        CMP #$0B
        BEQ b76D5
        JMP s5650

b76D5   INX 
        INX 
        LDA a864D,X
        BNE b76F0
        DEX 
        LDA a864D,X
        BNE b76EF
        DEX 
        STX a773A
        STA a26E3
        STA a26E4
        JMP j76F8

b76EF   INX 
b76F0   DEX 
        DEX 
        STX a773A
        JSR s50E2
j76F8   LDX a7739
        TXA 
        CLC 
        ADC #$01
        JSR s798D
        INX 
        LDA #$0B
        JSR s798D
        INX 
        LDA a26E3
        JSR s798D
        INX 
        LDA a26E4
        JSR s798D
        INX 
        LDA #$00
        JSR s798D
        INX 
        JSR s798D
        INX 
        LDA a7738
        JSR s798D
        INX 
        STX a7739
        LDX a773A
        BEQ b7733
        JMP j76C8

b7733   LDX a7739
        RTS 

a7737   .BYTE $00
a7738   .BYTE $00
a7739   .BYTE $00
a773A   .BYTE $00,$00,$00,$00,$00,$00
a7740   .BYTE $00
a7741   .BYTE $00
a7742   .BYTE $00
j7743   JSR j7755
        JMP j3017

j7749   JSR j790D
        JMP j3017

j774F   JSR j7911
        JMP j3017

j7755   LDX a7737
        JSR s7985
        BEQ b775F
        CMP #$08
b775F   BNE b7764
        JMP s5650

b7764   CMP #$02
        BEQ b7774
        CMP #$04
        BEQ b7774
        CMP #$09
        BNE b7774
        LDY a9E
        CPY #$02
b7774   BNE b77A0
        LDA a9E
        CMP #$02
        BEQ b777F
        JSR s5650
b777F   LDA #$74
        JSR s7610
        LDA a28
        JSR s7610
        LDA a29
        JSR s7610
        JSR s2502
        TXA 
        JSR s7610
        TYA 
        JSR s7610
        LDX #$02
        LDY #$00
        JMP j7880

b77A0   CMP #$05
        BNE b77F1
        LDA a9E
        CMP #$02
        BEQ b77B4
        CMP #$05
        BEQ b77B1
        JSR s5650
b77B1   JMP j77D0

b77B4   JSR s2502
        LDA a01
        PHA 
        ORA #$07
        STA a01
        TYA 
        PHA 
        TXA 
        TAY 
        PLA 
        JSR eB391
        LDX #$78
        LDY #$86
        JSR eBBD4
        PLA 
        STA a01
j77D0   LDA #$76
        JSR s7610
        LDA a28
        JSR s7610
        LDA a29
        JSR s7610
        LDX #$00
b77E1   LDA a8678,X
        JSR s7610
        INX 
        CPX #$05
        BNE b77E1
        LDY #$00
        JMP j7880

b77F1   CMP #$01
        BEQ b77F8
        JMP j7859

b77F8   LDA a9E
        CMP #$02
        BNE b781B
        LDA #$7A
        JSR s7610
        LDA a28
        JSR s7610
        LDA a29
        JSR s7610
        JSR s2502
        TXA 
        JSR s7610
        LDX #$01
        LDY #$00
        JMP j7880

b781B   LDA #$72
        JSR s7610
        LDA a28
        JSR s7610
        LDA a29
        JSR s7610
        LDX #$00
b782C   LDA a8678,X
        JSR s7610
        INX 
        CMP #$00
        BNE b782C
        CLC 
        TXA 
        ADC a28
        STA a28
        BCC b7841
        INC a29
b7841   LDY a7737
        INY 
        JSR s7989
        TAY 
        INY 
        INY 
        INY 
        TXA 
        JSR s7991
        INY 
        LDA #$00
        JSR s7991
        JMP j790D

j7859   CMP #$09
        BNE j7880
        LDA #$73
        JSR s7610
        LDA a28
        JSR s7610
        LDA a29
        JSR s7610
        LDX #$00
b786E   LDA a8678,X
        JSR s7610
        INX 
        CMP #$00
        BNE b786E
        LDX #$02
        LDY #$00
        JMP j7880

j7880   STX a7740
        STY a7741
        CLC 
        TXA 
        ADC a28
        STA a28
        TYA 
        ADC a29
        STA a29
        INC a7737
        LDX a7737
        INC a7737
j789A   JSR s7985
        BNE b78A0
        RTS 

b78A0   TAY 
        TAX 
        INX 
        INX 
        INX 
        CLC 
        JSR s7985
        ADC a7740
        JSR s798D
        INX 
        JSR s7985
        ADC a7741
        JSR s798D
        INY 
        INY 
        CMP f8DB3,Y
        BNE b78CA
        DEX 
        DEY 
        JSR s7985
        CMP f8DB3,Y
        INX 
        INY 
b78CA   BCC b78D9
        JSR s7989
        BNE b78D9
        DEY 
        JSR s7989
        BNE b78D8
        CLC 
b78D8   INY 
b78D9   BCS b78EC
        DEY 
        DEY 
        JSR s7989
        CMP #$0B
        BNE b78EB
        INX 
        JSR s7985
        STA a7737
b78EB   RTS 

b78EC   JSR s7989
        STA a7741
        DEY 
        JSR s7989
        STA a7740
        LDA #$00
        JSR s798D
        DEX 
        JSR s798D
        INX 
        INX 
        INX 
        INX 
        STX a7737
        DEX 
        JMP j789A

j790D   LDA #$00
        BEQ b7913
j7911   LDA #$01
b7913   STA a7742
        LDX a7737
        INX 
j791A   JSR s7985
        BNE b7920
        RTS 

b7920   TAX 
        INX 
        JSR s7985
        BNE b792F
        INX 
        JSR s7985
        BNE b792E
        RTS 

b792E   DEX 
b792F   INX 
        INX 
        JSR s7985
        BNE b7948
        INX 
        JSR s7985
        BNE b7947
        LDA a7742
        BNE b7942
        RTS 

b7942   INX 
        INX 
        JMP j791A

b7947   DEX 
b7948   SEC 
        LDA a28
        SBC f8DB3,X
        STA a28
        INX 
        LDA a29
        SBC f8DB3,X
        STA a29
        CLC 
        DEX 
        DEX 
        DEX 
        JSR s7985
        STA a7740
        ADC a28
        STA a28
        INX 
        JSR s7985
        STA a7741
        ADC a29
        STA a29
        INX 
        LDA #$00
        JSR s798D
        INX 
        JSR s798D
        INX 
        INX 
        INX 
        STX a7737
        DEX 
        JMP j789A

s7985   LDA f8DB3,X
        RTS 

s7989   LDA f8DB3,Y
        RTS 

s798D   STA f8DB3,X
        RTS 

s7991   STA f8DB3,Y
        RTS 

j7995   LDY #$00
        LDA (p34),Y
        STA a31
        CMP #$4B
        BNE b79B3
        LDA a36
        CMP #$0C
        BNE b79B3
        JSR s31D3
        BCS b79AF
        LDA #$01
        JMP j79B1

b79AF   LDA #$02
j79B1   CLC 
        RTS 

b79B3   CMP #$5F
        BNE b79CB
        LDA a36
        CMP #$0C
        BNE b79CB
        JSR s31BF
        BCC b79C7
        LDA #$01
        JMP j79C9

b79C7   LDA #$02
j79C9   CLC 
        RTS 

b79CB   CMP #$0D
        BNE b79E3
        LDA a36
        CMP #$1C
        BNE b79E3
        JSR s6902
        BCC b79DF
        LDA #$01
        JMP j79E1

b79DF   LDA #$02
j79E1   CLC 
        RTS 

b79E3   LDY a35
        LDX a34
        BNE b79EA
        DEY 
b79EA   DEX 
        STX a2B
        STY a2C
        LDY #$00
        LDA (p2B),Y
        STA a7A64
        LDA a31
        CMP #$7D
        BNE b7A1B
        LDA a7A64
        CMP #$09
        BEQ b7A17
        CMP #$0E
        BEQ b7A17
        CMP #$11
        BEQ b7A17
        CMP #$15
        BEQ b7A17
        CMP #$7E
        BEQ b7A17
        LDA #$01
        CLC 
        RTS 

b7A17   LDA #$02
        CLC 
        RTS 

b7A1B   LDA a36
        CMP #$3F
        BNE b7A31
        LDA a7A64
        CMP #$67
        BNE b7A2D
        LDA #$01
        JMP j7A2F

b7A2D   LDA #$02
j7A2F   CLC 
        RTS 

b7A31   LDA #<p7A65
        STA a2B
        LDA #>p7A65
        STA a2C
        LDY #$00
j7A3B   LDA (p2B),Y
        INY 
        CMP a31
        BNE b7A5D
        LDA (p2B),Y
        CMP a36
        BNE b7A5D
        INY 
        LDA (p2B),Y
        INY 
        CMP a7A64
        BNE b7A56
        LDA (p2B),Y
        JMP j7A5B

b7A56   LDA #$03
        SEC 
        SBC (p2B),Y
j7A5B   CLC 
        RTS 

b7A5D   INY 
        INY 
        INY 
        JMP j7A3B

        .BYTE $00
a7A64   .BYTE $00
p7A65   .BYTE $0D,$1C,$0E,$02,$11,$0E,$7D,$02
        .BYTE $15,$0E,$7D,$02,$4B,$0C,$0E,$02
        .BYTE $4B,$1B,$27
        .BYTE $02,$5F,$0C,$0E,$02,$5F,$0D,$0E
        .BYTE $02,$5F,$21,$0E,$02
        .BYTE $60,$0D,$0E,$02,$7D,$04,$0E,$02
        .BYTE $7D,$08,$0E,$02,$7D,$0B,$0E,$02
        .BYTE $7D,$0F,$0E,$02,$7D,$12,$0E,$02
        .BYTE $7D,$16,$0E,$02,$7D,$1A,$0E,$02
        .BYTE $7D,$20,$0E,$02,$7D,$21,$0E,$02
        .BYTE $7D,$26,$0E,$02,$7D,$2A,$0E,$02
        .BYTE $7E,$09,$49,$02,$7E,$0C,$49,$02
        .BYTE $7E,$0E,$49,$02,$7E,$11,$49,$02
        .BYTE $7E,$14,$49,$02,$7E,$15,$49,$02
f7acd=*
