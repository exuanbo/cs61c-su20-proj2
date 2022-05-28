.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1,
# this function exits with error code 8.
# ==============================================================================
relu:
    # Error checks
    blt zero, a1, checks_pass
    li a1, 8    # error code
    jal exit2
checks_pass:
    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
loop_start:
    mv s0, a0   # address of the vector
    mv s1, a1   # length of the vector
    li t1, 0    # counter
loop_body:
    slli, t0, t1, 2 # bias
    add t0, t0, s0  # address of the element
    lw t2, 0(t0)    # element
    bge t2, zero, loop_continue
    sw zero, 0(t0)
loop_continue:
    addi t1, t1, 1
    bne t1, s1, loop_body
loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
	ret
