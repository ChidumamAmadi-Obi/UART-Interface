`include "constants.vh"

module top (
    input wire clk,
    input wire rxUart,
    output wire txUart);

wire [7:0] msgOut [0:`MSG_BUFFER_LENGTH-1]; // for now the fpga is just gonna echo received msg back to pc
wire msgRdy;

rx rxModule(
    .clk(clk),
    .rx(rxUart),
    .rdy(msgRdy),
    .msgOut(msgOut)); // msg received by fpga

tx txModule(
    .clk(clk),
    .rdy(msgRdy),
    .tx(txUart),
    .msgOut(msgOut)); // msg fpga is sending
    
endmodule