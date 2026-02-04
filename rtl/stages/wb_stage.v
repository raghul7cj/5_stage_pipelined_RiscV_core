module wb_stage (
    // -------- Inputs from MEM/WB --------
    input  [31:0] mem_read_data_wb,   // load data from MEM
    input  [31:0] alu_result_wb,       // ALU result
    input  [31:0] pc_plus4_wb,         // PC + 4 (for JAL/JALR)
    input  [4:0]  rd_wb,               // destination register

    input         Reg_write_wb,
    input  [1:0]  Result_src_wb,

    // -------- Outputs to Register File --------
    output [31:0] wb_data,
    output [4:0]  wb_rd,
    output        wb_we
);

    // -----------------------------
    // Write-back data selection
    // -----------------------------
    assign wb_data =
        (Result_src_wb == 2'b00) ? alu_result_wb  :   // ALU result
        (Result_src_wb == 2'b01) ? mem_read_data_wb : // Load result
        (Result_src_wb == 2'b10) ? pc_plus4_wb    :   // JAL / JALR
                                   32'b0;

    // -----------------------------
    // Register file control
    // -----------------------------
    assign wb_rd = rd_wb;
    assign wb_we = Reg_write_wb;

endmodule
