


        MAC ST_WORD_X_ZP
.TableLo SET {1}
.TableHi SET {2}
.AddrZP  SET {3}
        LDA .TableLo,X
        STA .AddrZP
        LDA .TableHi,X
        STA .AddrZP+1
        ENDM

        MAC MOVSW_ZP_ZP
.SrcZP SET {1}
.DestZP  SET {2}
        LDA .SrcZP
        STA .DestZP
        LDA .SrcZP+1
        STA .DestZP+1
        ENDM

        MAC ADD_WORD_ZP
.ResultZP  SET {1}
.Arg1ZP SET {2}
.Arg2ZP  SET {3}
        LDA .Arg1ZP
        CLC
        ADC .Arg2ZP
        STA .ResultZP
        LDA .Arg1ZP+1
        ADC .Arg2ZP+1
        STA .ResultZP+1
        ENDM

; angle de 0 a 89 degres (enfin )
RayCast_0 SUBROUTINE
;        LDA #0
;        sta numCol

; Calcul Coordonnees Partielles
        LDA posx
        EOR #$FF
        CLC
        ADC #1
        bcc .xpartialok
        LDA #$FF        
.xpartialok
        sta xpart_square_lo
        sta xpart_square_hi
        eor #$FF
        sta xpart_square_lo_comp
        sta xpart_square_hi_comp

        LDA posy
;        bne .ypartialok
;        LDA #1
.ypartialok
        sta ypart_square_lo
        sta ypart_square_hi
        eor #$FF
        sta ypart_square_lo_comp
        sta ypart_square_hi_comp

RayCast_0_Known_Partials:
; case quart=2
;        case 1:
;        {
;          xtilestep = -1;
;          ytilestep = -1;
;          horzop = JLE;
;          vertop = JLE;
;          xstep = - MyTan((int)ALPHA256 - 64); //-tan(RAD(ALPHA256 - 64.0));
;          ystep = -MyTan(128 - (int)ALPHA256); //-tan(RAD(128.0  - 0.01 - ALPHA256)); // - 1
;          xpartial = (viewx & 255); //MAX(viewx - floor(viewx), 0.000);       //xpartialdown;
;          ypartial = (viewy & 255); //MAX(viewy - floor(viewy), 0.000);       //ypartialdown;
;          break;
;        }
;        case 0:
;        {
;          xtilestep = 1;
;;;          ytilestep = -1;
;          horzop = JGE;
;          vertop = JLE;
;          xstep = MyTan(64 - (int)ALPHA256); //tan(RAD(64.0 - 0.001 - ALPHA256)); //64 - 1 - ALPHA256));  // - 1 ?
;          ystep = -MyTan((int)ALPHA256); //-tan(RAD(ALPHA256));
;          xpartial = ((viewx & 255) ^ 255) + 1; // + 1 ? //1.0 - MAX(viewx - floor(viewx), 0.000); //xpartialup;
;          ypartial = (viewy & 255); //MAX(viewy - floor(viewy), 0.000);       //ypartialdown;
;          break;

;        LDA ang
        LDA startAng
        sec
        sbc numCol
;        sec
;        sbc #192
        EOR #$3F
        tax
        ST_WORD_X_ZP TangentLo+1, TangentHi+1, xstep
 ;       LDA ang
        LDA startAng
        sec
        sbc numCol
        tax
;        inx
;        CLC
;        ADC #1
;        tax
        ST_WORD_X_ZP TangentLo, TangentHi, ystep

        ;;;;;;;;;;;;;;;;;;
;        STA multiplier
;        LDX ystep
        LDY ystep+1
        ; jump to bank #2 for the mul
        CMP $1FF6
quart0_init_yintercept:
       echo "Offset quart0_init_yintercept: ", (*)

        ORG     $1000 + (quart0_init_yintercept_impl_end - $5000)
        RORG    $3000 + (quart0_init_yintercept_impl_end - $5000)


;        clc             ; A = yinterceptLo
        SEC
        LDA posy
        sbc yinterceptLo
        STA yinterceptLo
        lax posy+1
        sbc yinterceptHi
        STA yinterceptHi   ; yintercept = viewy - ((ystep * xpartial) 
        
        DEX
        STX ytile

;        LDX posx+1
;        INX
;        STX xtile     ; xcoord for yintercept
        
        ;;;;;;;;;;;;;;;
;        STA multiplier
;        MOVSW_ZP_ZP xstep, multiplicand
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        ADD_WORD_ZP xintercept, posx, result   ; xintercept = viewx - ((xstep * ypartial) >> 8);
        LDY xstep+1
        CMP $1FF6
quart0_init_xintercept:
       echo "Offset quart0_init_xintercept: ", (*)        
        ORG     $1000 + (quart0_init_xintercept_impl_end - $5000)
        RORG    $3000 + (quart0_init_xintercept_impl_end - $5000)

        CLC
        LDA posx
        ADC xinterceptLo
        STA xinterceptLo
        LAX posx+1
        ADC xinterceptHi
        STA xinterceptHi

;        LDY posx+1
;        INY ; y = xtile
        INX
        STX xtile     ; xcoord for yintercept
 
;        LDX posy+1
;        INX
;        STX ytile

;        RET_MAGI_CALL
;        LDA #30
;        STA COLUBK
        
;        ldy ytile
;        txs ; save xtile to s 
; Check collisions
.vertCheck
;       if (yintercept >> 8) >= ytile)) goto horzEntry;
 ;       LDX yinterceptHi ;+1
 ;       cpx ytile
;        bcs .horzEntry
        ldx ytile
        cpx yinterceptHi
        bpl .horzEntry  ; eq. bcs for signed numbers
.vertEntry
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        tsx

        LDX yinterceptHi ; 2
        LDY LSR4,X ; 4
        LDA (MapY),Y ; 5

;        tya
;        LDX yinterceptHi ;+1
;        ORA LSR4,X
;        ORA xtile
;        TAX
;        LDA Map,X   ; 12 cycles


;        MAGI_CALL 3, 2, CheckCoordB
;        CHECK_MAP yinterceptHi, xtile
;       LDY #0
;       LDA (coordB),y
        bne .hitVert
;        ADD_WORD_ZP yintercept, yintercept, ystep
        SEC
        LDA yinterceptLo
        SBC ystep
        STA yinterceptLo
        LDA yinterceptHi
        SBC ystep+1
        STA yinterceptHi

;        INY
        INC xtile
        bpl .vertCheck ; always jump, if in col 0 we always have intersection it is fine. Beware not going to .hitVert from here
.hitVert
;        LDA #0
;        STA COLUBK
;        LDY numCol
;        LDX Div8,Y
;        clc     ; sec for hitHorz
;        rol raycastoutputcols,x

; viewy - yintercept
        lda posy        ; calcul poids faible
        sec
        sbc yinterceptLo
        sta ystep
        lda posy+1 ; calcul poids fort
        sbc yinterceptHi
        sta ystep+1
        
        lda #0  ; calcul poids faible
;        sec    ; comme le resultat de la soustraction precedente est sensé etre positif, la carry devrait etre positionnee
        sbc posx
        sta xstep
;        txa
;        tya
        lda xtile ; calcul poids fort
        sbc posx+1
        sta xstep+1

        jmp .finCheck

.horzCheck
;    if (xintercept >> 8) >= xtile) goto vertEntry;
;        LDA xinterceptHi ;+1
        LDA xinterceptHi
        cmp xtile
        bpl .vertEntry     ; eq. bcs for signed numbers
.horzEntry        
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        LDA xinterceptHi 

        LDX ytile ; 2
        LDY LSR4,X ; 4
        LDA (MapX),Y ; 5

;        LDA xinterceptHi
;        LDX ytile
;        ORA LSR4,X
;        TAX
;        LDA Map,X

;        MAGI_CALL 3, 2, CheckCoordA
;                CHECK_MAP ytile, xinterceptHi
;       LDY #0
;       LDA (coordA),y
        bne .hitHorz
;        ADD_WORD_ZP xintercept, xintercept, xstep
        
        CLC
        LDA xinterceptLo
        ADC xstep
        STA xinterceptLo
        LDA xinterceptHi
        ADC xstep+1
        STA xinterceptHi


        DEC ytile
        bpl .horzCheck         ; see previous comment for DEC xtile/bmi
.hitHorz
;        LDA #0
;        STA COLUBK

;        LDA numCol
;        AND #7
;        tax
;        LDA CurrentPFCol
;        ORA PFBit,X
;        STA CurrentPFCol   ; 17

        LDY numCol 
        LDX Div8,Y ; get the output byte
        lda raycastoutputcols,x
        ORA PFBit,y
        sta raycastoutputcols,x ; 19

;        LDY numCol
;        LDX Div8,Y
;        sec     ; clc for hitVert
;        rol raycastoutputcols,x

        lda xinterceptLo        ; calcul poids faible
        sec
        sbc posx
        sta xstep
        lda xinterceptHi ; calcul poids fort
        sbc posx+1
        sta xstep+1

; viewy - ytile<<8        
        lda posy  ; calcul poids faible
;        sec
        sta ystep

;        tya
        lda posy+1 ; calcul poids fort
        clc         ;     if (ytilestep == -1) ytile++;
        sbc ytile
        sta ystep+1

.finCheck
;        RET_MAGI_CALL


;        lda ang
        LDA startAng
        sec
        sbc numCol
        tax
;        inx
;        clc
;        ADC #1
;        tax
        lda Sinus256,x
        ldy ystep+1

        CMP $1FF6
quart0_calc_ydist:
       echo "Offset quart0_calc_ydist: ", (*)        
        ORG     $1000 + (quart0_calc_ydist_impl_end - $5000)
        RORG    $3000 + (quart0_calc_ydist_impl_end - $5000)

;        sty multiplier
;        lda ystep
;        sta multiplicand
;        lda ystep+1
;        sta multiplicandhi
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        LDA result
;        STA ystep
;        LDA result+1
;        STA ystep+1

;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$3F
        tax
        lda Sinus256+1,x

        ldy xstep+1
        CMP $1FF6
quart0_add_calc_xdist:
       echo "Offset quart0_add_calc_xdist: ", (*)        
        ORG     $1000 + (quart0_add_calc_xdist_impl_end - $5000)
        RORG    $3000 + (quart0_add_calc_xdist_impl_end - $5000)

;1FF + 
;        sty multiplier
;        lda xstep
;        sta multiplicand
;        lda xstep+1
;        sta multiplicandhi
;        jsr multiply_aab_sar6_fast
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        clc
;        LDA result
;        ADC ystep
;        STA result
;        LDA result+1
;        ADC ystep+1
;        STA result+1

;        LDA #$0
;        STA COLUBK

;       ADD_WORD_ZP result, xstep, ystep
; result = distance finale        

;        LDA #$40
;        STA COLUBK



;        beq .endLoop
        RTS

; angle de 90 a 179 degres (enfin, 64-127)
RayCast_1 SUBROUTINE
;        LDA #0
;        sta numCol

; Calcul Coordonnees Partielles
        LDA posx
.xpartialok
        sta xpart_square_lo
        sta xpart_square_hi
        eor #$FF
        sta xpart_square_lo_comp
        sta xpart_square_hi_comp

        LDA posy
;        bne .ypartialok
;        LDA #1
.ypartialok
        sta ypart_square_lo
        sta ypart_square_hi
        eor #$FF
        sta ypart_square_lo_comp
        sta ypart_square_hi_comp
RayCast_1_Known_Partials:

; case quart=2
;          xtilestep = -1;
;          ytilestep = 1;
;          horzop = JLE;
;          vertop = JGE;
;          xstep = -MyTan(192-(int)ALPHA256); //-tan(RAD(192.0  - 0.01- ALPHA256));  //       - 1
;          ystep = MyTan((int)ALPHA256 - 128); //tan(RAD(ALPHA256 - 128.0));
;          xpartial = (viewx & 255); //MAX(viewx - floor(viewx), 0.000);       //xpartialdown;
;          ypartial = ((viewy & 255) ^ 255) + 1; // + 1 ? //1.0 - (MAX(viewy - floor(viewy), 0.000));       //ypartialup;
;          break;
;        case 1:
;        {
;          xtilestep = -1;
;          ytilestep = -1;
;          horzop = JLE;
;          vertop = JLE;
;          xstep = - MyTan((int)ALPHA256 - 64); //-tan(RAD(ALPHA256 - 64.0));
;          ystep = -MyTan(128 - (int)ALPHA256); //-tan(RAD(128.0  - 0.01 - ALPHA256)); // - 1
;          xpartial = (viewx & 255); //MAX(viewx - floor(viewx), 0.000);       //xpartialdown;
;          ypartial = (viewy & 255); //MAX(viewy - floor(viewy), 0.000);       //ypartialdown;
;          break;
;        }

