
; POC d'affichage d'un ecran type wolf3d
; avec les datas de l'ecran encodés sous forme de deltas
; format:
; 1 byte pour dire a quelle ligne le dessin commence
; 1 byte pour dire combien de fois le motif se repete apres que les deltas soient finis de consommer et avant d'arriver a la moitié de l'écran
; 4 octets de couleur (indique pour chaque colonne ecran la couleur, 1 bit par colonne)
; 4 octets PF de depart (lignes blanches et noires confondues)
; puis encodage de deltas: 1 byte indique quels octets PF changent.
; Bit7-4: utilisé pour le tracé a l'envers des deltas (seconde moitié de l'écran, on rejoue les deltas mais en ordre inverse). donc decrit les deltas precedents.
; Bit3: 1 si PF0 change, Bit2: 1 si PF1 change, Bit1: 1 si PF2 change, Bit0: 1 si PF3 change
; puis suivent les valeurs avec lesquelles XORer la valeur actuelle du PF concerné pour obtenir la nouvelle valeur.
; 

;Temp            equ $E0
;NbHorizonRepeat equ $E1


RayCastDraw SUBROUTINE
        ; init
        LDA InitialPFData
        STA TempPF0
        LDA InitialPFData + 1
        STA TempPF1
        LDA InitialPFData + 2
        STA TempPF2
        LDA InitialPFData + 3
        STA TempPF3
        
        LDA TopLineSkipCount
        lsr
        lsr
        lsr
        lsr
        sta BottomLineRepeatCount        
        LDA TopLineSkipCount
        AND #$0F
        EOR #$0F
        clc
;        sec
;        sbc BottomLineRepeatCount       ; substraction will always be positive -> carry will be set
        adc #0                          ; + 1. If 15 - 0 , result is 15 so we draw 16 lines
        STA NbLinesToDraw
        STA NbLinesToDraw2
        sec
        sbc BottomLineRepeatCount
        clc
        adc #2
        sta BottomLineSkipping

; wait correct number of lines according to TopLineSkipCount
        LDA TopLineSkipCount
        AND #$0F
        tax
        beq .endLineSkipping
.loopSkipLines
        sta WSYNC
        sta WSYNC
        sta WSYNC
        dex
        bne .loopSkipLines
        
;        LDA #13
;        STA Temp; nb de lignes a tracer (incluant les lignes repetees)
;        LDA RAMEncodedPic + 1
;        STA NbHorizonRepeat
.endLineSkipping
        LDX #0         ; start des deltas
        jmp BigLoop1
        
        ALIGN 256
BigLoop1


;       ldx #1
;        ldy #2  ; nb de fois que le motif est repete pour chaque ligne
LittleLoop1
; ligne3
        sta WSYNC

        lda #WallColor2
        sta COLUPF      ; +5
        
        LDA ColorsData
        EOR #$FF
        AND TempPF0
        sta PF1         ; +11  
        
        LDA ColorsData + 1
        EOR #$FF
        AND TempPF1
        sta PF2
        
;        SLEEP 10
        LDA PFDeltasData,X
        and #$0F
        tay
        nop
       
        LDA ColorsData + 2
        EOR #$FF
        And TempPF2
        sta PF2
        
        LDA ColorsData + 3
        EOR #$FF
        And TempPF3
        sta PF1

; 15 cycles ici 
; ligne4
        sta WSYNC

        lda #WallColor1
        sta COLUPF      ; +5
        
        LDA ColorsData
        AND TempPF0
        sta PF1         ; +11  
        
        LDA ColorsData + 1
        AND TempPF1
        sta PF2
        
        SLEEP 6 ; 14
        LDA NbLinesToDraw
        cmp BottomLineRepeatCount
        bcc .FinUpdatePF
       
        LDA.w ColorsData + 2
        And TempPF2
        sta PF2
        
        LDA ColorsData + 3
        And TempPF3
        sta PF1

        LDA UpdateUpperHi,y
        pha
        LDA UpdateUpperLo,y
        pha

        LDA #BGColor ; stop display
        STA COLUPF

        inx
        rts     ; go make the update: this is in fact a call. and the return will be @ FinUpdateUpper

