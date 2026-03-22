`timescale 1ns / 1ps

module gaussian_blur #(
    parameter WIDTH = 128
)(
    input clk,
    input rst,
    input valid_in,
    input [7:0] p_in,
    output reg valid_out,
    output reg [7:0] p_out
);

    reg [15:0] x_in;
    reg [15:0] y_in;

    always @(posedge clk) begin
        if (rst) begin
            x_in <= 0;
            y_in <= 0;
        end else if (valid_in) begin
            if (x_in == WIDTH - 1) begin
                x_in <= 0;
                y_in <= y_in + 1;
            end else begin
                x_in <= x_in + 1;
            end
        end
    end

    wire [7:0] lb1_out, lb2_out;

    line_buffer #(WIDTH) lb1 (.clk(clk), .valid_in(valid_in), .din(p_in), .dout(lb1_out));
    line_buffer #(WIDTH) lb2 (.clk(clk), .valid_in(valid_in), .din(lb1_out), .dout(lb2_out));

    reg [7:0] p_in_d1, p_in_d2;
    reg [7:0] lb1_out_d1;

    always @(posedge clk) begin
        if (valid_in) begin
            p_in_d1    <= p_in;
            p_in_d2    <= p_in_d1;
            lb1_out_d1 <= lb1_out;
        end
    end

    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;
    reg v1, v2, v3;

    always @(posedge clk) begin
        if (rst) begin
            v1 <= 0;
            v2 <= 0;
            v3 <= 0;
        end else if (valid_in) begin
            p02 <= lb2_out;
            p01 <= p02;
            p00 <= p01;

            p12 <= lb1_out_d1;
            p11 <= p12;
            p10 <= p11;

            p22 <= p_in_d2;
            p21 <= p22;
            p20 <= p21;

            v1 <= (x_in >= 2) && (y_in >= 2);
            v2 <= v1;
            v3 <= v2;
        end
    end

    reg [8:0] sum_c1, sum_c2;
    reg [8:0] sum_e1, sum_e2;
    reg [7:0] center_d1;

    reg [9:0] sum_corners;
    reg [9:0] sum_edges;
    reg [7:0] center_d2;

    reg [11:0] sum_partial;
    reg [9:0] center_shifted;

    reg [11:0] final_sum;
    reg v4, v5, v6, v7;

    always @(posedge clk) begin
        if (rst) begin
            v4 <= 0;
            v5 <= 0;
            v6 <= 0;
            v7 <= 0;
        end 
        
        else if (valid_in) begin
            sum_c1 <= p00 + p02;
            sum_c2 <= p20 + p22;
            sum_e1 <= p01 + p10;
            sum_e2 <= p12 + p21;
            center_d1 <= p11;
            v4 <= v3;

            sum_corners <= sum_c1 + sum_c2;
            sum_edges <= sum_e1 + sum_e2;
            center_d2 <= center_d1;
            v5 <= v4;

            sum_partial <= sum_corners + (sum_edges << 1);
            center_shifted <= {center_d2, 2'b00};
            v6 <= v5;

            final_sum <= sum_partial + center_shifted;
            v7 <= v6;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            valid_out <= 0;
            p_out <= 0;
        end else begin
            if (valid_in) begin
                p_out <= final_sum[11:4];
                valid_out <= v7;
            end 
            else begin
                valid_out <= 0;
            end
        end
    end

endmodule