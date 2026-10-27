@ This ARM Assembler code should implement a matching function, for use in the MasterMind program, as
@ described in the CW2 specification. It should produce as output 2 numbers, the first for the
@ exact matches (peg of right colour and in right position) and approximate matches (peg of right
@ color but not in right position). Make sure to count each peg just once!
	
@ Example (first sequence is secret, second sequence is guess):
@ 1 2 1
@ 3 1 3 ==> 0 1
@ You can return the result as a pointer to two numbers, or two values
@ encoded within one number
@
@ -----------------------------------------------------------------------------

.text
@ this is the matching fct that should be called from the C part of the CW	
.global         matches
@ use the name `main` here, for standalone testing of the assembler code
@ when integrating this code into `master-mind.c`, choose a different name
@ otw there will be a clash with the main function in the C code
.global         main1
main1: 
	LDR  R2, =secret	@ pointer to secret sequence
	LDR  R3, =guess		@ pointer to guess sequence

	@ you probably need to initialise more values here

	@ ... COMPLETE THE CODE BY ADDING YOUR CODE HERE, you should use sub-routines to structure your code

exit:	@MOV	 R0, R4		@ load result to output register
	MOV 	 R7, #1		@ load system call code
	SWI 	 0		@ return this value

@ -----------------------------------------------------------------------------
@ sub-routines

.extern seqlen

.section .text

matches:
  push {r4-r12, lr}         @ Save registers

    mov r4, #0                @ r4 = exact matches
    mov r5, #0                @ r5 = approx matches
    mov r6, #0                @ r6 = loop index

    @ Copy seq1 to cpy1 and seq2 to cpy2
copy_loop:
    ldr r7, =seqlen
    ldr r7, [r7]
    cmp r6, r7
    bge copy_done

    ldr r8, [r0, r6, LSL #2]  @ seq1[i]
    str r8, [r2, r6, LSL #2]  @ cpy1[i]
    ldr r8, [r1, r6, LSL #2]  @ seq2[i]
    str r8, [r3, r6, LSL #2]  @ cpy2[i]

    add r6, r6, #1
    b copy_loop

copy_done:
    mov r6, #0                @ Reset index

    @ First pass: count exact matches
exact_loop:
    ldr r7, =seqlen
    ldr r7, [r7]
    cmp r6, r7
    bge exact_done

    ldr r8, [r2, r6, LSL #2]  @ cpy1[i]
    ldr r9, [r3, r6, LSL #2]  @ cpy2[i]
    cmp r8, r9
    bne exact_next

    add r4, r4, #1            @ exact++
    mov r10, #0
    str r10, [r2, r6, LSL #2] @ mark cpy1[i] = 0
    str r10, [r3, r6, LSL #2] @ mark cpy2[i] = 0

exact_next:
    add r6, r6, #1
    b exact_loop

exact_done:
    mov r6, #0                @ Outer loop index over cpy1 (secret)
approx_outer_loop:
    ldr r7, =seqlen
    ldr r7, [r7]
    cmp r6, r7
    bge approx_done

    ldr r8, [r2, r6, LSL #2]  @ cpy1[i]
    cmp r8, #0
    beq approx_outer_next

    mov r9, #0                @ Inner loop index over cpy2 (guess)
approx_inner_loop:
    ldr r10, =seqlen
    ldr r10, [r10]
    cmp r9, r10
    bge approx_outer_next

    ldr r11, [r3, r9, LSL #2] @ cpy2[j]
    cmp r11, #0
    beq approx_inner_next

    cmp r8, r11
    bne approx_inner_next

    @ Match found
    add r5, r5, #1
    mov r12, #0
    str r12, [r2, r6, LSL #2] @ mark cpy1[i]
    str r12, [r3, r9, LSL #2] @ mark cpy2[j]
    b approx_outer_next       @ break inner loop

approx_inner_next:
    add r9, r9, #1
    b approx_inner_loop

approx_outer_next:
    add r6, r6, #1
    b approx_outer_loop

approx_done:
    @ Return (exact * 10 + approx) in r0
    mov r1, #10
    mul r0, r4, r1
    add r0, r0, r5

    pop {r4-r12, pc}          @ Restore and return

.section .note.GNU-stack,"",%progbits	
@ =============================================================================

.data

@ constants about the basic setup of the game: length of sequence and number of colors	
.equ LEN, 3
.equ COL, 3
.equ NAN1, 8
.equ NAN2, 9

@ a format string for printf that can be used in showseq
f4str: .asciz "Seq:    %d %d %d\n"

@ a memory location, initialised as 0, you may need this in the matching fct
n: .word 0x00
	
@ INPUT DATA for the matching function
.align 4
secret: .word 1 
	.word 2 
	.word 1 

.align 4
guess:	.word 3 
	.word 1 
	.word 3 

@ Not strictly necessary, but can be used to test the result	
@ Expect Answer: 0 1
.align 4
expect: .byte 0
	.byte 1

.align 4
secret1: .word 1 
	 .word 2 
	 .word 3 

.align 4
guess1:	.word 1 
	.word 1 
	.word 2 

@ Not strictly necessary, but can be used to test the result	
@ Expect Answer: 1 1
.align 4
expect1: .byte 1
	 .byte 1

.align 4
secret2: .word 2 
	 .word 3
	 .word 2 

.align 4
guess2:	.word 3 
	.word 3 
	.word 1 

@ Not strictly necessary, but can be used to test the result	
@ Expect Answer: 1 0
.align 4
expect2: .byte 1
	 .byte 0


