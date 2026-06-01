`ifndef TB_CONFIG
`define TB_CONFIG

`include "constants.vh"

// TB MACROS ****************************************************************************************************
`define SEE_RX_TEST_OUTPUTS 0 // config test logging (test reports are always printed this is for extra detail)
`define SEE_TX_TEST_OUTPUTS 0
`define SEE_TOP_TEST_OUTPUTS 0

`define NO_OF_RX_TESTS 5 // config number of random tests to be done for each module
`define NO_OF_TX_TESTS 5

`define DELAY_FRAMES_TB `DELAY_FRAMES*2 // delay in tb to get one uart frame
`define HALF_DELAY_FRAMES_TB `DELAY_FRAMES


// TASKS ****************************************************************************************************
task waitFrames(input integer frames);
	repeat (frames) begin
		@(posedge clk);
	end
endtask

task sendUartByte( // send one byte via uart
  input logic [7:0] byteIn,
  input logic [2:0] rxBitNumber,
  ref logic rx);

    #(`DELAY_FRAMES_TB) rx = 0; // start bit
    for (int i=0; i<8; i++) begin // data bits
		#(`DELAY_FRAMES_TB) rx = (byteIn >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
		if (`SEE_RX_TEST_OUTPUTS) $display("SENT: %d, BIT NO: %d...", rx, i);
    end
    #(`DELAY_FRAMES_TB) rx = 1; // stop bit  
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

task genRndmMsg( // put random bytes in msg buffer
  ref logic [`MSG_BIT_LENGTH-1:0] msg
  ref logic rdy);

    msg = $urandom_range($pow(2,`MSG_BIT_LENGTH),0);
    #1 rdy=1;
    #1 rdy=0;
endtask
task receiveUartByte( input logic rx );  
  logic [7:0] receivedByte=0; // start counting at first bit
    if ( rx == 0 ) begin
		waitFrames(`DELAY_FRAMES_TB); // wait until after start bit 
		for ( int i=0; i<8; i++) begin
			waitFrames(`HALF_DELAY_FRAMES_TB); // wait until in the middle of data bit to read it
			receivedByte[i] = rx; // populate byte bit by bit
		end
		wait(`DELAY_FRAMES_TB); // wait until stop bit finished
    end
endtask
task receiveUartMsg(

);
endtask

`endif
