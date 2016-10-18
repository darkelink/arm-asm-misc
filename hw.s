;------------------------------------------------------------------------------
;       Specific hardware dependant functions
;       John Gresty
;       2015-03-16
;


; append a char from R0
display 
        PUSH  {R1-R3, LR}
        MOV   R3, #PORT_AREA
        BL    tst_lcd
        ORR   R1, R1, #2 ; RS=1
        BIC   R1, R1, #4 ; RW=0
        STRB  R1, [R3, #CONTROL_PORT]
        BL    output
        POP   {R1-R3, LR}
        MOVS  PC, LR

; block until display is ready
tst_lcd LDRB  R1, [R3, #CONTROL_PORT]
        ORR   R1, R1, #5 ; RW=1, E=1
        BIC   R1, R1, #2 ; RS=0
        STRB  R1, [R3, #CONTROL_PORT]
        LDRB  R2, [R3, #DATA_PORT]
        BIC   R1, R1, #1 ; E=0
        STRB  R1, [R3, #CONTROL_PORT]
        TST   R2, #ST_STATUS_BIT
        BNE   tst_lcd
        MOV   PC, LR

; send data in R0 to display then strobe E
output  STRB  R0, [R3, #DATA_PORT]
        ORR   R1, R1, #1
        STRB  R1, [R3, #CONTROL_PORT]
        BIC   R1, R1, #1
        STRB  R1, [R3, #CONTROL_PORT]
        MOV   PC, LR
