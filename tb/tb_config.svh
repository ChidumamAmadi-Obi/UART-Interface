`ifndef TB_CONFIG
`define TB_CONFIG

`include "constants.vh"

// TB MACROS AND CONSTANTS ****************************************************************************************************
`define SEE_RX_TEST_OUTPUTS 0 // config test logging (test reports are always printed this is for extra detail)
`define SEE_TX_TEST_OUTPUTS 0
`define SEE_TOP_TEST_OUTPUTS 0

`define NO_OF_RX_TESTS 5 // config number of random tests to be done for each module
`define NO_OF_TX_TESTS 5
`define NO_OF_TOP_TESTS 5

`define DELAY_FRAMES_TB (`DELAY_FRAMES*2) // delay in tb to get one uart frame
`define HALF_DELAY_FRAMES_TB `DELAY_FRAMES

// TASKS ****************************************************************************************************

task automatic sendUartByte( // send one byte via uart
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
task automatic sendMsgRndm( // sends whole msg with random numbers and records expected msg buffer value
  input logic [2:0] bitNo,
  output logic [`MSG_BIT_LENGTH-1:0] expectedMsgBuffer,
  ref logic rx);

    static logic [7:0] byteIn=0; // store byte to be sent

    for (int i=0; i<`MSG_BUFFER_LENGTH; i++) begin
        byteIn = $urandom_range(255,0); // send random byte
        sendUartByte(byteIn, bitNo, rx);
        expectedMsgBuffer[ 8*i +: 8 ] = byteIn; // record each byte 
    end

    if (`SEE_RX_TEST_OUTPUTS) $display("--- EXPECTED MSG BUFFER: 0x%H ---",
        expectedMsgBuffer);  
endtask

// *****
task automatic genRndmMsg( // put random bytes in msg buffer
  ref logic [`MSG_BIT_LENGTH-1:0] msg,
  ref logic rdy);

	for (int i=0; i<`MSG_BUFFER_LENGTH; i++) begin
		msg[8*i +: 8] = $urandom_range(255,0);
	end
	
    #1 rdy=1;
    #1 rdy=0;
endtask

task automatic receiveUartByte( 
  ref logic tx,
  ref logic [7:0] receivedByte, 
  ref logic clk );  
	
	// $display("FRAME_NO: [%d]", $time/`DELAY_FRAMES_TB);
    @(negedge tx) begin // this thing misses the first byte of info for some reason
		#(`HALF_DELAY_FRAMES_TB); // wait until after start bit 
		for ( int i=0; i<8; i++) begin
			#(`DELAY_FRAMES_TB);
			receivedByte[i] = tx;// wait until in the middle of data bit 
			// populate byte bit by bit
				
		end
		#(`HALF_DELAY_FRAMES_TB*3); // wait until stop bit finished	
	end
endtask
task automatic receiveUartMsg( // get what message should be and store
  ref logic tx,
  ref logic [`MSG_BIT_LENGTH-1:0] expectedMsgViaTx,
  ref logic clk);

	static logic [7:0] receivedByte=0;

	for (int i=0; i< `MSG_BUFFER_LENGTH; i++) begin
		receiveUartByte(tx, receivedByte, clk); // get byte sent
		expectedMsgViaTx[8*i +: 8] = receivedByte;
	end	
endtask

`endif
