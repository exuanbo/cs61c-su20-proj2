.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense,
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense,
#   this function exits with exit code 3.
#   If the dimensions don't match,
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:
    # Error checks
    # check dimensions of m0
    mul t0, a1, a2
    bgt t0, zero, check_dimensions_m1
    li a1, 2    # error code
    jal exit2
check_dimensions_m1:
    mul t0, a4, a5
    bgt t0, zero, check_dimensions_match
    li a1, 3    # error code
    jal exit2
check_dimensions_match:
    beq a2, a4, check_pass
    li a1, 4    # error code
    jal exit2
check_pass:
    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    mv s0, a0   # the address of m0
    mv s1, a1   # the number of rows of m0
    mv s2, a2   # the number of colomns of m0
    mv s3, a3   # the address of m1
    mv s4, a4   # the number of rows of m1
    mv s5, a5   # the number of columns of m1
    mv s6, a6   # the address of result matrix
outer_loop_start:
    li t1, 0    # row counter of m0
outer_loop_body:
    mul t2, t1, s2  # the start index of the current row
    slli t2, t2, 2
    add t2, t2, s0  # the address of the current row
inner_loop_start:
    li t5, 0    # column counter of m1
inner_loop_body:
    slli t0, t5, 2
    add t0, t0, s3  # the address of the current column
    mv a0, t2   # dot a0
    mv a1, t0   # dot a1
    mv a2, s2   # the length of the vectors
    li a3, 1    # the stride of m0
    mv a4, s5   # the stride of m1
    addi sp, sp, -12
    sw t1, 0(sp)
    sw t2, 4(sp)
    sw t5, 8(sp)
    jal dot
    lw t1, 0(sp)
    lw t2, 4(sp)
    lw t5, 8(sp)
    addi sp, sp, 12
    mul t0, t1, s5  # the start index of the current row of the result matrix
    add t0, t0, t5  # the index of the current element of the result matrix
    slli t0, t0, 2
    add t0, t0, s6  # the address of the current element of the result matrix
    sw a0, 0(t0)
    # inner loop continue
    addi t5, t5, 1
    bne t5, s5, inner_loop_body
inner_loop_end:
    # outer loop continue
    addi t1, t1, 1
    bne t1, s1, outer_loop_body
outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    ret
