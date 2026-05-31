`ifndef TB_CONFIG
`define TB_CONFIG

`include "constants.vh"

// tb macros
`define SEE_RX_TEST_OUTPUTS 1
`define SEE_TX_TEST_OUTPUTS 0
`define SEE_TOP_TEST_OUTPUTS 0


// enums

// tasks

task sendUartByte(
    input logic [7:0] byteIn,
    input logic [2:0] rxBitNumber,
    input logic [7:0] rxDataIn,
    ref logic rx);

    #(`DELAY_TB) rx = 0; // start bit
    for (int i=0; i<8; i++) begin // data bits
      #(`DELAY_TB) rx = (byteIn >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
      if (SEE_RX_TEST_OUTPUTS) $display("[msg: %d] SENT: %d, BIT NO: %d, DATA IN: %b...",byteIn, rx, rxBitNumber, rxDataIn);
    end
    #(`DELAY_TB) rx = 1; // stop bit  
endtask

task receiveUartByte(

);
endtask

// functions

`endif