;        LDA ang
        LDA startAng
        sec
        sbc numCol

;        sec
;        sbc #192
        EOR #$40
        tax
        ST_WORD_X_ZP TangentLo, TangentHi, xstep
;        LDA ang
        LDA startAng
        sec
        sbc numCol

        EOR #$7F
        tax
;        inx
;        CLC
;        ADC #1
;        tax
        ST_WORD_X_ZP TangentLo+1, TangentHi+1, ystep

        ;;;;;;;;;;;;;;;;;;
;        STA multiplier
;        LDX ystep
        LDY ystep+1
        ; jump to bank #2 for the mul
        CMP $1FF6
quart1_init_yintercept:
       echo "Offset quart1_init_yintercept: ", (*)

        ORG     $1000 + (quart1_init_yintercept_impl_end - $5000)
        RORG    $3000 + (quart1_init_yintercept_impl_end - $5000)


;        clc             ; A = yinterceptLo
        SEC
        LDA posy
        sbc yinterceptLo
        STA yinterceptLo
        lax posy+1
        sbc yinterceptHi
        STA yinterceptHi   ; yintercept = viewy - ((ystep * xpartial) 
        
        DEX
        STX ytile

;        LDX posx+1
;        INX
;        STX xtile     ; xcoord for yintercept
        
        ;;;;;;;;;;;;;;;
;        STA multiplier
;        MOVSW_ZP_ZP xstep, multiplicand
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        ADD_WORD_ZP xintercept, posx, result   ; xintercept = viewx - ((xstep * ypartial) >> 8);
        LDY xstep+1
        CMP $1FF6
quart1_init_xintercept:
       echo "Offset quart1_init_xintercept: ", (*)        
        ORG     $1000 + (quart1_init_xintercept_impl_end - $5000)
        RORG    $3000 + (quart1_init_xintercept_impl_end - $5000)

        SEC
        LDA posx
        sbc xinterceptLo
        STA xinterceptLo
        LAX posx+1
        SBC xinterceptHi
        STA xinterceptHi

;        LDY posx+1
;        INY ; y = xtile
        DEX
        STX xtile     ; xcoord for yintercept
 
;        LDX posy+1
;        INX
;        STX ytile

;        RET_MAGI_CALL
;        LDA #30
;        STA COLUBK
        
;        ldy ytile
;        txs ; save xtile to s 
; Check collisions
.vertCheck
;       if (yintercept >> 8) >= ytile)) goto horzEntry;
 ;       LDX yinterceptHi ;+1
 ;       cpx ytile
;        bcs .horzEntry
        ldx ytile
        cpx yinterceptHi
        bpl .horzEntry  ; eq. bcs for signed numbers
.vertEntry
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        tsx

        LDX yinterceptHi ; 2
        LDY LSR4,X ; 4
        LDA (MapY),Y ; 5

;        tya
;        LDX yinterceptHi ;+1
;        ORA LSR4,X
;        ORA xtile
;        TAX
;        LDA Map,X   ; 12 cycles


;        MAGI_CALL 3, 2, CheckCoordB
;        CHECK_MAP yinterceptHi, xtile
;       LDY #0
;       LDA (coordB),y
        bne .hitVert
;        ADD_WORD_ZP yintercept, yintercept, ystep
        SEC
        LDA yinterceptLo
        SBC ystep
        STA yinterceptLo
        LDA yinterceptHi
        SBC ystep+1
        STA yinterceptHi

;        INY
        DEC xtile
        bpl .vertCheck ; always jump, if in col 0 we always have intersection it is fine. Beware not going to .hitVert from here
.hitVert
;        LDA #0
;        STA COLUBK
;        LDY numCol
;        LDX Div8,Y
;        clc     ; sec for hitHorz
;        rol raycastoutputcols,x

; viewy - yintercept
        lda posy        ; calcul poids faible
        sec
        sbc yinterceptLo
        sta ystep
        lda posy+1 ; calcul poids fort
        sbc yinterceptHi
        sta ystep+1
        
        LDA posx    ; viewx - xtile<<8
;        sec    ; comme le resultat de la soustraction precedente est sensé etre positif, la carry devrait etre positionnee
;        sbc #0
        STA xstep
        LDA posx+1
        CLC         ;     if (xtilestep == -1) xtile++;
        SBC xtile
        STA xstep+1

        jmp .finCheck

.horzCheck
;    if (xintercept >> 8) >= xtile) goto vertEntry;
;        LDA xinterceptHi ;+1
        LDA xtile
        cmp xinterceptHi
        bpl .vertEntry     ; eq. bcs for signed numbers
.horzEntry        
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        LDA xinterceptHi 

        LDX ytile ; 2
        LDY LSR4,X ; 4
        LDA (MapX),Y ; 5

;        LDA xinterceptHi
;        LDX ytile
;        ORA LSR4,X
;        TAX
;        LDA Map,X

;        MAGI_CALL 3, 2, CheckCoordA
;                CHECK_MAP ytile, xinterceptHi
;       LDY #0
;       LDA (coordA),y
        bne .hitHorz
;        ADD_WORD_ZP xintercept, xintercept, xstep
        
        SEC
        LDA xinterceptLo
        SBC xstep
        STA xinterceptLo
        LDA xinterceptHi
        SBC xstep+1
        STA xinterceptHi


        DEC ytile
        bpl .horzCheck         ; see previous comment for DEC xtile/bmi
.hitHorz
;        LDA #0
;        STA COLUBK

;        LDX numCol
;        LDA CurrentPFCol
;        ORA PFBit,X
;        STA CurrentPFCol

        LDY numCol 
        LDX Div8,Y ; get the output byte
        lda raycastoutputcols,x
        ORA PFBit,y
        sta raycastoutputcols,x ; 19

;        LDY numCol
;        LDX Div8,Y
;        sec     ; clc for hitVert
;        rol raycastoutputcols,x

; viewx - xintercept
        LDA posx        ; calcul poids faible
        sec
        sbc xinterceptLo
        sta xstep
        lda posx+1
        sbc xinterceptHi
        sta xstep+1

; viewy - ytile<<8        
        lda posy  ; calcul poids faible
;        sec
        sta ystep

;        tya
        lda posy+1 ; calcul poids fort
        clc         ;     if (ytilestep == -1) ytile++;
        sbc ytile
        sta ystep+1

.finCheck
;        RET_MAGI_CALL


