/* NOTES
 when using verilator, first byte of sent message is missed by task "receiveUartByte"
 this test bench needs to be compiled and run by another compiler from eda playground to work

 only first test gets completed freezes on second test
*/

`include "tb_config.svh"

module tx_tb;

logic rdyIn;
logic clkIn;
logic txOut;
logic [`MSG_BIT_LENGTH-1:0] msgOut; // store full  msg
logic [`MSG_BIT_LENGTH-1:0] expMsgViaTx; // expected message out

tx_uart txInstance(
    .clk(clkIn),
    .rdy(rdyIn),
    .msgOutP(msgOut),
    .tx(txOut));

task static txAutoRndmTest();
    static logic [`NO_OF_TX_TESTS-1:0] failedTests = '{ default : 0 };
    static integer noOfFailed=0;
    static integer testNo=0;

    for (int i=0; i<`NO_OF_TX_TESTS; i++) begin
        genRndmMsg(msgOut, rdyIn); // generate random msg in buffer and keep track of expected msg out
        receiveUartMsg(txOut, expMsgViaTx, clkIn); // receive and piece back together msg
        #10;

        if (`SEE_TX_TEST_OUTPUTS) begin
            $display("=== TEST NO %d ===",i);
            $display("--- SENT MSG:   0x%0H ---",msgOut);
            $display("--- ACTUAL MSG: 0x%0H ---",expMsgViaTx);             
        end

        if (msgOut != expMsgViaTx) failedTests |= 1 << i;
    end

    for (int i=0; i<`NO_OF_TX_TESTS; i++) begin  // checks each test to see pass fail
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

always #1 clkIn = ~clkIn;
initial begin
    clkIn=0;
    rdyIn=0;
    msgOut = '{ default : 0 }; // init buffer with zeros
    expMsgViaTx = '{ default : 0 };

    txAutoRndmTest();

    $finish;
end
endmodule
