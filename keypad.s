;------------------------------------------------------------------------------
;       Update characters from keypad and return character in R0 if 
;       it is held down for enough calls to this function
;       John Gresty
;       2015-03-16
;

kp_get_char PUSH {R1-R5, LR}
            ; load registers
kp_reset    MOV   R0, #1
            MOV   R1, #FPGA_PORTS
            MOV   R2, #bv
            MOV   R3, #&1F
            ; set upper 3 bits to output
            STRB  R3, [R1, #1]
            ; mask for key row
            ; column
            MOV   R4, #0
            ; row
            MOV   R5, #0
kp_loop
            ; set mask
            MOV   R0, #1
            ADD   R4, R4, #5
            MOV   R0, R0 LSL R4
            SUB   R4, R4, #5
            STRB  R0, [R1]

            ; get current key states
            LDRB  R3, [R1]
            ; mask out input bits
            AND   R3, R3, #&F

            ; loop over each row
kp_inner    MOV   R0, #1
            AND   R3, R3, R0 LSL R5
            CMP   R3, #0

            ADD   R6, R5, R4 LSL #2
            LDRB  R0, [R2, R6]
            MOV   R0, R0 LSL #1
            ADDNE R0, R0, #1
            STRB  R0, [R2, R6]
            CMP   R0, #&FF
            BEQ   kp_return

            ADD   R5, R5, #1
            CMP   R5, #4
            BNE   kp_loop
            MOV   R5, #0
            ADD   R4, R4, #1
            CMP   R4, #3
            BNE   kp_loop
            ; set invalid key if none are ready
            MOV   R6, #&C

kp_return   MOV   R0, R6
            POP   {R1-R5, PC}^

bv    DEFB  0, 0, 0, 0
      DEFB  0, 0, 0, 0
      DEFB  0, 0, 0, 0

; lookup from key index to ascii value
tb    DEFB  &33, &36, &39, &23
      DEFB  &32, &35, &38, &30
      DEFB  &31, &34, &37, &2A
