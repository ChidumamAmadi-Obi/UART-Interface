`include "constants.vh"

module tx_tb;

logic messageRdyIn;
logic [7:0] messageOut [0:MESSAGE_BUFFER_LENGTH-1];
logic clkIn;
logic txOut;

tx txInstance(
    .clk(clkIn),
    .messageRdy(messageRdyIn),
    .message(messageOut),
    .tx(txOut));

task receiveUartMessage( input tx );

endtask

always #1 clkIn = ~clkIn;
initial begin
    clkIn=0;
    messageRdyIn=0;
    messageOut[8] = '{ default : 0 };

end
endmodule