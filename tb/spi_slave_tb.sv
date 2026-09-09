`include "tb_config.svh"

module spi_slave_tb;

logic [31:0] data_in, data_out, expectedData_in, expectedData_out;
logic clk,rstn,sck,mosi,miso,csn,rdy;

spi_slave_top spi_slave_topInstance(
    .clk_i(clk),
    .rstn_i(rstn),
    .data_i(data_in),
    .data_o(data_out),
    .rdy_o(rdy),
    .sck_i(sck),
    .mosi_i(mosi),
    .csn_i(csn),
    .miso_o(miso));

always #1 clk = ~clk;
always @(posedge rdy) begin 
    expectedData_out = data_out;
end

initial begin 
    clk = 1'b0;
    rstn = 1'b1;
    sck = 1'b0;
    mosi = 1'b0;
    csn = 1'b1;
    data_in = 32'b0;


    csn = 1'b0; // csn active
    
    mcuSend32(mosi, sck, {24'h000000, 8'h12});
    $display("MCU SENT: 0x%h, FPGA RECEIVED: 0x%h, OUT 0x%h", 8'h12, spi_slave_topInstance.wordIN, expectedData_out);
    mcuSend32(mosi, sck, 32'hDEADBEEF);
    $display("MCU SENT: 0x%h, FPGA RECEIVED: 0x%h", 32'hDEADBEEF, spi_slave_topInstance.wordIN);

    csn = 1'b1; // csn inactive

    #(10);
    
    csn = 1'b0;

    data_in = 32'h12345678; // send data to transmit to mcu
    mcuReceive32(miso, mosi, sck, expectedData_in);
    $display("FPGA SENT: 0x%h, MCU RECEIVED: 0x%h", 32'h12345678, expectedData_in);

    csn = 1'b1;
    
    #(10);
    $finish;
end

endmodule