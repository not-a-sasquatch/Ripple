# Ripple

A envelope generator eurorack module with generates a modified ADSR envelope.


## TO DO


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
