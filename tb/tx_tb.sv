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
    
endtask 

always #1 clkIn = ~clkIn;
initial begin
    clkIn=0;
    rdyIn=0;
    msgOut = '{ default : 0 }; // init buffer with zeros
    expMsgViaTx = '{ default : 0 };

    fork
        genRndmMsg(msgOut, rdyIn); // generate random msg in buffer
        receiveUartMsg(txOut, expMsgViaTx, clkIn);              
    join

    $display("--- SENT MSG:   0x%0H ---",msgOut);
    $display("--- ACTUAL MSG: 0x%0H ---",expMsgViaTx);

    #(`DELAY_FRAMES_TB*`MSG_BUFFER_LENGTH*10) $finish;
    // time needed to send complete message = uart frame * number of bytes in the message * (8 + 2)
end
endmodule
