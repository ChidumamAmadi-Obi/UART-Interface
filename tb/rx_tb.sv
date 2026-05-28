`include "constants.vh"

module rx_tb;

logic rx_in;
logic clk_in;
logic [7:0] message_out [0:MESSAGE_BUFFER_LENGTH-1];
  
rx rxInstance (
    .clk(clk_in),
    .rx(rx_in),
    .message(message_out));

task sendUartChar( input [7:0] char );
    $display("-");
  	
    #(DELAY_TB) rx_in = 0; // start bit
    
    for (int i=0; i<8; i++) begin // data bits
      #(DELAY_TB) rx_in = (char >> i) & 1; // send each bit thats set in the byte (eg 5 -> 00000101)
      $display("[MESSAGE: %d] SENT: %d, BIT NO: %d, DATA IN: %b...",char, rx_in, rxInstance.rxBitNumber, rxInstance.dataIn);

    end
    
    #(DELAY_TB) rx_in = 1; // stop bit
    $display("-");
endtask

always #1 clk_in = ~clk_in; // gen clk signal
initial begin
 
  $monitor("--- MESSAGE: %d %d %d %d %d %d %d %d ---", // check message buffer
        message_out[0],
        message_out[1],
        message_out[2],
        message_out[3],
        message_out[4],
        message_out[5],
        message_out[6],
        message_out[7]);  
    rx_in=1; // start idle	
    clk_in=0; 
    sendUartChar(8); // send random numbers
    sendUartChar(7);
    sendUartChar(6);
    sendUartChar(5);
    sendUartChar(4);
    sendUartChar(3);
    sendUartChar(2);
    sendUartChar(1);

    #(DELAY_TB) $finish;
end
endmodule