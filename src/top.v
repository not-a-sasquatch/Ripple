//----------------------------------------------------------------------------
//                                                                          --
//                                 top.v                                    --
//                                                                          --
// Description TBD                                                          --
// Author: Connie S.                                                        --
//                                                                          --
//----------------------------------------------------------------------------
`include "src/spi_controller.v"

module top (
  // left side gpios
  output wire gpio_23,
  output wire gpio_25,
  output wire gpio_26,
  output wire gpio_27,
  output wire gpio_32,
  output wire gpio_35,
  output wire gpio_31,
  output wire gpio_37,
  output wire gpio_34,
  output wire gpio_43,
  output wire gpio_36,
  output wire gpio_42,
  output wire gpio_38,
  output wire gpio_28,
  // right side gpios
  output wire gpio_20,
  output wire gpio_10,
  output wire gpio_12,
  output wire gpio_21,
  output wire gpio_13,
  output wire gpio_19,
  output wire gpio_18,
  output wire gpio_11,
  output wire gpio_9,
  output wire gpio_6,
  output wire gpio_44,
  output wire gpio_4,
  output wire gpio_3,
  output wire gpio_48,
  input wire gpio_45,
  output wire gpio_47,
  input wire gpio_46,
  input wire gpio_2,
  // LEDs
  output wire led_red,
  output wire led_blue,
  output wire led_green
);

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillator                                --
//                                                                          --
//----------------------------------------------------------------------------
wire int_osc; // 12 MHz

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

// 0b00 = 48 MHz, 0b01 = 24 MHz, 0b10 = 12 MHz, 0b11 = 6 MHz
defparam u_SB_HFOSC.CLKHF_DIV = "0b11";

//----------------------------------------------------------------------------
//                                                                          --
//                       SPI controllers                                    --
//                                                                          --
//----------------------------------------------------------------------------
reg spi_clkA;
reg copiA;
wire pociA;
reg csA;

reg spi_clkB;
reg copiB;
wire pociB;
reg csB;

reg [9:0] chA0_word;
reg [9:0] chA1_word;
reg [9:0] chA2_word;

reg [9:0] chB0_word;
reg [9:0] chB1_word;
reg [9:0] chB2_word;

reg validA;
reg validB;

spi_controller spi_ADC_A
    (
        .clk(int_osc),              // system clk
        .rst(1'b0),                 // reset
        .sclk_o(spi_clkA),           // SPI clk out
        .cs_o(csA),                  // chip select out
        .data_o(copiA),              // SPI data ouput line
        .data_i(pociA),              // SPI data input line
        .ch0_word(chA0_word),        // ch0 data word
        .ch1_word(chA1_word),        // ch1 data word 
        .ch1_word(chA2_word),        // ch1 data word
        .valid(validA)               // data valid signal
    );

    spi_controller spi_ADC_B
    (
        .clk(int_osc),              // system clk
        .rst(1'b0),                 // reset
        .sclk_o(spi_clkB),           // SPI clk out
        .cs_o(csB),                  // chip select out
        .data_o(copiB),              // SPI data ouput line
        .data_i(pociB),              // SPI data input line
        .ch0_word(chB0_word),        // ch0 data word
        .ch1_word(chB1_word),        // ch1 data word 
        .ch1_word(chB2_word),        // ch1 data word
        .valid(validB)               // data valid signal
    );


//----------------------------------------------------------------------------
//                                                                          --
//                       LEDs                                               --
//                                                                          --
//----------------------------------------------------------------------------
SB_RGBA_DRV RGB_DRIVER(
  .RGBLEDEN(1'b1),
  .RGB0PWM(1'b1),
  .RGB1PWM(1'b1),
  .RGB2PWM(1'b1),
  .CURREN(1'b1),
  .RGB0(led_blue),
  .RGB1(led_red),
  .RGB2(led_green)
);
defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule
