`timescale 1ns / 1ps

module window_generator #(
    parameter int WIDTH = 128,
    parameter int PIX_WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    stream_if in_bus,
    output logic [PIX_WIDTH-1:0] window [3][3],
    output logic window_valid
);

    logic [$clog2(WIDTH)-1:0] x_in;
    logic [15:0] y_in;

    stream_if lb1_out_bus();
    stream_if lb2_out_bus();

    line_buffer #(.DEPTH(WIDTH)) lb1(
        .clk(clk), .rst_n(rst_n),
        .in_bus(in_bus),
        .out_bus(lb1_out_bus)
    );

    line_buffer #(.DEPTH(WIDTH)) lb2(
        .clk(clk), .rst_n(rst_n),
        .in_bus(lb1_out_bus),
        .out_bus(lb2_out_bus)
    );

    logic [PIX_WIDTH-1:0] p_in_d1, p_in_d2;
    logic [PIX_WIDTH-1:0] lb1_out_d1;

    always_ff @(posedge clk) begin
        if (in_bus.valid) begin
            p_in_d1 <= in_bus.pixel;
        end
        if (lb1_out_bus.valid) begin
            p_in_d2    <= p_in_d1;
            lb1_out_d1 <= lb1_out_bus.pixel;
        end
    end

    always_ff @(posedge clk) begin
        if (lb2_out_bus.valid) begin 
            window[0][2] <= lb2_out_bus.pixel;
            window[0][1] <= window[0][2];
            window[0][0] <= window[0][1];
            window[1][2] <= lb1_out_d1;
            window[1][1] <= window[1][2];
            window[1][0] <= window[1][1];
            window[2][2] <= p_in_d2;
            window[2][1] <= window[2][2];
            window[2][0] <= window[2][1];
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            x_in <= '0;
            y_in <= '0;
        end else if (lb2_out_bus.valid) begin
            if (x_in == WIDTH - 1) begin
                x_in <= '0;
                y_in <= y_in + 1'b1;
            end else begin
                x_in <= x_in + 1'b1;
            end
        end
    end

    assign window_valid = lb2_out_bus.valid && (x_in >= 2) && (y_in >= 2);

endmodule