.FinUpdatePF
        LDA ColorsData + 2
        And TempPF2
        sta PF2
        
        LDA ColorsData +3 
        And TempPF3
        sta PF1

        STA WSYNC
        LDA #BGColor ; stop display
        STA COLUPF
FinUpdateUpper


;       LDA RAMEncodedPic,X
;        cmp #0
        dec NbLinesToDraw
        beq .FinBigLoop1
        jmp BigLoop1
.FinBigLoop1        
;        jmp .FinDraw    ; todo : remove :)

; deuxieme partie de l'ecran: miroir horizontal du premier , rejouons les deltas a l'envers
;        LDA #13
;        STA Temp; nb de lignes a tracer

        dex ; on va sur le byte de controle precedent le byte de fin (ps: on n'a plus de byte de fin)

BigLoop2


;       ldx #1
;        ldy #2  ; nb de fois que le motif est repete pour chaque ligne
LittleLoop2
; ligne3
        sta WSYNC

        lda #WallColor2
        sta COLUPF      ; +5
        
        LDA ColorsData
        EOR #$FF
        AND TempPF0
        sta PF1         ; +11  
        
        LDA ColorsData + 1
        EOR #$FF
        AND TempPF1
        sta PF2
        
;        SLEEP 10
        LDY PFDeltasData,X
        LDA Local_LSR4,Y
        TAY
       
        LDA ColorsData + 2
        EOR #$FF
        And TempPF2
        sta PF2
        
        LDA ColorsData + 3
        EOR #$FF
        And TempPF3
        sta PF1

; 15 cycles ici 
; ligne4
        sta WSYNC

        lda #WallColor1
        sta COLUPF      ; +5
        
        LDA ColorsData
        AND TempPF0
        sta PF1         ; +11  
        
        LDA ColorsData + 1
        AND TempPF1
        sta PF2
        
        SLEEP 6 ; 14
        LDA NbLinesToDraw2
        cmp BottomLineSkipping ;BottomLineRepeatCount
        bcs .FinUpdatePF2
       
        LDA.w ColorsData + 2
        And TempPF2
        sta PF2
        
        LDA ColorsData + 3
        And TempPF3
        sta PF1

        LDA UpdateLowerHi,y
        pha
        LDA UpdateLowerLo,y
        pha

        LDA #BGColor ; stop display
        STA COLUPF

        dex
        rts     ; go make the update

.FinUpdatePF2
        LDA ColorsData + 2
        And TempPF2
        sta PF2
        
        LDA ColorsData + 3
        And TempPF3
        sta PF1

        STA WSYNC
        LDA #BGColor ; stop display
        STA COLUPF
FinUpdateLower


;       LDA RAMEncodedPic,X
;        cmp #0
        dec NbLinesToDraw2
        beq .FinBigLoop2
        jmp BigLoop2
.FinBigLoop2        
;        STA WSYNC
        LDA #BGColor ; stop display
        STA COLUPF

;        jsr UpdatePFLower
 
;       LDA RAMEncodedPic,X
;        cmp #0
;        dec Temp
;        bne BigLoop2

.FinDraw
        sta WSYNC
        LDA #0
        sta PF0
        sta PF1
        sta PF2
        

        RET_MAGI_CALL


;................................
;................................
;...............................X
;XX........................XXXXX.
;..XX.................XXXXX......
;....XX..........XXXXX...........
;......XX...XXXXX................
;........XXX.....................
;................................
;................................
;................................
;................................
;................................
;................................


        ALIGN 256
UpdateUpperLo
        .byte #<UpdateUpper0000-#1,#<UpdateUpper0001-#1,#<UpdateUpper0010-#1,#<UpdateUpper0011-#1
        .byte #<UpdateUpper0100-#1,#<UpdateUpper0101-#1,#<UpdateUpper0110-#1,#<UpdateUpper0111-#1
        .byte #<UpdateUpper1000-#1,#<UpdateUpper1001-#1,#<UpdateUpper1010-#1,#<UpdateUpper1011-#1
        .byte #<UpdateUpper1100-#1,#<UpdateUpper1101-#1,#<UpdateUpper1110-#1,#<UpdateUpper1111-#1
UpdateUpperHi
        .byte >(UpdateUpper0000-1),>(UpdateUpper0001-1),>(UpdateUpper0010-1),>(UpdateUpper0011-1)
        .byte >(UpdateUpper0100-1),>(UpdateUpper0101-1),>(UpdateUpper0110-1),>(UpdateUpper0111-1)
        .byte >(UpdateUpper1000-1),>(UpdateUpper1001-1),>(UpdateUpper1010-1),>(UpdateUpper1011-1)
        .byte >(UpdateUpper1100-1),>(UpdateUpper1101-1),>(UpdateUpper1110-1),>(UpdateUpper1111-1)

UpdateLowerLo
        .byte #<UpdateLower0000-#1,#<UpdateLower0001-#1,#<UpdateLower0010-#1,#<UpdateLower0011-#1
        .byte #<UpdateLower0100-#1,#<UpdateLower0101-#1,#<UpdateLower0110-#1,#<UpdateLower0111-#1
        .byte #<UpdateLower1000-#1,#<UpdateLower1001-#1,#<UpdateLower1010-#1,#<UpdateLower1011-#1
        .byte #<UpdateLower1100-#1,#<UpdateLower1101-#1,#<UpdateLower1110-#1,#<UpdateLower1111-#1
UpdateLowerHi
        .byte >(UpdateLower0000-1),>(UpdateLower0001-1),>(UpdateLower0010-1),>(UpdateLower0011-1)
        .byte >(UpdateLower0100-1),>(UpdateLower0101-1),>(UpdateLower0110-1),>(UpdateLower0111-1)
        .byte >(UpdateLower1000-1),>(UpdateLower1001-1),>(UpdateLower1010-1),>(UpdateLower1011-1)
        .byte >(UpdateLower1100-1),>(UpdateLower1101-1),>(UpdateLower1110-1),>(UpdateLower1111-1)

        ALIGN 256
        nop
        nop
UpdateUpper0000
        jmp FinUpdateUpper

UpdateUpper0001
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper0010
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        jmp FinUpdateUpper
UpdateUpper0011
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper0100
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        jmp FinUpdateUpper
UpdateUpper0101
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper0110
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        jmp FinUpdateUpper
UpdateUpper0111
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper1000
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        jmp FinUpdateUpper
UpdateUpper1001
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper1010
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        jmp FinUpdateUpper
UpdateUpper1011
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper1100
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        jmp FinUpdateUpper
UpdateUpper1101
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper
UpdateUpper1110
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        jmp FinUpdateUpper
UpdateUpper1111
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        INX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        INX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        INX     
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        INX     
        jmp FinUpdateUpper

        

UpdatePFUpper2 SUBROUTINE
        LDA PFDeltasData,X
        inx
        and #$0F
        tay
        LDA UpdateUpperHi,y
        pha
        LDA UpdateUpperLo,y
        pha
        rts
        
     

        ALIGN 256
        nop
        nop
UpdateLower0000
        jmp FinUpdateLower

UpdateLower0001
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        jmp FinUpdateLower
UpdateLower0010
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        jmp FinUpdateLower
UpdateLower0011
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        jmp FinUpdateLower
UpdateLower0100
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        jmp FinUpdateLower
UpdateLower0101
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        jmp FinUpdateLower
UpdateLower0110
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        jmp FinUpdateLower
UpdateLower0111
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        jmp FinUpdateLower
UpdateLower1000
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1001
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1010
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1011
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1100
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1101
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1110
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower
UpdateLower1111
        LDA PFDeltasData,X
        EOR TempPF3
        STA TempPF3
        DEX     
        LDA PFDeltasData,X
        EOR TempPF2
        STA TempPF2
        DEX     
        LDA PFDeltasData,X
        EOR TempPF1
        STA TempPF1
        DEX     
        LDA PFDeltasData,X
        EOR TempPF0
        STA TempPF0
        DEX     
        jmp FinUpdateLower        
 

        ALIGN 256
Local_LSR4
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
        .byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04
        .byte #$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05
        .byte #$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06
        .byte #$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07
        .byte #$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08
        .byte #$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09
        .byte #$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A
        .byte #$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B
        .byte #$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C
        .byte #$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D
        .byte #$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E
        .byte #$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F

