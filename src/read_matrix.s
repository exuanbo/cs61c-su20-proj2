.globl read_matrix

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

    mv s0, a0       # the address of the filename
    mv s1, a1       # the address of the number of rows
    mv s2, a2       # the address of the number of columns

    # open file
    mv a1, s0       # fopen a1
    li a2, 0        # read only permission
    jal fopen
    bge zero, a0, fopen_error
    mv s0, a0       # the file descriptor

    # allocate memory for the buffer
    li a0, 8        # 8 bytes for 2 4-byte numbers
    jal malloc
    beqz a0, malloc_error
    mv s3, a0       # the address of the buffer

    # read the dimensions into the buffer
    mv a1, s0       # fread a1
    mv a2, s3       # fread a2
    li a3, 8        # fread a3
    jal fread
    li t0, 8
    bne a0, t0, fread_error
    lw t1, 0(s3)    # the number of rows
    lw t2, 4(s3)    # the number of columns
    sw t1, 0(s1)    # store the number of rows to memory
    sw t2, 0(s2)    # store the number of columns to memory
    # s1 and s2 now can be reused
    mul t0, t1, t2
    slli s1, t0, 2  # the length of the array

    # free the memory of the buffer
    mv a0, s3       # free a0
    jal free

    # allocate memory for the matrix
    mv a0, s1       # malloc a0
    jal malloc
    beqz a0, malloc_error
    mv s2, a0       # the address of the matrix

    # read the rest of the file into the matrix
    mv a1, s0       # fread a1
    mv a2, s2       # fread a2
    mv a3, s1       # fread a3
    jal fread
    bne a0, s1, fread_error

    # close file
    mv a1, s0       # fclose a1
    jal fclose
    bnez a0, fclose_error

    # return value
    mv a0, s2

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
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
