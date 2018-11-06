RayCastConversion SUBROUTINE
; ok
; rc = tableau de bytes (2 colonnes par byte)
; rc = raycast

; H=15
; X=0;
; A=RC(0)
; Start encoding to PF

        LDX #0
        STX TempPF0
        STX TempPF1
        STX TempPF2
        STX TempPF3
        
        LDX RaycastOutputMaxHeight
        STX ConverterIterator
;        DEX
;        STX FirstDeltaConverterIterator
LoopCompute
        LDA TempPF0
        STA PrevPF0
        LDA TempPF1
        STA PrevPF1
        LDA TempPF2
        STA PrevPF2
        LDA TempPF3
        STA PrevPF3

; Y=A
; A=A & 15
; CMP H
; ROL TempPF0
; LDA HIGHQUAD,Y
; CMP H
; ROL TempPF0
        ; or 63 cycles ici si on fait tenir la hauteur sur 3 bits peut etre
        LDA RayCasterOut+6
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF0
        AND #15
        CMP ConverterIterator
        ROL TempPF0             ; total 27 cycles for 2 pixels -> 108 for whole register
        LDA RayCasterOut+7
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF0
        AND #15
        CMP ConverterIterator
        ROL TempPF0
        LDA RayCasterOut+8
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF0
        AND #15
        CMP ConverterIterator
        ROL TempPF0
        LDA RayCasterOut+9
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF0
        AND #15
        CMP ConverterIterator
        ROL TempPF0

        LDA RayCasterOut+10
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF1
        AND #15
        CMP ConverterIterator
        ROR TempPF1             ; total 27 cycles for 2 pixels -> 108 for whole register
        LDA RayCasterOut+11
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF1
        AND #15
        CMP ConverterIterator
        ROR TempPF1
        LDA RayCasterOut+12
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF1
        AND #15
        CMP ConverterIterator
        ROR TempPF1
        LDA RayCasterOut+13
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF1
        AND #15
        CMP ConverterIterator
        ROR TempPF1

        LDA RayCasterOut+14
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF2
        AND #15
        CMP ConverterIterator
        ROL TempPF2             ; total 27 cycles for 2 pixels -> 108 for whole register
        LDA RayCasterOut+15
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF2
        AND #15
        CMP ConverterIterator
        ROL TempPF2
        LDA RayCasterOut+16
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF2
        AND #15
        CMP ConverterIterator
        ROL TempPF2
        LDA RayCasterOut+17
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROL TempPF2
        AND #15
        CMP ConverterIterator
        ROL TempPF2

        LDA RayCasterOut+18
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF3
        AND #15
        CMP ConverterIterator
        ROR TempPF3             ; total 27 cycles for 2 pixels -> 108 for whole register
        LDA RayCasterOut+19
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF3
        AND #15
        CMP ConverterIterator
        ROR TempPF3
        LDA RayCasterOut+20
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF3
        AND #15
        CMP ConverterIterator
        ROR TempPF3
        LDA RayCasterOut+21
        TAY
        LDX .HIGHQUAD,Y
        CPX ConverterIterator
        ROR TempPF3
        AND #15
        CMP ConverterIterator
        ROR TempPF3

        LDA ConverterIterator
        CMP RaycastOutputMaxHeight ; first loop ? put the 2 bytes of begin and end and the 4 bytes of color and the 4 bytes of PF data 
        bne ComputeDelta ; otherwise compute the deltas
; 1ere iteration: ecrit le bootstrap de l'ecran
;        LDA RaycastOutputMaxHeight
;        EOR #$0F
;        STA Output ; topLineSkipCount = 15 - maxHeight
;        LDA RaycastOutputMinHeight
;        STA Output+1 ; bottomLineRepeatCount, will be >= 1 (min(raycast.mapDist))
        LDA RaycastOutputMinHeight
        ASL
        ASL
        ASL
        ASL
        ORA RaycastOutputMaxHeight
        EOR #$0F ; ; topLineSkipCount = 15 - maxHeight
        STA Output

        LDA raycastoutputcols
        STA Output+1
        LDX raycastoutputcols+1
        LDA .REVERSEDBITS,X
        STA Output+2
        LDA raycastoutputcols+2
        STA Output+3
        LDX raycastoutputcols+3
        LDA .REVERSEDBITS,X
        STA Output+4
        LDA TempPF0
        STA Output+5
        LDA TempPF1
        STA Output+6
        LDA TempPF2
        STA Output+7
        LDA TempPF3
        STA Output+8

        LDA #9
        STA CurrentOffsetDeltaByte
        STA PreviousOffsetDeltaByte
        JMP FinLoop

ComputeDelta
        LDY CurrentOffsetDeltaByte
        INY

; reste a inverser l'ordre des deltas

; quand on compare avec le PF precedent, il ne peut y avoir que des valeurs en plus ou egales (propriété du pattern affiché)
        LDA PrevPF0
        EOR TempPF0
        BEQ PFSetDelta_0     ;Si PrevPF0 < TempPF0 alors il y a un delta
                                 ;sinon PrevPF0 == TempPF0, Jump to CmpPF1 
PFSetDelta_1
        STA Output,Y
        INY
        LDA PrevPF1
        EOR TempPF1
        BEQ PFSetDelta_10
