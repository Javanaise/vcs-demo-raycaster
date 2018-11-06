; TIATracker music player
; Copyright 2016 Andre "Kylearan" Wichmann
; Website: https://bitbucket.org/kylearan/tiatracker
; Email: andre.wichmann@gmx.de
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Song author: Glafouk
; Song name: DixVeauxMongoles

; @com.wudsn.ide.asm.hardware=ATARI2600

        processor 6502
        include vcs.h
        include "macro.h"

; TV format switches
PAL             = 1
NTSC            = 0

        IF PAL
; VBlank 48 lignes
; Overscan 36 lignes
; kernal 228 lignes

TIM_VBLANK      = 43
TIM_OVERSCAN    = 36
TIM_KERNEL      = 19


; 229

        ELSE
TIM_VBLANK      = 45
TIM_OVERSCAN    = 38
TIM_KERNEL      = 15
        ENDIF

; =====================================================================
; Macros
; =====================================================================

        MAC BANK_SWITCH_TRAMPOLINE  
        pha             ; push hi byte
        tya             ; Y -> A
        pha             ; push lo byte
        lda $1FF4,x     ; do the bank switch ; 2 banks => FF8, 8 banks ==> FF4
        rts             ; return to target
        nop
        ENDM

; Macro that performs bank switch
        MAC BANK_SWITCH
.Bank   SET {1}
.Addr   SET {2}
        lda #>(.Addr-1)
        ldy #<(.Addr-1)
        ldx #.Bank
        jmp BankSwitch
        ENDM


        MAC MAGI_CALL
.CurrentBank SET {1}
.Bank SET {2}
.Addr SET {3}
        lda #>(.RetAddr - 1)
        pha
        lda #<(.RetAddr - 1)
        pha
        lda #.CurrentBank
        pha
        ldx #.Bank
        lda #>(.Addr-1)
        ldy #<(.Addr-1)
        jmp BankSwitch
.RetAddr
        ENDM

        MAC RET_MAGI_CALL
        pla 
        tax
        jmp BankSwitch + 3
        ENDM

         MAC ST_WORD_ZP
.Value16 SET {1}
.AddrZP SET {2}
        LDA #<.Value16
        STA .AddrZP
        LDA #>.Value16
        STA .AddrZP + 1
        ENDM
        
; taken from http://www.6502.org/source/general/SWN.html
; take bits 7-6 and put them in bits 1-0
; Input: angle (0-255)
; Output: bits 1-0 represents which fourth of the circle the input angle is in.
        MAC HALF_SWN
        ASL  
        ADC  #$80
        ROL  
        ENDM



; =====================================================================
; Variables
; =====================================================================

        SEG.U   variables
        ORG     $80


; todo: 
; virer result, wrapper result sur ystep
; eventuellement virer numCol. numCol = ang - startAng
; -> + 3 bytes back


        include "DixVeauxMongoles.asm_variables.asm"

; test
;player_time_max         ds 1

GlobalSpace equ $89
NumFrame equ GlobalSpace
GlobalSpace_end equ GlobalSpace + 2

MULTEMPS        EQU GlobalSpace_end ; 9 octets de travail pour TIA Tracker + tt_ptr temp variable at the end of this declaration

; bon. samedi.
; fixer le bug du cube semi transparent: impossible, semble s'auto-corriger. Il faudrait desactiver le recalcul quand pas de mouvement.
; recuperer un byte de RAMEncodedPic: done.
; faire la rotation rapide (sans deplacement). Et ne rafraichir le raycasting que quand cela est necessaire
; ajouter la detection de collision avec les murs
; ajouter les murs transparents
; ajouter le pitfall:
;    reinitialiser les pointeurs de multiplication a chaque appel de DoRayCast
;    calculer le pitfall au debut de chaque RayCastDraw
;    oh, il nous faut stocker les coordonnées du pitfall et son orientation qqpart. Ou generer ces données en fonction de numFrame
; ajouter le brouillard (voir si on peut utiliser la meme routine ou pas - je doute)

