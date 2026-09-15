`include "tb_config.svh"

module top_tb;

logic clk, rstn;
logic rxIn, txOut;

logic sck, mosi, miso, csn;
logic [2:0] echo;
logic trig;

int echoPulseLen;

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
    echoPulseLen = `RAW_DIST_MIN;
    clk = 1'b0;
    rstn = 1'b1;
    sck = 1'b0;
    mosi = 1'b0;
    csn = 1'b1;
    rxIn = 1'b1;
    echo = 3'b0;
endtask

task testSonarControl;
input int echoTime0;
input int echoTime1;
input int echoTime2;
    #(20); 
    echo[0] = 1'b1;
    #(echoTime0*2); 
    echo[0] = 1'b0;

    echo[1] = 1'b1;
    #(echoTime1*2);
    echo[1] = 1'b0;   
 
    echo[2] = 1'b1;
    #(echoTime2*2);
    echo[2] = 1'b0;
    #(20);

    $display("'topInstance.sonar_controlModule' MEASURED DISTANCE AT %.1fns", $realtime);
    /*
    $display("==================================================");
    $display("RAW DISTANCES IN REG FILE [0x%0h, 0x%0h, 0x%0h] %.1fns",
        topInstance.sonarReg0,
        topInstance.sonarReg1,
        topInstance.sonarReg2,
        $realtime);
    $display("    DISTANCES IN REG FILE [%.1f, %.1f, %.1f] %.1fns",
        calculateDistance(topInstance.sonarReg0),
        calculateDistance(topInstance.sonarReg1),
        calculateDistance(topInstance.sonarReg2), 
        $realtime);    
    */
endtask

task testSPIReadSonarRegisters;
static logic [31:0] dataOut = 0;
    $display("==================================================");
    #(10);
    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_SONAR_DISTANCE0, 24'h000000}); // send cmd to read from sonar reg 0
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_SONAR_DISTANCE0, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H %.1fns", dataOut, $realtime);
    csn = 1'b1; 
    #(10);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_SONAR_DISTANCE1, 24'h000000}); // send cmd to read from sonar reg 0
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_SONAR_DISTANCE1, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H %.1fns", dataOut, $realtime);
    csn = 1'b1; 
    #(10);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_SONAR_DISTANCE2, 24'h000000}); // send cmd to read from sonar reg 0
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_SONAR_DISTANCE2, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H %.1fns", dataOut, $realtime);
    csn = 1'b1;      
    #(10);   
    $display("==================================================");
endtask
task testSPISlave;
static logic [31:0] dataOut = 0;

    $display("==================================================");
    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_TEST_REG, 24'h000000}); // send cmd to test reg
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_TEST_REG, 24'h000000});
    csn = 1'b1;
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H %.1fns", dataOut, $realtime);
    csn = 1'b1; 

    #(100);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_STATUS_REG, 24'h000000}); // send cmd to read from status reg
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_STATUS_REG, 24'h000000});
    csn = 1'b1;    
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H %.1fns", dataOut, $realtime);
    csn = 1'b1; 
    #(10);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_WRITE_STATUS_REG, 8'h00 , 16'hB00B});
    $display("MCU SENT CMD: 0x%h",{`CMD_WRITE_STATUS_REG, 8'h00, 16'hB00B});
    csn = 1'b1;    
    #(10);

    csn = 1'b0;
    mcuSend32(mosi, sck, {`CMD_READ_STATUS_REG, 24'h000000});
    $display("MCU SENT CMD: 0x%h",{`CMD_READ_STATUS_REG, 24'h000000});
    csn = 1'b1;    
    #(10);
    csn = 1'b0;
    mcuReceive32(miso, mosi, sck, dataOut);
    $display("MCU RECEIVED: 0x%H %.1fns", dataOut, $realtime);
    csn = 1'b1;      
    $display("==================================================");
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
always @(negedge topInstance.trig_o) begin 
    echoPulseLen+=100;
    testSonarControl(echoPulseLen+100, echoPulseLen+200, echoPulseLen+300);
end
always #1 clk = ~clk;
initial begin
    init;   

    #(`TRIG_INTERVAL*2); //  test reading from sonar registers
    testSPIReadSonarRegisters;
    #(`TRIG_INTERVAL*2);
    testSPIReadSonarRegisters;
    #(`TRIG_INTERVAL*2);
    testSPIReadSonarRegisters;

    testSPISlave; //  test reading and writing from status and test registers

    // testUart;
    
    $finish;
end
endmodule
