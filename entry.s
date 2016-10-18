;------------------------------------------------------------------------------
;       Program entry point
;       John Gresty
;       2015-03-16
;

reset       B start
undef_ex    B .
svccall     B svchandle
prefetch    B .
data        B .
none        B .
irq         B inthandle
fiq         B .

start       MOV   LR, #&50
            MSR   SPSR, LR
            MOV   LR, #1
            MOV   R0, #PORT_AREA
            STRB  LR, [R0, #INT_EN_PORT]
            ADR   SP, (sys_stack+STACK_SIZE)
            ADR   LR, main
user_branch MOVS  PC, LR

STACK_SIZE  EQU   32
sys_stack   DEFS  STACK_SIZE
irq_stack   DEFS  STACK_SIZE

svchandle   
            LDR   R1, [LR, #-4]
            BIC   R1, R1, #&FF000000
            CMP   R1, #1
            BHI   user_branch
            ADR R2, svc_jmp_tbl
            LDR PC, [R2, R1 LSL #2]

svc_jmp_tbl DEFW  kp_get_char
            DEFW  display

inthandle   ADR   SP, (irq_stack+STACK_SIZE)
            SUB   LR, LR, #4
            STMFD SP!, {R0-R2, LR}
            ; clear timer interupt
            MOV   R1, #PORT_AREA
            MOV   R2, #0
            STRB  R2, [R1, #INTERUPT_PORT]

            LDMFD SP!, {R0-R2, PC}^
            

            GET constants.s
            GET hw.s
            GET keypad.s
            GET user.s

