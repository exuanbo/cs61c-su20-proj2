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
    # check length
    li t0, 1
    bge a2, t0, check_stride
    li a1, 5    # error code
    jal exit2
check_stride:
    blt a3, t0, invalid_stride
    blt a4, t0, invalid_stride
    j checks_pass
invalid_stride:
    li a1, 6    # error code
    jal exit2
checks_pass:
    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
loop_start:
    mv s0, a0   # address of v0
    mv s1, a1   # address of v1
    mv s2, a2   # length of the vectors
    mv s3, a3   # the stride of v0
    mv s4, a4   # the stride of v1
    li s5, 0    # dot product
    li t2, 0    # counter
loop_body:
    slli t0, t2, 2
    mul t0, t0, s3  # bias
    add t0, t0, s0  # address of the element in v0
    lw t0, 0(t0)    # element in v0
    slli t1, t2, 2
    mul t1, t1, s4  # bias
    add t1, t1, s1  # address of the element in v1
    lw t1, 0(t1)    # element in v1
    mul t3, t0, t1  # product
    add s5, s5, t3
    # loop continue
    addi t2, t2, 1
    bne t2, s2, loop_body
loop_end:
    mv a0, s5
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    addi sp, sp, 24
    ret
