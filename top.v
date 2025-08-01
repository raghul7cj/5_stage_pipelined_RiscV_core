`include "reg_flie.v"
`include "instruction_mem.v"
`include "Data_mem.v"
`include "Imm_extender.v"
`include "Control_unit.v"
`include "ALU.v"

module top(
    input clk,
    input rst
);
    //  Fetch Stage
    wire [31:0] instrF;
    wire [31:0] PCF;
    wire [31:0] PCF_;
    wire [31:0] PC_PLUS4F;
    
    //Decode stage
    wire [31:0] instrD, PCD, PC_PLUS4D, imm_extD, RD1D, RD2D;
    wire [4:0]  Rs1D, Rs2D, Reg_destD;
    wire [1:0]  ResultSrcD, ImmSrcD;
    wire        RegWriteD, MemWriteD, ALUSrcD, JumpD, BranchD;
    wire [2:0]  ALUControlD;
    
    //Excecute stage
    wire [31:0] RD1E, RD2E, imm_extE, SrcAE, SrcBE;
    wire [31:0] PCE, PC_PLUS4E, ALUResultE, WriteDataE, PCTargetE;
    wire [2:0]  ALU_ControlE;
    wire [1:0]  ResultSrcE;
    wire        RegWriteE, MemWriteE, ALUSrcE, JumpE, BranchE;
    wire [4:0]  Reg_destE;
    
    //Memory access stage
    wire [31:0] ALU_ResultM, WriteDataM, PC_PLUS4M, ReadDataM;
    wire [4:0]  Reg_destM;
    wire        RegWriteM, MemWriteM;
    wire [1:0]  ResultSrcM;

    //WriteBack stage
    wire [31:0] PC_PLUS4W;
    wire [4:0]  Reg_destW;
    wire [31:0] ReadDataW, ALU_ResultW, Result_dataW;
    wire [1:0]  ResultSrcW;
    wire        RegWriteW;

    // ------------------------------
    // Pipeline Registers
    // ------------------------------

    // F → D
    reg [31:0] instrD_reg, PCD_reg, PC_PLUS4D_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instrD_reg   <= 0;
            PCD_reg      <= 0;
            PC_PLUS4D_reg<= 0;
        end else begin
            instrD_reg   <= instrF;
            PCD_reg      <= PCF;
            PC_PLUS4D_reg<= PC_PLUS4F;
        end
    end
    assign instrD   = instrD_reg;
    assign PCD      = PCD_reg;
    assign PC_PLUS4D= PC_PLUS4D_reg;

    // D → E
    reg [31:0] RD1E_reg, RD2E_reg, imm_extE_reg, PCE_reg, PC_PLUS4E_reg;
    reg [4:0]  Reg_destE_reg;
    reg [2:0]  ALU_ControlE_reg;
    reg [1:0]  ResultSrcE_reg;
    reg        RegWriteE_reg, MemWriteE_reg, ALUSrcE_reg, JumpE_reg, BranchE_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD1E_reg <= 0; RD2E_reg <= 0; imm_extE_reg <= 0;
            PCE_reg <= 0; PC_PLUS4E_reg <= 0;
            Reg_destE_reg <= 0;
            ALU_ControlE_reg <= 0;
            ResultSrcE_reg <= 0;
            RegWriteE_reg <= 0; MemWriteE_reg <= 0; ALUSrcE_reg <= 0; JumpE_reg <= 0; BranchE_reg <= 0;
        end else begin
            RD1E_reg <= RD1D;
            RD2E_reg <= RD2D;
            imm_extE_reg <= imm_extD;
            PCE_reg <= PCD;
            PC_PLUS4E_reg <= PC_PLUS4D;
            Reg_destE_reg <= instrD[11:7];
            ALU_ControlE_reg <= ALUControlD;
            ResultSrcE_reg <= ResultSrcD;
            RegWriteE_reg <= RegWriteD;
            MemWriteE_reg <= MemWriteD;
            ALUSrcE_reg <= ALUSrcD;
            JumpE_reg <= JumpD;
            BranchE_reg <= BranchD;
        end
    end
    assign RD1E = RD1E_reg;
    assign RD2E = RD2E_reg;
    assign imm_extE = imm_extE_reg;
    assign PCE = PCE_reg;
    assign PC_PLUS4E = PC_PLUS4E_reg;
    assign Reg_destE = Reg_destE_reg;
    assign ALU_ControlE = ALU_ControlE_reg;
    assign ResultSrcE = ResultSrcE_reg;
    assign RegWriteE = RegWriteE_reg;
    assign MemWriteE = MemWriteE_reg;
    assign ALUSrcE = ALUSrcE_reg;
    assign JumpE = JumpE_reg;
    assign BranchE = BranchE_reg;

    // E → M
    reg [31:0] ALU_ResultM_reg, WriteDataM_reg, PC_PLUS4M_reg;
    reg [4:0]  Reg_destM_reg;
    reg [1:0]  ResultSrcM_reg;
    reg        RegWriteM_reg, MemWriteM_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALU_ResultM_reg <= 0; WriteDataM_reg <= 0; PC_PLUS4M_reg <= 0;
            Reg_destM_reg <= 0;
            ResultSrcM_reg <= 0;
            RegWriteM_reg <= 0; MemWriteM_reg <= 0;
        end else begin
            ALU_ResultM_reg <= ALUResultE;
            WriteDataM_reg <= RD2E;
            PC_PLUS4M_reg <= PC_PLUS4E;
            Reg_destM_reg <= Reg_destE;
            ResultSrcM_reg <= ResultSrcE;
            RegWriteM_reg <= RegWriteE;
            MemWriteM_reg <= MemWriteE;
        end
    end
    assign ALU_ResultM = ALU_ResultM_reg;
    assign WriteDataM = WriteDataM_reg;
    assign PC_PLUS4M = PC_PLUS4M_reg;
    assign Reg_destM = Reg_destM_reg;
    assign ResultSrcM = ResultSrcM_reg;
    assign RegWriteM = RegWriteM_reg;
    assign MemWriteM = MemWriteM_reg;

    // M → W
    reg [31:0] ALU_ResultW_reg, ReadDataW_reg, PC_PLUS4W_reg;
    reg [4:0]  Reg_destW_reg;
    reg [1:0]  ResultSrcW_reg;
    reg        RegWriteW_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ALU_ResultW_reg <= 0; ReadDataW_reg <= 0; PC_PLUS4W_reg <= 0;
            Reg_destW_reg <= 0;
            ResultSrcW_reg <= 0;
            RegWriteW_reg <= 0;
        end else begin
            ALU_ResultW_reg <= ALU_ResultM;
            ReadDataW_reg <= ReadDataM;
            PC_PLUS4W_reg <= PC_PLUS4M;
            Reg_destW_reg <= Reg_destM;
            ResultSrcW_reg <= ResultSrcM;
            RegWriteW_reg <= RegWriteM;
        end
    end
    assign ALU_ResultW = ALU_ResultW_reg;
    assign ReadDataW = ReadDataW_reg;
    assign PC_PLUS4W = PC_PLUS4W_reg;
    assign Reg_destW = Reg_destW_reg;
    assign ResultSrcW = ResultSrcW_reg;
    assign RegWriteW = RegWriteW_reg;

    // Register File
    Reg_File reg_file(
        .clk(clk),
        .A1(instrD[19:15]),
        .A2(instrD[24:20]),
        .A3(Reg_destW),
        .WD3(Result_dataW),
        .Reg_Write_En(RegWriteW),
        .RD1(RD1D),
        .RD2(RD2D)
    );

    // Instruction Memory
    Instr_Mem instr_mem(
        .addr(PCF),
        .instr(instrF)
    );

    // Data Memory
    Data_Mem data_mem(
        .clk(clk),
        .MemWrite(MemWriteM),
        .addr(ALU_ResultM),
        .write_data(WriteDataM),
        .read_data(ReadDataM)
    );

    // Immediate Extender
    immediate_extender imm_extender(
        .inst(instrD),
        .Imm_src(ImmSrcD),
        .imm_ext(imm_extD)
    );

    // Control Unit
    control_unit ctrl_unit(
        .opcode(instrD[6:0]),
        .funct3(instrD[14:12]),
        .funct7(instrD[31:25]),
        .Reg_write(RegWriteD),
        .Mem_Write(MemWriteD),
        .Result_src(ResultSrcD),
        .Imm_src(ImmSrcD),
        .jump(JumpD),
        .Branch(BranchD),
        .Alu_src(ALUSrcD),
        .ALU_Control(ALUControlD)
    );

    // ALU
    ALU alu(
        .A(RD1E),
        .B(ALUSrcE ? imm_extE : RD2E),
        .ALU_Control(ALU_ControlE),
        .ALU_Result(ALUResultE),
        .Zero()
    );

endmodule
