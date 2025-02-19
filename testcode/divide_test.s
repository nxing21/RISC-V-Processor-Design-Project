.section .data
dividend:    .word 100, 200, 300, 400, 500  # Array of dividends
divisor:     .word 2, 4, 5, 8, 10           # Array of divisors
result:      .space 20                      # Space for division results
remainder:   .space 20                      # Space for remainder results
length:      .word 20                        # Length of arrays

.section .text
.global _start

_start:
    # Load base addresses of arrays and their lengths
    la x10, dividend        # Load address of dividend array into x10
    la x11, divisor         # Load address of divisor array into x11
    la x12, result          # Load address for storing division results into x12
    la x13, remainder       # Load address for storing remainder results into x13
    lw x14, length          # Load length of arrays into x14 (number of iterations)
    li x15, 0               # Initialize loop counter

loop:
    bge x15, x14, end       # Exit loop if x15 (counter) >= x14 (length)

    # Load current dividend and divisor
    lw x16, 0(x10)          # Load current dividend into x16
    lw x17, 0(x11)          # Load current divisor into x17

    # Perform division and store results
    div x18, x16, x17       # x18 = x16 / x17 (quotient)
    rem x19, x16, x17       # x19 = x16 % x17 (remainder)
    sw x18, 0(x12)          # Store quotient into result array
    sw x19, 0(x13)          # Store remainder into remainder array

    # Increment pointers and counter
    addi x10, x10, 4        # Move to next element in dividend array
    addi x11, x11, 4        # Move to next element in divisor array
    addi x12, x12, 4        # Move to next storage position in result array
    addi x13, x13, 4        # Move to next storage position in remainder array
    addi x15, x15, 1        # Increment loop counter

    j loop                  # Jump back to start of loop

end:
    # Final instruction as requested
    slti x0, x0, -256       # Set x0 if x0 is less than -256
