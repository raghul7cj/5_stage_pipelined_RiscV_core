module id_stage (
    input  [31:0] instr,
    input  [31:0] wb_data,
    input         wb_we,
    input         clk,

    // Register outputs
    output [31:0] rd1,
    output [31:0] rd2,
    output [31:0] imm_ext,

    // Register indices
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    // Control outputs
    output        Reg_write,
    output        Mem_Write,
    output        Branch,
    output        jump,
    output        Alu_src,
    output [1:0]  Result_src,
    output [2:0]  Imm_src,
    output [3:0]  ALU_Control,

    // Type / condition outputs
    output [1:0]  Store_type,
    output [2:0]  Load_type,
    output [2:0]  branch_cond
);

    // Instruction fields
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // Control Unit
    control_unit CU (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7       (funct7),
        .Reg_write    (Reg_write),
        .Mem_Write    (Mem_Write),
        .Result_src   (Result_src),
        .Imm_src      (Imm_src),
        .jump         (jump),
        .Branch       (Branch),
        .Alu_src      (Alu_src),
        .ALU_Control  (ALU_Control),
        .Store_type   (Store_type),
        .Load_type    (Load_type),
        .branch_cond  (branch_cond)
    );

    // Register File
    reg_file RF (
        .clk (clk),
        .A1 (rs1),
        .A2 (rs2),
        .A3  (rd),
        .WD3  (wb_data),
        .Reg_Write_En  (wb_we),
        .RD1 (rd1),
        .RD2 (rd2)
    );

    // Immediate Generator
    immediate_extender IMM (
        .instr  (instr),
        .ImmSrc (Imm_src),
        .imm_ext    (imm_ext)
    );

endmodule
