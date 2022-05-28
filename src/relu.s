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
    # Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    # check vector length
    li t0, 1
    bge a1, t0, loop_start
    li a1, 8    # error code
    jal exit2
loop_start:
    mv s0, a0   # address of the vector
    mv s1, a1   # length of the vector
    li t1, 0    # counter
loop_continue:
    beq t1, s1, loop_end
    slli, t0, t1, 2 # bias
    add t0, t0, s0  # address of the element
    lw t2, 0(t0)    # element
    addi t1, t1, 1
    bge t2, zero, loop_continue
    sw zero, 0(t0)
    j loop_continue
loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
	ret
