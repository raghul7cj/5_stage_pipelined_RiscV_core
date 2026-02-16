    .section .text
    .globl _start
_start:
    // ----------------------------
    // Register setup (zero/pos/neg)
    // ----------------------------
    addi x1,  x0,  5        // x1 = +5
    addi x2,  x0, -5        // x2 = -5
    addi x3,  x0,  0        // x3 = 0

    // ----------------------------
    // U-type (LUI/AUIPC)
    // ----------------------------
    lui   x4,  0x12345      // LUI
    auipc x5,  0x1          // AUIPC

    // ----------------------------
    // R-type ALU ops (covers ctrl bins)
    // ----------------------------
    add  x6,  x1, x3         // ADD (pos + zero)
    sub  x7,  x1, x2         // SUB (pos - neg)
    and  x8,  x1, x2         // AND
    or   x9,  x1, x2         // OR
    xor  x10, x1, x2         // XOR
    sll  x11, x1, x1         // SLL
    srl  x12, x2, x1         // SRL (logical)
    sra  x13, x2, x1         // SRA (arith)
    slt  x14, x2, x1         // SLT (signed)
    sltu x15, x2, x1         // SLTU (unsigned)

    // ----------------------------
    // I-type ALU ops (more ctrl coverage)
    // ----------------------------
    addi  x16, x1,  1        // ADD
    andi  x17, x1,  0xF      // AND
    ori   x18, x1,  0x1      // OR
    xori  x19, x1,  0xA      // XOR
    slti  x20, x2,  0        // SLT
    sltiu x21, x2,  1        // SLTU
    slli  x22, x1,  2        // SLL
    srli  x23, x1,  1        // SRL
    srai  x24, x2,  1        // SRA

    // ----------------------------
    // Loads/Stores (SB/SH/SW + LB/LH/LW + LBU/LHU)
    // Base address = 0x1C; use offsets 0..3 to hit all align bins.
    // ----------------------------
    addi x25, x0, 28         // x25 = 0x1C

    sb   x1,  0(x25)
    sb   x1,  1(x25)
    sb   x1,  2(x25)
    sb   x1,  3(x25)

    sh   x2,  0(x25)
    sh   x2,  2(x25)

    sw   x4,  0(x25)

    lb   x26, 0(x25)
    lbu  x27, 1(x25)
    lb   x28, 2(x25)
    lbu  x29, 3(x25)

    lh   x30, 0(x25)
    lhu  x31, 2(x25)

    lw   x6,  0(x25)

    // ----------------------------
    // Branches: each type taken + not taken
    // ----------------------------
    // BEQ taken
    beq  x1, x1, beq_taken
    addi x3, x3, -100
beq_taken:
    addi x3, x3, 1

    // BEQ not taken
    beq  x1, x2, beq_not_taken
    addi x3, x3, 1
beq_not_taken:

    // BNE taken
    bne  x1, x2, bne_taken
    addi x3, x3, -100
bne_taken:
    addi x3, x3, 1

    // BNE not taken
    bne  x1, x1, bne_not_taken
    addi x3, x3, 1
bne_not_taken:

    // BLT taken (signed): -5 < +5
    blt  x2, x1, blt_taken
    addi x3, x3, -100
blt_taken:
    addi x3, x3, 1

    // BLT not taken
    blt  x1, x2, blt_not_taken
    addi x3, x3, 1
blt_not_taken:

    // BGE taken
    bge  x1, x2, bge_taken
    addi x3, x3, -100
bge_taken:
    addi x3, x3, 1

    // BGE not taken
    bge  x2, x1, bge_not_taken
    addi x3, x3, 1
bge_not_taken:

    // BLTU taken (unsigned): +5 < 0xFFFF_FFFB
    bltu x1, x2, bltu_taken
    addi x3, x3, -100
bltu_taken:
    addi x3, x3, 1

    // BLTU not taken
    bltu x2, x1, bltu_not_taken
    addi x3, x3, 1
bltu_not_taken:

    // BGEU taken (unsigned): 0xFFFF_FFFB >= +5
    bgeu x2, x1, bgeu_taken
    addi x3, x3, -100
bgeu_taken:
    addi x3, x3, 1

    // BGEU not taken
    bgeu x1, x2, bgeu_not_taken
    addi x3, x3, 1
bgeu_not_taken:

    // ----------------------------
    // JAL (unconditional jump)
    // ----------------------------
    jal  x7, after_jal
    addi x3, x3, -100
after_jal:
    addi x3, x3, 1

    // ----------------------------
    // JALR (uses AUIPC+ADDI to form a local target address)
    // ----------------------------
    auipc x8, 0              // x8 = current PC
    addi  x8, x8, 16         // x8 = PC + 16 (points at jalr_target)
    jalr  x0, 0(x8)          // jump to jalr_target
    addi  x3, x3, -100
jalr_target:
    addi  x3, x3, 1

end:
    jal x0, end

// Suggested flow to generate a memfile for `instruction_memory.v`:
// - Assemble/link at address 0, then objcopy to a hex format xsim can read with $readmemh.
// - Example (GNU toolchain):
//     riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0 -o cov.elf coverage_program_rv32i.S
//     riscv32-unknown-elf-objcopy -O verilog cov.elf memfile.hex
// - Then run xsim with: +memfile=memfile.hex
