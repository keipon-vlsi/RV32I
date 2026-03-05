# --- Initial Setup ---
addi x1, x0, 10      # x1 = 10 (0x0000000a)  : Source A
addi x2, x0, 3       # x2 = 3  (0x00000003)  : Source B
addi x30, x0, -5     # x30 = -5 (0xfffffffb) : For negative number testing

# --- Start R-Type Test ---
add  x3, x1, x2      # x3  = 10 + 3 = 13
sub  x4, x1, x2      # x4  = 10 - 3 = 7
and  x5, x1, x2      # x5  = 10 & 3 = 2  (1010 & 0011 = 0010)
or   x6, x1, x2      # x6  = 10 | 3 = 11 (1010 | 0011 = 1011)
xor  x7, x1, x2      # x7  = 10 ^ 3 = 9  (1010 ^ 0011 = 1001)
sll  x8, x1, x2      # x8  = 10 << 3 = 80
srl  x9, x1, x2      # x9  = 10 >> 3 = 1
sra  x10, x30, x2    # x10 = -5 >>> 3 = -1 (Arithmetic Shift Right)
slt  x11, x2, x1     # x11 = (3 < 10) ? 1 : 0 -> 1
sltu x12, x30, x1    # x12 = (-5 < 10) unsigned? -> 0 (Negative is treated as large positive)

# --- End Simulation (Infinite Loop) ---
end:
beq  x0, x0, end