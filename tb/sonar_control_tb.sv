`include "tb_config.svh"

parameter SPEED_OF_SOUND = 0.0340; // 0.034 cm/us, or 340/
parameter SYS_CLK_FREQ_MHZ = 27; // 27MHz

module sonar_control_tb;

logic clk, rstn, en, echo0, echo1, echo2; // inputs
logic [21:0] distance0, distance1, distance2; // outputs
logic trig;
logic [2:0] rdy;

real expectedDistance0,expectedDistance1,expectedDistance2;
int actualDistanceRaw0,actualDistanceRaw1,actualDistanceRaw2;

function automatic real clkCycles2us ( input int clkCycles ); // us = cycles/sysClkfreq
    return $itor(clkCycles)/$itor(SYS_CLK_FREQ_MHZ);
endfunction
function automatic real calculateDistance( input int clkCycles );
    return (SPEED_OF_SOUND * clkCycles2us(clkCycles))/2.0;
endfunction

sonar_control sonar_controlInstance (
    .clk_i(clk),
    .rstn_i(rstn),
    .en_i(en),
    .dist0_o(distance0),
    .dist1_o(distance1),
    .dist2_o(distance2),
    .echo0_i(echo0),
    .echo1_i(echo1),
    .echo2_i(echo2),
    .trig_o(trig),
    .rdy_o(rdy));

always #1 clk = ~clk; // this generates the clk pulse
always @(posedge rdy[0]) begin 
    actualDistanceRaw0 = distance0;
end
always @(posedge rdy[1]) begin 
    actualDistanceRaw1 = distance1;
end
always @(posedge rdy[2]) begin 
    actualDistanceRaw2 = distance2;
end

initial begin
    en = 1'b1; // en is always high when module in use
    clk = 1'b0;
    rstn = 1'b1;

    echo0 = 1'b0;
    echo1 = 1'b0;
    echo2 = 1'b0;

    // since en is high, a pulse is sent to trig_o for `TEN_US clk cycles (10us)

    #(`TEN_US*2); // trig pulse length

    // after pulse is sent, there is a waiting period before it echos back

    #(20); 

    // $monitor("RDY %d D0 %d D1 %d D2 %d ", rdy, distance0, distance1, distance2 );
    echo2 = 1'b1;
    #((`RAW_DIST_MAX)*2); // echo is high for a certain amount of time which is in proportion to the distance measured
    echo2 = 1'b0;

    echo0 = 1'b1;
    #((`RAW_DIST_MIN)*2);
    echo0 = 1'b0;   
 
    echo1 = 1'b1;
    #((`RAW_DIST_MIN+1750)*2);
    echo1 = 1'b0;

    en = 1'b0; 

    #(20);

    $display("[SENSOR 0 %.1fns] EXPECTED DISTANCE: %fcm, RAW_DISTANCE: %d, ECHO: %fus, ACTUAL DISTANCE: %fcm", $realtime,
        calculateDistance(`RAW_DIST_MIN), // calculate expected distance
        actualDistanceRaw0,
        clkCycles2us(actualDistanceRaw0), // calculate microseconds echo was high
        calculateDistance(actualDistanceRaw0)); // calculate actual distance measured
    $display("[SENSOR 1 %.1fns] EXPECTED DISTANCE: %fcm, RAW_DISTANCE: %d, ECHO: %fus, ACTUAL DISTANCE: %fcm", $realtime,
        calculateDistance(`RAW_DIST_MIN+1750), 
        actualDistanceRaw1,
        clkCycles2us(actualDistanceRaw1),
        calculateDistance(actualDistanceRaw1)); 
    $display("[SENSOR 2 %.1fns] EXPECTED DISTANCE: %fcm, RAW_DISTANCE: %d, ECHO: %fus, ACTUAL DISTANCE: %fcm", $realtime,
        calculateDistance(`RAW_DIST_MAX), 
        actualDistanceRaw2,
        clkCycles2us(actualDistanceRaw2),
        calculateDistance(actualDistanceRaw2));
    $finish;
end
endmodule

/* notes

add rdy signal, only output distances when rdy is sctivated and distance is fully calculated
test this along with different distance measurements accross sensors in test bench 

https://www.rfwireless-world.com/calculators/ultrasonic-sensor-calculator
https://chipverify.com/verilog/verilog-conversion-functions
*/