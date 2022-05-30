.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1,
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:

    # Error checks
    bge zero, a2, invalid_length
    bge zero, a3, invalid_stride
    bge zero, a4, invalid_stride

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)

    # Save the arguments
    mv s0, a0       # the address of v0
    mv s1, a1       # the address of v1
    slli s2, a2, 2  # the memory size of the vectors
    mv s3, a3       # the stride of v0
    mv s4, a4       # the stride of v1

    # Return value
    li s5, 0        # the result dot product

#loop_start
    li t2, 0        # the address offset
loop_body:

    # Load v0[i]
    mul t0, t2, s3  # address offset * stride of v0
    add t0, t0, s0  # the address of the current element of v0
    lw t0, 0(t0)    # the value of the current element of v0

    # Load v1[i]
    mul t1, t2, s4  # address offset * stride of v1
    add t1, t1, s1  # the address of the current element of v1
    lw t1, 0(t1)    # the value of the current element of v1

    # Multiply v0[i] and v1[i]
    mul t3, t0, t1  # the product of the two values
    add s5, s5, t3  # add to the result dot product

#loop_continue
    addi t2, t2, 4
    bne t2, s2, loop_body
#loop_end

    # Load the return value
    mv a0, s5

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    addi sp, sp, 24

    # Return
    ret

invalid_length:
    li a1, 5
    jal exit2

invalid_stride:
    li a1, 6
    jal exit2