PFSetDelta_11
        STA Output,Y
        INY
        LDA PrevPF2
        EOR TempPF2
        BEQ PFSetDelta_110
PFSetDelta_111
        STA Output,Y
        INY
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_1110
PFSetDelta_1111
        STA Output,Y
        INY
        LDA #$0F
        jmp FinDelta
PFSetDelta_1110
        LDA #$0E
        jmp FinDelta
PFSetDelta_110
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_1100
PFSetDelta_1101
        STA Output,Y
        INY
        LDA #$0D
        jmp FinDelta
PFSetDelta_1100
        LDA #$0C
        jmp FinDelta
PFSetDelta_10
        LDA PrevPF2
        EOR TempPF2
        BEQ PFSetDelta_100
PFSetDelta_101
        STA Output,Y
        INY
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_1010
PFSetDelta_1011
        STA Output,Y
        INY
        LDA #$0B
        jmp FinDelta
PFSetDelta_1010
        LDA #$0A
        jmp FinDelta
PFSetDelta_100
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_1000
PFSetDelta_1001
        STA Output,Y
        INY
        LDA #$09
        jmp FinDelta
PFSetDelta_1000
        LDA #$08
        jmp FinDelta

PFSetDelta_0
        LDA PrevPF1
        EOR TempPF1
        BEQ PFSetDelta_00
PFSetDelta_01
        STA Output,Y
        INY
        LDA PrevPF2
        EOR TempPF2
        BEQ PFSetDelta_010
PFSetDelta_011
        STA Output,Y
        INY
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_0110
PFSetDelta_0111
        STA Output,Y
        INY
        LDA #$07
        jmp FinDelta
PFSetDelta_0110
        LDA #$06
        jmp FinDelta
PFSetDelta_010
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_0100
PFSetDelta_0101
        STA Output,Y
        INY
        LDA #$05
        jmp FinDelta
PFSetDelta_0100
        LDA #$04
        jmp FinDelta
PFSetDelta_00
        LDA PrevPF2
        EOR TempPF2
        BEQ PFSetDelta_000
PFSetDelta_001
        STA Output,Y
        INY
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_0010
PFSetDelta_0011
        STA Output,Y
        INY
        LDA #$03
        jmp FinDelta
PFSetDelta_0010
        LDA #$02
        jmp FinDelta
PFSetDelta_000
        LDA PrevPF3
        EOR TempPF3
        BEQ PFSetDelta_0000
PFSetDelta_0001
        STA Output,Y
        INY
        LDA #$01
        jmp FinDelta
PFSetDelta_0000
        LDA #$00
        jmp FinDelta


; remaining: encodage retour arriere
; table how much to add to X for (X & 0xF)
; ecriture dans le quartet de poids fort de X+INC, la valeur qu'on avait. et voila.


FinDelta
        LDX CurrentOffsetDeltaByte
        STA Output,X  ; stockage du nouveau delta qu'on vient de finir d'écrire.
        LDA RaycastOutputMaxHeight
        sec
        sbc #1
        CMP ConverterIterator ; 1er delta ? si oui, pas de reverse delta
;        CMP FirstDeltaConverterIterator ; 1er delta ? si oui, pas de reverse delta
        beq FinWriteDeltas
; ecriture du reverse Delta
        LDX PreviousOffsetDeltaByte
        LDA Output,X
        ASL
        ASL
        ASL
        ASL
        LDX CurrentOffsetDeltaByte
        ORA Output,X
        STA Output,X
FinWriteDeltas        
        STX PreviousOffsetDeltaByte
        STY CurrentOffsetDeltaByte

FinLoop
        LDA ConverterIterator
        CMP RaycastOutputMinHeight
        beq FinCompute
        DEC ConverterIterator
        jmp LoopCompute        
        
FinCompute
; ecriture du delta final (only reverse delta - no forward)
        LDX PreviousOffsetDeltaByte
        LDA Output,X
        ASL
        ASL
        ASL
        ASL
        LDX CurrentOffsetDeltaByte
        STA Output,X

        RET_MAGI_CALL

        ALIGN 256
.HIGHQUAD 
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
        .byte #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
        .byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04
        .byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04
        .byte #$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05
        .byte #$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05
        .byte #$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06
        .byte #$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06
        .byte #$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07        
        .byte #$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07        
        .byte #$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08        
        .byte #$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08        
        .byte #$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09        
        .byte #$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09        
        .byte #$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A        
        .byte #$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A        
        .byte #$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B        
        .byte #$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B        
        .byte #$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C        
        .byte #$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C        
        .byte #$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D
        .byte #$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D
        .byte #$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E        
        .byte #$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E        
        .byte #$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F        
        .byte #$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F        
; this 256 bytes table performs the following function:
; if X = b7b6b5b4b3b2b1b0 (in binary format)
; f(X) = b0b1b2b3b4b5b6b7
; hence name, "ReversedBits"
.REVERSEDBITS
        .byte $00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
        .byte $08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
        .byte $04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
        .byte $0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
        .byte $02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
        .byte $0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
        .byte $06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
        .byte $0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
        .byte $01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
        .byte $09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
        .byte $05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
        .byte $0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
        .byte $03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
        .byte $0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
        .byte $07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
        .byte $0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

        
        