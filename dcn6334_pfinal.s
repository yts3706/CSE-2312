/****************
*Final Program
****************/

.global main
.func main

main:
	MOV R0, #0		@ initialize index variable
	BL _generate
	PUSH {R10}
	MOV R0, #0
	BL _readloop
	MOV R0, #0
	BL _prompt
	BL _sort_ascending
	BL _getValue
	MOV R8, R0
	BL _search_value
@	B _exit
	
_scanf:
	PUSH {LR}
    	SUB SP, SP, #4          @ make room on stack
    	LDR R0, =format_str     @ R0 contains address of format string
    	MOV R1, SP              @ move SP to R1 to store entry on stack
    	BL scanf                @ call scanf
    	LDR R0, [SP]            @ load value at SP into R0
    	ADD SP, SP, #4          @ restore the stack pointer
    	POP {PC}	        @ return
	
_generate:
	CMP R0, #0
	PUSHEQ {LR}
	MOVEQ R10, #0
	CMP R0, #10		@ check to see if we are done iterating
	POPEQ {PC}		@ exit loop if done
	LDR R1, =array_a	@ get address of a
	LSL R2, R0, #2		@ multiply index * 4 to get array offset
	ADD R2, R1, R2		@ R2 = address of 'a[R0]'
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	BL _scanf
	MOV R4, R0		@ moving return value of _scanf to R0
	POP {R2}
	POP {R1}
	POP {R0}
	STR R4, [R2]		@ a[R0] = user input
	ADD R0, R0, #1		@ R0++
	B _generate	
	
_readloop:
	CMP R0, #0
	PUSHEQ {LR}
	CMP R0, #10		@ check to see if we are done iterating
	POPEQ {PC}		@ exit loop if done
	LDR R1, =array_a	@ get address of a
	LSL R2, R0, #2		@ multiply index * 4 to get array offset
	ADD R2, R1, R2		@ R2 = address a[R0]
	LDR R1, [R2]		@ read the array 'a' at address
	PUSH {R0} 		@ backup register before printf
	PUSH {R1}		@ backup register before printf
	PUSH {R2} 		@ backup register before printf
	MOV R2, R1		@ move array value to R2 for printf
	MOV R1, R0		@ move array index to R1 for printf
	BL _printfA		@ branch to _printf procedure with return
	POP {R2}
	POP {R1}
	POP {R0}
	ADD R0, R0, #1		@ increment index
	B _readloop		@ branch to next loop iteration

_printfA:
	PUSH {LR}		@ store the return address
	LDR R0, =printf_str	@ R0 contains formatted string address
	BL printf		@ call printf
	POP {PC}		@ restore the stack pointer and return
	
_sort_ascending:
	PUSH {LR}

_prompt:
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #22             @ print string length
    LDR R1, =prompt_str     @ string at label prompt_str:
    SWI 0                   @ execute syscall
    MOV PC, LR              @ return

_getValue:
	PUSH {LR}
    	SUB SP, SP, #4          @ make room on stack
    	LDR R0, =format_str     @ R0 contains address of format string
    	MOV R1, SP              @ move SP to R1 to store entry on stack
    	BL scanf                @ call scanf
    	LDR R0, [SP]            @ load value at SP into R0
    	ADD SP, SP, #4          @ restore the stack pointer
    	POP {PC}	        @ return


_search_value:
	CMP R5, #10
	BEQ _search_complete
	LDR R1, =array_a
	LSL R2, R5, #2
	ADD R2, R1, R2
	LDR R3, [R2]
	CMP R3, R8
	LDREQ R0, =output_result
	MOVEQ R1, R5
	MOVEQ R2, R3
	BLEQ printf
	MOVEQ R10, #1
	ADD R5, R5, #1
	B _search_value		@ branch to next loop iteration

_search_complete:
    CMP R10, #0
    LDREQ R0, =output_none
    BLEQ printf


@_exit:
@	PUSH {LR}
@	MOV R7, #4		@ write syscall, 4
@	MOV R0, #1		@ output stream to monitor, 1
@	MOV R2, #21		@ print string length
@	LDR R1, =exit_str 	@ string at label exit_str:
@	SWI 0			@ execute syscall
@	MOV R7, #1		@ terminate syscall, 1
@	SWI 0			@ execute syscall
@	POP {PC}

.data

.balign	4
array_a:	.skip		40
printf_str: 	.asciz		"array_a[%d] = %d\n"
prompt_str:	.asciz		"Enter a search value: "
output_result:	.asciz		"array_a[%d] = %d\n"
output_none:	.ascii		"That value does not exist in the array!\n"
@exit_str:	.ascii		"Terminating Program.\n"
format_str:	.asciz		"%d"
