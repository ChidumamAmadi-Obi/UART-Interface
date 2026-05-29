`include "constants.vh"

module rx_tb;

logic rxIn;
logic clkIn;
logic [7:0] messageOut [0:MESSAGE_BUFFER_LENGTH-1];
  
rx rxInstance (
    .clk(clkIn),
    .rx(rxIn),
    .message(messageOut));

task sendUartChar( input [7:0] char );
    #(DELAY_TB) rxIn = 0; // start bit
    
    for (int i=0; i<8; i++) begin // data bits
      #(DELAY_TB) rxIn = (char >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
      $display("[MESSAGE: %d] SENT: %d, BIT NO: %d, DATA IN: %b...",char, rxIn, rxInstance.rxBitNumber, rxInstance.dataIn);

    end
    #(DELAY_TB) rxIn = 1; // stop bit

endtask

always #1 clkIn = ~clkIn; // gen clk signal
initial begin
 
  $monitor("--- MESSAGE: %d %d %d %d %d %d %d %d ---", // check message buffer
        messageOut[0],
        messageOut[1],
        messageOut[2],
        messageOut[3],
        messageOut[4],
        messageOut[5],
        messageOut[6],
        messageOut[7]);  
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