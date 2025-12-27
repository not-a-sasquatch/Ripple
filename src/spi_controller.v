//----------------------------------------------------------------------------
//                                                                          --
//                            spi_controller.v                              --
//                                                                          --
// Interface to SPI module. Handles custom commands for MP3008 ADC.         --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
`include "src/spi_module.v"

module spi_controller
    (
        input wire clk,                                      // system clk
        input wire rst,                                      // reset
        output wire sclk_o,                                  // SPI clk out
        output wire cs_o,                                    // chip select out
        output wire data_o,                                  // SPI data ouput line
        input wire data_i,                                   // SPI data input line
        output reg [9:0] ch0_word,                           // ch0 data word
        output reg [9:0] ch1_word,                           // ch1 data word 
        output reg valid                                     // data valid signal
    );

localparam cpol = 1'b0;                                      // SPI clock polarity
localparam cpha = 1'b0;                                     // SPI clock phase
localparam spi_word_send_len = 5;                            // number of bits in send word
localparam spi_word_rcv_len = 12;                            // number of bits in receive word
localparam num_word_send = 5'd1;
localparam num_word_rcv = 5'd1;

// SPI clock divider circuitry
reg spi_clk;
reg [15:0] spi_clk_cnt;
localparam spi_period = 16'd100;
always @(posedge clk) begin
    if(rst) begin
        spi_clk <= 0;
        spi_clk_cnt <= 0;
    end else begin
        if(spi_clk_cnt < spi_period) begin
            spi_clk_cnt <= spi_clk_cnt + 16'd1;
        end else begin
            spi_clk <= ~spi_clk;
            spi_clk_cnt <= 0;
        end
    end
end

// SPI sequence controller
reg process_next_word;
/* verilator lint_off UNUSEDSIGNAL */
reg processing_word;
reg processing_transaction;
reg word_done;
/* verilator lint_off UNUSEDSIGNAL */
reg transaction_done;
reg ready;

reg [4:0] spi_status;
localparam delay_1 = 5'd0;
localparam send_1 = 5'd1;
localparam pause_1 = 5'd2;
localparam rcv_1 = 5'd3;
localparam pause_2 = 5'd4;
localparam delay_2 = 5'd5;
localparam send_2 = 5'd6;
localparam pause_3 = 5'd7;
localparam rcv_2 = 5'd8;
localparam finish = 5'd9;

reg [15:0] delay_clk_cnt;
localparam delay_period_1 = 16'd2000;
localparam delay_period_2 = 16'd400;

reg [9:0] ch0_word_sync;
reg [9:0] ch1_word_sync;
always @(posedge clk) begin
    if(rst) begin
        spi_status <= delay_1;
        delay_clk_cnt <= 0;
        valid <= 1'b0;
        ch0_word_sync <= 10'd0;
        ch1_word_sync <= 10'd0;
        process_next_word <= 1'b0;
        data_word_send <= 4'b1000;
    end else begin
        case(spi_status)
            delay_1: begin
                valid <= 1'b0;
                if(delay_clk_cnt < delay_period_1) begin
                    delay_clk_cnt <= delay_clk_cnt + 16'd1;
                end else begin
                    if(ready) begin
                        delay_clk_cnt <= 0;
                        spi_status <= send_1;
                    end
                end
            end
            send_1: begin
                data_word_send <= 5'b00011;
                process_next_word <= 1'b1;
                spi_status <= pause_1;
            end
            pause_1: begin
                process_next_word <= 1'b0;
                if(processing_transaction && ready) begin
                    spi_status <= rcv_1;
                end
            end
            rcv_1: begin
                process_next_word <= 1'b1;
                spi_status <= pause_2;
            end
            pause_2: begin
                process_next_word <= 1'b0;
                if(transaction_done) begin
                    spi_status <= delay_2;
                    //ch0_word <= data_word_rcv[10:1];
                    ch0_word_sync <= data_word_rcv[11:2];
                end
            end
            delay_2: begin
                if(delay_clk_cnt < delay_period_2) begin
                    delay_clk_cnt <= delay_clk_cnt + 16'd1;
                end else begin
                    if(ready) begin
                        delay_clk_cnt <= 0;
                        spi_status <= send_2;
                    end
                end
            end
            send_2: begin
                data_word_send <= 5'b10011;
                process_next_word <= 1'b1;
                spi_status <= pause_3;
            end
            pause_3: begin
                process_next_word <= 1'b0;
                if(processing_transaction && ready) begin
                    spi_status <= rcv_2;
                end
            end
            rcv_2: begin
                process_next_word <= 1'b1;
                spi_status <= finish;
            end
            finish: begin
                process_next_word <= 1'b0;
                if(transaction_done) begin
                    spi_status <= delay_1;
                    //ch1_word <= data_word_rcv[10:1];
                    ch1_word_sync <= data_word_rcv[11:2];
                    valid <= 1'b1;
                end
            end
            default: begin
                spi_status <= delay_1;
            end
        endcase
    end
end

// Reverse bit order
genvar i;
generate
    for (i = 0; i < 10; i = i+1) begin : reverse_bits
        assign ch0_word[i] = ch0_word_sync[9-i];
        assign ch1_word[i] = ch1_word_sync[9-i];
    end
endgenerate


// 
reg [11:0] data_word_rcv;
reg [4:0] data_word_send;// = 4'b1001;


spi_module #(.cpol(cpol), .cpha(cpha), .invert_data_order(1'b0), .spi_controller(1'b1), .spi_word_send_len(spi_word_send_len), .spi_word_rcv_len(spi_word_rcv_len)) spi_ADC
            (
                .clk(clk), .rst(rst), .sclk_o(sclk_o), .sclk_i(spi_clk), .cs_o(cs_o), .cs_i(1'b0), .data_o(data_o),
                .data_i(data_i), .processing_word(processing_word), .process_next_word(process_next_word), .processing_transaction(processing_transaction),
                .data_word_send(data_word_send), .data_word_rcv(data_word_rcv), .num_word_send(num_word_send), .num_word_rcv(num_word_rcv),
                .ready(ready), .word_done(word_done), .transaction_done(transaction_done)
            );

endmodule
