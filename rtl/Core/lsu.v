module lsu (
    input wire [2:0] Load_type_mem,
    input wire [1:0] Store_type_mem,
    input wire [31:0]mem_data,

    output reg [3:0] write_strb,
    output reg [31:0]load_data 
);

    localparam LOAD_WORD = 3'b000,
           LOAD_HALF = 3'b001,
           LOAD_BYTE = 3'b010,
           LOAD_HALF_U = 3'b011,   
           LOAD_BYTE_U = 3'b111;  

    localparam STORE_WORD = 2'b00,
           STORE_HALF = 2'b01,
           STORE_BYTE = 2'b10;

    always @(*) begin   //load to registers
        case (Load_type_mem)
            LOAD_HALF:      load_data  = { {16{mem_data[15]}} ,mem_data[15:0]};
            LOAD_BYTE:      load_data  = { {24{mem_data[15]}} ,mem_data[7:0]};
            LOAD_HALF_U:    load_data  = { 16'b0 ,mem_data[15:0]};
            LOAD_BYTE_U:    load_data  = { 24'b0 ,mem_data[7:0]};
            LOAD_WORD  :    load_data  = mem_data
            default:        load_data  = mem_data;
        endcase
    end

    always @(*) begin
        case (Store_type_mem)
            STORE_WORD: write_strb = 4'b1111;
            STORE_HALF: write_strb = 4'b0011;
            STORE_BYTE: write_strb = 4'b0001;
            default: write_strb = 4'b1111
        endcase
    end
endmodule