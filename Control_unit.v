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
    output reg branch_on_not_equal,
    output reg [1:0] Store_type,
    output reg [2:0] Load_type,
    output reg [2:0] branch_cond
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
    localparam  ALU_ADD  = 4'b0000,
                ALU_SUB  = 4'b0001,
                ALU_AND  = 4'b0010,
                ALU_OR   = 4'b0011,
                ALU_XOR  = 4'b0100,
                ALU_SLL  = 4'b0101,
                ALU_SRL  = 4'b0110,
                ALU_SRA  = 4'b0111,
                ALU_SLT  = 4'b1000,
                ALU_SLTU = 4'b1001;

    localparam LOAD_WORD = 3'b000,
           LOAD_HALF = 3'b001,
           LOAD_BYTE = 3'b010,
           LOAD_HALF_U = 3'b011,   // You may compress differently if desired
           LOAD_BYTE_U = 3'b111;  // Or use 3 bits if you want all explicit types

    localparam STORE_WORD = 2'b00,
           STORE_HALF = 2'b01,
           STORE_BYTE = 2'b10;
           
        localparam BR_EQ  = 3'b000,
           BR_NE  = 3'b001,
           BR_LT  = 3'b010,
           BR_GE  = 3'b011,
           BR_LTU = 3'b100,
           BR_GEU = 3'b101;


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
                    10'b0100000101: ALU_Control = ALU_SRA; // SRA
                    10'b0000000010: ALU_Control = ALU_SLT; // SLT
                    10'b0000000011: ALU_Control = ALU_SLTU; // SLTU
                    default: ALU_Control = ALU_ADD;
                endcase
            end
            7'b0010011: begin // I-Type (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI)
                Reg_write = 1;
                Alu_src   = ALU_SRC_IMM;
                Imm_src   = IMM_I;
                case (funct)
                    10'b0000000_000: ALU_Control = ALU_ADD;   // ADDI
                    10'b0000000_111: ALU_Control = ALU_AND;   // ANDI
                    10'b0000000_110: ALU_Control = ALU_OR;    // ORI
                    10'b0000000_100: ALU_Control = ALU_XOR;   // XORI
                    10'b0000000_010: ALU_Control = ALU_SLT;   // SLTI
                    10'b0000000_011: ALU_Control = ALU_SLTU;  // SLTIU
                    10'b0000000_001: ALU_Control = ALU_SLL;   // SLLI
                    10'b0000000_101: ALU_Control = ALU_SRL;   // SRLI
                    10'b0100000_101: ALU_Control = ALU_SRA;   // SRAI
                    default:         ALU_Control = ALU_ADD;
                endcase
            end

            7'b0000011: begin // LOAD Instructions (LB, LH, LW, LBU, LHU)
                Reg_write   = 1;
                Mem_Write   = 0;
                Result_src  = RES_SRC_Mem;  // Data comes from memory
                Imm_src     = IMM_I;
                Alu_src     = ALU_SRC_IMM;
                ALU_Control = ALU_ADD;      // Base + offset for address

                case (funct3)
                    3'b000: Load_type = LOAD_BYTE;   // LB
                    3'b001: Load_type = LOAD_HALF;   // LH
                    3'b010: Load_type = LOAD_WORD;   // LW
                    3'b100: Load_type = LOAD_BYTE_U; // LBU
                    3'b101: Load_type = LOAD_HALF_U; // LHU
                    default: Load_type = LOAD_WORD;  // Safe fallback
                endcase
            end


            7'b0100011: begin // STORE Instructions (SB, SH, SW)
                Reg_write   = 0;             // no register write
                Mem_Write   = 1;             // enable memory write
                Result_src  = RES_SRC_Alu;   // irrelevant; no wb
                Imm_src     = IMM_S;         // store offset
                Alu_src     = ALU_SRC_IMM;   // compute base + offset
                ALU_Control = ALU_ADD;       // address calculation

                case (funct3)
                    3'b000: Store_type = STORE_BYTE;   // SB
                    3'b001: Store_type = STORE_HALF;   // SH
                    3'b010: Store_type = STORE_WORD;   // SW
                    default: Store_type = STORE_WORD;
                endcase
            end

            7'b1100011: begin // Branch group (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                Branch      = 1;
                Imm_src     = IMM_B;
                Alu_src     = ALU_SRC_REG;
                Result_src  = RES_SRC_Alu; // irrelevant for branch
                Reg_write   = 0;
                Mem_Write   = 0;

                case (funct3)
                    3'b000: begin // BEQ
                        ALU_Control = ALU_SUB;  // compare equality by subtract
                        branch_cond  = BR_EQ;
                    end
                    3'b001: begin // BNE
                        ALU_Control = ALU_SUB;
                        branch_cond  = BR_NE;
                    end
                    3'b100: begin // BLT (signed)
                        ALU_Control = ALU_SLT;
                        branch_cond  = BR_LT;
                    end
                    3'b101: begin // BGE (signed)
                        ALU_Control = ALU_SLT;
                        branch_cond  = BR_GE;
                    end
                    3'b110: begin // BLTU (unsigned)
                        ALU_Control = ALU_SLTU;
                        branch_cond  = BR_LTU;
                    end
                    3'b111: begin // BGEU (unsigned)
                        ALU_Control = ALU_SLTU;
                        branch_cond  = BR_GEU;
                    end
                    default: begin
                        ALU_Control = ALU_SUB;
                        branch_cond  = BR_EQ;
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
