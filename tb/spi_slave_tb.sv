`include "tb_config.svh"

module spi_slave_tb;

logic [31:0] data_in, data_out, expectedData_in, expectedData_out;
logic clk,rstn,sck,mosi,miso,csn;

task spiToggleSck;
ref logic sck;
    sck = 1'b0; // start on negedge
    #(SPI_CLK_PERIOD/2);
    sck = 1'b1;
    #(SPI_CLK_PERIOD/2);
endtask

task mcuSend32; // fpga receives from mcu
ref logic mosi;
input logic [31:0] data;
    for (int i=31; i>=0; i--) begin
        mosi = data[i]; spiToggleSck(sck);
    end
endtask
task mcuSend8; // fpga receives from mcu
ref logic mosi;
input logic [7:0] data;
    for (int i=7; i>=0; i--) begin
        mosi = data[i]; spiToggleSck(sck);
    end
endtask

task mcuReceive32;
ref logic miso;
ref logic mosi;
ref logic sck;
output logic [31:0] data;
    for (int i=31; i>=0; i--) begin 
        mosi = 1'b0; 
        sck = 1'b0; #(SPI_CLK_PERIOD);

        data[i] = miso; 
        sck = 1'b1; #(SPI_CLK_PERIOD);
    end
endtask
task mcuReceive8;
ref logic miso;
ref logic mosi;
ref logic sck;
output logic [7:0] data;
    for (int i=7; i>=0; i--) begin 
        mosi = 1'b0; 
        sck = 1'b0; #(SPI_CLK_PERIOD);

        data[i] = miso; 
        sck = 1'b1; #(SPI_CLK_PERIOD);
    end
endtask


spi_slave_top spi_slave_topInstance(
    .clk_i(clk),
    .rstn_i(rstn),
    .data_i(data_in),
    .data_o(data_out),
    .sck_i(sck),
    .mosi_i(mosi),
    .csn_i(csn),
    .miso_o(miso));

always #1 clk = ~clk;

initial begin 
    clk = 1'b0;
    rstn = 1'b1;
    sck = 1'b0;
    mosi = 1'b0;
    csn = 1'b1;
    data_in = 32'b0;


    csn = 1'b0; // csn active
    
    mcuSend8(mosi, 8'h12);
    $display("MCU SENT: 0x%h, FPGA RECEIVED: 0x%h", 8'h12, spi_slave_topInstance.wordIN);
    mcuSend32(mosi, 32'hDEADBEEF);
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