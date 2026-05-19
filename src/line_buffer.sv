`timescale 1ns / 1ps

module line_buffer #(parameter int DEPTH = 128)(
    input logic clk, rst_n,
    stream_if.rx in_bus, 
    stream_if.tx out_bus
);

    localparam int PTR_W = $clog2(DEPTH);

    logic [PTR_W-1:0] ptr;
    logic [7:0] mem [DEPTH];
    
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            mem[i] = '0;
        end
    end    
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ptr <= '0;
            out_bus.valid <= '0;
            out_bus.pixel <= '0;
        end
        else begin
            out_bus.valid <= in_bus.valid;
            if (in_bus.valid) begin
                out_bus.pixel <= mem[ptr];
                mem[ptr] <= in_bus.pixel;
                ptr <= (ptr == DEPTH - 1) ? '0 : ptr + 1'b1;
            end
        end
    end
endmodule