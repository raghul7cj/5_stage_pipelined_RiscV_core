`timescale 1ns / 1ps

module RISC_top_cov_tb;

    reg clk, rst;

    // Instantiate DUT (with added lsunit output)
    RISC_top dut (
        .rst           (rst),
        .clk           (clk),
        .PC_next1      (),
        .PC1           (),
        .A_i1          (),
        .RD_i1         (),
        .A11           (),
        .A21           (),
        .A31           (),
        .WD31          (),
        .RD11          (),
        .RD21          (),
        .WE31          (),
        .operand11     (),
        .operand21     (),
        .alu_result1   (),
        .alu_r1        (),
        .ctrl1         (),
        .flags1        (),
        .ALUSrc1       (),
        .WE1           (),
        .A_d1          (),
        .WD_d1         (),
        .RD_d1         (),
        .pc_plus1      (),
        .Imm_Ext1      (),
        .ImmSrc1       (),
        .LUISrc1       (),
        .isLUI1        (),
        .isJALR1       (),
        .pc_target_jb1 (),
        .lui_result1   (),
        .PCSrc1        (),
        .result1       (),
        .ResultSrc1    (),
        .in_l1         (),
        .out_l1        (),
        .strobe1       (),
        .lsunit        (lsunit)      // now connected
    );

    // Expose internal signals for coverage (via DUT instance)
    wire [31:0] instruction = dut.RD_i1;
    wire [3:0]  alu_ctrl    = dut.ctrl1;
    wire [3:0]  flags       = dut.flags1;
    wire [4:0]  lsunit;
    wire        pcsrc       = dut.PCSrc1;
    wire [1:0]  immsrc      = dut.ImmSrc1;
    wire [6:0]  opcode      = instruction[6:0];
    wire [2:0]  funct3      = instruction[14:12];
    wire [6:0]  funct7      = {instruction[30], instruction[5]}; // for R-type

    // -----------------------------------------------------------------
    // Clock & Reset
    // -----------------------------------------------------------------
    initial clk = 1'b1;
    always #5 clk = ~clk;

    initial begin
        rst = 1'b0;
        #32 rst = 1'b1;
        #2000 $finish;   // run long enough to execute the whole test program
    end

    // =================================================================
    // FUNCTIONAL COVERAGE GROUPS
    // =================================================================

    // 1. Instruction opcodes
    covergroup instruction_cg @(posedge clk);
        opcode_cp : coverpoint opcode {
            bins lui    = {7'b0110111};
            bins auipc  = {7'b0010111};
            bins jal    = {7'b1101111};
            bins jalr   = {7'b1100111};
            bins load   = {7'b0000011};
            bins store  = {7'b0100011};
            bins branch = {7'b1100011};
            bins itype  = {7'b0010011};  // I-type ALU
            bins rtype  = {7'b0110011};  // R-type ALU
            illegal_bins illegal = default;
        }
    endgroup

    // 2. ALU control signals
    covergroup alu_ctrl_cg @(posedge clk);
        ctrl_cp : coverpoint alu_ctrl {
            bins add   = {4'b0000};
            bins sub   = {4'b0001};
            bins AND   = {4'b0100};
            bins OR    = {4'b0101};
            bins XOR   = {4'b0111};
            bins jalr  = {4'b0110};   // JALR uses ALU to add
            bins sll   = {4'b1000};
            bins srl   = {4'b1001};
            bins sra   = {4'b1010};
            bins sltu  = {4'b1100};
            bins slt   = {4'b1111};
        }
    endgroup

    // 3. Branch outcomes (taken / not taken) - only for branch instructions
    event branch_insn;
    covergroup branch_outcome_cg;
        option.per_instance = 1;
        taken : coverpoint pcsrc;
    endgroup

    branch_outcome_cg br_cov = new();

    always @(posedge clk) begin
        if (opcode == 7'b1100011) begin   // branch instruction
            -> branch_insn;
        end
    end

    always @(branch_insn) begin
        br_cov.sample();
    end

    // 4. Load/store types (funct3) and direction
    covergroup ls_cg @(posedge clk);
        // Only sample when lsunit[4] is high (valid load/store)
        funct3_cp : coverpoint lsunit[2:0] iff (lsunit[4]) {
            bins lb    = {3'b000};
            bins lh    = {3'b001};
            bins lw    = {3'b010};
            bins lbu   = {3'b100};
            bins lhu   = {3'b101};
        }
        dir_cp : coverpoint lsunit[3] iff (lsunit[4]) {
            bins load  = {1'b0};
            bins store = {1'b1};
        }
        // Cross to ensure each load/store type is covered for both load and store
        cross funct3_cp, dir_cp;
    endgroup

    // 5. ALU flags
    covergroup flags_cg @(posedge clk);
        carry : coverpoint flags[3];
        sign  : coverpoint flags[1];
        zero  : coverpoint flags[0];
    endgroup

    // 6. Immediate type (ImmSrc)
    covergroup imm_cg @(posedge clk);
        immsrc_cp : coverpoint immsrc {
            bins itype = {2'b00};
            bins stype = {2'b01};
            bins btype = {2'b10};
            bins jtype = {2'b11};
        }
    endgroup

    // Instantiate all covergroups
    instruction_cg  inst_cg   = new();
    alu_ctrl_cg     alu_cg    = new();
    ls_cg           lsu_cg    = new();
    flags_cg        flag_cg   = new();
    imm_cg          imm_cg_inst = new();

endmodule