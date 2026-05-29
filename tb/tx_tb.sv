`include "constants.vh"

module tx_tb;

logic rdyIn;
logic clkIn;
logic txOut;
logic [7:0] messageOut [0:MESSAGE_BUFFER_LENGTH-1]; // store full  message

tx txInstance(
    .clk(clkIn),
    .rdy(rdyIn),
    .message(messageOut),
    .tx(txOut));

always #1 clkIn = ~clkIn;
initial begin
	
    $monitor("TX: %d, TX BIT NO: %d MSG BIT NO: %d",
    txOut, 
    txInstance.txBitNumber, 
    txInstance.messageByteNumber);

    clkIn=0;
    rdyIn=0;
    messageOut = '{ default : 0 }; // init buffer with zeros

    messageOut[0] = 8; // load random numbers into message buffer
    messageOut[3] = 20;

    $display("-- MESSAGE: %d %d %d %d %d %d %d %d --",
           messageOut[0],
           messageOut[1],
           messageOut[2],
           messageOut[3],
           messageOut[4],
           messageOut[5],
           messageOut[6],
           messageOut[7]);
           

    #1 rdyIn=1; 
    #1 rdyIn=0;

    #(DELAY_TB*MESSAGE_BUFFER_LENGTH*10) $finish;
end
endmodule
