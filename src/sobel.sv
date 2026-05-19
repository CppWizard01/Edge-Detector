`timescale 1ns / 1ps

module sobel #(
    parameter int WIDTH = 128,
    parameter int PIX_WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [PIX_WIDTH-1:0] threshold,
    stream_if.rx in_bus,
    stream_if.tx out_bus
);

    logic [PIX_WIDTH-1:0] window [3][3];
    logic window_valid;

    window_generator #(
        .WIDTH(WIDTH),
        .PIX_WIDTH(PIX_WIDTH)
    ) win_gen (
        .clk(clk),
        .rst_n(rst_n),
        .in_bus(in_bus),
        .window(window),
        .window_valid(window_valid)
    );

    localparam int PIPE_DEPTH = 5;
    logic [PIPE_DEPTH-1:0] valid_pipe;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            valid_pipe <= '0;
            out_bus.valid <= 1'b0;
        end else if (in_bus.valid) begin
            valid_pipe <= {valid_pipe[PIPE_DEPTH-2:0], window_valid};
            out_bus.valid <= valid_pipe[PIPE_DEPTH-1];
        end else begin
            out_bus.valid <= 1'b0;
        end
    end

    logic signed [11:0] gx, gy;
    logic [11:0] gx_abs, gy_abs;
    logic [10:0] g;
    logic [10:0] sum_right, sum_left;
    logic [10:0] sum_bottom, sum_top;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            gx <= '0;
            gy <= '0;
            gx_abs <= '0;
            gy_abs <= '0;
            g <= '0;
            sum_right <= '0;
            sum_left <= '0;
            sum_bottom <= '0;
            sum_top <= '0;
            out_bus.pixel <= '0;
        end 
        else if (in_bus.valid) begin
            sum_right  <= window[0][2] + window[2][2] + (window[1][2] << 1);
            sum_left   <= window[0][0] + window[2][0] + (window[1][0] << 1);
            sum_bottom <= window[2][0] + window[2][2] + (window[2][1] << 1);
            sum_top    <= window[0][0] + window[0][2] + (window[0][1] << 1);

            gx <= $signed({1'b0, sum_right})  - $signed({1'b0, sum_left});
            gy <= $signed({1'b0, sum_bottom}) - $signed({1'b0, sum_top});

            gx_abs <= (gx < 0) ? -gx : gx;
            gy_abs <= (gy < 0) ? -gy : gy;

            g <= gx_abs + gy_abs;
            
            out_bus.pixel <= (g > threshold) ? 8'hFF : 8'h00;
        end
    end

endmodule