module ex_mem_reg (
    input clk,
    input rst,

    // -------- From EX stage --------
    input [31:0] alu_result_ex,
    input [31:0] rd2_ex,
    input [31:0] pc_branch_ex,
    input [4:0]  rd_ex,

    input        take_branch_ex,
    input        jump_ex,

    input        Mem_Write_ex,
    input        Reg_write_ex,
    input [1:0]  Result_src_ex,
    input [1:0]  Store_type_ex,
    input [2:0]  Load_type_ex,

    // -------- To MEM stage --------
    output reg [31:0] alu_result_mem,
    output reg [31:0] store_data_mem,
    output reg [31:0] pc_branch_mem,
    output reg [4:0]  rd_mem,

    output reg        take_branch_mem,
    output reg        jump_mem,

    output reg        Mem_Write_mem,
    output reg        Reg_write_mem,
    output reg [1:0]  Result_src_mem,
    output reg [1:0]  Store_type_mem,
    output reg [2:0]  Load_type_mem
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_mem  <= 32'b0;
            store_data_mem  <= 32'b0;
            pc_branch_mem   <= 32'b0;
            rd_mem          <= 5'b0;

            take_branch_mem <= 1'b0;
            jump_mem        <= 1'b0;

            Mem_Write_mem   <= 1'b0;
            Reg_write_mem   <= 1'b0;
            Result_src_mem  <= 2'b0;
            Store_type_mem  <= 2'b0;
            Load_type_mem   <= 3'b0;
        end else begin
            alu_result_mem  <= alu_result_ex;
            store_data_mem  <= rd2_ex;
            pc_branch_mem   <= pc_branch_ex;
            rd_mem          <= rd_ex;

            take_branch_mem <= take_branch_ex;
            jump_mem        <= jump_ex;

            Mem_Write_mem   <= Mem_Write_ex;
            Reg_write_mem   <= Reg_write_ex;
            Result_src_mem  <= Result_src_ex;
            Store_type_mem  <= Store_type_ex;
            Load_type_mem   <= Load_type_ex;
        end
    end

endmodule
