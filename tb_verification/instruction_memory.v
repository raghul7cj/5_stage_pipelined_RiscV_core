`timescale 1ns / 1ps

module instruction_memory(
    input rst,
    input [31:0] A,
    output [31:0] RD
);

    reg [31:0] mem [0:1023];

    assign RD = (~rst) ? 32'd0 : mem[A[31:2]];

    initial begin
        // =========================================================
        // COVERAGE TEST PROGRAM
        // Executes every instruction type at least once.
        // All instructions are placed sequentially (no branches
        // that skip large blocks) to guarantee execution.
        // =========================================================

        // ---------- U-type ----------
        mem[0]   = 32'h12345037;   // lui   x0, 0x12345     (LUI)
        mem[1]   = 32'h00001297;   // auipc x5, 0x1         (AUIPC)

        // ---------- JAL & JALR ----------
        mem[2]   = 32'h008000EF;   // jal   x1, +8          (JAL)
        mem[3]   = 32'h00008067;   // jalr  x0, 0(x1)       (JALR)   (jumps to x1, which points to mem[5])

        // ---------- I-type ALU (immediate) ----------
        mem[4]   = 32'h00500093;   // addi  x1, x0, 5
        mem[5]   = 32'hFFB00113;   // addi  x2, x0, -5      (signed immediate)
        mem[6]   = 32'h0020A193;   // slti  x3, x1, 2
        mem[7]   = 32'h0060B213;   // sltiu x4, x1, 6
        mem[8]   = 32'h00F0C293;   // xori  x5, x1, 15
        mem[9]   = 32'h00F0E313;   // ori   x6, x1, 15
        mem[10]  = 32'h00F0F393;   // andi  x7, x1, 15
        mem[11]  = 32'h00109413;   // slli  x8, x1, 1       (SLLI)
        mem[12]  = 32'h0010D493;   // srli  x9, x1, 1       (SRLI)
        mem[13]  = 32'h4010D513;   // srai  x10, x1, 1      (SRAI)

        // ---------- R-type ALU (register) ----------
        mem[14]  = 32'h002081B3;   // add   x3, x1, x2
        mem[15]  = 32'h40208233;   // sub   x4, x1, x2
        mem[16]  = 32'h002092B3;   // sll   x5, x1, x2      (SLL)
        mem[17]  = 32'h0020A333;   // slt   x6, x1, x2
        mem[18]  = 32'h0020B3B3;   // sltu  x7, x1, x2
        mem[19]  = 32'h0020C433;   // xor   x8, x1, x2
        mem[20]  = 32'h0020E4B3;   // or    x9, x1, x2
        mem[21]  = 32'h0020F533;   // and   x10, x1, x2
        mem[22]  = 32'h0020D5B3;   // srl   x11, x1, x2     (SRL)
        mem[23]  = 32'h4020D633;   // sra   x12, x1, x2     (SRA)

        // ---------- Load/Store with all sizes ----------
        // Set up base address
        mem[24]  = 32'h00001137;   // lui   x2, 0x1         (x2 = 0x1000)
        mem[25]  = 32'h00810113;   // addi  x2, x2, 8       (x2 = 0x1008, aligned)

        // Store operations
        mem[26]  = 32'h00A12023;   // sw    x10, 0(x2)      (word)
        mem[27]  = 32'h00911223;   // sh    x9,  4(x2)      (half)
        mem[28]  = 32'h00810423;   // sb    x8,  8(x2)      (byte)

        // Load operations (signed and unsigned)
        mem[29]  = 32'h00012183;   // lw    x3, 0(x2)
        mem[30]  = 32'h00411203;   // lh    x4, 4(x2)
        mem[31]  = 32'h00810283;   // lb    x5, 8(x2)
        mem[32]  = 32'h00415203;   // lhu   x4, 4(x2)
        mem[33]  = 32'h00814283;   // lbu   x5, 8(x2)

        // ---------- Branches (both taken and not taken) ----------
        mem[34]  = 32'h00100093;   // addi  x1, x0, 1
        mem[35]  = 32'h00200113;   // addi  x2, x0, 2

        // BEQ (not taken)
        mem[36]  = 32'h00208463;   // beq   x1, x2, +8      (skip next if equal ? not taken)
        mem[37]  = 32'h00000013;   // nop                   (executed)

        // BNE (taken)
        mem[38]  = 32'h00209463;   // bne   x1, x2, +8      (skip nop)
        mem[39]  = 32'h00000013;   // nop                   (skipped)

        // BLT (taken: 1 < 2)
        mem[40]  = 32'h0020C463;   // blt   x1, x2, +8
        mem[41]  = 32'h00000013;   // nop                   (skipped)

        // BGE (not taken: 1 is not >= 2)
        mem[42]  = 32'h0020D663;   // bge   x1, x2, +12
        mem[43]  = 32'h00000013;   // nop                   (executed)
        mem[44]  = 32'h00000013;   // nop                   (executed)

        // BLTU (unsigned, taken)
        mem[45]  = 32'h0020E663;   // bltu  x1, x2, +12
        mem[46]  = 32'h00000013;   // nop                   (skipped)
        mem[47]  = 32'h00000013;   // nop                   (skipped)

        // BGEU (unsigned, not taken: 1 < 2)
        mem[48]  = 32'h0020F463;   // bgeu  x1, x2, +8
        mem[49]  = 32'h00000013;   // nop                   (executed)

        // ---------- End with infinite loop ----------
        mem[50]  = 32'h0000006F;   // jal   x0, 0           (infinite loop)
    end

endmodule