ooo_test.s:
.align 4
.section .text
.globl _start
    # This program will provide a simple test for
    # demonstrating OOO-ness

    # This test is NOT exhaustive
_start:

# initialize
li x1, 10
li x2, 20
li x5, 50
# li x6, 60
# li x8, 21
# li x9, 28
# li x11, 8
# li x12, 4
# li x14, 3
# li x15, 1

# nop
# nop
# nop
# nop
# nop
# nop

# # this should take many cycles
# # if this writes back to the ROB after the following instructions, you get credit for CP2
# mul x3, x1, x2

# # these instructions should  resolve before the multiply
# add x4, x5, x6
# xor x7, x8, x9
# sll x10, x11, x12
# and x13, x14, x15

# lui x16, 0x01000
# addi x17, x1, 5
# slti x18, x2, 6
# sltiu x19, x3, 9
# xori x20, x5, 18
# ori x19, x6, 15

# sub x22, x19, x2
# andi x18, x4, 12
# slli x17, x16, 19
# srli x15, x2, 4
# srai x19, x8, 12
# add x21, x3, x4

# sltu x29, x1, x2
# xor x5, x6, x9
# sll x25, x6, x7
# slt x23, x7, x8

# srl x9, x3, x3
# sra x2, x9, x5
# or x2, x2, x9
# and x1, x8, x19
# mul x3, x2, x2
# mulh x1, x8, x2
# mulhsu x5, x5, x4
# mulhu x7, x1, x2
# div x8, x6, x2
# divu x1, x1, x18
# rem x4, x6, x2
# remu x8, x9, x1




halt:
    slti x0, x0, -256
