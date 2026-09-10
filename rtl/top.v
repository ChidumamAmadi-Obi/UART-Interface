`include "constants.vh"

module top (
    input wire clk_i,
    input wire rstn_i,

    input wire sck_i, // spi signals
    input wire mosi_i,  
    input wire csn_i,    
    output wire miso_o,

    input wire rxUart_i, // uart signals
    output wire txUart_o,
    
    input wire echo0_i, // distance sensor signals
    input wire echo1_i,
    input wire echo2_i,
    output wire trig_o);

wire [`MSG_BIT_LENGTH-1:0] msg; // for now the fpga is just gonna echo received msg back to pc
wire msgRdy;

rx_uart rxModule(
    .clk(clk_i),
    .rx(rxUart_i),
    .rdy(msgRdy),
    .msgInP(msg)); // msg received by fpga

tx_uart txModule(
    .clk(clk_i),
    .rdy(msgRdy),
    .tx(txUart_o),
    .msgOutP(msg)); // msg fpga is sending

reg [31:0] spiSlaveOut, spiSlaveIn; // data going in and out of slave module
reg [8:0] spiMasterCmd;
wire [31:0] spiSlaveOut_wire;
wire spiMasterCmdRdy;

wire [21:0] sonarDistanceWire0, sonarDistanceWire1, sonarDistanceWire2; // data coming out of sonar controller
wire [2:0] distRdy; // sonar control rdy signals

spi_slave_top spi_slave_topModule(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .data_i(spiSlaveIn),
    .data_o(spiSlaveOut_wire),
    .rdy_o(spiMasterCmdRdy),
    .sck_i(sck_i),
    .mosi_i(mosi_i),
    .csn_i(csn_i),
    .miso_o(miso_o));
cmd_decoder cmd_decoderModule(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .cmd_i(spiSlaveOut),
    .address_o(spiMasterCmd[7:0]),
    .rw_o(spiMasterCmd[8]) // 1: read, 0: write
);

sonar_control sonar_controlModule(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .en_i(1'b1), // always enabled for now
    .dist0_o(sonarDistanceWire0),
    .dist1_o(sonarDistanceWire1),
    .dist2_o(sonarDistanceWire2),
    .echo0_i(echo0_i),
    .echo1_i(echo1_i),
    .echo2_i(echo2_i),
    .trig_o(trig_o),
    .rdy_o(distRdy));

always @(posedge clk_i or negedge rstn_i or posedge spiMasterCmdRdy) begin 
    if (rstn_i == 1'b0) begin 
        spiSlaveOut = 32'h0;
    end else if (spiMasterCmdRdy) begin 
        spiSlaveOut = spiSlaveOut_wire;
    end
end

// REGISTER FILE 
reg [21:0] sonarReg0, sonarReg1, sonarReg2; // store measured sonar distances

// sensor modules write data to registers
always @(posedge clk_i or negedge rstn_i or posedge distRdy) begin 
    if (rstn_i == 1'b0) begin 
        sonarReg0 <= 22'h0;
        sonarReg1 <= 22'h0;
        sonarReg2 <= 22'h0;
    end
    if (distRdy[0]) sonarReg0 <= sonarDistanceWire0;
    if (distRdy[1]) sonarReg1 <= sonarDistanceWire1;
    if (distRdy[2]) sonarReg2 <= sonarDistanceWire2;
end

// spi module can read data in registers
always @* begin
    if (spiMasterCmd[8]) begin // reading
        case (spiMasterCmd[7:0]) 
            `ADDR_SONAR_DIST_0: spiSlaveIn = sonarReg0;
            `ADDR_SONAR_DIST_1: spiSlaveIn = sonarReg1;
            `ADDR_SONAR_DIST_2: spiSlaveIn = sonarReg2;
            default: spiSlaveIn = 32'h0;
        endcase
    end
end
endmodule