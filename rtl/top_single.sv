
// pipeline regs removed: wiring stages directly (no renaming of existing stage ports)
module riscv_top (
    input clk,
    input rst
);

    // =====================================================
    // WIRES / REGS declaration (kept names you used)
    // =====================================================
    
    // PC
    reg  [31:0] pc;
    wire [31:0] pc_next;

    // IF Stage Wires
    wire [31:0] instr_if;
    wire [31:0] pc_plus4_if;

    // ID Stage Wires (outputs from id_stage)
    wire [31:0] rd1_id, rd2_id, imm_id;
    wire [4:0]  rs1_id, rs2_id, rd_id;
    wire        Reg_write_id, Mem_Write_id, Branch_id, jump_id, Alu_src_id;
    wire [1:0]  Result_src_id, Store_type_id;
    wire [2:0]  Imm_src_id, Load_type_id, branch_cond_id;
    wire [3:0]  ALU_Control_id;

    // EX Stage Wires (outputs from ex_stage)
    wire [31:0] alu_result_ex, store_data_ex, pc_target_ex;
    wire        take_branch_ex;

    // MEM Stage Wires (outputs from mem_stage)
    wire [31:0] mem_read_data_out;
    wire [31:0] alu_result_wb_out;
    wire [31:0] pc_plus4_wb_out;
    wire [4:0]  rd_wb_out;
    wire        Reg_write_wb_out;
    wire [1:0]  Result_src_wb_out;

    // WB stage wires
    wire [31:0] wb_data;
    wire [4:0]  wb_rd;
    wire        wb_we;

    // =====================================================
    // IF STAGE
    // =====================================================
    if_stage IF (
        .pc       (pc),
        .instr    (instr_if),
        .pc_plus4 (pc_plus4_if)
    );

    // =====================================================
    // ID STAGE (directly fed from IF outputs)
    // Keep the same port names as your id_stage expects.
    // =====================================================
    id_stage ID (
        .instr       (instr_if),   // was instr_id when pipelined
        .wb_data     (wb_data),    // feedback from WB
        .wb_we       (wb_we),      // feedback from WB
        .clk         (clk),
        .wb_rd       (wb_rd),

        .rd1         (rd1_id),
        .rd2         (rd2_id),
        .imm_ext     (imm_id),
        .rs1         (rs1_id),
        .rs2         (rs2_id),
        .rd          (rd_id),

        .Reg_write   (Reg_write_id),
        .Mem_Write   (Mem_Write_id),
        .Branch      (Branch_id),
        .jump        (jump_id),
        .Alu_src     (Alu_src_id),
        .Result_src  (Result_src_id),
        .Imm_src     (Imm_src_id),
        .ALU_Control (ALU_Control_id),
        .Store_type  (Store_type_id),
        .Load_type   (Load_type_id),
        .branch_cond (branch_cond_id)
    );

    // =====================================================
    // EX STAGE (directly fed from ID outputs)
    // Use the exact port names expected by ex_stage
    // =====================================================
    ex_stage EX (
        .pc_ex          (pc),             // previously pc_ex came from ID/EX (PCD) -> now directly use current PC
        .rd1_ex         (rd1_id),
        .rd2_ex         (rd2_id),
        .imm_ex         (imm_id),
        .Branch_ex      (Branch_id),
        .jump_ex        (jump_id),
        .Alu_src_ex     (Alu_src_id),
        .ALU_Control_ex (ALU_Control_id),
        .branch_cond_ex (branch_cond_id),

        .alu_result_ex  (alu_result_ex),
        .store_data_ex  (store_data_ex),
        .pc_branch_ex   (pc_target_ex),
        .take_branch_ex (take_branch_ex)
    );

    // =====================================================
    // MEM STAGE (directly fed from EX outputs and ID control signals)
    // Keep exact port names for mem_stage
    // =====================================================
    mem_stage MEM (
        .alu_result_mem  (alu_result_ex),    // was alu_result_mem_in from EX/MEM reg
        .store_data_mem  (store_data_ex),    // was store_data_mem_in
        .pc_branch_mem   (pc_target_ex),     // was pc_branch_mem_in
        .rd_mem          (rd_id),            // rd from ID (no pipeline reg)

        .Mem_Write_mem   (Mem_Write_id),
        .Reg_write_mem   (Reg_write_id),
        .take_branch_mem (take_branch_ex),
        .jump_mem        (jump_id),
        .Result_src_mem  (Result_src_id),
        .Store_type_mem  (Store_type_id),
        .Load_type_mem   (Load_type_id),
        .clk             (clk),

        .mem_read_data   (mem_read_data_out),
        .alu_result_wb   (alu_result_wb_out),
        .pc_plus4_wb     (pc_plus4_wb_out),
        .rd_wb           (rd_wb_out),
        .Reg_write_wb    (Reg_write_wb_out),
        .Result_src_wb   (Result_src_wb_out)
    );

    // =====================================================
    // WB STAGE (directly fed from MEM outputs)
    // Keep exact port names for wb_stage
    // =====================================================
    wb_stage WB (
        .mem_read_data_wb (mem_read_data_out),
        .alu_result_wb    (alu_result_wb_out),
        .pc_plus4_wb      (pc_plus4_wb_out),
        .rd_wb            (rd_wb_out),
        .Reg_write_wb     (Reg_write_wb_out),
        .Result_src_wb    (Result_src_wb_out),

        .wb_data          (wb_data),
        .wb_rd            (wb_rd),
        .wb_we            (wb_we)
    );

    // =====================================================
    // PC UPDATE (branch decision comes from EX outputs)
    // =====================================================
    assign pc_next = (take_branch_ex) ? pc_target_ex : pc_plus4_if;

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule
