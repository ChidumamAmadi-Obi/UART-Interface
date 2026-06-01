`include "tb_config.svh"

module top_tb;

logic clkIn;
logic rxIn;
logic txOut;

top topInstance (
    .clk(clkIn),
    .rxUart(rxIn),
    .txUart(txOut));

always #1 clkIn = ~clkIn;
initial begin
    $monitor("TX: %d, TX_BIT_NO: %d, MSG_BYTE: %d",
        txOut, 
        topInstance.txModule.txBitNumber,
        topInstance.txModule.msgByteNumber);

    rxIn=1;
    clkIn=0;
    
    // send random stuff
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 0
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 1
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 2
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 3
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 4
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 5
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 6
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 7
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 8
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 9
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 10
    sendUartByte(30, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 11
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 12
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 13
    sendUartByte(0, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 14
    sendUartByte(250, topInstance.rxInstance.rxBitNumber, topInstance.rxInstance.dataIn, rxIn); // 15

    #(`DELAY_TB*200) $finish;
end
endmodule