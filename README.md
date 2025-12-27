# Timekeeper

A clock generator eurorack module based on the Upduino open source FPGA development board (FPGA: Lattic UltraPlus ICE40UP5K)

Logic outputs are clock square-waves with frequencies x1, x2, x3, x4, x5, x8, x16, /2, /3, /4, /5, /8, /16 a master signal. The master frequency and duty cycle of the signals are 
controlled by potentiometers read by a 10-bit ADC. A switch changes the master frequency control between the potentiometer and an input logic signal.

## TO DO
Tune adc period/duty offset & scale factors

Could improve div line synchronization by using a different method to track periods & duty cycle. For mul_x, generate a list of length 2*x, where for even number indices i, the
value is i/2 * div_x_period, and for odd indices the value is i/2 * div_x_period + div_x_duty, and compare the value of div_x_counter to the values in the array to control the 
output div_x. Keep the sync logic with div_x_reps.


## Build instruction

Yosys: open source synthesis tool for Verilog code
Nextpnr: open source place & route tool
IceStorm: open source bitsream generation tool targeting iCE40 FPGAs

Build & programming instructions
    make
    iceprog build/top.bin

## Simulation instructions

SPI module testbench:
    verilator -cc tb/spi_module_tb.v
    verilator -Wall --trace -cc tb/spi_module_tb.v --exe tb/tb_spi.cpp
    make -C obj_dir -f Vspi_module_tb.mk Vspi_module_tb
    ./obj_dir/Vspi_module_tb
    gtkwave waveform.vcd

SPI controller testbench:
    verilator -cc tb/spi_controller_tb.v
    verilator -Wall --trace -cc tb/spi_controller_tb.v --exe tb/tb_spi_controller.cpp
    make -C obj_dir -f Vspi_controller_tb.mk Vspi_controller_tb
    ./obj_dir/Vspi_controller_tb
    gtkwave waveform.vcd

Clock divider testbench:
    verilator -cc tb/clk_div_tb.v
    verilator -Wall --trace -cc tb/clk_div_tb.v --exe tb/tb_div.cpp
    make -C obj_dir -f Vclk_div_tb.mk Vclk_div_tb
    ./obj_dir/Vclk_div_tb
    gtkwave waveform.vcd

## Documentation

UPduino documentation:
https://upduino.readthedocs.io/en/latest/index.html

UPduino v3 github:
https://github.com/tinyvision-ai-inc/UPduino-v3.0

Yosys github:
https://github.com/YosysHQ/yosys

NextPNR github:

https://github.com/YosysHQ/nextpnr

Verilator documentation:
https://verilator.org/guide/latest/overview.html

GTKWave page:
https://gtkwave.sourceforge.net/

UPduino page:
https://tinyvision.ai/products/fpga-development-board-upduino-v3-1
