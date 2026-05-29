`include "constants.vh"

module rx_tb;

logic rxIn;
logic clkIn;
logic rdyIn;
logic [7:0] msgOut [0:MSG_BUFFER_LENGTH-1];
  
rx rxInstance (
    .clk(clkIn),
    .rx(rxIn),
    .rdy(rdyIn),
    .msgOut(msgOut));

task sendUartChar( input [7:0] char );
    #(DELAY_TB) rxIn = 0; // start bit
    
    for (int i=0; i<8; i++) begin // data bits
      #(DELAY_TB) rxIn = (char >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
      $display("[msg: %d] SENT: %d, BIT NO: %d, DATA IN: %b...",char, rxIn, rxInstance.rxBitNumber, rxInstance.dataIn);

    end
    #(DELAY_TB) rxIn = 1; // stop bit

endtask

always #1 clkIn = ~clkIn; // gen clk signal
initial begin
 
  $monitor("--- msg: %d %d %d %d %d %d %d %d ---", // check msg buffer
        msgOut[0],
        msgOut[1],
        msgOut[2],
        msgOut[3],
        msgOut[4],
        msgOut[5],
        msgOut[6],
        msgOut[7]);  
    rxIn=1; // start idle	
    clkIn=0; 
    sendUartChar(8); // send random numbers
    sendUartChar(7);
    sendUartChar(6);
    sendUartChar(5);
    sendUartChar(4);
    sendUartChar(3);
    sendUartChar(2);
    sendUartChar(1);

    #(DELAY_TB) $finish;
end
endmodule