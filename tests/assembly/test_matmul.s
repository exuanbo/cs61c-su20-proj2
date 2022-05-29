.import ../../src/matmul.s
.import ../../src/utils.s
.import ../../src/dot.s

# static values for testing
.data
m0: .word 1 2 3 4 5 6 7 8 9
m1: .word 1 2 3 4 5 6 7 8 9
d: .word 0 0 0 0 0 0 0 0 0 # allocate static space for output

.text
main:
    # Load addresses of input matrices (which are in static memory), and set their dimensions
    la s0, m0
    la s3, m1
    la s6, d

    # Call matrix multiply, m0 * m1
    mv a0, s0
    li a1, 3
    li a2, 3
    mv a3, s3
    li a4, 3
    li a5, 3
    mv a6, s6
    jal matmul

    # Print the output (use print_int_array in utils.s)
    mv a0, s6
    li a1, 3
    li a2, 3
    jal print_int_array

    # Exit the program
    jal exit
