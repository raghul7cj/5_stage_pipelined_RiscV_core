module reg_file(
        input clk,
        input rst,
        input [4:0]A1,
        input [4:0]A2,
        input [4:0]A3,
        input [31:0]WD3,
        input Reg_Write_En,
        output wire [31:0]RD1,
        output wire [31:0]RD2
);
    reg [31:0] Reg_array [31:0] ;

    always @(negedge clk ) begin
        if(rst)
        begin
            Reg_array[0] = 32'd0;
        end
        else
        begin
        if (Reg_Write_En && A3 != 5'd0) begin
            Reg_array[A3] <= WD3 ;
        end
        end
    end
    
    assign RD1 = Reg_array [A1];
    assign RD2 = Reg_array [A2];
    


    

endmodule