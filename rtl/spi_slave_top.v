`include "constants.vh"

/* refs
    https://gist.github.com/nickfox-taterli/fe3713455b0ba55c73b63d45512f2bd9
    https://youtu.be/sHmixFJhr3M?si=WnA5U4PyAfqdaKQL
*/

module spi_slave_top(
    input wire clk,
    input wire rstn,

    input wire sclk, // mcu -> fpga (spi clock)
    input wire mosi, // mcu -> fpga
    input wire csn, // mcu -> fpga (chip select) 
    output wire miso); // fpga -> mcu

always @(posedge clk or negedge rstn) begin

end
    

endmodule
