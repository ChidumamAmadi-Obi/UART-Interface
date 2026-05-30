`include "constants.vh"
//`include "tx.v" // add if using testbench
//`include "rx.v"

module top (
    input wire clk,
    input wire rxUart,
    output wire txUart);

wire [`MSG_BIT_LENGTH-1:0] msg; // for now the fpga is just gonna echo received msg back to pc
wire msgRdy;

rx rxModule(
    .clk(clk),
    .rx(rxUart),
    .rdy(msgRdy),
    .msgOutP(msg)); // msg received by fpga

tx txModule(
    .clk(clk),
    .rdy(msgRdy),
    .tx(txUart),
    .msgOutP(msg)); // msg fpga is sending
    
endmodule