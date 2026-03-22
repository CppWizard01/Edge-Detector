`timescale 1ns / 1ps

module tb_edge_detector();

    reg clk;
    reg rst;
    
    reg valid_in;
    reg [7:0] p_in;
    reg [7:0] threshold;
    
    wire valid_out;
    wire [7:0] p_out;
    
    edge_detector #(.WIDTH(128)) dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .p_in(p_in),
        .threshold(threshold),
        .valid_out(valid_out),
        .p_out(p_out)
    );
    
    reg [7:0] img_mem [0:16383];
    
    integer out_file;
    integer i;
    integer valid_cnt;
    
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_edge_detector);

        valid_cnt = 0;
        
        $readmemh("input_image.hex", img_mem);
        out_file = $fopen("output_image.hex", "w");
        
        rst = 1;
        valid_in = 0;
        p_in = 0;
        threshold = 8'h80;
        
        #100;
        rst = 0;
        #20;
        
        for (i = 0; i < 16384; i = i + 1) begin
            @(posedge clk);
            valid_in <= 1;
            p_in <= img_mem[i];
        end
        
        for (i = 0; i < 50; i = i + 1) begin
            @(posedge clk);
            valid_in <= 1;
            p_in <= 8'h00;
        end
        
        @(posedge clk);
        valid_in <= 0;

        #5000;
        
        $display("Simulation complete. Captured %0d valid output pixels.", valid_cnt);
        $fclose(out_file);
        $finish;
    end
    
    always @(posedge clk) begin
        if (valid_out && valid_cnt < 15376) begin
            $fwrite(out_file, "%02X\n", p_out);
            valid_cnt = valid_cnt + 1;
        end
    end

endmodule