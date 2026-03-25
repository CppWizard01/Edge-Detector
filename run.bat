@echo off
echo === Step 1: Generating Input Image Hex ===
python scripts\gen_input.py
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 2: Compiling Verilog Design ===
iverilog -o sim.vvp testbench\tb_edge_detector.v src\edge_detector.v src\gaussian_blur.v src\sobel.v src\line_buffer.v
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 3: Running Hardware Simulation ===
vvp sim.vvp
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 4: Reconstructing Output Image ===
python scripts\read_output.py
if %errorlevel% neq 0 exit /b %errorlevel%

echo === ALL STEPS COMPLETED SUCCESSFULLY ===