; RaycastState: 3 bits pour savoir ce qu'on est en train de faire: (du coup on va les cacher dans un autre pointeur)
; 1 pour signaler le rafraichissement complet de l'image (call DoRayCasting)
; 1 pour signaler une rotation a gauche
; 1 pour signaler une rotation a droite
; a chaque ecran:
; si RaycastState est à 000, alors on checke le controleur, sinon on ne checke pas
;   si deplacement (haut ou bas + gauche ou droite ou rien) alors on met a 100 et on initialise numCol a -16
;   si deplacement seulement a gauche on met a 010
;   si deplacement seulement a droite on met a 001
; si Raycast est egal a 100, on appelle (DoRayCast ou RaycastConverter) puis DrawScreen puis (DoRayCast ou RaycastConverter)
; si Raycast est egal a 010, on fait la rotation du raycast precedent et on calcule juste un rayon, puis on appelle RaycastConverter, puis DrawScreen
; si Raycast est egal a 001, on fait la rotation du raycast precedent et on calcule juste un rayon, puis on appelle RaycastConverter, puis DrawScreen
; quand RaycastConverter se termine, il fout le RaycastState a 000.

xpart_square_lo       equ MULTEMPS
xpart_square_hi       equ MULTEMPS + 2 ;.byte $0
xpart_square_lo_comp  equ MULTEMPS + 4 ; .word
xpart_square_hi_comp  equ MULTEMPS + 6 ;.word
ypart_square_lo       equ MULTEMPS + 8
ypart_square_hi       equ MULTEMPS + 10 ;.byte $0, $0
ypart_square_lo_comp  equ MULTEMPS + 12 ; .word
ypart_square_hi_comp  equ MULTEMPS + 14 ;.word
square_lo       equ MULTEMPS + 16
square_hi       equ MULTEMPS + 18 ;.byte $0, $0
square_lo_comp  equ MULTEMPS + 20 ; .word
square_hi_comp  equ MULTEMPS + 22 ;.word

PreviousQuart equ MULTEMPS + 23
;multiplicand    equ MULTEMPS + 24 ;.byte $0                  ;
;multiplicandhi  equ MULTEMPS + 25 ; .byte $0                  ;
;multiplier      equ MULTEMPS + 26 ; .byte $0                  ;
;result          equ MULTEMPS + 24 ; .word $0               ; little endian
MULTEMPS_END    equ MULTEMPS + 24

; le poids fort de posx et posy est sur 4 bits. On pourrait peut etre les grouper ensemble.
RAYCASTER       equ MULTEMPS_END
posx            equ RAYCASTER ;.word
posy            equ RAYCASTER + 2 ;.word
startAng        equ RAYCASTER + 4 ; .byte ; on peut l'utiliser pour le bouclage et le reinitialiser en fin de boucle
;ang             equ RAYCASTER + 5
numCol          equ RAYCASTER + 5 ;.byte $0
;CurrentPFCol    equ RAYCASTER + 7
RAYCASTER_END   equ RAYCASTER + 6

RAYCASTER_WORK  equ RAYCASTER_END

;xpartial byte ; utilisé  au debut pour initialiser intercepts
;ypartial byte

xinterceptLo    equ RAYCASTER_WORK ;.byte
; here we have address where to check map @ [xintercept, ytile]
;coordA          equ RAYCASTER_WORK + 2

xinterceptHi    equ RAYCASTER_WORK + 1 ;.byte
MapX            equ RAYCASTER_WORK + 1 ;.byte
MapXHi            equ RAYCASTER_WORK + 2 ;.byte
ytile           equ RAYCASTER_WORK + 3 ; .byte
; here we have address where to check map @ [xintercept, ytile]
;coordB          equ RAYCASTER_WORK + 4
xtile           equ RAYCASTER_WORK + 4 ; .byte
MapY            equ RAYCASTER_WORK + 4 ;.byte
MapYHi            equ RAYCASTER_WORK + 5 ;.byte
yinterceptHi    equ RAYCASTER_WORK + 6 ; .byte
yinterceptLo    equ RAYCASTER_WORK + 7 ; .byte
result          equ RAYCASTER_WORK + 8
xstep           equ RAYCASTER_WORK + 8 ;.word
ystep           equ RAYCASTER_WORK + 10 ;.word
;xtilestep byte ; constante dependant de quart
;ytilestep byte
;index           .byte $0,$0
;RAYCASTER_WORK_END      equ RAYCASTER_WORK + 11
RAYCASTER_WORK_END      equ RAYCASTER_WORK + 12 ; be homegeneous with ConverterVariables and RaycastDrawWork


