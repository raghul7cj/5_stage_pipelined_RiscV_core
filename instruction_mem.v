module Instr_Mem (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255];  // 1KB instruction memory (256 instructions)

    initial begin
        $readmemh("instr_mem.hex", mem); // Hex file with machine code
    end

    assign instr = mem[addr[9:2]];  // Word-aligned access
endmodule
