`include "Core/alu.v"
`include "Core/Control_unit.v"
`include "Core/Data_mem.v"
`include "Core/Imm_extender.v"
`include "Core/instruction_mem.v"
`include "Core/lsu.v"
`include "Core/reg_file.v"

`include "pipeline_reg/if_id_reg.v"
`include "pipeline_reg/id_ex_reg.v"
`include "pipeline_reg/ex_mem_reg.v"
`include "pipeline_reg/mem_wb_reg.v"

`include "stages/if_stage.v"
`include "stages/id_stage.v"
`include "stages/ex_stage.v"
`include "stages/mem_stage.v"
`include "stages/wb_stage.v"

`include "Hazard_unit.v"

module riscv_top (
    input clk,
    input rst
);

    // =====================================================
    // PC REGISTER
    // =====================================================
    reg  [31:0] pc;
    wire [31:0] pc_next;

    // =====================================================
    // IF STAGE
    // =====================================================
    wire [31:0] instr_if;
    wire [31:0] pc_plus4_if;

    if_stage IF (
        .pc        (pc),
        .instr     (instr_if),
        .pc_plus4  (pc_plus4_if)
    );

    // =====================================================
    // IF / ID PIPELINE REGISTER
    // =====================================================
    wire [31:0] instr_id;
    wire [31:0] pc_plus4_id;

    if_id_reg IF_ID (
        .clk         (clk),
        .rst         (rst),
        .instr_if    (instr_if),
        .pc_plus4_if (pc_plus4_if),
        .instr_id    (instr_id),
        .pc_plus4_id (pc_plus4_id)
    );

    // =====================================================
    // ID STAGE
    // =====================================================
    wire [31:0] rd1_id, rd2_id, imm_id;
    wire [4:0]  rs1_id, rs2_id, rd_id;

    wire        Reg_write_id;
    wire        Mem_Write_id;
    wire        Branch_id;
    wire        jump_id;
    wire        Alu_src_id;
    wire [1:0]  Result_src_id;
    wire [2:0]  Imm_src_id;
    wire [3:0]  ALU_Control_id;
    wire [1:0]  Store_type_id;
    wire [2:0]  Load_type_id;
    wire [2:0]  branch_cond_id;

    id_stage ID (
        .instr       (instr_id),
        .wb_data     (wb_data),
        .wb_we       (wb_we),
        .clk         (clk),

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
    // ID / EX PIPELINE REGISTER
    // =====================================================
    wire [31:0] pc_plus4_ex;
    wire [31:0] rd1_ex, rd2_ex, imm_ex;
    wire [4:0]  rd_ex;

    wire        Reg_write_ex;
    wire        Mem_Write_ex;
    wire        Branch_ex;
    wire        jump_ex;
    wire        Alu_src_ex;
    wire [1:0]  Result_src_ex;
    wire [3:0]  ALU_Control_ex;
    wire [1:0]  Store_type_ex;
    wire [2:0]  Load_type_ex;
    wire [2:0]  branch_cond_ex;

    id_ex_reg ID_EX (
        .clk             (clk),
        .rst             (rst),

        .pc_plus4_id     (pc_plus4_id),
        .rd1_id          (rd1_id),
        .rd2_id          (rd2_id),
        .imm_id          (imm_id),
        .rd_id           (rd_id),

        .Reg_write_id    (Reg_write_id),
        .Mem_Write_id    (Mem_Write_id),
        .Branch_id       (Branch_id),
        .jump_id         (jump_id),
        .Alu_src_id      (Alu_src_id),
        .Result_src_id   (Result_src_id),
        .ALU_Control_id  (ALU_Control_id),
        .Store_type_id   (Store_type_id),
        .Load_type_id    (Load_type_id),
        .branch_cond_id  (branch_cond_id),

        .pc_plus4_ex     (pc_plus4_ex),
        .rd1_ex          (rd1_ex),
        .rd2_ex          (rd2_ex),
        .imm_ex          (imm_ex),
        .rd_ex           (rd_ex),

        .Reg_write_ex    (Reg_write_ex),
        .Mem_Write_ex    (Mem_Write_ex),
        .Branch_ex       (Branch_ex),
        .jump_ex         (jump_ex),
        .Alu_src_ex      (Alu_src_ex),
        .Result_src_ex   (Result_src_ex),
        .ALU_Control_ex  (ALU_Control_ex),
        .Store_type_ex   (Store_type_ex),
        .Load_type_ex    (Load_type_ex),
        .branch_cond_ex  (branch_cond_ex)
    );

    // =====================================================
    // EX STAGE
    // =====================================================
    wire [31:0] alu_result_ex;
    wire [31:0] store_data_ex;
    wire [31:0] pc_target_ex;
    wire        take_branch_ex;

    ex_stage EX (
        .pc_ex          (pc_plus4_ex),
        .rd1_ex         (rd1_ex),
        .rd2_ex         (rd2_ex),
        .imm_ex         (imm_ex),

        .Branch_ex      (Branch_ex),
        .jump_ex        (jump_ex),
        .Alu_src_ex     (Alu_src_ex),
        .ALU_Control_ex (ALU_Control_ex),
        .branch_cond_ex (branch_cond_ex),

        .alu_result_ex  (alu_result_ex),
        .store_data_ex  (store_data_ex),
        .pc_branch_ex   (pc_target_ex),
        .take_branch_ex (take_branch_ex)
    );

    // =====================================================
    // EX / MEM PIPELINE REGISTER
    // =====================================================
    wire [31:0] alu_result_mem;
    wire [31:0] store_data_mem;
    wire [31:0] pc_plus4_mem;
    wire [4:0]  rd_mem;

    wire        Reg_write_mem;
    wire        Mem_Write_mem;
    wire [1:0]  Result_src_mem;
    wire [1:0]  Store_type_mem;
    wire [2:0]  Load_type_mem;

    ex_mem_reg EX_MEM (
        .clk              (clk),
        .rst              (rst),

        .alu_result_ex    (alu_result_ex),
        .store_data_ex    (store_data_ex),
        .pc_plus4_ex      (pc_plus4_ex),
        .rd_ex            (rd_ex),

        .Reg_write_ex     (Reg_write_ex),
        .Mem_Write_ex     (Mem_Write_ex),
        .Result_src_ex    (Result_src_ex),
        .Store_type_ex    (Store_type_ex),
        .Load_type_ex     (Load_type_ex),

        .alu_result_mem   (alu_result_mem),
        .store_data_mem   (store_data_mem),
        .pc_plus4_mem     (pc_plus4_mem),
        .rd_mem           (rd_mem),

        .Reg_write_mem    (Reg_write_mem),
        .Mem_Write_mem    (Mem_Write_mem),
        .Result_src_mem   (Result_src_mem),
        .Store_type_mem   (Store_type_mem),
        .Load_type_mem    (Load_type_mem)
    );

    // =====================================================
    // MEM STAGE
    // =====================================================
    wire [31:0] mem_read_data_mem;

    mem_stage MEM (
        .alu_result_mem  (alu_result_mem),
        .store_data_mem  (store_data_mem),
        .rd_mem          (rd_mem),

        .Mem_Write_mem   (Mem_Write_mem),
        .Reg_write_mem   (Reg_write_mem),
        .Result_src_mem  (Result_src_mem),
        .Store_type_mem  (Store_type_mem),
        .Load_type_mem   (Load_type_mem),

        .clk             (clk),

        .mem_read_data   (mem_read_data_mem)
    );

    // =====================================================
    // MEM / WB PIPELINE REGISTER
    // =====================================================
    wire [31:0] mem_read_data_wb;
    wire [31:0] alu_result_wb;
    wire [31:0] pc_plus4_wb;
    wire [4:0]  rd_wb;

    wire        Reg_write_wb;
    wire [1:0]  Result_src_wb;

    mem_wb_reg MEM_WB (
        .clk               (clk),
        .rst               (rst),

        .mem_read_data_mem (mem_read_data_mem),
        .alu_result_mem    (alu_result_mem),
        .pc_plus4_mem      (pc_plus4_mem),
        .rd_mem            (rd_mem),

        .Reg_write_mem     (Reg_write_mem),
        .Result_src_mem    (Result_src_mem),

        .mem_read_data_wb  (mem_read_data_wb),
        .alu_result_wb     (alu_result_wb),
        .pc_plus4_wb       (pc_plus4_wb),
        .rd_wb             (rd_wb),

        .Reg_write_wb      (Reg_write_wb),
        .Result_src_wb     (Result_src_wb)
    );

    // =====================================================
    // WB STAGE
    // =====================================================
    wire [31:0] wb_data;
    wire        wb_we;

    wb_stage WB (
        .mem_read_data_wb (mem_read_data_wb),
        .alu_result_wb    (alu_result_wb),
        .pc_plus4_wb      (pc_plus4_wb),
        .rd_wb            (rd_wb),

        .Reg_write_wb     (Reg_write_wb),
        .Result_src_wb    (Result_src_wb),

        .wb_data          (wb_data),
        .wb_we            (wb_we)
    );

    // =====================================================
    // PC UPDATE LOGIC
    // =====================================================
    assign pc_next = (take_branch_ex | jump_ex) ? pc_target_ex : pc_plus4_if;

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule

