`timescale 1ns / 1ps

module tb_edge_detector();

    logic clk = 0;
    logic rst_n;
    logic [7:0] threshold;
    
    stream_if #(.WIDTH(8)) in_bus();
    stream_if #(.WIDTH(8)) out_bus();
    
    edge_detector #(.WIDTH(128)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .threshold(threshold),
        .in_bus(in_bus),
        .out_bus(out_bus)
    );
    
    logic [7:0] img_mem [16384];
    int out_file;
    int valid_cnt;
    
    always #5 clk = ~clk; 
    
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_edge_detector);

        valid_cnt = 0;
        
        $readmemh("ip_img1.hex", img_mem);
        out_file = $fopen("output_image.hex", "w");
        
        rst_n = 0;
        in_bus.valid = 0;
        in_bus.pixel  = 0;
        threshold    = 8'h80;
        
        #100;
        rst_n = 1'b1;
        #20;
        
        for (int i = 0; i < 16384; i++) begin
            @(posedge clk);
            in_bus.valid <= 1'b1;
            in_bus.pixel  <= img_mem[i];
        end
        
        for (int i = 0; i < 600; i++) begin
            @(posedge clk);
            in_bus.valid <= 1'b1;
            in_bus.pixel  <= 8'h00;
        end
        
        @(posedge clk);
        in_bus.valid <= 1'b0;

        #5000;
        
        $display("Simulation complete. Captured %0d valid output pixels.", valid_cnt);
        $fclose(out_file);
        $finish;
    end
    
    always_ff @(posedge clk) begin
        if (out_bus.valid && valid_cnt < 15376) begin
            $fwrite(out_file, "%02X\n", out_bus.pixel);
            valid_cnt <= valid_cnt + 1;
        end
    end

endmodule