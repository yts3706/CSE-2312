	.global main
	.func main
	
main: 
	
	BL _scanf		@ branch to _scanf procedure with return
	MOV R4, R0		@ storing the value of n in R7 	
	BL _scanf		@ branch to _scanf procedure with return
	MOV R5, R0		@ storing the value of m in R8
	MOV R1, R4		@ storing the value of n to R1
	MOV R2, R5		@ storing the value of m in R2
	MOV R7, #0
	MOV R0, #0
	BL count_partitions	@ Branch to the _countpart procedure with return
	ADD R0, R0, R7
	MOV R1, R0
	MOV R2, R4		@ move n to R1
	MOV R3, R5		@ move m to R2
	BL _printf		@ branch to _printf procedure with return
	B main			@ branch to main procedure with no return	
	
	
count_partitions:
	PUSH {LR}		@ store the value of the return address
	CMP R1, #0		@ compare the value of n with 0
	MOVEQ R0, #1		
	POPEQ {PC}

	MOVLT R0, #0		
	POPLT {PC}
	
	CMP R2, #0		@ compare the value of m with 0
	MOVEQ R0, #0
	POPEQ {PC}
	
	@ ELSE
	PUSH {R1}
	PUSH {R2}	
	SUB R1, R1, R2

	BL count_partitions
	
	ADD R7, R7, R0
	POP {R2}
	POP {R1}	
	SUB R2, R2, #1	
	BL count_partitions
	
	@ MOV R0, R7
	POP {PC}
_scanf:
	PUSH {LR} 		@ store the return address
	PUSH {R1} 		@ back the value of register R1
	LDR R0, =format_str	@ R0 contains address of format string
	SUB SP, SP, #4		@ make room on stack
	MOV R1, SP		@ move SP to R1 to store entry on stack
	BL scanf		@ call scanf
	LDR R0, [SP]		@ load value at SP into R0
	ADD SP, SP, #4		@ remove value from stack
	POP {R1}		@ restore register value
	POP {PC}		@ restore the stack pointer and return
	
_printf:
	PUSH {LR}		@ store the return address
	LDR R0, =printf_str	@ R0 contains the address of the formatted string
	BL printf		@ call printf
	POP {PC} 		@ restore the stack pointer and return 
	
	
	
	
.data

format_str:		.asciz		"%d"	

printf_str: 		.asciz		"There are %d partitions of %d using integers upto %d.\n"
	