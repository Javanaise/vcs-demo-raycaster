;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quart no 0

; we dont need signed version, we already know the sign of everything
; multiply 16 bit x 8 bit / 256 -> 16 bit result (unsigned) (could be same method for signed a)

        ORG     $2000 + (quart0_init_yintercept - $3000)
        RORG    $5000 + (quart0_init_yintercept - $3000)

; ; yintercept = viewy + ((ystep * xpartial) 
; ici on calcule ystep * xpartial	
quart0_init_yintercept_impl SUBROUTINE

; *B. ; already ready
; AH * B
                sec
                lda (xpart_square_lo),y 
                sbc (xpart_square_lo_comp),y
                sta yinterceptLo
;tax                
                lda (xpart_square_hi),y
                sbc (xpart_square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (xpart_square_hi),y 
                sbc (xpart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart0_init_yintercept_impl_end
       echo "Offset quart0_init_yintercept_impl_end: ", (*)



        ORG     $2000 + (quart0_init_xintercept - $3000)
        RORG    $5000 + (quart0_init_xintercept - $3000)

; ; xintercept = viewx + ((xstep * ypartial) 
; ici on calcule xstep * ypartial	
quart0_init_xintercept_impl SUBROUTINE
; *B
;				sta square_lo
;				sta square_hi
;				eor #$FF
;				sta square_lo_comp
;				sta square_hi_comp
; AH * B
                sec
                lda (ypart_square_lo),y 
                sbc (ypart_square_lo_comp),y
                sta xinterceptLo
                
                lda (ypart_square_hi),y
                sbc (ypart_square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (ypart_square_hi),y 
                sbc (ypart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart0_init_xintercept_impl_end
       echo "Offset quart0_init_xintercept_impl_end: ", (*)


        ORG     $2000 + (quart0_calc_ydist - $3000)
        RORG    $5000 + (quart0_calc_ydist - $3000)

; ici on calcule ydist(in ystep) * sin(angle) -> result in yintercept	
quart0_calc_ydist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta yinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart0_calc_ydist_impl_end
       echo "Offset quart0_calc_ydist_impl_end	: ", (*)


        ORG     $2000 + (quart0_add_calc_xdist - $3000)
        RORG    $5000 + (quart0_add_calc_xdist - $3000)

; ici on calcule xdist(in xstep) * cos(angle) -> result in xintercept. then add with yintercept as calculated above and map result on xstep
quart0_calc_xdist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta xinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
				lda xinterceptLo
				clc
				adc yinterceptLo
				sta result
				lda xinterceptHi
				adc yinterceptHi
				sta result+1
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart0_add_calc_xdist_impl_end
       echo "Offset quart0_add_calc_xdist_impl_end	: ", (*)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quart no 1

; we dont need signed version, we already know the sign of everything
; multiply 16 bit x 8 bit / 256 -> 16 bit result (unsigned) (could be same method for signed a)

        ORG     $2000 + (quart1_init_yintercept - $3000)
        RORG    $5000 + (quart1_init_yintercept - $3000)

; ; yintercept = viewy + ((ystep * xpartial) 
; ici on calcule ystep * xpartial	
quart1_init_yintercept_impl SUBROUTINE

; *B. ; already ready
; AH * B
                sec
                lda (xpart_square_lo),y 
                sbc (xpart_square_lo_comp),y
                sta yinterceptLo
;tax                
                lda (xpart_square_hi),y
                sbc (xpart_square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (xpart_square_hi),y 
                sbc (xpart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart1_init_yintercept_impl_end
       echo "Offset quart1_init_yintercept_impl_end: ", (*)



        ORG     $2000 + (quart1_init_xintercept - $3000)
        RORG    $5000 + (quart1_init_xintercept - $3000)

; ; xintercept = viewx + ((xstep * ypartial) 
; ici on calcule xstep * ypartial	
quart1_init_xintercept_impl SUBROUTINE
; *B
;				sta square_lo
;				sta square_hi
;				eor #$FF
;				sta square_lo_comp
;				sta square_hi_comp
; AH * B
                sec
                lda (ypart_square_lo),y 
                sbc (ypart_square_lo_comp),y
                sta xinterceptLo
                
                lda (ypart_square_hi),y
                sbc (ypart_square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (ypart_square_hi),y 
                sbc (ypart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart1_init_xintercept_impl_end
       echo "Offset quart1_init_xintercept_impl_end: ", (*)


        ORG     $2000 + (quart1_calc_ydist - $3000)
        RORG    $5000 + (quart1_calc_ydist - $3000)

; ici on calcule ydist(in ystep) * sin(angle) -> result in yintercept	
quart1_calc_ydist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta yinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart1_calc_ydist_impl_end
       echo "Offset quart1_calc_ydist_impl_end	: ", (*)


        ORG     $2000 + (quart1_add_calc_xdist - $3000)
        RORG    $5000 + (quart1_add_calc_xdist - $3000)

; ici on calcule xdist(in xstep) * cos(angle) -> result in xintercept. then add with yintercept as calculated above and map result on xstep
quart1_calc_xdist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta xinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
;				lda xinterceptLo
				clc
				adc yinterceptLo
				sta result
				lda xinterceptHi
				adc yinterceptHi
				sta result+1
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart1_add_calc_xdist_impl_end
       echo "Offset quart1_add_calc_xdist_impl_end	: ", (*)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quart no 2

; we dont need signed version, we already know the sign of everything
; multiply 16 bit x 8 bit / 256 -> 16 bit result (unsigned) (could be same method for signed a)

        ORG     $2000 + (quart2_init_yintercept - $3000)
        RORG    $5000 + (quart2_init_yintercept - $3000)

; ; yintercept = viewy + ((ystep * xpartial) 
; ici on calcule ystep * xpartial	
quart2_init_yintercept_impl SUBROUTINE

; *B. ; already ready
; AH * B
                sec
                lda (xpart_square_lo),y 
                sbc (xpart_square_lo_comp),y
                sta yinterceptLo
;tax                
                lda (xpart_square_hi),y
                sbc (xpart_square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (xpart_square_hi),y 
                sbc (xpart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart2_init_yintercept_impl_end
       echo "Offset quart2_init_yintercept_impl_end: ", (*)



        ORG     $2000 + (quart2_init_xintercept - $3000)
        RORG    $5000 + (quart2_init_xintercept - $3000)

; ; xintercept = viewx + ((xstep * ypartial) 
; ici on calcule xstep * ypartial	
quart2_init_xintercept_impl SUBROUTINE
; *B
;				sta square_lo
;				sta square_hi
;				eor #$FF
;				sta square_lo_comp
;				sta square_hi_comp
; AH * B
                sec
                lda (ypart_square_lo),y 
                sbc (ypart_square_lo_comp),y
                sta xinterceptLo
                
                lda (ypart_square_hi),y
                sbc (ypart_square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (ypart_square_hi),y 
                sbc (ypart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart2_init_xintercept_impl_end
       echo "Offset quart2_init_xintercept_impl_end: ", (*)


        ORG     $2000 + (quart2_calc_ydist - $3000)
        RORG    $5000 + (quart2_calc_ydist - $3000)

; ici on calcule ydist(in ystep) * sin(angle) -> result in yintercept	
quart2_calc_ydist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta yinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart2_calc_ydist_impl_end
       echo "Offset quart2_calc_ydist_impl_end	: ", (*)


        ORG     $2000 + (quart2_add_calc_xdist - $3000)
        RORG    $5000 + (quart2_add_calc_xdist - $3000)

; ici on calcule xdist(in xstep) * cos(angle) -> result in xintercept. then add with yintercept as calculated above and map result on xstep
quart2_calc_xdist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta xinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
;				lda ystep
				clc
				adc yinterceptLo
				sta result
				lda xinterceptHi
				adc yinterceptHi
				sta result+1
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart2_add_calc_xdist_impl_end
       echo "Offset quart2_add_calc_xdist_impl_end	: ", (*)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quart no 3

; we dont need signed version, we already know the sign of everything
; multiply 16 bit x 8 bit / 256 -> 16 bit result (unsigned) (could be same method for signed a)

        ORG     $2000 + (quart3_init_yintercept - $3000)
        RORG    $5000 + (quart3_init_yintercept - $3000)

; ; yintercept = viewy + ((ystep * xpartial) 
; ici on calcule ystep * xpartial	
quart3_init_yintercept_impl SUBROUTINE

; *B. ; already ready
; AH * B
                sec
                lda (xpart_square_lo),y 
                sbc (xpart_square_lo_comp),y
                sta yinterceptLo
;tax                
                lda (xpart_square_hi),y
                sbc (xpart_square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (xpart_square_hi),y 
                sbc (xpart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart3_init_yintercept_impl_end
       echo "Offset quart3_init_yintercept_impl_end: ", (*)



        ORG     $2000 + (quart3_init_xintercept - $3000)
        RORG    $5000 + (quart3_init_xintercept - $3000)

; ; xintercept = viewx + ((xstep * ypartial) 
; ici on calcule xstep * ypartial	
quart3_init_xintercept_impl SUBROUTINE
; *B
;				sta square_lo
;				sta square_hi
;				eor #$FF
;				sta square_lo_comp
;				sta square_hi_comp
; AH * B
                sec
                lda (ypart_square_lo),y 
                sbc (ypart_square_lo_comp),y
                sta xinterceptLo
                
                lda (ypart_square_hi),y
                sbc (ypart_square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (ypart_square_hi),y 
                sbc (ypart_square_hi_comp),y
                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart3_init_xintercept_impl_end
       echo "Offset quart3_init_xintercept_impl_end: ", (*)


        ORG     $2000 + (quart3_calc_ydist - $3000)
        RORG    $5000 + (quart3_calc_ydist - $3000)

; ici on calcule ydist(in ystep) * sin(angle) -> result in yintercept	
quart3_calc_ydist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta yinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta yinterceptHi

				LDY ystep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc yinterceptLo
                sta yinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc yinterceptHi
.ok
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart3_calc_ydist_impl_end
       echo "Offset quart3_calc_ydist_impl_end	: ", (*)


        ORG     $2000 + (quart3_add_calc_xdist - $3000)
        RORG    $5000 + (quart3_add_calc_xdist - $3000)

; ici on calcule xdist(in xstep) * cos(angle) -> result in xintercept. then add with yintercept as calculated above and map result on xstep
quart3_calc_xdist_impl SUBROUTINE

; *B
				sta square_lo
				sta square_hi
				eor #$FF
				sta square_lo_comp
				sta square_hi_comp
; AH * B
                sec
                lda (square_lo),y 
                sbc (square_lo_comp),y
                sta xinterceptLo
                
                lda (square_hi),y
                sbc (square_hi_comp),y
                sta xinterceptHi

				LDY xstep
; Hi(AL * B)
;                sec
                lda (square_hi),y 
                sbc (square_hi_comp),y
;                clc							; on pourra le supprimer celui-la probablement
                adc xinterceptLo
                sta xinterceptLo
                bcc .ok
;                lda #0
;                adc result+1
;                sta result+1
				inc xinterceptHi
.ok
;				lda ystep
				clc
				adc yinterceptLo
				sta result
				lda xinterceptHi
				adc yinterceptHi
				sta result+1
				; retour a la ROM de depart
				CMP $1FF5	; bye
quart3_add_calc_xdist_impl_end
       echo "Offset quart3_add_calc_xdist_impl_end	: ", (*)





        ORG     $2700
        RORG    $5700


	ALIGN 256
square_high
	.byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
	.byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
	.byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$02,#$02
	.byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03
	.byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$06
	.byte #$06,#$06,#$06,#$06,#$06,#$07,#$07,#$07,#$07,#$07,#$07,#$08,#$08,#$08,#$08,#$08
	.byte #$09,#$09,#$09,#$09,#$09,#$09,#$0a,#$0a,#$0a,#$0a,#$0a,#$0b,#$0b,#$0b,#$0b,#$0c
	.byte #$0c,#$0c,#$0c,#$0c,#$0d,#$0d,#$0d,#$0d,#$0e,#$0e,#$0e,#$0e,#$0f,#$0f,#$0f,#$0f
	.byte #$10,#$10,#$10,#$10,#$11,#$11,#$11,#$11,#$12,#$12,#$12,#$12,#$13,#$13,#$13,#$13
	.byte #$14,#$14,#$14,#$15,#$15,#$15,#$15,#$16,#$16,#$16,#$17,#$17,#$17,#$18,#$18,#$18
	.byte #$19,#$19,#$19,#$19,#$1a,#$1a,#$1a,#$1b,#$1b,#$1b,#$1c,#$1c,#$1c,#$1d,#$1d,#$1d
	.byte #$1e,#$1e,#$1e,#$1f,#$1f,#$1f,#$20,#$20,#$21,#$21,#$21,#$22,#$22,#$22,#$23,#$23
	.byte #$24,#$24,#$24,#$25,#$25,#$25,#$26,#$26,#$27,#$27,#$27,#$28,#$28,#$29,#$29,#$29
	.byte #$2a,#$2a,#$2b,#$2b,#$2b,#$2c,#$2c,#$2d,#$2d,#$2d,#$2e,#$2e,#$2f,#$2f,#$30,#$30
	.byte #$31,#$31,#$31,#$32,#$32,#$33,#$33,#$34,#$34,#$35,#$35,#$35,#$36,#$36,#$37,#$37
	.byte #$38,#$38,#$39,#$39,#$3a,#$3a,#$3b,#$3b,#$3c,#$3c,#$3d,#$3d,#$3e,#$3e,#$3f,#$3f
	.byte #$40,#$40,#$41,#$41,#$42,#$42,#$43,#$43,#$44,#$44,#$45,#$45,#$46,#$46,#$47,#$47
	.byte #$48,#$48,#$49,#$49,#$4a,#$4a,#$4b,#$4c,#$4c,#$4d,#$4d,#$4e,#$4e,#$4f,#$4f,#$50
	.byte #$51,#$51,#$52,#$52,#$53,#$53,#$54,#$54,#$55,#$56,#$56,#$57,#$57,#$58,#$59,#$59
	.byte #$5a,#$5a,#$5b,#$5c,#$5c,#$5d,#$5d,#$5e,#$5f,#$5f,#$60,#$60,#$61,#$62,#$62,#$63
	.byte #$64,#$64,#$65,#$65,#$66,#$67,#$67,#$68,#$69,#$69,#$6a,#$6a,#$6b,#$6c,#$6c,#$6d
	.byte #$6e,#$6e,#$6f,#$70,#$70,#$71,#$72,#$72,#$73,#$74,#$74,#$75,#$76,#$76,#$77,#$78
	.byte #$79,#$79,#$7a,#$7b,#$7b,#$7c,#$7d,#$7d,#$7e,#$7f,#$7f,#$80,#$81,#$82,#$82,#$83
	.byte #$84,#$84,#$85,#$86,#$87,#$87,#$88,#$89,#$8a,#$8a,#$8b,#$8c,#$8d,#$8d,#$8e,#$8f
	.byte #$90,#$90,#$91,#$92,#$93,#$93,#$94,#$95,#$96,#$96,#$97,#$98,#$99,#$99,#$9a,#$9b
	.byte #$9c,#$9d,#$9d,#$9e,#$9f,#$a0,#$a0,#$a1,#$a2,#$a3,#$a4,#$a4,#$a5,#$a6,#$a7,#$a8
	.byte #$a9,#$a9,#$aa,#$ab,#$ac,#$ad,#$ad,#$ae,#$af,#$b0,#$b1,#$b2,#$b2,#$b3,#$b4,#$b5
	.byte #$b6,#$b7,#$b7,#$b8,#$b9,#$ba,#$bb,#$bc,#$bd,#$bd,#$be,#$bf,#$c0,#$c1,#$c2,#$c3
	.byte #$c4,#$c4,#$c5,#$c6,#$c7,#$c8,#$c9,#$ca,#$cb,#$cb,#$cc,#$cd,#$ce,#$cf,#$d0,#$d1
	.byte #$d2,#$d3,#$d4,#$d4,#$d5,#$d6,#$d7,#$d8,#$d9,#$da,#$db,#$dc,#$dd,#$de,#$df,#$e0
	.byte #$e1,#$e1,#$e2,#$e3,#$e4,#$e5,#$e6,#$e7,#$e8,#$e9,#$ea,#$eb,#$ec,#$ed,#$ee,#$ef
	.byte #$f0,#$f1,#$f2,#$f3,#$f4,#$f5,#$f6,#$f7,#$f8,#$f9,#$fa,#$fb,#$fc,#$fd,#$fe,#$ff

	ALIGN 256
square_compl_high
	.byte #$3f,#$3f,#$3e,#$3e,#$3d,#$3d,#$3c,#$3c,#$3b,#$3b,#$3a,#$3a,#$39,#$39,#$38,#$38
	.byte #$37,#$37,#$36,#$36,#$35,#$35,#$35,#$34,#$34,#$33,#$33,#$32,#$32,#$31,#$31,#$31
	.byte #$30,#$30,#$2f,#$2f,#$2e,#$2e,#$2d,#$2d,#$2d,#$2c,#$2c,#$2b,#$2b,#$2b,#$2a,#$2a
	.byte #$29,#$29,#$29,#$28,#$28,#$27,#$27,#$27,#$26,#$26,#$25,#$25,#$25,#$24,#$24,#$24
	.byte #$23,#$23,#$22,#$22,#$22,#$21,#$21,#$21,#$20,#$20,#$1f,#$1f,#$1f,#$1e,#$1e,#$1e
	.byte #$1d,#$1d,#$1d,#$1c,#$1c,#$1c,#$1b,#$1b,#$1b,#$1a,#$1a,#$1a,#$19,#$19,#$19,#$19
	.byte #$18,#$18,#$18,#$17,#$17,#$17,#$16,#$16,#$16,#$15,#$15,#$15,#$15,#$14,#$14,#$14
	.byte #$13,#$13,#$13,#$13,#$12,#$12,#$12,#$12,#$11,#$11,#$11,#$11,#$10,#$10,#$10,#$10
	.byte #$0f,#$0f,#$0f,#$0f,#$0e,#$0e,#$0e,#$0e,#$0d,#$0d,#$0d,#$0d,#$0c,#$0c,#$0c,#$0c
	.byte #$0c,#$0b,#$0b,#$0b,#$0b,#$0a,#$0a,#$0a,#$0a,#$0a,#$09,#$09,#$09,#$09,#$09,#$09
	.byte #$08,#$08,#$08,#$08,#$08,#$07,#$07,#$07,#$07,#$07,#$07,#$06,#$06,#$06,#$06,#$06
	.byte #$06,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$04,#$04,#$04,#$04,#$04,#$04,#$04,#$04
	.byte #$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$02,#$02,#$02,#$02,#$02,#$02,#$02,#$02
	.byte #$02,#$02,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01
	.byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
	.byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
	.byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00
	.byte #$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$00,#$01
	.byte #$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$01,#$02,#$02,#$02
	.byte #$02,#$02,#$02,#$02,#$02,#$02,#$02,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$03,#$04
	.byte #$04,#$04,#$04,#$04,#$04,#$04,#$04,#$05,#$05,#$05,#$05,#$05,#$05,#$05,#$06,#$06
	.byte #$06,#$06,#$06,#$06,#$07,#$07,#$07,#$07,#$07,#$07,#$08,#$08,#$08,#$08,#$08,#$09
	.byte #$09,#$09,#$09,#$09,#$09,#$0a,#$0a,#$0a,#$0a,#$0a,#$0b,#$0b,#$0b,#$0b,#$0c,#$0c
	.byte #$0c,#$0c,#$0c,#$0d,#$0d,#$0d,#$0d,#$0e,#$0e,#$0e,#$0e,#$0f,#$0f,#$0f,#$0f,#$10
	.byte #$10,#$10,#$10,#$11,#$11,#$11,#$11,#$12,#$12,#$12,#$12,#$13,#$13,#$13,#$13,#$14
	.byte #$14,#$14,#$15,#$15,#$15,#$15,#$16,#$16,#$16,#$17,#$17,#$17,#$18,#$18,#$18,#$19
	.byte #$19,#$19,#$19,#$1a,#$1a,#$1a,#$1b,#$1b,#$1b,#$1c,#$1c,#$1c,#$1d,#$1d,#$1d,#$1e
	.byte #$1e,#$1e,#$1f,#$1f,#$1f,#$20,#$20,#$21,#$21,#$21,#$22,#$22,#$22,#$23,#$23,#$24
	.byte #$24,#$24,#$25,#$25,#$25,#$26,#$26,#$27,#$27,#$27,#$28,#$28,#$29,#$29,#$29,#$2a
	.byte #$2a,#$2b,#$2b,#$2b,#$2c,#$2c,#$2d,#$2d,#$2d,#$2e,#$2e,#$2f,#$2f,#$30,#$30,#$31
	.byte #$31,#$31,#$32,#$32,#$33,#$33,#$34,#$34,#$35,#$35,#$35,#$36,#$36,#$37,#$37,#$38
	.byte #$38,#$39,#$39,#$3a,#$3a,#$3b,#$3b,#$3c,#$3c,#$3d,#$3d,#$3e,#$3e,#$3f,#$3f,#$40

	ALIGN 256
square_low
	.byte #$00,#$00,#$01,#$02,#$04,#$06,#$09,#$0c,#$10,#$14,#$19,#$1e,#$24,#$2a,#$31,#$38
	.byte #$40,#$48,#$51,#$5a,#$64,#$6e,#$79,#$84,#$90,#$9c,#$a9,#$b6,#$c4,#$d2,#$e1,#$f0
	.byte #$00,#$10,#$21,#$32,#$44,#$56,#$69,#$7c,#$90,#$a4,#$b9,#$ce,#$e4,#$fa,#$11,#$28
	.byte #$40,#$58,#$71,#$8a,#$a4,#$be,#$d9,#$f4,#$10,#$2c,#$49,#$66,#$84,#$a2,#$c1,#$e0
	.byte #$00,#$20,#$41,#$62,#$84,#$a6,#$c9,#$ec,#$10,#$34,#$59,#$7e,#$a4,#$ca,#$f1,#$18
	.byte #$40,#$68,#$91,#$ba,#$e4,#$0e,#$39,#$64,#$90,#$bc,#$e9,#$16,#$44,#$72,#$a1,#$d0
	.byte #$00,#$30,#$61,#$92,#$c4,#$f6,#$29,#$5c,#$90,#$c4,#$f9,#$2e,#$64,#$9a,#$d1,#$08
	.byte #$40,#$78,#$b1,#$ea,#$24,#$5e,#$99,#$d4,#$10,#$4c,#$89,#$c6,#$04,#$42,#$81,#$c0
	.byte #$00,#$40,#$81,#$c2,#$04,#$46,#$89,#$cc,#$10,#$54,#$99,#$de,#$24,#$6a,#$b1,#$f8
	.byte #$40,#$88,#$d1,#$1a,#$64,#$ae,#$f9,#$44,#$90,#$dc,#$29,#$76,#$c4,#$12,#$61,#$b0
	.byte #$00,#$50,#$a1,#$f2,#$44,#$96,#$e9,#$3c,#$90,#$e4,#$39,#$8e,#$e4,#$3a,#$91,#$e8
	.byte #$40,#$98,#$f1,#$4a,#$a4,#$fe,#$59,#$b4,#$10,#$6c,#$c9,#$26,#$84,#$e2,#$41,#$a0
	.byte #$00,#$60,#$c1,#$22,#$84,#$e6,#$49,#$ac,#$10,#$74,#$d9,#$3e,#$a4,#$0a,#$71,#$d8
	.byte #$40,#$a8,#$11,#$7a,#$e4,#$4e,#$b9,#$24,#$90,#$fc,#$69,#$d6,#$44,#$b2,#$21,#$90
	.byte #$00,#$70,#$e1,#$52,#$c4,#$36,#$a9,#$1c,#$90,#$04,#$79,#$ee,#$64,#$da,#$51,#$c8
	.byte #$40,#$b8,#$31,#$aa,#$24,#$9e,#$19,#$94,#$10,#$8c,#$09,#$86,#$04,#$82,#$01,#$80
	.byte #$00,#$80,#$01,#$82,#$04,#$86,#$09,#$8c,#$10,#$94,#$19,#$9e,#$24,#$aa,#$31,#$b8
	.byte #$40,#$c8,#$51,#$da,#$64,#$ee,#$79,#$04,#$90,#$1c,#$a9,#$36,#$c4,#$52,#$e1,#$70
	.byte #$00,#$90,#$21,#$b2,#$44,#$d6,#$69,#$fc,#$90,#$24,#$b9,#$4e,#$e4,#$7a,#$11,#$a8
	.byte #$40,#$d8,#$71,#$0a,#$a4,#$3e,#$d9,#$74,#$10,#$ac,#$49,#$e6,#$84,#$22,#$c1,#$60
	.byte #$00,#$a0,#$41,#$e2,#$84,#$26,#$c9,#$6c,#$10,#$b4,#$59,#$fe,#$a4,#$4a,#$f1,#$98
	.byte #$40,#$e8,#$91,#$3a,#$e4,#$8e,#$39,#$e4,#$90,#$3c,#$e9,#$96,#$44,#$f2,#$a1,#$50
	.byte #$00,#$b0,#$61,#$12,#$c4,#$76,#$29,#$dc,#$90,#$44,#$f9,#$ae,#$64,#$1a,#$d1,#$88
	.byte #$40,#$f8,#$b1,#$6a,#$24,#$de,#$99,#$54,#$10,#$cc,#$89,#$46,#$04,#$c2,#$81,#$40
	.byte #$00,#$c0,#$81,#$42,#$04,#$c6,#$89,#$4c,#$10,#$d4,#$99,#$5e,#$24,#$ea,#$b1,#$78
	.byte #$40,#$08,#$d1,#$9a,#$64,#$2e,#$f9,#$c4,#$90,#$5c,#$29,#$f6,#$c4,#$92,#$61,#$30
	.byte #$00,#$d0,#$a1,#$72,#$44,#$16,#$e9,#$bc,#$90,#$64,#$39,#$0e,#$e4,#$ba,#$91,#$68
	.byte #$40,#$18,#$f1,#$ca,#$a4,#$7e,#$59,#$34,#$10,#$ec,#$c9,#$a6,#$84,#$62,#$41,#$20
	.byte #$00,#$e0,#$c1,#$a2,#$84,#$66,#$49,#$2c,#$10,#$f4,#$d9,#$be,#$a4,#$8a,#$71,#$58
	.byte #$40,#$28,#$11,#$fa,#$e4,#$ce,#$b9,#$a4,#$90,#$7c,#$69,#$56,#$44,#$32,#$21,#$10
	.byte #$00,#$f0,#$e1,#$d2,#$c4,#$b6,#$a9,#$9c,#$90,#$84,#$79,#$6e,#$64,#$5a,#$51,#$48
	.byte #$40,#$38,#$31,#$2a,#$24,#$1e,#$19,#$14,#$10,#$0c,#$09,#$06,#$04,#$02,#$01,#$00

	ALIGN 256
square_compl_low
	.byte #$80,#$01,#$82,#$04,#$86,#$09,#$8c,#$10,#$94,#$19,#$9e,#$24,#$aa,#$31,#$b8,#$40
	.byte #$c8,#$51,#$da,#$64,#$ee,#$79,#$04,#$90,#$1c,#$a9,#$36,#$c4,#$52,#$e1,#$70,#$00
	.byte #$90,#$21,#$b2,#$44,#$d6,#$69,#$fc,#$90,#$24,#$b9,#$4e,#$e4,#$7a,#$11,#$a8,#$40
	.byte #$d8,#$71,#$0a,#$a4,#$3e,#$d9,#$74,#$10,#$ac,#$49,#$e6,#$84,#$22,#$c1,#$60,#$00
	.byte #$a0,#$41,#$e2,#$84,#$26,#$c9,#$6c,#$10,#$b4,#$59,#$fe,#$a4,#$4a,#$f1,#$98,#$40
	.byte #$e8,#$91,#$3a,#$e4,#$8e,#$39,#$e4,#$90,#$3c,#$e9,#$96,#$44,#$f2,#$a1,#$50,#$00
	.byte #$b0,#$61,#$12,#$c4,#$76,#$29,#$dc,#$90,#$44,#$f9,#$ae,#$64,#$1a,#$d1,#$88,#$40
	.byte #$f8,#$b1,#$6a,#$24,#$de,#$99,#$54,#$10,#$cc,#$89,#$46,#$04,#$c2,#$81,#$40,#$00
	.byte #$c0,#$81,#$42,#$04,#$c6,#$89,#$4c,#$10,#$d4,#$99,#$5e,#$24,#$ea,#$b1,#$78,#$40
	.byte #$08,#$d1,#$9a,#$64,#$2e,#$f9,#$c4,#$90,#$5c,#$29,#$f6,#$c4,#$92,#$61,#$30,#$00
	.byte #$d0,#$a1,#$72,#$44,#$16,#$e9,#$bc,#$90,#$64,#$39,#$0e,#$e4,#$ba,#$91,#$68,#$40
	.byte #$18,#$f1,#$ca,#$a4,#$7e,#$59,#$34,#$10,#$ec,#$c9,#$a6,#$84,#$62,#$41,#$20,#$00
	.byte #$e0,#$c1,#$a2,#$84,#$66,#$49,#$2c,#$10,#$f4,#$d9,#$be,#$a4,#$8a,#$71,#$58,#$40
	.byte #$28,#$11,#$fa,#$e4,#$ce,#$b9,#$a4,#$90,#$7c,#$69,#$56,#$44,#$32,#$21,#$10,#$00
	.byte #$f0,#$e1,#$d2,#$c4,#$b6,#$a9,#$9c,#$90,#$84,#$79,#$6e,#$64,#$5a,#$51,#$48,#$40
	.byte #$38,#$31,#$2a,#$24,#$1e,#$19,#$14,#$10,#$0c,#$09,#$06,#$04,#$02,#$01,#$00,#$00
	.byte #$00,#$01,#$02,#$04,#$06,#$09,#$0c,#$10,#$14,#$19,#$1e,#$24,#$2a,#$31,#$38,#$40
	.byte #$48,#$51,#$5a,#$64,#$6e,#$79,#$84,#$90,#$9c,#$a9,#$b6,#$c4,#$d2,#$e1,#$f0,#$00
	.byte #$10,#$21,#$32,#$44,#$56,#$69,#$7c,#$90,#$a4,#$b9,#$ce,#$e4,#$fa,#$11,#$28,#$40
	.byte #$58,#$71,#$8a,#$a4,#$be,#$d9,#$f4,#$10,#$2c,#$49,#$66,#$84,#$a2,#$c1,#$e0,#$00
	.byte #$20,#$41,#$62,#$84,#$a6,#$c9,#$ec,#$10,#$34,#$59,#$7e,#$a4,#$ca,#$f1,#$18,#$40
	.byte #$68,#$91,#$ba,#$e4,#$0e,#$39,#$64,#$90,#$bc,#$e9,#$16,#$44,#$72,#$a1,#$d0,#$00
	.byte #$30,#$61,#$92,#$c4,#$f6,#$29,#$5c,#$90,#$c4,#$f9,#$2e,#$64,#$9a,#$d1,#$08,#$40
	.byte #$78,#$b1,#$ea,#$24,#$5e,#$99,#$d4,#$10,#$4c,#$89,#$c6,#$04,#$42,#$81,#$c0,#$00
	.byte #$40,#$81,#$c2,#$04,#$46,#$89,#$cc,#$10,#$54,#$99,#$de,#$24,#$6a,#$b1,#$f8,#$40
	.byte #$88,#$d1,#$1a,#$64,#$ae,#$f9,#$44,#$90,#$dc,#$29,#$76,#$c4,#$12,#$61,#$b0,#$00
	.byte #$50,#$a1,#$f2,#$44,#$96,#$e9,#$3c,#$90,#$e4,#$39,#$8e,#$e4,#$3a,#$91,#$e8,#$40
	.byte #$98,#$f1,#$4a,#$a4,#$fe,#$59,#$b4,#$10,#$6c,#$c9,#$26,#$84,#$e2,#$41,#$a0,#$00
	.byte #$60,#$c1,#$22,#$84,#$e6,#$49,#$ac,#$10,#$74,#$d9,#$3e,#$a4,#$0a,#$71,#$d8,#$40
	.byte #$a8,#$11,#$7a,#$e4,#$4e,#$b9,#$24,#$90,#$fc,#$69,#$d6,#$44,#$b2,#$21,#$90,#$00
	.byte #$70,#$e1,#$52,#$c4,#$36,#$a9,#$1c,#$90,#$04,#$79,#$ee,#$64,#$da,#$51,#$c8,#$40
	.byte #$b8,#$31,#$aa,#$24,#$9e,#$19,#$94,#$10,#$8c,#$09,#$86,#$04,#$82,#$01,#$80,#$00
