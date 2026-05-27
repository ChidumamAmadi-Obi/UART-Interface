`include "tb_functions.svh"

module rx_tb;

logic rx_in;
logic clk_in;
logic [] message_out;

rx rxInstance (
    .clk(clk_in),
    .rx(rx_in),
    .message(message_out));

    initial begin
        
    end

endmodule