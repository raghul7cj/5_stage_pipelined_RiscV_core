module mem_stage (
    // -------- Inputs from EX/MEM --------
    input  [31:0] alu_result_mem,   // address from ALU
    input  [31:0] store_data_mem,    // rs2 value for store
    input  [31:0] pc_branch_mem,     // branch / jump target
    input  [4:0]  rd_mem,            // destination register

    // Control signals
    input         Mem_Write_mem,
    input         Reg_write_mem,
    input         take_branch_mem,
    input         jump_mem,
    input  [1:0]  Result_src_mem,
    input  [1:0]  Store_type_mem,
    input  [2:0]  Load_type_mem,

    input         clk,

    // -------- Outputs to MEM/WB --------
    output [31:0] mem_read_data,
    output [31:0] alu_result_wb,
    output [31:0] pc_plus4_wb,
    output [4:0]  rd_wb,

    output        Reg_write_wb,
    output [1:0]  Result_src_wb
);

    // -----------------------------
    // Internal wires
    // -----------------------------
    wire [31:0] data_mem_rdata;
    wire [31:0] load_data_ext;
    wire [3:0]  write_strobe;

    // -----------------------------
    // LSU (Load / Store Unit)
    // -----------------------------
    lsu LSU (
        .Load_type_mem (Load_type_mem),
        .Store_type_mem(Store_type_mem),
        .mem_data      (data_mem_rdata),
        .write_strb    (write_strobe),
        .load_data     (load_data_ext)
    );

    // -----------------------------
    // Data Memory
    // -----------------------------
    Data_Mem DMEM (
        .clk        (clk),
        .MemWrite   (Mem_Write_mem),
        .write_strb (write_strobe),
        .addr       (alu_result_mem),
        .write_data (store_data_mem),
        .read_data  (data_mem_rdata)
    );

    // -----------------------------
    // Pass-throughs to MEM/WB
    // -----------------------------
    assign mem_read_data  = load_data_ext;
    assign alu_result_wb  = alu_result_mem;
    assign rd_wb          = rd_mem;
    assign Reg_write_wb   = Reg_write_mem;
    assign Result_src_wb  = Result_src_mem;

    // -----------------------------
    // PC + 4 forwarding (WB use)
    // -----------------------------
    assign pc_plus4_wb = pc_branch_mem; 
    // NOTE: This assumes pc_branch_mem already holds PC+4 for JAL/JALR
    // If not, you must forward PC+4 separately from EX/MEM.

endmodule
