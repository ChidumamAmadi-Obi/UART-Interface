`include "tx.v"
`include "rx.v"
`include "constants.vh"

module uart (
    input wire clk,
    input wire rxUart,
    input wire txUart,
);

reg [7:0] msg [0:MSG_BUFFER_LENGTH-1]; // for now the fpga is just gonna echo received msg back to pc
wire msgRdy;

rx rxModule(
    .clk(clk),
    .rx(rxUart),
    .rdy(msgRdy),
    .msgOut(msg)); // msg received by fpga

tx txModule(
    .clk(clk),
    .rdy(msgRdy),
    .tx(txUart),
    .msg(msg)); // msg fpga is sending
    
endmodule