;------------------------------------------------------------------------------
;         Utilities for printing strings
;         John Gresty
;         Version 1.0
;         2015-02-03
; 

              B   _str_end ; protect from accidental execution

              GET constants.s


; clear the screen and print string 
; R0 string pointer
; returns 
; R0 end of string
; R1 new cursor position
str_print     PUSH  {R4-R9, LR}
              BL    _str_init
              MOV   R2, #CH_FF  ; clear screen first
              BL    _str_control
              B     _str_setup


; append a single character to the screen
; R1 current cursor position
; R2 character to print
; returns
; R1 new cursor position
str_print_ch  PUSH  {R4-R9, LR}
              BL    _str_init
              ; can't call str_setup as that will fall through to the loop
              MOV   R3, #&25
              MOV   R5, #&22
              MOV   R6, #&23
              BL    _str_app_ch
              POP   {R4-R9, PC}


; append current string to screen
; R0 string pointer
; R1 current cursor position
; returns 
; R0 end of string
; R1 new cursor position
str_append    PUSH  {R4-R9, LR}
              BL    _str_init
; fall through to setup

; setup registers for printing characters
_str_setup    MOV   R3, #&25    ; R/W=1, RS=0, E=1
              MOV   R5, #&22    ; R/W=0, RS=1
              MOV   R6, #&23    ; E=1
; fall through to the loop

; print loop until control sequence
_str_prt_loop LDRB  R2, [R0]
              CMP   R1, #ST_LCD_WIDTH
              MOVEQ R2, #CH_LF 
              ADDNE R0, R0, #1      ; do not add for auto-end of line
              CMP   R2, #&D         ; test for control sequences
              ADRLE LR, _str_setup  ; need to reset the registers after
              BLE   _str_control
              BL    _str_app_ch
              ADD   R1, R1, #1
              B     _str_prt_loop

; initalise registers and LCD functions
_str_init     MOV   R8, #PORT_AREA
              MOV   R4, #&24      ; E=0
              MOV   R9, #ST_STATUS_BIT
              MOV   PC, LR

; wait for LCD to be ready then append character in R2
_str_app_ch   STRB  R3, [R8, #CONTROL_PORT] ; set control to read, enable bus
              LDRB  R7, [R8, #DATA_PORT]    ; read status
              STRB  R4, [R8, #CONTROL_PORT] ; disable bus
              TST   R7, R9                  ; test status bit
              BNE   _str_app_ch

              STRB  R5, [R8, #CONTROL_PORT]
              STRB  R2, [R8, #DATA_PORT]    ; write char
              ; strobe E
              STRB  R6, [R8, #CONTROL_PORT]
              STRB  R5, [R8, #CONTROL_PORT]
              MOV   PC, LR

; handle control sequences
_str_control  CMP   R2, #0 ; null (exit)
              POPEQ {R4-R9}
              BEQ   user_branch
              MOV   R4, #&24
              MOV   R5, #&20
              MOV   R6, #&21
              CMP   R2, #CH_FF
              MOVEQ R2, #&1
              MOVEQ R1, #0   ; reset cursor pos
              BEQ   _str_app_ch
              CMP   R2, #CH_LF
              MOVEQ R2, #&C0
              MOVEQ R1, #0   ; reset cursor pos
              BEQ   _str_app_ch
              B     _str_setup ; character not found, try to recover
_str_end 

; 0 - string address
; 1 - cursor position
; 2 - character to print
; 3 - LCD control signal
; 4 - LCD control signal
; 5 - LCD control signal
; 6 - LCD control signal
; 7 - test LCD ready
; 8 - const port address
; 9 - const test bit
