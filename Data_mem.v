module Data_Mem (
    input         clk,
    input         MemWrite,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:255];  // 1KB data memory

    always @(posedge clk) begin
        if (MemWrite)
            mem[addr[9:2]] <= write_data;
    end

    assign read_data = mem[addr[9:2]] ;
endmodule
