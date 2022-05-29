.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero,
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    #
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # check the number of command line args
    li t0, 5
    bne a0, t0, wrong_arg_count

    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)

    mv s0, a1       # char **argv
    mv s1, a2       # print the classification if is zero

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    li a0, 8        # malloc a0
    jal malloc
    mv s2, a0       # the start address of the dimensions of m0
    lw a0, 4(s0)    # read_matrix a0
    mv a1, s2       # read_matrix a1
    addi a2, s2, 4  # read_matrix a2
    jal read_matrix
    mv s3, a0       # the address of m0

    # Load pretrained m1
    li a0, 8        # malloc a0
    jal malloc
    mv s4, a0       # the start address of the dimensions of m1
    lw a0, 8(s0)    # read_matrix a0
    mv a1, s4       # read_matrix a1
    addi a2, s4, 4  # read_matrix a2
    jal read_matrix
    mv s5, a0       # the address of m1

    # Load input matrix
    li a0, 9        # malloc a0
    jal malloc
    mv s6, a0       # the start address of the dimensions of input
    lw a0, 12(s0)   # read_matrix a0
    mv a1, s6       # read_matrix a1
    addi a2, s6, 4  # read_matrix a2
    jal read_matrix
    mv s7, a0       # the address of input

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # allocate memory for hidden layer
    lw t0, 0(s2)    # the number of rows in hidden layer == m0
    lw t1, 4(s6)    # the number of columns in hidden layer == input
    mul a0, t0, t1  # the number of elements in hidden layer
    slli a0, a0, 2  # malloc a0
    jal malloc
    mv s8, a0       # the address of hidden layer

    # hidden_layer = matmul(m0, input)
    mv a0, s3       # matmul a0
    lw a1, 0(s2)    # matmul a1
    lw a2, 4(s2)    # matmul a2
    mv a3, s7       # matmul a3
    lw a4, 0(s6)    # matmul a4
    lw a5, 4(s6)    # matmul a5
    mv a6, s8       # matmul a6
    jal matmul

    # relu(hidden_layer)
    lw t0, 0(s2)    # the number of rows in hidden layer == m0
    lw t1, 4(s6)    # the number of columns in hidden layer == input
    mul a1, t0, t1  # relu a1
    mv a0, s8       # relu a0
    jal relu

    # allocate memory for score
    lw t0, 0(s4)    # the number of rows in score == m1
    lw t1, 4(s6)    # the number of columns in score == hidden layer == input
    mul a0, t0, t1  # the number of elements in score
    slli a0, a0, 2  # malloc a0
    jal malloc
    mv s9, a0       # the address of score

    # scores = matmul(m1, hidden_layer)
    mv a0, s5       # matmul a0
    lw a1, 0(s4)    # matmul a1
    lw a2, 4(s4)    # matmul a2
    mv a3, s8       # matmul a3
    lw a4, 0(s2)    # matmul a4
    lw a5, 4(s6)    # matmul a5
    mv a6, s9       # matmul a6
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

    lw a0, 16(s0)   # write_matrix a0
    mv a1, s9       # write_matrix a1
    lw a2, 0(s4)    # write_matrix a2
    lw a3, 4(s6)    # write_matrix a3
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    lw t0, 0(s4)    # the number of rows in score == m1
    lw t1, 4(s6)    # the number of columns in score == hidden layer == input
    mul a1, t0, t1  # argmax a1
    mv a0, s9       # argmax a0
    jal argmax
    mv s10, a0      # the classification

    # Print classification
    bnez s1, skip_print
    mv a1, s10
    jal print_int

    # Print newline afterwards for clarity
    li a1 '\n'
    jal ra print_char

skip_print:

    # free space
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free

    # return value
    mv a0, s10

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    ret

wrong_arg_count:
    li a1, 49
    jal exit2
