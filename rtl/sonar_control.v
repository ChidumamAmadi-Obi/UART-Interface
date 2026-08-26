`include "constants.vh"

// control 3 ultra sonic distance sensors, filter the data and output 

module sonar_control(
    input wire clk_i,
    input wire rstn_i,

    output reg [7:0] filteredDist0_o, // left
    output reg [7:0] filteredDist1_o, // middle
    output reg [7:0] filteredDist2_o, // right

    input wire echo0_i,
    input wire echo1_i,
    input wire echo2_i,
    output wire trig_o
);

reg [7:0] filteredDist0, filteredDist1, filteredDist2;
reg [7:0] rawDist0, rawDist1, rawDist2;
reg trig;

always @(posedge clk_i or negedge rstn_i) begin 
    if (rstn_i == 1'b0) begin
        trig <= 1'b0;
        rawDist0 <= 8'b0;
        rawDist1 <= 8'b0;
        rawDist2 <= 8'b0;    
        filteredDist0 <= 8'b0;
        filteredDist1 <= 8'b0;
        filteredDist2 <= 8'b0;
    end else begin

    end
end
endmodule 