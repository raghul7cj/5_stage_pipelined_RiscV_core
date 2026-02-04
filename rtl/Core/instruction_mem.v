module Instr_Mem (
    input  [31:0] addr,
    output reg [31:0] instr
);
    reg [31:0] mem [0:255];  // 1KB instruction memory

    // Preload instructions using a combinational assignment
    // (Synthesis tools will map this to LUT/BRAM with init values)

    always @(*) begin
        case (addr[9:2])
            // -------- Set 1: No Hazards --------
            8'd0:  instr = 32'h00500093; // addi x1, x0, 5
            8'd1:  instr = 32'h00A00113; // addi x2, x0, 10
            8'd2:  instr = 32'h002081B3; // add  x3, x1, x2
            8'd3:  instr = 32'h01400213; // addi x4, x0, 20
            8'd4:  instr = 32'h00302023; // sw   x3, 0(x0)
            8'd5:  instr = 32'h00002283; // lw   x5, 0(x0)

            // -------- Set 2: Hazards --------
            8'd6:  instr = 32'h00500093; // addi x1, x0, 5
            8'd7:  instr = 32'h00308113; // addi x2, x1, 3
            8'd8:  instr = 32'h001101B3; // add  x3, x2, x1
            8'd9:  instr = 32'h00302023; // sw   x3, 0(x0)
            8'd10: instr = 32'h00002203; // lw   x4, 0(x0)
            8'd11: instr = 32'h001202B3; // add  x5, x4, x1

            // Default: NOP
            default: instr = 32'h00000013; // addi x0, x0, 0
        endcase
    end
endmodule
