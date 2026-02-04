//RV32I alu 
module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALU_Control,
    output reg [31:0] ALU_Result,
    output Zero
);
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

    
    always @(*) begin
        case (ALU_Control)
            ALU_ADD: ALU_Result = A + B;          // ADD
            ALU_SUB: ALU_Result = A - B;          // SUB
            ALU_AND: ALU_Result = A & B;          // AND
            ALU_OR:  ALU_Result = A | B;          // OR
            ALU_XOR: ALU_Result = A ^ B;          // XOR
            ALU_SLL: ALU_Result = A << B[4:0];    // SLL
            ALU_SRL: ALU_Result = A >> B[4:0];    // SRL
            ALU_SRA: ALU_Result = $signed(A) >>> B[4:0];
            ALU_SLT: ALU_Result = $signed(A) < $signed(B) ? 32'b1 : 32'b0;
            ALU_SLTU:ALU_Result = A < B ? 32'b1 : 32'b0;
            default: ALU_Result = 32'b0;
        endcase
    end

    assign Zero = (ALU_Result == 0);
endmodule
 
