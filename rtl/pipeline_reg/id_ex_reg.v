module id_ex_reg (
    input clk,
    input rst,

    // -------- From ID stage --------
    input [31:0] pc_id,
    input [31:0] rd1_id,
    input [31:0] rd2_id,
    input [31:0] imm_id,

    input [4:0]  rs1_id,
    input [4:0]  rs2_id,
    input [4:0]  rd_id,

    // Control signals
    input        Branch_id,
    input        jump_id,
    input        Alu_src_id,
    input [3:0]  ALU_Control_id,
    input [2:0]  branch_cond_id,

    input        Mem_Write_id,
    input        Reg_write_id,
    input [1:0]  Result_src_id,
    input [1:0]  Store_type_id,
    input [2:0]  Load_type_id,

    // -------- To EX stage --------
    output reg [31:0] pc_ex,
    output reg [31:0] rd1_ex,
    output reg [31:0] rd2_ex,
    output reg [31:0] imm_ex,

    output reg [4:0]  rs1_ex,
    output reg [4:0]  rs2_ex,
    output reg [4:0]  rd_ex,

    // Control
    output reg        Branch_ex,
    output reg        jump_ex,
    output reg        Alu_src_ex,
    output reg [3:0]  ALU_Control_ex,
    output reg [2:0]  branch_cond_ex,

    output reg        Mem_Write_ex,
    output reg        Reg_write_ex,
    output reg [1:0]  Result_src_ex,
    output reg [1:0]  Store_type_ex,
    output reg [2:0]  Load_type_ex
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_ex           <= 32'b0;
            rd1_ex          <= 32'b0;
            rd2_ex          <= 32'b0;
            imm_ex          <= 32'b0;
            rs1_ex          <= 5'b0;
            rs2_ex          <= 5'b0;
            rd_ex           <= 5'b0;

            Branch_ex       <= 1'b0;
            jump_ex         <= 1'b0;
            Alu_src_ex      <= 1'b0;
            ALU_Control_ex  <= 4'b0;
            branch_cond_ex  <= 3'b0;

            Mem_Write_ex    <= 1'b0;
            Reg_write_ex    <= 1'b0;
            Result_src_ex   <= 2'b0;
            Store_type_ex   <= 2'b0;
            Load_type_ex    <= 3'b0;
        end else begin
            pc_ex           <= pc_id;
            rd1_ex          <= rd1_id;
            rd2_ex          <= rd2_id;
            imm_ex          <= imm_id;
            rs1_ex          <= rs1_id;
            rs2_ex          <= rs2_id;
            rd_ex           <= rd_id;

            Branch_ex       <= Branch_id;
            jump_ex         <= jump_id;
            Alu_src_ex      <= Alu_src_id;
            ALU_Control_ex  <= ALU_Control_id;
            branch_cond_ex  <= branch_cond_id;

            Mem_Write_ex    <= Mem_Write_id;
            Reg_write_ex    <= Reg_write_id;
            Result_src_ex   <= Result_src_id;
            Store_type_ex   <= Store_type_id;
            Load_type_ex    <= Load_type_id;
        end
    end

endmodule