;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$7F
        tax
;        inx
;        clc
;        ADC #1
;        tax
        lda Sinus256+1,x
        ldy ystep+1

        CMP $1FF6
quart1_calc_ydist:
       echo "Offset quart1_calc_ydist: ", (*)        
        ORG     $1000 + (quart1_calc_ydist_impl_end - $5000)
        RORG    $3000 + (quart1_calc_ydist_impl_end - $5000)

;        sty multiplier
;        lda ystep
;        sta multiplicand
;        lda ystep+1
;        sta multiplicandhi
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        LDA result
;        STA ystep
;        LDA result+1
;        STA ystep+1

;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$40
        tax
        lda Sinus256,x

        ldy xstep+1
        CMP $1FF6
quart1_add_calc_xdist:
       echo "Offset quart1_add_calc_xdist: ", (*)        
        ORG     $1000 + (quart1_add_calc_xdist_impl_end - $5000)
        RORG    $3000 + (quart1_add_calc_xdist_impl_end - $5000)

;1FF + 
;        sty multiplier
;        lda xstep
;        sta multiplicand
;        lda xstep+1
;        sta multiplicandhi
;        jsr multiply_aab_sar6_fast
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        clc
;        LDA result
;        ADC ystep
;        STA result
;        LDA result+1
;        ADC ystep+1
;        STA result+1

;        LDA #$0
;        STA COLUBK

;       ADD_WORD_ZP result, xstep, ystep
; result = distance finale        

;        LDA #$40
;        STA COLUBK



;        beq .endLoop
        RTS

; angle de 180 a 269 degres (enfin, 128-191)
RayCast_2 SUBROUTINE

;        LDA #0
;        sta numCol

; Calcul Coordonnees Partielles
        LDA posx
.xpartialok
        sta xpart_square_lo
        sta xpart_square_hi
        eor #$FF
        sta xpart_square_lo_comp
        sta xpart_square_hi_comp

        LDA posy
        EOR #$FF
        CLC
        ADC #1
        bcc .ypartialok
        LDA #$FF

;        bne .ypartialok
;        LDA #1
.ypartialok
        sta ypart_square_lo
        sta ypart_square_hi
        eor #$FF
        sta ypart_square_lo_comp
        sta ypart_square_hi_comp
RayCast_2_Known_Partials:
 ;       LDA ang
 ;       asl
;        STA COLUBK
; case quart=3
;          xtilestep = 1;
;          ytilestep = 1;
;          horzop = JGE;
;          vertop = JGE;
;;          xstep = MyTan((int)ALPHA256 - 192); //tan(RAD(ALPHA256 - 192.0));
;          ystep = MyTan(256 - (int)ALPHA256); //tan(RAD(256.0  - 0.01- ALPHA256)); //    - 1
;          xpartial = ((viewx & 255) ^ 255) + 1; // +1 ? // 1.0 - MAX(viewx - floor(viewx), 0.000);       //xpartialup;
;          ypartial = ((viewy & 255) ^ 255) + 1; // +1 ? // 1.0 - MAX(viewy - floor(viewy), 0.000);       //ypartialup;

; case quart=2
;          xtilestep = -1;
;          ytilestep = 1;
;          horzop = JLE;
;          vertop = JGE;
;          xstep = -MyTan(192-(int)ALPHA256); //-tan(RAD(192.0  - 0.01- ALPHA256));  //       - 1
;          ystep = MyTan((int)ALPHA256 - 128); //tan(RAD(ALPHA256 - 128.0));
;          xpartial = (viewx & 255); //MAX(viewx - floor(viewx), 0.000);       //xpartialdown;
;          ypartial = ((viewy & 255) ^ 255) + 1; // + 1 ? //1.0 - (MAX(viewy - floor(viewy), 0.000));       //ypartialup;
;          break;

;        LDA ang
        LDA startAng
        sec
        sbc numCol

;        sec
;        sbc #192
        EOR #$BF
        tax
        ST_WORD_X_ZP TangentLo+1, TangentHi+1, xstep
;        LDA ang
        LDA startAng
        sec
        sbc numCol

        EOR #$80
        tax
;        inx
;        CLC
;        ADC #1
;        tax
        ST_WORD_X_ZP TangentLo, TangentHi, ystep

        ;;;;;;;;;;;;;;;;;;
;        STA multiplier
;        LDX ystep
        LDY ystep+1
        ; jump to bank #2 for the mul
        CMP $1FF6
quart2_init_yintercept:
       echo "Offset quart2_init_yintercept: ", (*)

        ORG     $1000 + (quart2_init_yintercept_impl_end - $5000)
        RORG    $3000 + (quart2_init_yintercept_impl_end - $5000)


;        clc             ; A = yinterceptLo
        adc posy
        STA yinterceptLo
        lax posy+1
        adc yinterceptHi
        STA yinterceptHi   ; yintercept = viewy + ((ystep * xpartial) 
        
        INX
        STX ytile

;        LDX posx+1
;        INX
;        STX xtile     ; xcoord for yintercept
        
        ;;;;;;;;;;;;;;;
;        STA multiplier
;        MOVSW_ZP_ZP xstep, multiplicand
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        ADD_WORD_ZP xintercept, posx, result   ; xintercept = viewx - ((xstep * ypartial) >> 8);
        LDY xstep+1
        CMP $1FF6
quart2_init_xintercept:
       echo "Offset quart2_init_xintercept: ", (*)        
        ORG     $1000 + (quart2_init_xintercept_impl_end - $5000)
        RORG    $3000 + (quart2_init_xintercept_impl_end - $5000)

        SEC
        LDA posx
        sbc xinterceptLo
        STA xinterceptLo
        LAX posx+1
        SBC xinterceptHi
        STA xinterceptHi

;        LDY posx+1
;        INY ; y = xtile
        DEX
        STX xtile     ; xcoord for yintercept
 
;        LDX posy+1
;        INX
;        STX ytile

;        RET_MAGI_CALL
;        LDA #30
;        STA COLUBK
        
;        ldy ytile
;        txs ; save xtile to s 
; Check collisions
.vertCheck
;       if (yintercept >> 8) >= ytile)) goto horzEntry;
 ;       LDX yinterceptHi ;+1
 ;       cpx ytile
;        bcs .horzEntry
        ldx yinterceptHi
        cpx ytile
        bpl .horzEntry     ; eq. BCS for signed numbers
