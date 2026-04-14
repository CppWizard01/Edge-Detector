`timescale 1ns / 1ps

module line_buffer #(
    parameter WIDTH = 128
)(
    input clk,
    input valid_in,
    input [7:0] din,
    output reg [7:0] dout
);

   localparam ptr_w = $clog2(WIDTH);
    reg [ptr_w-1:0] ptr = 0;
    
    reg [7:0] mem [0:WIDTH-1];
    
    integer i;
    initial begin
        for (i = 0; i < WIDTH; i = i + 1) begin
            mem[i] = 0;
        end
    end    
    
    always @(posedge clk) begin
        if (valid_in) begin
            dout <= mem[ptr];
            mem[ptr] <= din;
            ptr <= (ptr == WIDTH - 1) ? 0 : ptr + 1;
        end
    end
endmodule