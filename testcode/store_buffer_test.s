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
    addi x2, x1, 0x200             # Load data[0] into x2 8
    
    sw x2, 16(x1)            # Store it to data[4] 1eceb00c

    lw x3, 16(x1)             # Load data[1] into x3 1eceb010
    
    sw x3, 20(x1)            # Store it to data[5] 1eceb014

    # End the simulation
    slti x0, x0, -256        # Magic instruction to end the simulation