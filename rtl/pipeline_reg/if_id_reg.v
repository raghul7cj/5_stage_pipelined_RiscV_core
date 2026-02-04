module if_id_reg (
    input         clk,
    input         rst,

    input  [31:0] instrF,
    input  [31:0] PCF,
    input  [31:0] PC_PLUS4F,

    output reg [31:0] instrD,
    output reg [31:0] PCD,
    output reg [31:0] PC_PLUS4D
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instrD     <= 32'b0;
            PCD        <= 32'b0;
            PC_PLUS4D  <= 32'b0;
        end else begin
            instrD     <= instrF;
            PCD        <= PCF;
            PC_PLUS4D  <= PC_PLUS4F;
        end
    end

endmodule