; quand le converter travaille, il peut reutiliser l'espace de travail du raycaster
ConverterVariables equ RAYCASTER_WORK
ConverterIterator      equ ConverterVariables
PreviousOffsetDeltaByte equ ConverterVariables + 1
CurrentOffsetDeltaByte equ ConverterVariables + 2

PrevPF0 equ ConverterVariables +3
PrevPF1 equ ConverterVariables +4
PrevPF2 equ ConverterVariables +5
PrevPF3 equ ConverterVariables +6

TempPF0 equ ConverterVariables +7
TempPF1 equ ConverterVariables +8
TempPF2 equ ConverterVariables +9
TempPF3 equ ConverterVariables +10

;FirstDeltaConverterIterator equ ConverterVariables +11
ConverterVariables_end equ ConverterVariables + 11

RaycastDrawWork EQU RAYCASTER_WORK
NbLinesToDraw EQU RaycastDrawWork
NbLinesToDraw2 EQU RaycastDrawWork+1
BottomLineSkipping EQU RaycastDrawWork+2
BottomLineRepeatCount equ RaycastDrawWork+3
RaycastDrawWork_end EQU RAYCASTER_WORK + 4


RayCasterOut EQU RAYCASTER_WORK_END
RaycastOutputMaxHeight EQU RayCasterOut ; .byte $0
RaycastOutputMinHeight EQU RayCasterOut+1 ; .byte $0
raycastoutputcols EQU RayCasterOut + 2
;       .byte $0,$0,$0,$0
raycastoutput EQU RayCasterOut + 6
;       .byte $0,$0,$0,$0
;       .byte $0,$0,$0,$0
;       .byte $0,$0,$0,$0
;       .byte $0,$0,$0,$0
raycastoutput_end equ RayCasterOut + 22


Output equ raycastoutput_end
RAMEncodedPic   equ raycastoutput_end
TopLineSkipCount equ RAMEncodedPic
;BottomLineRepeatCount equ RAMEncodedPic+1
ColorsData            equ RAMEncodedPic+1
InitialPFData         equ RAMEncodedPic+5
PFDeltasData         equ RAMEncodedPic+9
; 1 byte topLineSkipCount
; 1 byte bottomLineRepeatCount
; 4 bytes col
; 4 bytes of initial PF datas
; double linked list of max 15 PF deltas

; TIA Tracker work variable
tt_ptr                  equ RAYCASTER_WORK ; $89 ;ds 2

; constantes pour le raycast rasterizer
BGColor         equ #$D6
WallColor1      equ #$0D
WallColor2      equ #$02

; =====================================================================
; Start of code
; =====================================================================

        SEG     Code
;        ORG     $1000
;        RORG     $F000
        ORG     $0000
        RORG     $1000

Bank1   SUBROUTINE
Start

;        lda #0
;        sta DemoOffset
;        sta FrameCnt
;        sta FrameCnt+1
;        lda #$FF
;        sta CurEffect

        include "DixVeauxMongoles.asm_init.asm"

; init fonction de multiplication
; a faire une fois avant l'effet
                lda #>square_high
                sta square_hi+1
                sta xpart_square_hi+1
                sta ypart_square_hi+1
                lda #>square_compl_high
                sta square_hi_comp+1
                sta xpart_square_hi_comp+1
                sta ypart_square_hi_comp+1
                lda #>square_low
                sta square_lo+1
                sta xpart_square_lo+1
                sta ypart_square_lo+1
                lda #>square_compl_low
                sta square_lo_comp+1
                sta xpart_square_lo_comp+1
                sta ypart_square_lo_comp+1

; init graphique: playfield en mode reflect, sprite noir a gauche et a droite pour faire un border noir
        LDA #1                  ; reflect
        STA CTRLPF
 ;       LDA #0
 ;       STA COLUP1
 ;       LDA #7
 ;       STA NUSIZ1
 ;       LDA #$FF
 ;       STA GRP1
 ;       STA WSYNC
 ;       SLEEP 65
 ;       STA RESP1
