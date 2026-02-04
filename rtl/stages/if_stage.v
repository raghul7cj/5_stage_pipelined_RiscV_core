module if_stage (
    input  [31:0] pc,

    output [31:0] instr,
    output [31:0] pc_plus4
);

    assign pc_plus4 = pc + 32'd4;

    Instr_Mem imem (
        .addr  (pc),
        .instr (instr)
    );

endmodule
