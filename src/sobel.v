`timescale 1ns / 1ps

module sobel #(
    parameter WIDTH = 128
)(
    input clk,
    input rst,
    input valid_in,
    input [7:0] p_in,
    input [7:0] threshold,
    output reg valid_out,
    output reg [7:0] p_out
);

    reg [15:0] x_in;
    reg [15:0] y_in;

    always @(posedge clk) begin
        if (rst) begin
            x_in <= 0;
            y_in <= 0;
        end 
        
        else if (valid_in) begin
            if (x_in == WIDTH - 1) begin
                x_in <= 0;
                y_in <= y_in + 1;
            end 
            
            else begin
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
            p_in_d1 <= p_in;
            p_in_d2 <= p_in_d1;
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
        end 
        
        else if (valid_in) begin
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

    reg signed [11:0] gx, gy;
    reg [11:0] gx_abs, gy_abs;
    reg [10:0] g;
    reg [10:0] sum_right, sum_left;
    reg [10:0] sum_bottom, sum_top;
    reg v4, v5, v6, v7;

    always @(posedge clk) begin
        if (rst) begin
            gx <= 0;
            gy <= 0;
            gx_abs <= 0;
            gy_abs <= 0;
            g <= 0;
            v4 <= 0;
            v5 <= 0;
            v6 <= 0;
            v7 <= 0;
            valid_out <= 0;
            p_out <= 0;
        end 
        
        else if (valid_in) begin
            sum_right <= p02 + p22 + (p12 << 1);
            sum_left <= p00 + p20 + (p10 << 1);
            sum_bottom <= p20 + p22 + (p21 << 1);
            sum_top <= p00 + p02 + (p01 << 1);
            v4 <= v3;

            gx <= $signed({1'b0, sum_right})  - $signed({1'b0, sum_left});
            gy <= $signed({1'b0, sum_bottom}) - $signed({1'b0, sum_top});
            v5 <= v4;

            gx_abs <= gx[11] ? (~gx + 1) : gx;
            gy_abs <= gy[11] ? (~gy + 1) : gy;
            v6 <= v5;

            g <= gx_abs + gy_abs;
            v7 <= v6;

            valid_out <= v7;
            
            if (v7) begin
                p_out <= (g > threshold) ? 8'hFF : 8'h00;
            end 
            else begin
                p_out <= 8'h00; 
            end
        end 
        
        else begin
            valid_out <= 0;
            p_out <= 0;
        end
    end

endmodule