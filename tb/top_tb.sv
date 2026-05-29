`include "constants.vh"

module top_tb;

logic clkIn;
logic rxIn;
logic txOut;

top topInstance (
    .clk(clkIn),
    .rxUart(rxIn),
    .txUart(txOut));

task sendUartChar( input [7:0] char );
    #(DELAY_TB) rxIn = 0; // start bit
    
    for (int i=0; i<8; i++) begin // data bits
      #(DELAY_TB) rxIn = (char >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
    end
    
    #(DELAY_TB) rxIn = 1; // stop bit
endtask

always #1 clkIn = ~clkIn;
initial begin
  $monitor("TX: %d, TX_BIT_NO: %d, MSG_BYTE: %d",
        txOut, 
        topInstance.txModule.txBitNumber,
        topInstance.txModule.msgByteNumber);

    rxIn=1;
    clkIn=0;

    sendUartChar(0); // 0
    sendUartChar(0); // 1
    sendUartChar(0); // 2
    sendUartChar(0); // 3
    sendUartChar(0); // 4
    sendUartChar(0); // 5
    sendUartChar(0); // 6
    sendUartChar(0); // 7
    sendUartChar(0); // 8
    sendUartChar(0); // 9
    sendUartChar(0); // 10
    sendUartChar(30); // 11
    sendUartChar(0); // 12
    sendUartChar(0); // 13
    sendUartChar(0); // 14
    sendUartChar(255); // 15

  #(DELAY_TB*200) $finish;
end
endmodule