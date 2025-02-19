.section .text
.globl _start

# Step 1: Initialize registers
_start:
    addi x1, x0, 0          # x1 = result accumulator
    addi x2, x0, 12         # x2 = outer loop counter
    addi x3, x0, 8          # x3 = middle loop counter
    addi x4, x0, 5          # x4 = inner loop counter
    addi x5, x0, 3          # x5 = deepest loop counter
    addi x6, x0, 100        # x6 = threshold for adjustments
    addi x7, x0, -50        # x7 = negative threshold
    addi x8, x0, 1          # x8 = increment flag
    addi x9, x0, 0          # x9 = temporary storage
    addi x10, x0, 10        # x10 = multiplier for shifts
    addi x11, x0, 4         # x11 = shift amount
    addi x12, x0, 200       # x12 = large threshold

# Outer Loop
outer_loop:
    beq x2, x0, finalize_outer   # Exit if x2 == 0
    addi x3, x0, 8               # Reset middle loop counter

# Middle Loop
middle_loop:
    beq x3, x0, next_outer       # Exit if x3 == 0
    addi x4, x0, 5               # Reset inner loop counter

# Inner Loop
inner_loop:
    beq x4, x0, end_inner        # Exit if x4 == 0
    addi x5, x0, 3               # Reset deepest loop counter

# Deepest Loop
deepest_loop:
    beq x5, x0, end_deepest      # Exit if x5 == 0
    addi x1, x1, 7               # Add 7 to x1

    # Condition to check if x1 needs adjustment
    blt x1, x6, adjust_positive
    addi x9, x9, 1               # Increment temporary register
    jal skip_adjust

adjust_positive:
    addi x1, x1, 10              # Add 10 to x1 if below threshold
    sll x1, x1, x11             # Shift left to multiply by 16
    srl x1, x1, x11             # Shift right to divide by 16

skip_adjust:
    addi x5, x5, -1             # Decrement deepest loop counter
    jal deepest_loop

end_deepest:
    addi x4, x4, -1             # Decrement inner loop counter
    jal inner_loop

end_inner:
    addi x3, x3, -1             # Decrement middle loop counter
    jal middle_loop

next_outer:
    addi x2, x2, -1             # Decrement outer loop counter
    jal outer_loop

finalize_outer:

# Countdown Loop with Adjustments
    addi x2, x0, 20             # Initialize countdown loop counter
countdown_loop:
    beq x2, x0, end_countdown   # Exit countdown if zero

    # Adjust x1 based on flag conditions
    blt x1, x7, handle_negative # If x1 < -50, handle negative case
    bge x1, x12, handle_large   # If x1 >= 200, handle large case
    jal continue_countdown

handle_negative:
    addi x1, x1, 30             # Add 30 to x1 if negative
    jal continue_countdown

handle_large:
    sll x1, x1, 2               # Double x1 by shifting left
    srl x1, x1, 1               # Halve x1 by shifting right

continue_countdown:
    addi x1, x1, 9              # Add 9 to x1
    addi x2, x2, -1             # Decrement countdown counter
    jal countdown_loop

end_countdown:

# Flag Checking and Final Adjustments
    addi x8, x8, 5              # Increment flag for condition check
    beq x8, x10, flag_check     # Check if flag matches value

flag_check:
    addi x1, x1, -5             # Adjust x1 based on flag check
    sll x1, x1, 1               # Multiply by 2 using shift
    srl x1, x1, 1               # Divide by 2 using shift

# Store Final Result
    add x9, x1, x0              # Store result in x9 for verification

end_program:
    # End program with return statement
    slti x0, x0, -256           # Halt the program