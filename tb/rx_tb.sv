`include "tb_config.svh"

module rx_tb;

logic rxIn;
logic clkIn;
logic rdyIn;
logic [`MSG_BIT_LENGTH-1:0] msgIn;
logic [`MSG_BIT_LENGTH-1:0] expMsgIn; // expected msg received

rx_uart rxInstance (
    .clk(clkIn),
    .rx(rxIn),
    .rdy(rdyIn),
    .msgInP(msgIn));

task static rxAutoRndmTest(); // automatically checks tests and gives report
    logic [`NO_OF_RX_TESTS-1:0] failedTests = '{ default : 0 };
    integer noOfFailed=0;
    integer testNo=0;

    for (int i=0; i<`NO_OF_RX_TESTS; i++) begin // checks expected val against actual val
        sendMsgRndm(
            rxInstance.rxBitNumber,
            expMsgIn,
            rxIn);     
         #(`DELAY_FRAMES_TB); // wait until last uart frame before checking buffer
        if (expMsgIn != msgIn) failedTests |= 1 << i; // uses bitmask to track pass/fail of test
    end

    for (int i=0; i<`NO_OF_RX_TESTS; i++) begin  // checks each test to see pass fail
        if (failedTests >> i) begin // if bit is set that means that test failed
            $display("TEST NO: %d FAILED...", i);
            noOfFailed++;
        end
    end
                        $display("==========================");
    if (noOfFailed > 0) $display("=== FAILED %d TESTS(S) ===", noOfFailed); // reports on if tb passed/failed
    else                $display("=== PASSED ALL TESTS!  ===");
                        $display("==========================");
endtask

always #1 clkIn = ~clkIn; // gen clk signal
initial begin
    if (`SEE_RX_TEST_OUTPUTS) $monitor("--- ACTUAL MSG BUFFER:   0x%H ---", msgIn); // check msg buffer
        
    rxIn=1; // start idle	
    clkIn=0; 

    rxAutoRndmTest();

    $finish;
end
endmodule