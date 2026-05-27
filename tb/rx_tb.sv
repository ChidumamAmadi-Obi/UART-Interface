`include "constants.vh"

module rx_tb;

logic rx_in;
logic clk_in;
logic [7:0] message_out [0:MESSAGE_BUFFER_LENGTH-1];
integer charBit;
  
always #1 clk_in = ~clk_in;

rx rxInstance (
    .clk(clk_in),
    .rx(rx_in),
    .message(message_out));

task sendUartChar( input [7:0] char );
    $display("-");
  	charBit=0;
  	
    #10 rx_in = 0; // start bit
    for (int i=0; i<8; i++) begin // data bits
      #16 rx_in = (char >> charBit) & 1; //
      charBit++;
      $display("%d",rx_in);
    end
    
    #16 rx_in = 1; // stop bit
    $display("-");
endtask


initial begin
    rx_in=1; // start idle	

    sendUartChar(8); // send random numbers
  	sendUartChar(7);
  	sendUartChar(6);
  	sendUartChar(5);

    $display("--- MESSAGE: %d %d %d %d %d %d %d %d", 
    message_out[0],
    message_out[1],
    message_out[2],
    message_out[3],
    message_out[4],
    message_out[5],
    message_out[6],
    message_out[7]);

    #1000 $finish;
end

endmodule