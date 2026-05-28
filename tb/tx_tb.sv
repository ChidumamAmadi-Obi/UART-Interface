`include "constants.vh"

module tx_tb;

tx txInstance(

);

always #1 clk_in = ~clk_in;
initial begin
end
endmodule