.vertEntry
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        tsx

        LDX yinterceptHi ; 2
        LDY LSR4,X ; 4
        LDA (MapY),Y ; 5

;        tya
;        LDX yinterceptHi ;+1
;        ORA LSR4,X
;        ORA xtile
;        TAX
;        LDA Map,X   ; 12 cycles


;        MAGI_CALL 3, 2, CheckCoordB
;        CHECK_MAP yinterceptHi, xtile
;       LDY #0
;       LDA (coordB),y
        bne .hitVert
;        ADD_WORD_ZP yintercept, yintercept, ystep
        LDA ystep
        CLC
        ADC yinterceptLo
        STA yinterceptLo
        LDA ystep+1
        ADC yinterceptHi
        STA yinterceptHi

;        INY
        DEC xtile
        bpl .vertCheck
.hitVert
;        LDA #0
;        STA COLUBK
;        LDY numCol
;        LDX Div8,Y
;        clc     ; sec for hitHorz
;        rol raycastoutputcols,x

        lda yinterceptLo        ; calcul poids faible
        sec
        sbc posy
        sta ystep
        lda yinterceptHi ; calcul poids fort
        sbc posy+1
        sta ystep+1
        
        LDA posx
;        sec    ; comme le resultat de la soustraction precedente est sensé etre positif, la carry devrait etre positionnee
;        sbc #0
        STA xstep
        LDA posx+1
        clc           ;     if (xtilestep == -1) xtile++;
        SBC xtile
        STA xstep+1

        jmp .finCheck

.horzCheck
;    if (xintercept >> 8) >= xtile) goto vertEntry;
;        LDA xinterceptHi ;+1
        LDA xtile
        cmp xinterceptHi
        bpl .vertEntry
.horzEntry        
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        LDA xinterceptHi 

        LDX ytile ; 2
        LDY LSR4,X ; 4
        LDA (MapX),Y ; 5

;        LDA xinterceptHi
;        LDX ytile
;        ORA LSR4,X
;        TAX
;        LDA Map,X

;        MAGI_CALL 3, 2, CheckCoordA
;                CHECK_MAP ytile, xinterceptHi
;       LDY #0
;       LDA (coordA),y
        bne .hitHorz
;        ADD_WORD_ZP xintercept, xintercept, xstep
        
        SEC
        LDA xinterceptLo
        SBC xstep
        STA xinterceptLo
        LDA xinterceptHi
        SBC xstep+1
        STA xinterceptHi


        INC ytile
        bne .horzCheck
.hitHorz
;        LDA #0
;        STA COLUBK

;        LDX numCol
;        LDA CurrentPFCol
;        ORA PFBit,X
;        STA CurrentPFCol

        LDY numCol 
        LDX Div8,Y ; get the output byte
        lda raycastoutputcols,x
        ORA PFBit,y
        sta raycastoutputcols,x ; 19

;        LDY numCol
;        LDX Div8,Y
;        sec     ; clc for hitVert
;        rol raycastoutputcols,x

        LDA posx        ; calcul poids faible
        sec
        sbc xinterceptLo
        sta xstep
        lda posx+1
        sbc xinterceptHi
        sta xstep+1
        
        lda #0  ; calcul poids faible
;        sec
        sbc posy
        sta ystep

;        tya
        lda ytile ; calcul poids fort
        sbc posy+1
        sta ystep+1

.finCheck
;        RET_MAGI_CALL


;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$80
        tax
;        inx
;        clc
;        ADC #1
;        tax
        lda Sinus256,x
        ldy ystep+1

        CMP $1FF6
quart2_calc_ydist:
       echo "Offset quart2_calc_ydist: ", (*)        
        ORG     $1000 + (quart2_calc_ydist_impl_end - $5000)
        RORG    $3000 + (quart2_calc_ydist_impl_end - $5000)

;        sty multiplier
;        lda ystep
;        sta multiplicand
;        lda ystep+1
;        sta multiplicandhi
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        LDA result
;        STA ystep
;        LDA result+1
;        STA ystep+1

;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$BF
        tax
        lda Sinus256+1,x

        ldy xstep+1
        CMP $1FF6
quart2_add_calc_xdist:
       echo "Offset quart2_add_calc_xdist: ", (*)        
        ORG     $1000 + (quart2_add_calc_xdist_impl_end - $5000)
        RORG    $3000 + (quart2_add_calc_xdist_impl_end - $5000)

;1FF + 
;        sty multiplier
;        lda xstep
;        sta multiplicand
;        lda xstep+1
;        sta multiplicandhi
;        jsr multiply_aab_sar6_fast
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        clc
;        LDA result
;        ADC ystep
;        STA result
;        LDA result+1
;        ADC ystep+1
;        STA result+1

;        LDA #$0
;        STA COLUBK

;       ADD_WORD_ZP result, xstep, ystep
; result = distance finale        

;        LDA #$40
;        STA COLUBK



;        beq .endLoop
        RTS

RayCast_3 SUBROUTINE

;        LDA #0
;        sta numCol

; Calcul Coordonnees Partielles
        LDA posx
        EOR #$FF
        CLC
        ADC #1
        bcc .xpartialok
        LDA #$FF
 ;       bne .xpartialok
;        LDA #1
.xpartialok
        sta xpart_square_lo
        sta xpart_square_hi
        eor #$FF
        sta xpart_square_lo_comp
        sta xpart_square_hi_comp

        LDA posy
        EOR #$FF
        CLC
        ADC #1
        bcc .ypartialok
        LDA #$FF
;        bne .ypartialok
;        LDA #1
.ypartialok
        sta ypart_square_lo
        sta ypart_square_hi
        eor #$FF
        sta ypart_square_lo_comp
        sta ypart_square_hi_comp
RayCast_3_Known_Partials:
 ;       LDA ang
 ;       asl
;        STA COLUBK
; case quart=3
;          xtilestep = 1;
;          ytilestep = 1;
;          horzop = JGE;
;          vertop = JGE;
;;          xstep = MyTan((int)ALPHA256 - 192); //tan(RAD(ALPHA256 - 192.0));
;          ystep = MyTan(256 - (int)ALPHA256); //tan(RAD(256.0  - 0.01- ALPHA256)); //    - 1
;          xpartial = ((viewx & 255) ^ 255) + 1; // +1 ? // 1.0 - MAX(viewx - floor(viewx), 0.000);       //xpartialup;
;          ypartial = ((viewy & 255) ^ 255) + 1; // +1 ? // 1.0 - MAX(viewy - floor(viewy), 0.000);       //ypartialup;

