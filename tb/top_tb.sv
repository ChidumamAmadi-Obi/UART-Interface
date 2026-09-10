`include "tb_config.svh"

module top_tb;

logic clk, rstn;
logic rxIn, txOut;

logic sck, mosi, miso, csn;
logic [2:0] echo;
logic trig;

top topInstance (
    .clk_i(clk),
    .rstn_i(rstn),

    .sck_i(sck),
    .mosi_i(mosi),
    .csn_i(csn),
    .miso_o(miso),

    .rxUart_i(rxIn),
    .txUart_o(txOut),
    
    .echo0_i(echo[0]),
    .echo1_i(echo[1]),
    .echo2_i(echo[2]),
    .trig_o(trig));

task init;
    clk = 1'b0;
    rstn = 1'b1;
    sck = 1'b0;
    mosi = 1'b0;
    csn = 1'b1;
    rxIn = 1'b1;
    echo = 3'b0;
endtask

task testSonarControl;
    #(`TEN_US*2); 
    #(20); 

    echo[0] = 1'b1;
    #((`RAW_DIST_MAX)*2); 
    echo[0] = 1'b0;

    echo[1] = 1'b1;
    #((`RAW_DIST_MIN)*2);
    echo[1] = 1'b0;   
 
    echo[2] = 1'b1;
    #((`RAW_DIST_MIN+1750)*2);
    echo[2] = 1'b0;

    #(20);
    $display("==================================================");
    $display("RAW DISTANCES IN REG FILE [0x%0h, 0x%0h, 0x%0h]",
    topInstance.sonarReg0,
    topInstance.sonarReg1,
    topInstance.sonarReg2);
    $display("    DISTANCES IN REG FILE [%.1f, %.1f, %.1f]",
    calculateDistance(topInstance.sonarReg0),
    calculateDistance(topInstance.sonarReg1),
    calculateDistance(topInstance.sonarReg2));
endtask

task testSpiSlave;
    logic [31:0] dataOut;

    $display("==================================================");

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_SONAR_DISTANCE0, 24'h000000}); // send cmd to read from sonar reg 0
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_SONAR_DISTANCE0, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H", dataOut);
    csn = 1'b1; 
    #(10);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_SONAR_DISTANCE1, 24'h000000}); // send cmd to read from sonar reg 0
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_SONAR_DISTANCE1, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H", dataOut);
    csn = 1'b1; 
    #(10);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_SONAR_DISTANCE2, 24'h000000}); // send cmd to read from sonar reg 0
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_SONAR_DISTANCE2, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H", dataOut);
    csn = 1'b1;      
    #(10);   
endtask

task testUart;
    $monitor("TX: %d, TX_BIT_NO: %d, MSG_BYTE: %d",
        txOut, 
        topInstance.txModule.txBitNumber,
        topInstance.txModule.msgByteNumber);

    // send random stuff
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 0
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 1
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 2
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 3
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 4
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 5
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 6
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 7
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 8
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 9
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 10
    sendUartByte(30, topInstance.rxModule.rxBitNumber, rxIn); // 11
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 12
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 13
    sendUartByte(0, topInstance.rxModule.rxBitNumber, rxIn); // 14
    sendUartByte(250, topInstance.rxModule.rxBitNumber, rxIn); // 15
    #(`DELAY_FRAMES_TB*200);
endtask

always #1 clk = ~clk;
initial begin
    init;

    testSonarControl; // measure distance once with one trig pulse
    testSpiSlave;
    // testUart;
    
    $finish;
end
endmodule
