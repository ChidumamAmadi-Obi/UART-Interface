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

    output reg [21:0] filteredDist0_o, // left
    output reg [21:0] filteredDist1_o, // middle
    output reg [21:0] filteredDist2_o, // right

    input wire echo0_i,
    input wire echo1_i,
    input wire echo2_i,
    output wire trig_o
);

reg [21:0] filteredDist0, filteredDist1, filteredDist2;
reg [21:0] rawDist0, rawDist1, rawDist2;
reg [9:0] cnt0, cnt1, cnt2; // holds amount of clk cycles it takes for echo to get back
reg [2:0] state0, state1, state2;
reg trigPulsed;

wire rawDistRdy0, rawDistRdy1 ,rawDistRdy2;

wire inIDLE0, inIDLE1, inIDLE2; // for tracking states
wire inTRIG0, inTRIG1, inTRIG2;
wire inWAIT0, inWAIT1, inWAIT2;
wire inECHO0, inECHO1, inECHO2;

assign inIDLE0 = (state0 == `SONAR_CTRL_IDLE); 
assign inIDLE1 = (state1 == `SONAR_CTRL_IDLE); 
assign inIDLE2 = (state2 == `SONAR_CTRL_IDLE);
assign inTRIG0 = (state0 == `SONAR_CTRL_TRIG); 
assign inTRIG1 = (state1 == `SONAR_CTRL_TRIG); 
assign inTRIG2 = (state2 == `SONAR_CTRL_TRIG);
assign inWAIT0 = (state0 == `SONAR_CTRL_WAIT);
assign inWAIT1 = (state1 == `SONAR_CTRL_WAIT);
assign inWAIT2 = (state2 == `SONAR_CTRL_WAIT);
assign inECHO0 = (state0 == `SONAR_CTRL_ECHO);
assign inECHO1 = (state1 == `SONAR_CTRL_ECHO);
assign inECHO2 = (state2 == `SONAR_CTRL_ECHO);

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
            `SONAR_CTRL_IDLE: begin state0 <= (en_i) ? `SONAR_CTRL_TRIG : state0; end
            `SONAR_CTRL_TRIG: begin /* pulse the trig pin once an then switch states */ state0 <= (trigPulsed) ? `SONAR_CTRL_WAIT : state0; end // assign trigPulsed 0 after state transiton
            `SONAR_CTRL_WAIT: begin state0 <= (echo0_i) ? `SONAR_CTRL_ECHO : state0; end
            `SONAR_CTRL_ECHO: begin state0 <= (echo0_i) ? state0 : `SONAR_CTRL_IDLE; end
        endcase
        case(state1)
            `SONAR_CTRL_IDLE: begin state1 <= (en_i) ? `SONAR_CTRL_TRIG : state1; end 
            `SONAR_CTRL_TRIG: begin state1 <= (trigPulsed) ? `SONAR_CTRL_WAIT : state1; end 
            `SONAR_CTRL_WAIT: begin state1 <= (echo1_i) ? `SONAR_CTRL_ECHO : state1; end
            `SONAR_CTRL_ECHO: begin state1 <= (echo1_i) ? state1 : `SONAR_CTRL_IDLE; end
        endcase
        case(state2)
            `SONAR_CTRL_IDLE: begin state2 <= (en_i) ? `SONAR_CTRL_TRIG : state2; end
            `SONAR_CTRL_TRIG: begin state2 <= (trigPulsed) ? `SONAR_CTRL_WAIT : state2; end 
            `SONAR_CTRL_WAIT: begin state2 <= (echo2_i) ? `SONAR_CTRL_ECHO : state2; end
            `SONAR_CTRL_ECHO: begin state2 <= (echo2_i) ? state2 : `SONAR_CTRL_IDLE; end
        endcase
        rawDist0 <= inWAIT0 ? 22'b0 : rawDist0 + {21'b0 , inECHO0}; // get raw distance
        rawDist1 <= inWAIT1 ? 22'b0 : rawDist1 + {21'b0 , inECHO1};
        rawDist2 <= inWAIT2 ? 22'b0 : rawDist2 + {21'b0 , inECHO2};        
    end
end

always@(posedge clk_i) begin // Counter
    if(inIDLE0) cnt0 <= 10'd0;
    else cnt0 <= cnt0 + {9'd0, (|cnt0 | inTRIG0)};
    if(inIDLE1) cnt1 <= 10'd0;
    else cnt1 <= cnt1 + {9'd0, (|cnt1 | inTRIG1)};
    if(inIDLE2) cnt2 <= 10'd0;
    else cnt2 <= cnt2 + {9'd0, (|cnt2 | inTRIG2)};                
end

assign trig_o = (inTRIG0 && inTRIG1 && inTRIG2);  // if all states reach TRIG state, send trig pulse out
assign trigPulsed = (cnt0 == `TEN_US) && (cnt2 == `TEN_US) && (cnt2 == `TEN_US);

endmodule 