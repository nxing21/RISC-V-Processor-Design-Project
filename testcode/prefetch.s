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
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8

    bne x1, x2, label1

label8:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label9

label7:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label8

label6:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label7


label5:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label6

label4:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label5

label3:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label4

label2:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label3

label1:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    bne x1, x2, label2

label9:
    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

    li x1, 10
    li x2, 20
    li x5, 50
    li x6, 60
    li x8, 21
    li x9, 28
    li x11, 8
    li x12, 4

halt:
    slti x0, x0, -256
