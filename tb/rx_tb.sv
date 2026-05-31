`include "tb_config.svh"

module rx_tb;

logic rxIn;
logic clkIn;
logic rdyIn;
logic [`MSG_BIT_LENGTH-1:0] msgIn;
  
rx rxInstance (
    .clk(clkIn),
    .rx(rxIn),
    .rdy(rdyIn),
    .msgInP(msgIn));

always #1 clkIn = ~clkIn; // gen clk signal
initial begin
 
  $monitor("--- MSG BUFFER: %b ---", // check msg buffer
        msgIn);  
    rxIn=1; // start idle	
    clkIn=0; 
    sendUartByte(8, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn); // send random numbers
    sendUartByte(7, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);
    sendUartByte(6, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);
    sendUartByte(5, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);
    sendUartByte(4, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);
    sendUartByte(3, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);
    sendUartByte(2, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);
    sendUartByte(1, rxInstance.rxBitNumber, rxInstance.dataIn, rxIn);

    #(`DELAY_TB) $finish;
end
endmodule