module Data_Mem (
    input         clk,
    input         MemWrite,         
    input  [3:0]  write_strb,       //for selecting b/w 8/16/32 bit writes - signal from control unit
    input  [31:0] addr,
    input  [31:0] write_data,       // 4 bytes - each byte has one strobe for memory banking like structure
    output [31:0] read_data
);
    reg [7:0] mem [0:255];  // 1KB data memory - 256 byte banking - 4 banks - 10 bits needed to address

    always @(posedge clk) begin
        if (MemWrite) begin

            if (write_strb[0])
                mem[{address[9:2],2'b00}] <= write_data[7:0];
                
            if (write_strb[1])
                mem[{address[9:2],2'b01}] <= write_data[15:8];

            if (write_strb[2])
                mem[{address[9:2],2'b10}] <= write_data[23:16];
            
            if (write_strb[3])
                mem[{address[9:2],2'b11}] <= write_data[31:24];

        end
    end

    wire [9:0] base_addr = {address[9:2], 2'b00}; //word alignment

    assign read_data =  {mem[base_addr +3],  
                        mem[base_addr +2],  
                        mem[base_addr +1],  
                        mem[base_addr   ]} ;  

endmodule
