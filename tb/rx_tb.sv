`include "tb_config.svh"

module rx_tb;

logic rxIn;
logic clkIn;
logic rdyIn;
logic [`MSG_BIT_LENGTH-1:0] msgIn;
logic [`MSG_BIT_LENGTH-1:0] expMsgIn;

rx rxInstance (
    .clk(clkIn),
    .rx(rxIn),
    .rdy(rdyIn),
    .msgInP(msgIn));

always #1 clkIn = ~clkIn; // gen clk signal
initial begin
    if (`SEE_RX_TEST_OUTPUTS) $monitor("--- ACTUAL MSG BUFFER:   0x%H ---", msgIn); // check msg buffer
        
    rxIn=1; // start idle	
    clkIn=0; 

    sendMsgRndm(
        rxInstance.rxBitNumber,
        expMsgIn,
        rxIn);

    #(`DELAY_TB); // wait until last uart frame before checking buffer

    if (expMsgIn != msgIn) begin
        $display("TEST FAILED");
    end else begin
        $display("TEST PASSED!!");
    end

    $finish;
end
endmodule