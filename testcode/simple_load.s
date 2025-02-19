.section .data
data:
    
    .word 0x01928500 # 31:0
    .word 0x01928501 # 63:32
    .word 0x01928502 # 95:64
    .word 0x01928503 # 127:96
    .word 0x01928504 # 159:128
    .word 0x01928505 # 191:160
    .word 0x01928506 # 223:192
    .word 0x01928507 # 255:224
    .word 0x01928508
    .word 0x01928509
    .word 0x0192850a
    .word 0x0192850b ## should replace 92 with the byte
    .word 0x0192850c
    .word 0x0192850d
    .word 0x0192850e
    .word 0x0192850f
    .word 0x01928510
    .word 0x01928511
    .word 0x01928512
    .word 0x01928513
    .byte 0xff                # Extra byte for lbu
    .half 0x1234             # Extra half-word for lhu

.section .text
.globl _start
_start:
    auipc x1, 0              # Load PC-relative address into x1 0
    
    addi x1, x1, 0x600       # Adjust address to point to data section 4
    
    addi x1, x1, 0x600       # Adjust address to point to data section 4

    addi x1, x1, 0x400       # Adjust address to point to data section 4

    # Load and Store operations
    lw x2, 0(x1)             # Load data[0] into x2 8
    
    sw x2, 16(x1)            # Store it to data[4] 1eceb00c

    lw x3, 4(x1)             # Load data[1] into x3 1eceb010
    
    sw x3, 20(x1)            # Store it to data[5] 1eceb014
    
    
    
    
    

    lw x4, 8(x1)             # Load data[2] into x4 1eceb018
    
    
    
    
    
    sw x4, 24(x1)            # Store it to data[6] 1eceb01c
    
    
    
    
    

    lw x6, 12(x1)            # Load data[3] into x6 1eceb020
    
    
    
    
    
    sw x6, 28(x1)            # Store it to data[7] 1eceb024
    
    
    
    
    

    # Load byte and store byte
    lbu x7, 64(x1)           # Load byte into x7 1eceb028 
    
    
    
    
    
    sb x7, 44(x1)            # Store byte into data[11] 1eceb02c
    
    
    
    
    

    lbu x8, 65(x1)           # Load another byte into x8 1eceb030
    
    
    
    
    
    sb x8, 45(x1)            # Store byte into data[12]
    
    
    
    
    

    lbu x9, 66(x1)           # Load another byte into x9
    
    
    
    
    
    sb x9, 46(x1)            # Store byte into data[13]
    
    
    
    
    

    # Load half and store half
    lhu x10, 68(x1)          # Load half into x10
    
    
    
    
    
    sh x10, 48(x1)           # Store half into data[14]
    
    
    
    
    

    lhu x12, 70(x1)          # Load another half into x12
    
    
    
    
    
    sh x12, 50(x1)           # Store half into data[15]
    
    
    
    
    

    lhu x13, 72(x1)          # Load another half into x13
    
    
    
    
    
    sh x13, 52(x1)           # Store half into data[16]
    
    
    
    
    

    # ALU operations
    add x14, x2, x3          # x14 = x2 + x3
    
    
    
    
    
    sw x14, 56(x1)           # Store result into data[17]
    
    
    
    
    

    add x15, x4, x6          # x15 = x4 + x6
    
    
    
    
    
    sw x15, 60(x1)           # Store result into data[18]
    
    
    
    
    

    # More ALU operations
    sll x16, x2, 1           # x16 = x2 << 1
    
    
    
    
    
    sw x16, 68(x1)           # Store result into data[20]
    
    
    
    
    

    sll x17, x3, 2           # x17 = x3 << 2
    
    
    
    
    
    sw x17, 72(x1)           # Store result into data[21]
    
    
    
    
    

    sll x18, x4, 3           # x18 = x4 << 3
    
    
    
    
    
    sw x18, 76(x1)           # Store result into data[22]
    
    
    
    
    

    slt x19, x3, x2          # x19 = (x3 < x2) ? 1 : 0
    
    
    
    
    
    sw x19, 80(x1)           # Store result into data[23]
    
    
    
    
    

    slt x20, x2, x3          # x20 = (x2 < x3) ? 1 : 0
    
    
    
    
    
    sw x20, 84(x1)           # Store result into data[24]
    
    
    
    
    

    slt x21, x4, x6          # x21 = (x4 < x6) ? 1 : 0
    
    
    
    
    
    sw x21, 88(x1)           # Store result into data[25]
    
    
    
    
    

    sltu x22, x2, x3         # x22 = (unsigned)x2 < (unsigned)x3
    
    
    
    
    
    sw x22, 92(x1)           # Store result into data[26]
    
    
    
    
    

    sltu x23, x4, x6         # x23 = (unsigned)x4 < (unsigned)x6
    
    
    
    
    
    sw x23, 96(x1)           # Store result into data[27]
    
    
    
    
    

    xor x24, x2, x3          # x24 = x2 ^ x3
    
    
    
    
    
    sw x24, 100(x1)          # Store result into data[28]
    
    
    
    
    

    xor x25, x4, x6          # x25 = x4 ^ x6
    
    
    
    
    
    sw x25, 104(x1)          # Store result into data[29]
    
    
    
    
    

    # Bitwise operations
    or x26, x2, x3           # x26 = x2 | x3
    
    
    
    
    
    sw x26, 108(x1)          # Store result into data[30]
    
    
    
    
    

    and x27, x4, x6          # x27 = x4 & x6
    
    
    
    
    
    sw x27, 112(x1)          # Store result into data[31]
    
    
    
    
    

    # Shift right logical
    srl x28, x4, 1           # x28 = x4 >> 1
    
    
    
    
    
    sw x28, 116(x1)          # Store result into data[32]
    
    
    
    
    

    srl x29, x3, 2           # x29 = x3 >> 2
    
    
    
    
    
    sw x29, 120(x1)          # Store result into data[33]
    
    
    
    
    

    # End the simulation
    slti x0, x0, -256        # Magic instruction to end the simulation