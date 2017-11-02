	.global main
	.func main
	
main:
	MOV R0, #0		@ initialize index variable
	BL _generate
	PUSH {R10}
	MOV R0, #0
	BL _readloop
	MOV R0, #0
	BL _sort_ascending
	BL _find
	POP {R10}
	BL _printf_sum
	B _exit
	
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
	LDR R3, =array_b	@ get address of b
	LSL R2, R0, #2		@ multiply index * 4 to get array offset
	LSL R5, R0, #2
	ADD R2, R1, R2		@ R2 = address of 'a[R0]'
	ADD R5, R3, R5		@ R5 = address of 'b[R0]'
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	PUSH {R5}
	BL _scanf
	MOV R4, R0		@ moving return value of _scanf to R0
	ADD R10, R10, R4	@ sum += user input
	POP {R5}
	POP {R3}
	POP {R2}
	POP {R1}
	POP {R0}
	STR R4, [R2]		@ a[R0] = user input
	STR R4, [R5]		@ b[R0] = user input
	ADD R0, R0, #1		@ R0++
	B _generate	
	
_readloop:
	CMP R0, #0
	PUSHEQ {LR}
	CMP R0, #10		@ check to see if we are done iterating
	POPEQ {PC}		@ exit loop if done
	LDR R1, =array_a	@ get address of a
	LDR R3, =array_b	
	LSL R2, R0, #2		@ multiply index * 4 to get array offset
	LSL R5, R0, #2
	ADD R2, R1, R2		@ R2 = address a[R0]
	ADD R5, R3, R5		@ R5 = address b[R0]
	LDR R1, [R2]		@ read the array 'a' at address
	LDR R3, [R5]		@ read the array 'b' at address
	PUSH {R0} 		@ backup register before printf
	PUSH {R1}		@ backup register before printf
	PUSH {R2} 		@ backup register before printf
	PUSH {R3}		@ backup register before printf
	PUSH {R5}		@ backup register before printf
	MOV R2, R1		@ move array value to R2 for printf
	MOV R1, R0		@ move array index to R1 for printf
	BL _printfA		@ branch to _printf procedure with return
	POP {R5}
	POP {R3}
	POP {R2}
	POP {R1}
	POP {R0}
	ADD R0, R0, #1		@ increment index
	B _readloop		@ branch to next loop iteration
	
_exit:
	PUSH {LR}
	MOV R7, #4		@ write syscall, 4
	MOV R0, #1		@ output stream to monitor, 1
	MOV R2, #21		@ print string length
	LDR R1, =exit_str 	@ string at label exit_str:
	SWI 0			@ execute syscall
	MOV R7, #1		@ terminate syscall, 1
	SWI 0			@ execute syscall
	POP {PC}
	
_printfA:
	PUSH {LR}		@ store the return address
	LDR R0, =printf_str	@ R0 contains formatted string address
	BL printf		@ call printf
	POP {PC}		@ restore the stack pointer and return

_printf_sum:
	PUSH {LR}
	MOV R1, R10
	LDR R0, =printf_str_sum
	BL printf
	POP {PC}
	
_sort_ascending:
	PUSH {LR}
loop_i:
	CMP R0, #9		@ R0 = j
	POPEQ {PC} 
	LDR R3, =array_b	@ R3 contains the address of array b	
	LSL R2, R0, #2   	@ initiate the process of reading the array
	ADD R2, R3, R2
	LDR R2, [R2]		@ a[iMin] = R2
	PUSH {R2}
	ADD R1, R0, #1		@ i stored in R1 (j=i+1)
loop_j:
	CMP R1, #10
	BEQ compare
	LSL R7, R1, #2
	ADD R7, R3, R7
	LDR R7, [R7]		@ R7 = a[i]		
	CMP R7, R2		@ a[i] < a[iMin]
	MOVLT R2, R7		@ a[iMin]=a[i]
	MOVLT R10, R1		@ iMIN = i
	ADD R1, R1, #1
	B loop_j
compare:
	POP {R5}
	CMP R2, R5
	BLNE swap
	ADD R0, R0, #1
	B loop_i
swap:
	MOV R8, R2
	MOV R2, R5
	MOV R5, R8
	LSL R11, R0, #2
	ADD R11, R11, R3
	STR R5, [R11]
	LSL R9, R10, #2
	ADD R9, R9, R3
	STR R2, [R9]
	MOV PC,LR
	
_find:
	PUSH {LR}
	LDR R3, =array_b
	ADD R7, R3, #0		@ address of b[0]
	LDR R8, [R7]		@ read the array at address
	PUSH {R7}
	PUSH {R3}
	MOV R1, R8	
	LDR R0, =printf_str_min
	BL printf		@ call printf
	POP {R3}
	POP {R7}
	ADD R7, R7, #36
	LDR R9, [R7]
	MOV R1, R9
	LDR R0, =printf_str_max
	BL printf
	POP {PC}
		
.data

.balign	4
array_a:	.skip		40
array_b:	.skip		40
printf_str: 	.asciz		"array_a[%d] = %d\n"
printf_str_max:	.asciz		"maximum = %d\n"
printf_str_min:	.asciz		"minimum = %d\n"
printf_str_sum:	.asciz		"sum = %d\n"
exit_str:	.ascii		"Terminating Program.\n"
format_str:	.asciz		"%d"
		