;        LDA #$20
;        STA HMP1
;        STA WSYNC
;        STA HMOVE
;        STA HMCLR
        
        lda #BGColor
        sta COLUBK      ; background color ; todo: mettre ca en variable pour faire l'effet "brouillard"

;                LDA #$60 ;96
;                STA startAng
;                ST_WORD_ZP $0304, posx      ; decalx = $10
;                ST_WORD_ZP $0304, posy      ; plus $10 pour lire en ROM


                LDA -#16
                STA numCol

                LDA PreviousQuart
                AND #$1F        ; Les 5 bits inferieurs sont le poids fort d'un des pointeurs utilisés pour les multiplications
                ORA #$20        ; ce bit sert a forcer la reinitialisation du cache des coordonnees partielles
                STA PreviousQuart
;                LDA #$D0 ;96
;                STA startAng               
;                ST_WORD_ZP $0304, posx      ; decalx = $10
;                ST_WORD_ZP $0304, posy      ; plus $10 pour lire en ROM
                LDA #$22 ;96
                STA startAng               
                ST_WORD_ZP $B7A, posx      ; decalx = $10
                ST_WORD_ZP $DCB, posy      ; plus $10 pour lire en ROM



; =====================================================================
; MAIN LOOP
; =====================================================================

        sta WSYNC
        lda #2
        sta VBLANK
        lda #TIM_OVERSCAN
        sta TIM64T

        ; Do overscan stuff
;        jmp ExecOverscan
;EndOverscan

.waitForIntim10
        lda INTIM
        bne .waitForIntim10

MainLoop:


; ---------------------------------------------------------------------
; VBlank
; ---------------------------------------------------------------------

VBlank  SUBROUTINE
        lda #%1110
.vsyncLoop:
        sta WSYNC
        sta VSYNC
        lsr
        bne .vsyncLoop
        lda #2
        sta VBLANK
        lda #128 ; #TIM_VBLANK
        sta TIM64T

        ; Do VBlank stuff
        include "DixVeauxMongoles.asm_player.asm"

        ; Measure player worst case timing
;        lda #TIM_VBLANK
;        sec
;        sbc INTIM
;        cmp player_time_max
;        bcc .noNewMax
;        sta player_time_max
;.noNewMax:
        JSR DoRayCasting

.waitForVBlank:
        nop     ; ; 22-26 INTIM de marge sur le test (environ 2 rayons et demi de marge)
.waitForVBlankLoop:        
        lda INTIM
        bne .waitForVBlankLoop

        sta WSYNC
        sta VBLANK


; ---------------------------------------------------------------------
; Kernel
; ---------------------------------------------------------------------

Kernel  SUBROUTINE
;        lda #TIM_KERNEL
;        sta T1024T
        LDA #117 ;
        sta TIM64T

;        JSR PtitDegrade
        lda #BGColor
        sta COLUBK      ; background color ; todo: mettre ca en variable pour faire l'effet "brouillard"

;        LDA #40
;        sta COLUBK
    ; Do kernel stuff
        LDA NumFrame+1
        bne .DrawMaPoule
        LDA NumFrame
        cmp #2
        bcc .RetourDrawMaPoule
.DrawMaPoule        
    MAGI_CALL 0, 3, RayCastDraw
.RetourDrawMaPoule    
;    BANK_SWITCH 1, RayCast

;        STA WSYNC
;        JSR PtitDegradeDown
;       MAGI_CALL 0, 1, RayCast
;        STA COLUBK
;        STA COLUPF

.waitForIntim:
        lda INTIM
        bne .waitForIntim

; ---------------------------------------------------------------------
; Overscan
; ---------------------------------------------------------------------

Overscan        SUBROUTINE

        sta WSYNC
        lda #2
        sta VBLANK

        lda #122 ; TIM_OVERSCAN
        sta TIM64T

        ; Do overscan stuff
        JSR DoRayCasting

