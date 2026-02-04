module mem_wb_reg (
    input         clk,
    input         rst,

    input  [31:0] ReadDataM,
    input  [31:0] ALUResultM,
    input  [31:0] PC_PLUS4M,
    input  [4:0]  Reg_destM,

    input         RegWriteM,
    input  [1:0]  ResultSrcM,

    output reg [31:0] ReadDataW,
    output reg [31:0] ALUResultW,
    output reg [31:0] PC_PLUS4W,
    output reg [4:0]  Reg_destW,

    output reg        RegWriteW,
    output reg [1:0]  ResultSrcW
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ReadDataW <= 0;
            ALUResultW <= 0;
            PC_PLUS4W <= 0;
            Reg_destW <= 0;

            RegWriteW <= 0;
            ResultSrcW <= 0;
        end else begin
            ReadDataW <= ReadDataM;
            ALUResultW <= ALUResultM;
            PC_PLUS4W <= PC_PLUS4M;
            Reg_destW <= Reg_destM;

            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
        end
    end

endmodule
