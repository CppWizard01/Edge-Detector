`timescale 1ns / 1ps

module edge_detector #(
    parameter WIDTH = 128
)(
    input clk,
    input rst,
    input valid_in,
    input [7:0] p_in,
    input [7:0] threshold,
    
    output valid_out,
    output [7:0] p_out
);

    wire blur_valid;
    wire [7:0] blur_pixel;

    gaussian_blur #(.WIDTH(WIDTH)) blur_inst (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .p_in(p_in),
        .valid_out(blur_valid),
        .p_out(blur_pixel)
    );

    sobel #(.WIDTH(WIDTH - 2)) sobel_inst (
        .clk(clk),
        .rst(rst),
        .valid_in(blur_valid),
        .p_in(blur_pixel),
        .threshold(threshold),
        .valid_out(valid_out),
        .p_out(p_out)
    );

endmodule