.waitForIntim
        nop     ; 7 INTIM de marge sur le test (moins d'un rayon)
.waitForIntimLoop        
        lda INTIM
        bne .waitForIntimLoop

        LDA NumFrame+1
        inc NumFrame
        adc #0
        STA NumFrame+1

        jmp MainLoop

DoRayCasting SUBROUTINE
        LDA numCol
        CMP -#16
        bne .notStart
;        LDA startAng
;        CLC
;        ADC #16
;        STA ang      ; init du calcul de la frame
        LDA #0
        STA RaycastOutputMaxHeight
        STA raycastoutputcols
        STA raycastoutputcols+1
        STA raycastoutputcols+2
        STA raycastoutputcols+3
;        STA CurrentPFCol
        LDA #$0F
        STA RaycastOutputMinHeight
;        JSR CalculPartielles
        LDA numCol
.notStart
        CMP #16
        beq .finishedRayCasting        
; TODO: si changement de quart, entre le rayon 0 et 11, faire en deux parties,
;       avec changement de partiels en cours de route.        
        MAGI_CALL 0, 1, RayCast
        rts
.finishedRayCasting
        LDA -#16
        STA numCol

; fait la conversion du raycaster output en image ecran
        MAGI_CALL 0, 3, RayCastConversion

; update position pour voir (todo: updater pour les autres quarts du cercle)
;        LDA NumFrame
;        and #31

;        bne .UpdatePosition
;        ST_WORD_ZP $0304, posx      ; decalx = $10
;        ST_WORD_ZP $0304, posy      ; plus $10 pour lire en ROM
;        ST_WORD_ZP $0496, posx      ; decalx = $10
;        ST_WORD_ZP $0496, posy      ; plus $10 pour lire en ROM
;        JMP .FinUpdatePosition        
;.UpdatePosition        
        JSR CheckGoingUp
        bcc .notGoingUp

        LDA PreviousQuart
        AND #$1F
        ORA #$20
        STA PreviousQuart

        LDA startAng
        HALF_SWN
        AND #3
        tax

        LDA #>(.notGoingUp - 1)
        pha
        LDA #<(.notGoingUp - 1)
        pha

        LDA GoForwardMethodHi,X
        pha
        LDA GoForwardMethodLo,X
        pha
        RTS

.notGoingUp
        JSR CheckGoingDown
        bcc .notGoingDown

        LDA PreviousQuart
        AND #$1F
        ORA #$20
        STA PreviousQuart

        LDA startAng
        HALF_SWN
        AND #3

        TAX
        LDA #>(.notGoingDown - 1)
        pha
        LDA #<(.notGoingDown - 1)
        pha
        LDA GoBackwardMethodHi,X
        pha
        LDA GoBackwardMethodLo,X
        pha
        RTS

.notGoingDown
        JSR CheckGoingLeft
        bcc .notGoingLeft
;        LDA startAng
;        CMP #$F0
;        bcs .leftNotPossible
        INC startAng
        INC startAng
.notGoingLeft
        JSR CheckGoingRight
        bcc .notGoingRight
;        LDA startAng
;        CMP #$51
;        bcc .rightNotPossible
        DEC startAng
        DEC startAng
.rightNotPossible

.notGoingRight
        RTS

GoForwardMethodHi .byte #>(GoForwardMethod_0 - 1),#>(GoForwardMethod_1 - 1),#>(GoForwardMethod_2 - 1),#>(GoForwardMethod_3 - 1)
GoForwardMethodLo .byte #<(GoForwardMethod_0 - 1),#<(GoForwardMethod_1 - 1),#<(GoForwardMethod_2 - 1),#<(GoForwardMethod_3 - 1)
GoBackwardMethodHi .byte #>(GoBackwardMethod_0 - 1),#>(GoBackwardMethod_1 - 1),#>(GoBackwardMethod_2 - 1),#>(GoBackwardMethod_3 - 1)
GoBackwardMethodLo .byte #<(GoBackwardMethod_0 - 1),#<(GoBackwardMethod_1 - 1),#<(GoBackwardMethod_2 - 1),#<(GoBackwardMethod_3 - 1)

GoForwardMethod_0 SUBROUTINE
        LDA startAng
        EOR #$3F
        tax
        lda Sinus256_Bank0+1,x
        lsr
        lsr
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #$0
        sta posx+1

        LDA startAng
        tax
        lda Sinus256_Bank0,x

        lsr
        lsr
        beq .continue
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$FF
        sta posy+1
.continue        
        RTS

GoBackwardMethod_0 SUBROUTINE
        LDA startAng
        EOR #$3F
        tax
        lda Sinus256_Bank0+1,x
        lsr
        lsr
        beq .continue
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #$FF
        sta posx+1
.continue
        LDA startAng
        tax
        lda Sinus256_Bank0,x

        lsr
        lsr
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$0
        sta posy+1
        RTS

GoForwardMethod_1 SUBROUTINE
; -cos(128-ang), -sin(128-ang)
;-> -sin(64 - (128 - ang)), -sin(128-ang)
;-> -sin(ang - 64), -sin(128-ang)
        LDA startAng
        EOR #$40
        tax
        lda Sinus256_Bank0,x
        lsr
        lsr
        beq .continue
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #$FF
        sta posx+1
.continue
        LDA startAng
        EOR #$7F
        tax
        lda Sinus256_Bank0+1,x

        lsr
        lsr
        beq .continue2
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$FF
        sta posy+1
.continue2        
        RTS
GoBackwardMethod_1 SUBROUTINE
        LDA startAng
        EOR #$40
        tax
        lda Sinus256_Bank0,x
        lsr
        lsr
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #$0
        sta posx+1

        LDA startAng
        EOR #$7F
        tax
        lda Sinus256_Bank0+1,x

        lsr
        lsr
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$0
        sta posy+1
        RTS

GoForwardMethod_2 SUBROUTINE
; -cos(ang - 128), +sin(ang - 128)
; -> -sin(64 - (ang - 128)), +sin(ang-128) 
; -> -sin(192 - ang), + sin(ang - 128)
        LDA startAng
        EOR #$BF
        tax
        lda Sinus256_Bank0+1,x
        lsr
        lsr
;        lsr
        beq .continue
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #$FF
        sta posx+1
.continue
        LDA startAng
        EOR #$80
        tax
        LDA Sinus256_Bank0,x
        lsr
        lsr
;        lsr
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$0
        sta posy+1

        RTS


GoBackwardMethod_2 SUBROUTINE
        LDA startAng
        EOR #$BF
        tax
        lda Sinus256_Bank0+1,x
        lsr
        lsr
;        lsr
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #0
        sta posx+1

        LDA startAng
        EOR #$80
        tax
        LDA Sinus256_Bank0,x
        lsr
        lsr
        beq .continue
;        lsr
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$FF
        sta posy+1
.continue
        RTS

GoForwardMethod_3 SUBROUTINE
        LDA startAng
        EOR #$FF
        tax
        LDA Sinus256_Bank0+1,x
        lsr
        lsr
;        lsr
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #0
        sta posy+1

        LDA startAng
        EOR #$C0
        tax
        lda Sinus256_Bank0,x        
        lsr
        lsr
;        lsr
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #0
        sta posx+1
        RTS

GoBackwardMethod_3 SUBROUTINE
        LDA startAng
        EOR #$FF
        tax
        LDA Sinus256_Bank0+1,x
        lsr
        lsr
        beq .continue
;        lsr
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posy
        sta posy
        lda posy+1
        adc #$FF
        sta posy+1
.continue
        LDA startAng
        EOR #$C0
        tax
        lda Sinus256_Bank0,x        
        lsr
        lsr
        beq .continue2
;        lsr
        EOR #$FF
        CLC
        ADC #1
        CLC
        adc posx
        sta posx
        lda posx+1
        adc #$FF
        sta posx+1
.continue2        
        rts


PtitDegrade SUBROUTINE
        LDA #$D0        ; le ptit degradé
        STA COLUBK
        STA WSYNC
        STA WSYNC
        STA WSYNC
        LDA #$D2
        STA COLUBK
        STA WSYNC
        STA WSYNC
        STA WSYNC
        LDA #$D4
        STA COLUBK
        STA WSYNC
        STA WSYNC
        STA WSYNC
        RTS

PtitDegradeDown SUBROUTINE
        LDA #$D4        ; le ptit degradé
        STA COLUBK
        STA WSYNC
        STA WSYNC
        STA WSYNC
        LDA #$D2
        STA COLUBK
        STA WSYNC
        STA WSYNC
        STA WSYNC
        LDA #$D0
        STA COLUBK
        STA WSYNC
        STA WSYNC
        STA WSYNC
        RTS

; Return Carry if going up
CheckGoingUp SUBROUTINE
    LDA #0
    sta SWACNT
    LDA SWCHA
    EOR #$FF
    AND #$10
    CMP #$10
    RTS

CheckGoingDown SUBROUTINE
    LDA #0
    sta SWACNT
    LDA SWCHA
    EOR #$FF
    AND #$20
    CMP #$20
    RTS

CheckGoingLeft SUBROUTINE
    LDA #0
    sta SWACNT
    LDA SWCHA
    EOR #$FF
    AND #$40
    CMP #$40
    RTS

CheckGoingRight SUBROUTINE
    LDA #0
    sta SWACNT
    LDA SWCHA
    EOR #$FF
    AND #$80
    CMP #$80
    RTS


; =====================================================================
; Data
; =====================================================================

        include "DixVeauxMongoles.asm_trackdata.asm"

Sinus256_Bank0
    .byte #$00,#$06,#$0c,#$12,#$19,#$1f,#$25,#$2b,#$31,#$37,#$3e,#$44,#$4a,#$50,#$56,#$5b
    .byte #$61,#$67,#$6d,#$72,#$78,#$7d,#$83,#$88,#$8d,#$93,#$98,#$9d,#$a2,#$a6,#$ab,#$b0
    .byte #$b4,#$b9,#$bd,#$c1,#$c5,#$c9,#$cd,#$d0,#$d4,#$d7,#$db,#$de,#$e1,#$e4,#$e6,#$e9
    .byte #$ec,#$ee,#$f0,#$f2,#$f4,#$f6,#$f7,#$f9,#$fa,#$fb,#$fc,#$fd,#$fe,#$fe,#$ff,#$ff
    .byte #$ff
;texte
;      dc.b 'SALUT'

; =====================================================================
; Vectors
; =====================================================================
        echo "ROM left: ", ($1fed - *)

        org $0FEC
        rorg $1FEC
BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK

Bank2 SUBROUTINE
        ORG     $1000
        RORG    $3000

; Ensure that bank 0 is selected
Start1
;----End of bank-identical code----
;multiply_aab_real_fast
;        BANK_SWITCH 0, RetourMul

        include "raycast.asm"

;        org $2FFA
;        RORG    $FFFA
        org $1FEC
        rorg $3FEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ORG     $3000
;        RORG    $F000
        ORG     $2000
        RORG    $5000
Bank3   SUBROUTINE

Start2
        include "mul8.8x8.asm"        

;        include "mapcheck.asm"
;        org $3FFA
;        RORG    $FFFA
        org $2FEC
        rorg $5FEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ORG     $4000
;        RORG    $F000
        ORG     $3000
        RORG    $7000
Bank4   SUBROUTINE

        include "raycast_converter.asm"
        include "raycast_rasterizer.asm"



        org $3FEC
        rorg $7FEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK
;        org $4FFA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ORG     $5000
;        RORG    $F000
        ORG     $4000
        RORG    $9000
Bank5   SUBROUTINE

        org $4FEC
        rorg $9FEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ORG     $6000
;        RORG    $F000
        ORG     $5000
        RORG    $B000
Bank6   SUBROUTINE

        org $5FEC
        rorg $BFEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ORG     $7000
;        RORG    $F000
        ORG     $6000
        RORG    $D000
Bank7   SUBROUTINE

        org $6FEC
        rorg $DFEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$4C ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word $1FFB      ; RESET
        .word $1000      ; BRK

;        org $7FFA

;        .word $F000      ; NMI
;        .word $F000      ; RESET
;        .word $F000      ; BRK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        ORG     $8000
;        RORG    $F000
        ORG     $7000
        RORG    $F000
Bank8   SUBROUTINE

Start7
        CLEAN_START
        BANK_SWITCH 0, Start


        org $7FEC
        rorg $FFEC
.BankSwitch
        BANK_SWITCH_TRAMPOLINE
    ;$1FF4-$1FFB
    .byte #0,#0,#0,#0
    .byte #0,#0,#0,#$0 ;JMP Start (reading the instruction jumps to bank 7, where Start's address is)
; Bank 0 epilogue
;        org $1FFA
;        rorg $FFFA
;        org $0FFA
;        rorg $1FFA
;        .word $1000      ; NMI
        .word Start7      ; RESET
        .word Start7      ; BRK


