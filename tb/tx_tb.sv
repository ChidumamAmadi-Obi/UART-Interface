`include "constants.vh"

module tx_tb;

logic rdyIn;
logic clkIn;
logic txOut;
logic [7:0] msgOut [0:MSG_BUFFER_LENGTH-1]; // store full  msg

tx txInstance(
    .clk(clkIn),
    .rdy(rdyIn),
    .msg(msgOut),
    .tx(txOut));

always #1 clkIn = ~clkIn;
initial begin
	
    $monitor("TX: %d, TX BIT NO: %d MSG BIT NO: %d",
    txOut, 
    txInstance.txBitNumber, 
    txInstance.msgByteNumber);

    clkIn=0;
    rdyIn=0;
    msgOut = '{ default : 0 }; // init buffer with zeros

    msgOut[0] = 8; // load random numbers into msg buffer
    msgOut[3] = 20;

    $display("-- msg: %d %d %d %d %d %d %d %d --",
           msgOut[0],
           msgOut[1],
           msgOut[2],
           msgOut[3],
           msgOut[4],
           msgOut[5],
           msgOut[6],
           msgOut[7]);
           

    #1 rdyIn=1; 
    #1 rdyIn=0;

    #(DELAY_TB*MSG_BUFFER_LENGTH*10) $finish;
    // time needed to send complete message = uart frame * number of bytes in the message * (8 + 2)
end
endmodule
