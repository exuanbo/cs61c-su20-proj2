#define MAX 2147483647
#define MIN -2147483647

.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the vector
#   a1 (int)  is the # of elements in the vector
# Returns:
#   a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1,
# this function exits with error code 7.
# =================================================================
argmax:

    # Error checks
    bge zero, a1, invalid_length

    # Prologue
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    # Save the arguments
    mv s0, a0       # the address of the vector
    mv s1, a1       # the length of the vector

    # Return value
    li s2, MAX      # the index of the largest element

#loop_start
    li t1, 0        # element counter
    li t2, MIN      # the largest element
loop_body:
    slli t0, t1, 2
    add t0, t0, s0  # the address of the current element
    lw t0, 0(t0)    # the value of the current element
    blt t0, t2, loop_continue
    beq t0, t2, handle_equal
    mv s2, t1       # save the new index
    mv t2, t0       # save the new largest element
    j loop_continue
handle_equal:
    bge t1, s2, loop_continue
    mv s2, t1       # save the smaller index
loop_continue:
    addi t1, t1, 1
    bne t1, s1, loop_body
#loop_end

    # Load the return value
    mv a0, s2

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12

    # Return
    ret

invalid_length:
    li a1, 7
    jal exit2