;        LDA ang
        LDA startAng
        sec
        sbc numCol

;        sec
;        sbc #192
        EOR #$C0
        tax
        ST_WORD_X_ZP TangentLo, TangentHi, xstep
;        LDA ang
        LDA startAng
        sec
        sbc numCol

        EOR #$FF
        tax
;        inx
;        CLC
;        ADC #1
;        tax
        ST_WORD_X_ZP TangentLo+1, TangentHi+1, ystep

        ;;;;;;;;;;;;;;;;;;
;        STA multiplier
;        LDX ystep
        LDY ystep+1
        ; jump to bank #2 for the mul
        CMP $1FF6
quart3_init_yintercept:
       echo "Offset quart3_init_yintercept: ", (*)

        ORG     $1000 + (quart3_init_yintercept_impl_end - $5000)
        RORG    $3000 + (quart3_init_yintercept_impl_end - $5000)


;        clc             ; A = yinterceptLo
        adc posy
        STA yinterceptLo
        lax posy+1
        adc yinterceptHi
        STA yinterceptHi   ; yintercept = viewy + ((ystep * xpartial) 
        
        INX
        STX ytile

;        LDX posx+1
;        INX
;        STX xtile     ; xcoord for yintercept
        
        ;;;;;;;;;;;;;;;
;        STA multiplier
;        MOVSW_ZP_ZP xstep, multiplicand
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        ADD_WORD_ZP xintercept, posx, result   ; xintercept = viewx + ((xstep * ypartial) >> 8);
        LDY xstep+1
        CMP $1FF6
quart3_init_xintercept:
       echo "Offset quart3_init_xintercept: ", (*)        
        ORG     $1000 + (quart3_init_xintercept_impl_end - $5000)
        RORG    $3000 + (quart3_init_xintercept_impl_end - $5000)


;        CLC
        ADC posx
        STA xinterceptLo
        LAX posx+1
        ADC xinterceptHi
        STA xinterceptHi

;        LDY posx+1
;        INY ; y = xtile
        INX
        STX xtile     ; xcoord for yintercept
 
;        LDX posy+1
;        INX
;        STX ytile

;        RET_MAGI_CALL
;        LDA #30
;        STA COLUBK
        
;        ldy ytile
;        txs ; save xtile to s 
; Check collisions
.vertCheck
;       if (yintercept >> 8) >= ytile)) goto horzEntry;
 ;       LDX yinterceptHi ;+1
 ;       cpx ytile
;        bcs .horzEntry
        ldx yinterceptHi
        cpx ytile
        bcs .horzEntry
.vertEntry
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        tsx

        LDX yinterceptHi ; 2
        LDY LSR4,X ; 4
        LDA (MapY),Y ; 5

;        tya
;        LDX yinterceptHi ;+1
;        ORA LSR4,X
;        ORA xtile
;        TAX
;        LDA Map,X   ; 12 cycles


;        MAGI_CALL 3, 2, CheckCoordB
;        CHECK_MAP yinterceptHi, xtile
;       LDY #0
;       LDA (coordB),y
        bne .hitVert
;        ADD_WORD_ZP yintercept, yintercept, ystep
        LDA ystep
        CLC
        ADC yinterceptLo
        STA yinterceptLo
        LDA ystep+1
        ADC yinterceptHi
        STA yinterceptHi

;        INY
        INC xtile
        bne .vertCheck
.hitVert
;        LDA #0
;        STA COLUBK
;        LDY numCol
;        LDX Div8,Y
;        clc     ; sec for hitHorz
;        rol raycastoutputcols,x

        lda yinterceptLo        ; calcul poids faible
        sec
        sbc posy
        sta ystep
        lda yinterceptHi ; calcul poids fort
        sbc posy+1
        sta ystep+1
        
        lda #0  ; calcul poids faible
;        sec    ; comme le resultat de la soustraction precedente est sensé etre positif, la carry devrait etre positionnee
        sbc posx
        sta xstep
;        txa
;        tya
        lda xtile ; calcul poids fort
        sbc posx+1
        sta xstep+1

        jmp .finCheck

.horzCheck
;    if (xintercept >> 8) >= xtile) goto vertEntry;
;        LDA xinterceptHi ;+1
        LDA xinterceptHi
        cmp xtile
        bcs .vertEntry
.horzEntry        
;        LDX .CoordY
;        LDA LSR4,X
;        ORA .CoordX
;        TAX
;        LDA Map,X ; 14 cycles
;        LDA xinterceptHi 

        LDX ytile ; 2
        LDY LSR4,X ; 4
        LDA (MapX),Y ; 5

;        LDA xinterceptHi
;        LDX ytile
;        ORA LSR4,X
;        TAX
;        LDA Map,X

;        MAGI_CALL 3, 2, CheckCoordA
;                CHECK_MAP ytile, xinterceptHi
;       LDY #0
;       LDA (coordA),y
        bne .hitHorz
;        ADD_WORD_ZP xintercept, xintercept, xstep
        LDA xstep
        CLC
        ADC xinterceptLo
        STA xinterceptLo
        LDA xstep+1
        ADC xinterceptHi
        STA xinterceptHi


        INC ytile
        bne .horzCheck
.hitHorz
;        LDA #0
;        STA COLUBK

;        LDX numCol
;        LDA CurrentPFCol
;        ORA PFBit,X
;        STA CurrentPFCol
        LDY numCol 
        LDX Div8,Y ; get the output byte
        lda raycastoutputcols,x
        ORA PFBit,y
        sta raycastoutputcols,x ; 19

;        LDY numCol
;        LDX Div8,Y
;        sec     ; clc for hitVert
;        rol raycastoutputcols,x

        lda xinterceptLo        ; calcul poids faible
        sec
        sbc posx
        sta xstep
        lda xinterceptHi ; calcul poids fort
        sbc posx+1
        sta xstep+1
        
        lda #0  ; calcul poids faible
;        sec
        sbc posy
        sta ystep

;        tya
        lda ytile ; calcul poids fort
        sbc posy+1
        sta ystep+1

.finCheck
;        RET_MAGI_CALL


;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$FF
        tax
;        inx
;        clc
;        ADC #1
;        tax
        lda Sinus256+1,x
        ldy ystep+1

        CMP $1FF6
quart3_calc_ydist:
       echo "Offset quart3_calc_ydist: ", (*)        
        ORG     $1000 + (quart3_calc_ydist_impl_end - $5000)
        RORG    $3000 + (quart3_calc_ydist_impl_end - $5000)

