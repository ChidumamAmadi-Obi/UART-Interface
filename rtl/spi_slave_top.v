`include "constants.vh"

/* refs
    https://gist.github.com/nickfox-taterli/fe3713455b0ba55c73b63d45512f2bd9
    https://youtu.be/sHmixFJhr3M?si=WnA5U4PyAfqdaKQL
    https://www.fpga4fun.com/SPI2.html
*/

module spi_slave_top(
    input wire clk_i,
    input wire rstn_i,

    input wire [31:0] data_i, // data to be sent out 

    input wire sck_i,    // mcu -> fpga (spi clock)
    input wire mosi_i,    // mcu -> fpga (data input)
    input wire csn_i,     // mcu -> fpga (chip select) 
    output wire miso_o);  // mcu <- fpga (data output)

// these are to capture the rising and falling edges of serial clock and chip select, and filter mosi input
reg [2:0] sckR;
wire sckPosedge, sckNegedge;
reg [2:0] csnR;
wire csnActive, csnStart, csnEnd;
reg [1:0] mosiR;
wire mosiD; // mosi data

// store and track data receivec
reg [4:0] bitCount;
reg [31:0] wordIN;
reg wordReceived;

// handle sending data
reg [31:0] wordOUT;
// reg [32-1:0] msgCount;

always @(posedge clk_i or negedge rstn_i) begin 
    if (rstn_i == 1'b0) begin
        sckR        <= 0;
        csnR         <= 0;
        mosiR        <= 0;
        bitCount     <= 0;
        wordIN       <= 0;
        wordOUT      <= 0;
        wordReceived <= 0;
        // msgCount  <= 0;     


    end else begin // filter incomming raw signals
        sckR <= {sckR[1:0], sck_i}; // capture and store state of sck across 2 clk cycles
        csnR  <= {csnR[1:0], csn_i}; // capture and store state of csn across 2 clk cycles
        mosiR <= {mosiR[0], mosi_i};
        
        if (~csnActive) bitCount <= 5'b0; // if chip not selected do nothing
        else if (sckPosedge) begin // shift the reg
            bitCount <= bitCount + 1'b1; 
            wordIN <= {wordIN[30:0], mosiD}; 
        end    

        wordReceived <= csnActive && sckPosedge && (bitCount == 32); // update byte receied flag
        // always @(posedge clk) if (csnStart) msgCount <= msgCount + 1'b1; // count amount of msgs incoming

        if (csnActive) begin // transmit 
            if (csnStart) wordOUT <= data_i; 
            // if (csnStart) wordOUT <= msgCount; 
            else if (sckNegedge) begin 
                if (bitCount == 3'b000) wordOUT <= 32'b0; 
                else wordOUT <= {wordOUT[30:0], 1'b0}; 
            end
        end
    end
end 

assign sckPosedge = (sckR[2:1] == 2'b01);
assign sckNegedge = (sckR[2:1] == 2'b10);
assign csnActive   = ~csnR[1];
assign csnStart    = (csnR[2:1] == 2'b10); // msg start at falling edge
assign csnEnd      = (csnR[2:1] == 2'b01); // msg end at pos edge
assign mosiD       = mosiR[1];

assign miso_o = wordOUT[31];

endmodule
