
module immediate_extender (
    input  wire [31:0] inst,      // 32 bit instruction
    input  wire [2:0]  Imm_src,   // Control signal 
    output wire [31:0] imm_ext    // The sign-extended 32-bit immediate
);
    // matches the control unit
    parameter IMM_I = 3'b000,
              IMM_S = 3'b001,
              IMM_B = 3'b010,
              IMM_U = 3'b011,
              IMM_J = 3'b100;

    reg [31:0] imm_ext_reg;

    always @(inst, Imm_src) begin
        case (Imm_src)
            // I-type: For ADDI, LW, JALR
            IMM_I:
                imm_ext_reg = { {20{inst[31]}}, inst[31:20] };

            // S-type: For SW
            IMM_S:
                imm_ext_reg = { {20{inst[31]}}, inst[31:25], inst[11:7] };

            // B-type: For BEQ, BNE
            IMM_B:
                imm_ext_reg = { {20{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 };

            // U-type: For LUI, AUIPC
            IMM_U:
                imm_ext_reg = { inst[31:12], 12'b0 };
            
            // J-type: For JAL
            IMM_J:
                imm_ext_reg = { {12{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0 };

            default:
                imm_ext_reg = 32'hxxxxxxxx; 
        endcase
    end

    assign imm_ext = imm_ext_reg;

endmodule