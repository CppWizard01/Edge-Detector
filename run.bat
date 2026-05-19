@echo off

echo === Step 1: Generating Input Image Hex ===
python scripts\gen_input.py data\ip_img1.png
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 2: Compiling SystemVerilog Design ===

wsl bash -c "cd /mnt/c/Users/sdhai/Desktop/Edge-Detector && verilator --binary --timing -Wall -Wno-fatal -sv src/stream_if.sv src/window_generator.sv src/line_buffer.sv src/gaussian_blur.sv src/sobel.sv src/edge_detector.sv testbench/tb_edge_detector.sv --top-module tb_edge_detector"

if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 3: Running Hardware Simulation ===

wsl bash -c "cd /mnt/c/Users/sdhai/Desktop/Edge-Detector && ./obj_dir/Vtb_edge_detector"

if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 4: Reconstructing Output Image ===
python scripts\read_output.py
if %errorlevel% neq 0 exit /b %errorlevel%

echo === ALL STEPS COMPLETED SUCCESSFULLY ===