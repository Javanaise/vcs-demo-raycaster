
        MAC TIMER_SETUP
.Lines  SET {1}
        lda #(((.Lines-1)*76-14)/64)
        sta TIM64T
        ENDM

        MAC TIMER_WAIT
.waitForIntim
        lda INTIM
        bne .waitForIntim
        ENDM
