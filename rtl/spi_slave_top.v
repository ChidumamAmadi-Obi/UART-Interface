`include "constants.vh"

/* refs
    https://gist.github.com/nickfox-taterli/fe3713455b0ba55c73b63d45512f2bd9
    https://youtu.be/sHmixFJhr3M?si=WnA5U4PyAfqdaKQL
    https://www.fpga4fun.com/SPI2.html
*/

module spi_slave_top(
    input wire clk,
    input wire rstn,

    input reg [32-1:0] dataOut, // data to be sent out 

    input wire sclk,    // mcu -> fpga (spi clock)
    input wire mosi,    // mcu -> fpga (data input)
    input wire csn,     // mcu -> fpga (chip select) 
    output wire miso);  // mcu <- fpga (data output)

// these are to capture the rising and falling edges of serial clock and chip select, and filter mosi input
reg [2:0] sclkR;
wire sclkPosedge, sclkNegedge;
reg [2:0] csnR;
wire csnActive, csnStart, csnEnd;
reg [1:0] mosiR;
wire mosiD; // mosi data

// store and track data receivec
reg [5-1:0] bitCount;
reg [32-1:0] wordIN;
reg wordReceived;

// handle sending data
reg [32-1:0] wordOUT;
// reg [32-1:0] msgCount;

// filter incomming raw signals
always @(posedge clk) begin 
    sclkR <= {sclkR[1:0], sclk}; // capture and store state of sclk across 2 clk cycles
    csnR  <= {csnR[1:0], csn}; // capture and store state of csn across 2 clk cycles
    mosiR <= {mosiR[0], mosi};
end 
assign sclkPosedge = (sclkR[2:1] == 2'b01);
assign sclkNegedge = (sclkR[2:1] == 2'b10);
assign csnActive   = ~csnR[1];
assign csnStart    = (csnR[2:1] == 2'b10); // msg start at falling edge
assign csnEnd      = (csnR[2:1] == 2'b01); // msg end at pos edge
assign mosiD       = mosiR[1];

always @(posedge clk) begin
    if (~csnActive) bitCount <= '{default:0}; // if chip not selected do nothing
    else if (sclkPosedge) begin // shift the reg
        bitCount <= bitCount + 1'b1; 
        wordIN <= {wordIN[32-2:0], mosiD}; 
    end
end

always @(posedge clk) wordReceived <= csnActive && sclkPosedge && (bitCount == 32); // update byte receied flag
// always @(posedge clk) if (csnStart) msgCount <= msgCount + 1'b1; // count amount of msgs incoming

// transmit 
always @(posedge clk) begin 
    if (csnActive) begin
        if (csnStart) wordOUT <= dataOut; 
        // if (csnStart) wordOUT <= msgCount; 
        else if (sclkNegedge) begin 
            if (bitCount == 3'b000) wordOUT <= '{ default : 0 }; 
            else wordOUT <= {wordOUT[32-2:0], 1'b0}; 
        end
    end
end 
    
assign miso = wordOUT[32-1];

endmodule
