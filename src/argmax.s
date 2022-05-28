#define MAX 2147483647
#define MIN -2147483647

.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1,
# this function exits with error code 7.
# =================================================================
argmax:
    # Prologue
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    # check vector length
    li t0, 1
    bge a1, t0, loop_start
    li a1, 7    # error code
    jal exit2
loop_start:
    mv s0, a0   # address of the vector
    mv s1, a1   # length of the vector
    li s2, MAX  # index of the largest element
    li t1, -1   # counter
    li t2, MIN  # the largest element
loop_body:
    slli t0, t1, 2  # bias
    add t0, t0, s0  # address of the element
    lw t3, 0(t0)    # element
    blt t3, t2, loop_continue
    beq t3, t2, handle_equal
    mv s2, t1
    mv t2, t3
    j loop_continue
handle_equal:
    bge t1, s2, loop_continue
    mv s2, t1
loop_continue:
    addi t1, t1, 1
    bne t1, s1, loop_body
loop_end:
    mv a0, s2
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret
