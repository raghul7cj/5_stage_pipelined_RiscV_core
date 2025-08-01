// Control Unit for RV32I (Recommended Instructions Only)
module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output reg Reg_write,
    output reg Mem_Write,
    output reg [1:0] Result_src,
    output reg [1:0] Imm_src,
    output reg jump,
    output reg Branch,
    output reg Alu_src,
    output reg [2:0] ALU_Control
);

    // Immediate Source Encoding
    localparam IMM_I = 2'b00,
               IMM_S = 2'b01,
               IMM_B = 2'b10,
               IMM_U = 2'b11;

    // Result Source Encoding
    localparam RES_SRC_Alu = 2'b00,
               RES_SRC_Mem = 2'b01,
               RES_SRC_PC  = 2'b10;

    // ALU Source Encoding
    localparam ALU_SRC_REG = 1'b0,
               ALU_SRC_IMM = 1'b1;

    // ALU Operations
    localparam ALU_ADD  = 3'b000,
               ALU_SUB  = 3'b001,
               ALU_AND  = 3'b010,
               ALU_OR   = 3'b011,
               ALU_SLL  = 3'b100,
               ALU_SRL  = 3'b101;

    wire [9:0] funct;
    assign funct = {funct7[6:0], funct3[2:0]};

    always @(*) begin
        // Defaults
        Reg_write   = 0;
        Mem_Write   = 0;
        Result_src  = RES_SRC_Alu;
        Imm_src     = IMM_I;
        jump        = 0;
        Branch      = 0;
        Alu_src     = ALU_SRC_REG;
        ALU_Control = ALU_ADD;

        case (opcode)
            7'b0110011: begin // R-Type (ADD, SUB, AND, OR, SLL, SRL)
                Reg_write = 1;
                Alu_src = ALU_SRC_REG;
                case (funct)
                    10'b0000000000: ALU_Control = ALU_ADD; // ADD
                    10'b0100000000: ALU_Control = ALU_SUB; // SUB
                    10'b0000000111: ALU_Control = ALU_AND; // AND
                    10'b0000000110: ALU_Control = ALU_OR;  // OR
                    10'b0000000001: ALU_Control = ALU_SLL; // SLL
                    10'b0000000101: ALU_Control = ALU_SRL; // SRL
                    default: ALU_Control = ALU_ADD;
                endcase
            end
            7'b0010011: begin // I-Type (ADDI, ANDI, ORI, SLLI, SRLI)
                Reg_write = 1;
                Alu_src = ALU_SRC_IMM;
                case (funct)
                    10'b0000000000: ALU_Control = ALU_ADD;      // ADDI
                    10'b0000000111: ALU_Control = ALU_AND;      // ANDI
                    10'b0000000110: ALU_Control = ALU_OR;       // ORI
                    10'b0000000001: ALU_Control = ALU_SLL;      // SLLI
                    10'b0000000101: ALU_Control = ALU_SRL;      // SRLI
                    default: ALU_Control = ALU_ADD;
                endcase
            end
            7'b0000011: begin // LW
                Reg_write   = 1;
                Mem_Write   = 0;
                Result_src  = RES_SRC_Mem;
                Imm_src     = IMM_I;
                Alu_src     = ALU_SRC_IMM;
                ALU_Control = ALU_ADD;
            end
            7'b0100011: begin // SW
                Reg_write   = 0;
                Mem_Write   = 1;
                Imm_src     = IMM_S;
                Alu_src     = ALU_SRC_IMM;
                ALU_Control = ALU_ADD;
            end
            7'b1100011: begin // Branch (BEQ, BNE)
                Branch      = 1;
                Imm_src     = IMM_B;
                case (funct3)
                    3'b000: ALU_Control = ALU_SUB; // BEQ
                    3'b001: ALU_Control = ALU_SUB; // BNE
                    default: ALU_Control = ALU_SUB;
                endcase
            end
            7'b0110111: begin // LUI
                Reg_write   = 1;
                Imm_src     = IMM_U;
                Alu_src     = ALU_SRC_IMM;
                ALU_Control = ALU_ADD; // Treated as constant pass-through
            end
            7'b0010111: begin // AUIPC
                Reg_write   = 1;
                Result_src  = RES_SRC_PC;
                Imm_src     = IMM_U;
                Alu_src     = ALU_SRC_IMM;
                ALU_Control = ALU_ADD;
            end
            7'b1101111: begin // JAL
                Reg_write   = 1;
                Result_src  = RES_SRC_PC;
                Imm_src     = IMM_U;
                jump        = 1;
            end
            7'b1100111: begin // JALR
                Reg_write   = 1;
                Result_src  = RES_SRC_PC;
                Imm_src     = IMM_I;
                jump        = 1;
                Alu_src     = ALU_SRC_IMM;
                ALU_Control = ALU_ADD;
            end
        endcase
    end

endmodule
