.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # Read matrix into memory

    # load the address of the filename
    la s0, file_path

    # allocate memory for the number of rows
    li a0, 4
    jal malloc
    mv s1, a0

    # allocate memory for the number of columns
    li a0, 4
    jal malloc
    mv s2, a0

    # call read_matrix
    mv a0, s0
    mv a1, s1
    mv a2, s2
    jal read_matrix
    mv s3, a0

    # Print out elements of matrix
    mv a0, s3
    lw a1, 0(s1)
    lw a2, 0(s2)
    jal print_int_array

    # Terminate the program
    jal exit