;        sty multiplier
;        lda ystep
;        sta multiplicand
;        lda ystep+1
;        sta multiplicandhi
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        LDA result
;        STA ystep
;        LDA result+1
;        STA ystep+1

;        lda ang
        LDA startAng
        sec
        sbc numCol

        EOR #$C0
        tax
        lda Sinus256,x

        ldy xstep+1
        CMP $1FF6
quart3_add_calc_xdist:
       echo "Offset quart3_add_calc_xdist: ", (*)        
        ORG     $1000 + (quart3_add_calc_xdist_impl_end - $5000)
        RORG    $3000 + (quart3_add_calc_xdist_impl_end - $5000)

;1FF + 
;        sty multiplier
;        lda xstep
;        sta multiplicand
;        lda xstep+1
;        sta multiplicandhi
;        jsr multiply_aab_sar6_fast
;        MAGI_CALL 1,2,multiply_aab_real_fast
;        clc
;        LDA result
;        ADC ystep
;        STA result
;        LDA result+1
;        ADC ystep+1
;        STA result+1

;        LDA #$0
;        STA COLUBK

;       ADD_WORD_ZP result, xstep, ystep
; result = distance finale        

;        LDA #$40
;        STA COLUBK



;        beq .endLoop
        RTS



RayCastMethodHi .byte #>(RayCast_0 - 1),#>(RayCast_1 - 1),#>(RayCast_2 - 1),#>(RayCast_3 - 1)
RayCastMethodLo .byte #<(RayCast_0 - 1),#<(RayCast_1 - 1),#<(RayCast_2 - 1),#<(RayCast_3 - 1)

RayCast SUBROUTINE
        LDA #>Map
        STA MapXHi
        STA MapYHi
.beginLoop
;        LDA ang
        LDA #>(.returnAddress - 1)
        pha
        LDA #<(.returnAddress - 1)
        pha

        LDA startAng
        sec
        sbc numCol
        tax

        EOR PreviousQuart
        AND #$E0
        BNE .newQuart
        
        txa
        asl
        bcs .sameQuart23
        asl
        bcs .sameQuart1
        jmp RayCast_0_Known_Partials
.sameQuart1
        jmp RayCast_1_Known_Partials
.sameQuart23
        asl
        bcs .sameQuart3
        jmp RayCast_2_Known_Partials
.sameQuart3
        jmp RayCast_3_Known_Partials

.newQuart
        EOR PreviousQuart
        STA PreviousQuart

        txa
        asl
        bcs .newQuart23
        asl
        bcs .newQuart1
        jmp RayCast_0
.newQuart1
        jmp RayCast_1
.newQuart23
        asl
        bcs .newQuart3
        jmp RayCast_2
.newQuart3
        jmp RayCast_3

.returnAddress
; when we back here, result contains the distance at which ray intersected a wall
        LDA numCol
        CLC
        ADC #$10
        LSR
        TAX
        bcs .lowBits
.highBits               ; first we write high bits
        ldy result
        LDA True_LSR4,y
        LDY result+1
        ora LSR4,y
        tay
        lda MapDist,y
        CMP RaycastOutputMinHeight
        BCS .notNewMin1
        STA  RaycastOutputMinHeight
        bcc .notNewMax1
.notNewMin1
        CMP RaycastOutputMaxHeight
        bcc .notNewMax1
;        beq .notNewMax1
        STA RaycastOutputMaxHeight
.notNewMax1

;        JSR CalcDist
;        AND #$0F        ; remove that when sure calcDist is ok
        TAY
        LDA LSR4,Y
        STA raycastoutput,x    
        jmp .endOutput
.lowBits                ; then, low bits
        ldy result
        LDA True_LSR4,y
        LDY result+1
        ora LSR4,y
        tay
        lda MapDist,y
        CMP RaycastOutputMaxHeight
        bcc .notNewMax2
;        beq .notNewMax1
        STA RaycastOutputMaxHeight
        bcs .notNewMin2
.notNewMax2
        CMP RaycastOutputMinHeight
        BCS .notNewMin2
        STA  RaycastOutputMinHeight
.notNewMin2

;        JSR CalcDist
        ORA raycastoutput,x
        STA raycastoutput,x
.endOutput    
;        DEC ang
        INC numCol
        LDA numCol
;        tax
;        and #7
;        bne .noNewColPF
;        LDA Div8,X
;        tay
;        LDA CurrentPFCol
;        STA raycastoutputcols-1,Y
;        LDA #0
;        STA CurrentPFCol
;.noNewColPF
        CMP #16
        beq .exitLoop

        LDA INTIM
        CMP #40
        bcc .exitLoop ; s'il reste assez de temps machine pour un rayon de plus, continue
        jmp .beginLoop
.exitLoop   
        RET_MAGI_CALL


;int MyDiv(int d) {
;  int h = 0;
;  while (dist[17 - h - 1] < d) h++;
;  return 16 - h;
;}
;DivTableHi
;       .byte #$1a,#$0d,#$09,#$06,#$05,#$04,#$03,#$03,#$03,#$02,#$02,#$02,#$02,#$01,#$01,#$01
;DivTableLo;
;       .byte #$2e,#$65,#$00,#$c6,#$6f,#$89,#$e4,#$68,#$08,#$ba,#$7b,#$46,#$1a,#$f3,#$d2,#$b5
; result contains distance
; Example 4.1.1: a 16-bit unsigned comparison which branches to LABEL2 if NUM1 < NUM2
; CMP sets carry if A>=val , sets Z if A == val
;CalcDist SUBROUTINE
;        LDY #15
;.CmpLoop        
;        LDA result+1 ; compare high bytes
;        CMP DivTableHi,Y
;        BCC .ExitLoop
;        BNE .Next
;        LDA result ; compare low byte
;        CMP DivTableLo,Y
;        BCC .ExitLoop
;.Next
;        dey
;        bne .CmpLoop
;.ExitLoop
;        TYA
;        EOR #$F ; return 15-A
;        RTS

;NewCalcDist SUBROUTINE
;        lda result
;        lsr
;        lsr
;        lsr
;        lsr
;        LDX result+1
;        ora LSR4,x
;        tax
;        lda MapDist,x
;        rts

        ALIGN 256
