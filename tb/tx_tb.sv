`include "constants.vh"

module tx_tb;

logic rdyIn;
logic clkIn;
logic txOut;
logic [`MSG_BIT_LENGTH-1:0] msgOut; // store full  msg
logic [`MSG_BIT_LENGTH-1:0] expMsg; // expected message out

tx txInstance(
    .clk(clkIn),
    .rdy(rdyIn),
    .msgOutP(msgOut),
    .tx(txOut));

task txAutoRndmTest();
    
endtask 

always #1 clkIn = ~clkIn;
initial begin
	
    $monitor("TX: %d, TX BIT NO: %d MSG BIT NO: %d",
        txOut, 
        txInstance.txBitNumber, 
        txInstance.msgByteNumber);

    clkIn=0;
    rdyIn=0;
    msgOut = '{ default : 0 }; // init buffer with zeros

    genRndmMsg(msgOut, rdyIn); // generate random msg in buffer

    #(`DELAY_FRAMES_TB*`MSG_BUFFER_LENGTH*10) $finish;
    // time needed to send complete message = uart frame * number of bytes in the message * (8 + 2)
end
endmodule
