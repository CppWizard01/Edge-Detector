`timescale 1ns / 1ps

module edge_detector #(
    parameter int WIDTH = 128
)(
    input logic clk, rst_n,
    input logic [7:0] threshold,
    stream_if in_bus,
    stream_if out_bus
);

    stream_if #(.WIDTH(8)) blur_to_sobel_bus();

    gaussian_blur #(.WIDTH(WIDTH)) blur_inst (
        .clk,
        .rst_n,
        .in_bus(in_bus),
        .out_bus(blur_to_sobel_bus)
    );

    sobel #(.WIDTH(WIDTH - 2)) sobel_inst (
        .clk,
        .rst_n,
        .threshold,
        .in_bus(blur_to_sobel_bus),
        .out_bus(out_bus)
    );

endmodule