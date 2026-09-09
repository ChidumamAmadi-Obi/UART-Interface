module top (
    input wire clk_i,
    input wire rstn_i,

    input wire sck_i, // spi signals
    input wire mosi_i,  
    input wire csn_i,    
    output wire miso_o,

    input wire rxUart_i, // uart signals
    output wire txUart_o,
    
    input wire echo0_i, // distance sensor signals
    input wire echo1_i,
    input wire echo2_i,
    output wire trig_o);

`include "constants.vh"

wire [`MSG_BIT_LENGTH-1:0] msg; // for now the fpga is just gonna echo received msg back to pc
wire msgRdy;

rx_uart rxModule(
    .clk(clk_i),
    .rx(rxUart_i),
    .rdy(msgRdy),
    .msgInP(msg)); // msg received by fpga

tx_uart txModule(
    .clk(clk_i),
    .rdy(msgRdy),
    .tx(txUart_o),
    .msgOutP(msg)); // msg fpga is sending

reg [31:0] spi_slave_data_out, spi_slave_data_in; // data going in and out of slave module
reg [21:0] distanceReg0, distanceReg1, distanceReg2; // data coming out of sonar controller
wire [2:0] distRdy; // sonar control rdy signals

spi_slave_top spi_slave_topModule(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .data_i(spi_slave_data_in),
    .data_o(spi_slave_data_out),
    .sck_i(sck_i),
    .mosi_i(mosi_i),
    .csn_i(csn_i),
    .miso_o(miso_o));

sonar_control sonar_controlModule(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .en_i(1'b1), // always enabled for now
    .dist0_o(distance0),
    .dist1_o(distance1),
    .dist2_o(distance2),
    .echo0_i(echo0_i),
    .echo1_i(echo1_i),
    .echo2_i(echo2_i),
    .trig_o(trig_o),
    .rdy_o(distRdy));


// REGISTER FILE 


endmodule