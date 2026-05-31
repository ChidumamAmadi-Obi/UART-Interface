`ifndef TB_CONFIG
`define TB_CONFIG

`include "constants.vh"

// tb macros
`define SEE_RX_TEST_OUTPUTS 1
`define SEE_TX_TEST_OUTPUTS 0
`define SEE_TOP_TEST_OUTPUTS 0

// enums

// TASKS ****************************************************************************************************

task sendUartByte( // send one byte via uart
    input logic [7:0] byteIn,
    input logic [2:0] rxBitNumber,
    ref logic rx);

    #(`DELAY_TB) rx = 0; // start bit
    for (int i=0; i<8; i++) begin // data bits
      #(`DELAY_TB) rx = (byteIn >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
      if (`SEE_RX_TEST_OUTPUTS) $display("SENT: %d, BIT NO: %d...", rx, i);
    end
    #(`DELAY_TB) rx = 1; // stop bit  
    
endtask

task sendMsgRndm( // sends whole msg with random numbers and records expected msg buffer value
    input logic [2:0] bitNo,
    output logic [`MSG_BIT_LENGTH-1:0] expectedMsgBuffer,
    ref logic rx);

    logic [7:0] byteIn=0; // store byte to be sent
    logic [`MSG_BIT_LENGTH-1:0] expectedMsgBuffer = '{ default : 0 };

    for (int i=0; i<`MSG_BUFFER_LENGTH; i++) begin
        byteIn = $urandom_range(255,0); // send random byte
        sendUartByte(byteIn, bitNo, rx);
        expectedMsgBuffer[ 8*i +: 8 ] = byteIn; // record each byte 
    end

    if (`SEE_RX_TEST_OUTPUTS) $display("--- EXPECTED MSG BUFFER: 0x%H ---",
        expectedMsgBuffer);  

endtask

task receiveUartByte(

);
endtask

// functions

`endif
