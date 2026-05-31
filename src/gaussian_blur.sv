`timescale 1ns / 1ps

module gaussian_blur #(
    parameter int WIDTH = 128,
    parameter int PIX_WIDTH = 8
)(
    input logic clk, rst_n,
    stream_if in_bus,
    stream_if out_bus
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
        end else begin
            valid_pipe <= {valid_pipe[PIPE_DEPTH-2:0], window_valid};
            out_bus.valid <= valid_pipe[PIPE_DEPTH-1];
        end
    end

    logic [8:0] sum_c1, sum_c2, sum_e1, sum_e2;
    logic [7:0] center_d1, center_d2;
    logic [9:0] sum_corners, sum_edges, center_shifted;
    logic [11:0] sum_partial, final_sum;

    always_ff @(posedge clk) begin
        sum_c1         <= window[0][0] + window[0][2];
        sum_c2         <= window[2][0] + window[2][2];
        sum_e1         <= window[0][1] + window[1][0];
        sum_e2         <= window[1][2] + window[2][1];
        center_d1      <= window[1][1];
        sum_corners    <= sum_c1 + sum_c2;
        sum_edges      <= sum_e1 + sum_e2;
        center_d2      <= center_d1;
        sum_partial    <= sum_corners + (sum_edges << 1);
        center_shifted <= {center_d2, 2'b00};
        final_sum      <= sum_partial + center_shifted;

        if (!rst_n) begin
            out_bus.pixel <= '0;
        end else begin
            out_bus.pixel <= final_sum[11:4];
        end
    end

endmodule