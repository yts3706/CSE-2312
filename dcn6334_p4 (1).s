/**************
*Float Division
***************/

.global main
.func main

main:
	BL _prompt1	    @ branch to prompt procedure with return
	BL _scanf
	MOV R5, R0	    @ numerator n
	BL _prompt2	    @ branch to prompt procedure with return
	BL _scanf
	MOV R10, R0	    @ denominator d
	BL _division

_prompt1:
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #31             @ print string length
    LDR R1, =prompt_str1     @ string at label prompt_str1:
    SWI 0                   @ execute syscall
    MOV PC, LR              @ return

_prompt2:
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #31             @ print string length
    LDR R1, =prompt_str2     @ string at label prompt_str2:
    SWI 0                   @ execute syscall
    MOV PC, LR              @ return

_scanf:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_division:
    VMOV S0, R5             @ move the numerator to floating point register
    VMOV S1, R10             @ move the denominator to floating point register
    VCVT.F32.S32 S0, S0     @ convert unsigned bit representation to single float
    VCVT.F32.S32 S1, S1     @ convert unsigned bit representation to single float
	
    VDIV.F32 S2, S0, S1     @ compute S2 = S0 * S1
    
    VCVT.F64.F32 D4, S2     @ covert the result to double precision for printing
    VMOV R1, R2, D4         @ split the double VFP register into two ARM registers
    BL  _printf_result      @ print the result

_printf_result:
    PUSH {LR}               @ push LR to stack
    LDR R0, =result_str     @ R0 contains formatted string address
    BL printf               @ call printf
    B main

.data
format_str:     .asciz      "%d"
prompt_str1:     .asciz      "Type a number and press enter: "
prompt_str2:     .asciz      "Type a number and press enter: "
result_str:     .asciz      "%f\n"
