.globl read_matrix

.data
dimensions_buffer: .word 0 0

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof,
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    # Save the arguments
    mv s0, a0       # the address of the filename
    mv s1, a1       # the address of the number of rows
    mv s2, a2       # the address of the number of columns

    # Open the file
    mv a1, s0       # a1: the address of the filename
    li a2, 0        # a2: 0 for read only permission
    jal fopen
    bge zero, a0, fopen_error
    mv s0, a0       # the file descriptor

    # Read the dimensions and store them back to memory
    la s3, dimensions_buffer
    mv a1, s0       # a1: the file descriptor
    mv a2, s3       # a2: the address of the buffer
    li a3, 8        # a3: the number of bytes to read
    jal fread
    li t0, 8
    bne a0, t0, fread_error
    lw t1, 0(s3)    # the number of rows
    lw t2, 4(s3)    # the number of columns
    sw t1, 0(s1)    # store the number of rows to memory
    sw t2, 0(s2)    # store the number of columns to memory
    # s1 and s2 now can be reused

    # Calculate the size of the matrix
    mul t0, t1, t2
    slli s1, t0, 2  # the length of the array

    # Allocate memory for the matrix
    mv a0, s1       # a0: the length of the array
    jal malloc
    beqz a0, malloc_error
    mv s2, a0       # the address of the matrix

    # Read the rest of the file into the matrix
    mv a1, s0       # a1: the file descriptor
    mv a2, s2       # a2: the address of the matrix
    mv a3, s1       # a3: the length of the array
    jal fread
    bne a0, s1, fread_error

    # Close the file
    mv a1, s0       # a1: the file descriptor
    jal fclose
    bnez a0, fclose_error

    # Load the return value
    mv a0, s2

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20

    # Return
    ret

malloc_error:
    li a1, 48
    jal exit2

fopen_error:
    li a1, 50
    jal exit2

fread_error:
    li a1, 51
    jal exit2

fclose_error:
    li a1, 52
    jal exit2
