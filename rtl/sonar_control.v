`include "constants.vh"

/* notes
ref https://github.com/suoglu/HC-SR04/blob/master/Sources/hc-sr04.v

sys clk at 27MHz
*/


// control 3 ultra sonic distance sensors, filter the data and output 

module sonar_control(
    input wire clk_i,
    input wire rstn_i,
    input wire en_i, // keep high

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
reg [2:0] state0, state1, state2;
reg trigPulsed0, trigPulsed1, trigPulsed2;
reg echoReceived0, echoReceived1, echoReceived2;
reg en;

wire rawDistRdy0, rawDistRdy1 ,rawDistRdy2;

assign en = en_i;


always @(posedge clk_i or negedge rstn_i) begin 
    if (rstn_i == 1'b0) begin
        state0 <= `SONAR_CTRL_IDLE;
        state1 <= `SONAR_CTRL_IDLE;
        state2 <= `SONAR_CTRL_IDLE;
        filteredDist0 <= 8'b0;
        filteredDist1 <= 8'b0;
        filteredDist2 <= 8'b0;
        rawDist0 <= 8'b0;
        rawDist1 <= 8'b0;
        rawDist2 <= 8'b0;  
        
    end else begin // ctrl states of 3 distance sensors
        case(state0)
            `SONAR_CTRL_IDLE: begin state0 <= (en) ? `SONAR_CTRL_TRIG : state0; end // assign rawDistRdy 0 after state transition
            `SONAR_CTRL_TRIG: begin /* pulse the trig pin once an then switch states */ state0 <= (trigPulsed0) ? `SONAR_CTRL_WAIT : state0; end // assign trigPulsed 0 after state transiton
            `SONAR_CTRL_WAIT: begin state0 <= (echoReceived0) ? `SONAR_CTRL_ECHO : state0; end
            `SONAR_CTRL_ECHO: begin state0 <= (echoReceived0) ? state0 : `SONAR_CTRL_IDLE; end
        endcase
        case(state1)
            `SONAR_CTRL_IDLE: begin state1 <= (en) ? `SONAR_CTRL_TRIG : state1; end 
            `SONAR_CTRL_TRIG: begin state1 <= (trigPulsed1) ? `SONAR_CTRL_WAIT : state1; end 
            `SONAR_CTRL_WAIT: begin state1 <= (echoReceived1) ? `SONAR_CTRL_ECHO : state1; end
            `SONAR_CTRL_ECHO: begin state1 <= (echoReceived1) ? state1 : `SONAR_CTRL_IDLE; end
        endcase
        case(state2)
            `SONAR_CTRL_IDLE: begin state2 <= (en) ? `SONAR_CTRL_TRIG : state2; end
            `SONAR_CTRL_TRIG: begin state2 <= (trigPulsed2) ? `SONAR_CTRL_WAIT : state2; end 
            `SONAR_CTRL_WAIT: begin state2 <= (echoReceived2) ? `SONAR_CTRL_ECHO : state2; end
            `SONAR_CTRL_ECHO: begin state2 <= (echoReceived2) ? state2 : `SONAR_CTRL_IDLE; end
        endcase
    end
end
endmodule 