module ex_stage (
    // -------- Inputs from ID/EX --------
    input  [31:0] pc_ex,
    input  [31:0] rd1_ex,
    input  [31:0] rd2_ex,
    input  [31:0] imm_ex,

    input         Branch_ex,
    input         jump_ex,
    input         Alu_src_ex,
    input  [3:0]  ALU_Control_ex,
    input  [2:0]  branch_cond_ex,

    // -------- Outputs to EX/MEM --------
    output [31:0] alu_result_ex,
    output [31:0] store_data_ex,
    output [31:0] pc_branch_ex,
    output        take_branch_ex
);

    // ----------------------------------
    // ALU operand selection
    // ----------------------------------
    wire [31:0] alu_in2;

    assign alu_in2 = (Alu_src_ex) ? imm_ex : rd2_ex;

    // ----------------------------------
    // ALU
    // ----------------------------------
    alu ALU (
        .A      (rd1_ex),
        .B      (alu_in2),
        .ALU_Control   (ALU_Control_ex),
        .ALU_Result (alu_result_ex),
        .zero   ()                  // not used directly for better critical path and cleaner logic
    );

    // ----------------------------------
    // Branch target calculation
    // ----------------------------------
    assign pc_branch_ex = pc_ex + imm_ex;

    // ----------------------------------
    // Branch condition evaluation          //keep it outsude the alu (better implimentation?)
    // ----------------------------------
    reg branch_taken;

    localparam BR_EQ  = 3'b000,
           BR_NE  = 3'b001,
           BR_LT  = 3'b010,
           BR_GE  = 3'b011,
           BR_LTU = 3'b100,
           BR_GEU = 3'b101;

    always @(*) begin
        branch_taken   = 0;
        case (branch_cond_ex)
            BR_EQ:  branch_taken = (rd1_ex == rd2_ex);
            BR_NE:  branch_taken = (rd1_ex != rd2_ex);
            BR_LT:  branch_taken = ($signed(rd1_ex) <  $signed(rd2));
            BR_GE:  branch_taken = ($signed(rd1_ex) >=  $signed(rd2))
            BR_LTU: branch_taken = (rd1_ex < rd2);
            BR_GEU: branch_taken = (rd1_ex >= rd2);
            default: branch_taken = 1'b0;
        endcase
    end

    assign take_branch_ex = branch_taken | jump_ex;

    
    // Store data forwarding (no logic yet) - mem[ rs1 + imm ] ← rs2 
    assign store_data_ex = rd2_ex;

endmodule