MapDist 
        .byte #$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F, #$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F
        .byte #$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F, #$0F,#$0F,#$0F,#$0F,#$0F,#$0E,#$0E,#$0D
        .byte #$0D,#$0D,#$0C,#$0C,#$0C,#$0B,#$0B,#$0B, #$0A,#$0A,#$0A,#$0A,#$09,#$09,#$09,#$09
        .byte #$09,#$08,#$08,#$08,#$08,#$08,#$08,#$07, #$07,#$07,#$07,#$07,#$07,#$07,#$07,#$06
        .byte #$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06, #$06,#$05,#$05,#$05,#$05,#$05,#$05,#$05
        .byte #$05,#$05,#$05,#$05,#$05,#$05,#$05,#$04, #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04
        .byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04, #$04,#$04,#$04,#$04,#$04,#$03,#$03,#$03
        .byte #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03, #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
        .byte #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03, #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
        .byte #$03,#$02,#$02,#$02,#$02,#$02,#$02,#$02, #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02, #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02, #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02, #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$01,#$01, #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01, #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01, #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01

        ALIGN 256
Map
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$01,#$00,#$01,#$00,#$01,#$00,#$01,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$01
        .byte #$01,#$00,#$01,#$01,#$01,#$00,#$01,#$00,#$01,#$00,#$01,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$01,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$01
        .byte #$01,#$01,#$00,#$00,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$00,#$01
        .byte #$01,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01




;DivTableHi
;        .byte #$1a,#$0d,#$09,#$06,#$05,#$04,#$03,#$03,#$03,#$02,#$02,#$02,#$02,#$01,#$01,#$01
;DivTableLo
;        .byte #$2e,#$65,#$00,#$c6,#$6f,#$89,#$e4,#$68,#$08,#$ba,#$7b,#$46,#$1a,#$f3,#$d2,#$b5

; keep only whats necessary (16 bytes)


        ALIGN 256
; todo: and rename this to SHR4
True_LSR4
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

;Div8
;        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
;        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03;
;
;PFBit   .byte #$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01,#$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01
;        .byte #$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01,#$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01

; adapt for NumCol between -16 and +15

Div8
        .byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
PFBit   
        .byte #$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01,#$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01

TangentHi
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$01,#$01,#$01,#$01,#$01,#$01,#$02,#$02
        .byte #$02,#$02,#$02,#$03,#$03,#$03,#$04,#$04
        .byte #$05,#$05,#$06,#$08,#$0a,#$0d,#$13,#$2a
        .byte #$75
TangentLo
        .byte #$00,#$06,#$0d,#$13,#$19,#$20,#$26,#$2c
        .byte #$33,#$39,#$40,#$47,#$4e,#$55,#$5c,#$63
        .byte #$6a,#$71,#$79,#$81,#$89,#$91,#$99,#$a2
        .byte #$ab,#$b4,#$be,#$c8,#$d2,#$dd,#$e8,#$f4
        .byte #$00,#$0d,#$1a,#$29,#$38,#$48,#$59,#$6c
        .byte #$7f,#$95,#$ac,#$c4,#$de,#$fc,#$1e,#$44
        .byte #$6a,#$96,#$c8,#$03,#$48,#$9b,#$00,#$7e
        .byte #$05,#$d1,#$bd,#$00,#$3d,#$79,#$b1,#$ab
        .byte #$00

Sinus256
    .byte #$00,#$06,#$0c,#$12,#$19,#$1f,#$25,#$2b,#$31,#$37,#$3e,#$44,#$4a,#$50,#$56,#$5b
    .byte #$61,#$67,#$6d,#$72,#$78,#$7d,#$83,#$88,#$8d,#$93,#$98,#$9d,#$a2,#$a6,#$ab,#$b0
    .byte #$b4,#$b9,#$bd,#$c1,#$c5,#$c9,#$cd,#$d0,#$d4,#$d7,#$db,#$de,#$e1,#$e4,#$e6,#$e9
    .byte #$ec,#$ee,#$f0,#$f2,#$f4,#$f6,#$f7,#$f9,#$fa,#$fb,#$fc,#$fd,#$fe,#$fe,#$ff,#$ff
    .byte #$ff

;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;        .byte #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0

;        .byte #0,#0,#0
        .byte          #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
;div8 neg
        .byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
        .byte #$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01,#$80,#$40,#$20,#$10,#$08,#$04,#$02,#$01
; todo: rename this to SHL4

LSR4        
        .byte #$00,#$10,#$20,#$30,#$40,#$50,#$60,#$70,#$80,#$90,#$A0,#$B0,#$C0,#$D0,#$E0,#$F0  

;        .byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$05
;        .byte #$06,#$06,#$06,#$06,#$06,#$06,#$06,#$06,#$07,#$07,#$07,#$07,#$07,#$07,#$07,#$07
;;        .byte #$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$09,#$09,#$09,#$09,#$09,#$09,#$09,#$09
;        .byte #$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0A,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B,#$0B
;        .byte #$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0C,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D,#$0D
;        .byte #$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0E,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F,#$0F
;        .byte #$10,#$10,#$10,#$10,#$10,#$10,#$10,#$10,#$11,#$11,#$11,#$11,#$11,#$11,#$11,#$11
;        .byte #$12,#$12,#$12,#$12,#$12,#$12,#$12,#$12,#$13,#$13,#$13,#$13,#$13,#$13,#$13,#$13
;        .byte #$14,#$14,#$14,#$14,#$14,#$14,#$14,#$14,#$15,#$15,#$15,#$15,#$15,#$15,#$15,#$15
;        .byte #$16,#$16,#$16,#$16,#$16,#$16,#$16,#$16,#$17,#$17,#$17,#$17,#$17,#$17,#$17,#$17
;        .byte #$18,#$18,#$18,#$18,#$18,#$18,#$18,#$18,#$19,#$19,#$19,#$19,#$19,#$19,#$19,#$19
;        .byte #$1A,#$1A,#$1A,#$1A,#$1A,#$1A,#$1A,#$1A,#$1B,#$1B,#$1B,#$1B,#$1B,#$1B,#$1B,#$1B
;        .byte #$1C,#$1C,#$1C,#$1C,#$1C,#$1C,#$1C,#$1C,#$1D,#$1D,#$1D,#$1D,#$1D,#$1D,#$1D,#$1D
;        .byte #$1E,#$1E,#$1E,#$1E,#$1E,#$1E,#$1E,#$1E,#$1F,#$1F,#$1F,#$1F,#$1F,#$1F,#$1F,#$1F



