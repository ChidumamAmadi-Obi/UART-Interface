`include "tx.v"
`include "rx.v"
`include "constants.vh"

module uart (
    input wire clk,
    input wire rxUart,
    input wire txUart,
);

reg [7:0] msgReceived [0:MESSAGE_BUFFER_LENGTH-1];
reg [7:0] msgToSend [0:MESSAGE_BUFFER_LENGTH-1];

wire msgRdy;

    
endmodule