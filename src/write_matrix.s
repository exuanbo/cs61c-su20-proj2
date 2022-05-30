.globl write_matrix

.data
dimensions_buffer: .word 0 0

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof,
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    # Save the arguments
    mv s0, a0       # the address of the filename
    mv s1, a1       # the address of the matrix
    mv s2, a2       # the number of rows in the matrix
    mv s3, a3       # the number of columns in the matrix

    # Open the file
    mv a1, s0       # a1: the address of the filename
    li a2, 1        # a2: 1 for write only permission
    jal fopen
    bge zero, a0, fopen_error
    mv s0, a0       # the file descriptor

    # Write dimensions
    la t0, dimensions_buffer
    sw s2, 0(t0)    # store the number of rows into the buffer
    sw s3, 4(t0)    # store the number of columns into the buffer
    # s2 and s3 now can be reused
    mv a1, s0       # a1: the file descriptor
    mv a2, t0       # a2: the address of the buffer
    li a3, 2        # a3: the number of elements to write
    li a4, 4        # a4: the size of each element
    jal fwrite
    li t0, 2
    blt a0, t0, fwrite_error

    # Write matrix
    mul s3, s2, s3  # the number of elements in the matrix
    mv a1, s0       # a1: the file descriptor
    mv a2, s1       # a2: the address of the matrix
    mv a3, s3       # a3: the number of elements to write
    li a4, 4        # a4: the size of each element
    jal fwrite
    blt a0, s3, fwrite_error

    # Close the file
    mv a1, s0       # a1: the file descriptor
    jal fclose
    bnez a0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20

    # Return
    ret

fopen_error:
    li a1, 53
    jal exit2

fwrite_error:
    li a1, 54
    jal exit2

fclose_error:
    li a1, 55
    jal exit2
