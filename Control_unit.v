// Control Unit for RV32I (Recommended Instructions Only)
module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output reg Reg_write,
    output reg Mem_Write,
    output reg [1:0] Result_src,
    output reg [2:0] Imm_src,
    output reg jump,
    output reg Branch,
    output reg Alu_src,
    output reg [3:0] ALU_Control,
    output reg branch_on_not_equal
);

    // Immediate Source Encoding
    localparam IMM_I = 3'b000,
              IMM_S = 3'b001,
              IMM_B = 3'b010,
              IMM_U = 3'b011,
              IMM_J = 3'b100;


    // Result Source Encoding
    localparam RES_SRC_Alu = 2'b00,
               RES_SRC_Mem = 2'b01,
               RES_SRC_PC  = 2'b10;

    // ALU Source Encoding
    localparam ALU_SRC_REG = 1'b0,
               ALU_SRC_IMM = 1'b1;

    // ALU Operations
    localparam ALU_ADD  = 4'b0000,
               ALU_SUB  = 4'b0001,
               ALU_AND  = 4'b0010,
               ALU_OR   = 4'b0011,
               ALU_SLL  = 4'b0100,
               ALU_SRL  = 4'b0101;

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
        branch_on_not_equal = 0;
        case (opcode)
            7'b0110011: begin // R-Type (ADD, SUB, AND, OR, SLL, SRL)
                Reg_write = 1;
                Alu_src = ALU_SRC_REG;
                Result_src = RES_SRC_Alu;
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
                Imm_src = IMM_I;
                case (funct3)
                    3'b000: ALU_Control = ALU_ADD;      // ADDI
                    3'b111: ALU_Control = ALU_AND;      // ANDI
                    3'b110: ALU_Control = ALU_OR;       // ORI
                    3'b001: ALU_Control = ALU_SLL;      // SLLI
                    3'b101: ALU_Control = ALU_SRL;      // SRLI
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
                    3'b000: begin   
                        ALU_Control = ALU_SUB; // BEQ
                        branch_on_not_equal = 0;
                    end
                    3'b001: begin  
                        ALU_Control = ALU_SUB; // BNE
                        branch_on_not_equal = 1;
                    end
                    default: begin
                        ALU_Control = ALU_SUB;
                        branch_on_not_equal = 0;
                    end
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
                Imm_src     = IMM_J;
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
