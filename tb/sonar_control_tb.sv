`include "tb_config.svh"
parameter SPEED_OF_SOUND = 0.0340; // 0.034 cm/us, or 340/
parameter SYS_CLK_FREQ_MHZ = 27; // 27MHz

module sonar_control_tb;

logic clk, rstn, en, echo0, echo1, echo2; // inputs
logic [21:0] distance0, distance1, distance2; // outputs
logic trig;

real expectedDistance0,expectedDistance1,expectedDistance2;
int actualDistanceRaw;

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
    .filteredDist0_o(distance0),
    .filteredDist1_o(distance1),
    .filteredDist2_o(distance2),
    .echo0_i(echo0),
    .echo1_i(echo1),
    .echo2_i(echo2),
    .trig_o(trig));

always #1 clk = ~clk; // this generates the clk pulse
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

    #(10); 

    echo0 = 1'b1;
    echo1 = 1'b1;
    echo2 = 1'b1;
    #((`RAW_DIST_MIN)*2); // echo is high for a certain amount of time which is in proportion to the distance measured
    echo0 = 1'b0;
    echo1 = 1'b0;
    echo2 = 1'b0;

    en = 1'b0; 

    actualDistanceRaw = sonar_controlInstance.rawDist0;

    #(10);  // distance is calculated after
    $display("DISTANCE_E %fcm,      RAW_DISTANCE %d, ECHO_US %fus, DISTANCE_A %fcm", 
        calculateDistance(`RAW_DIST_MIN), // calculate expected distance
        sonar_controlInstance.rawDist0,
        clkCycles2us(actualDistanceRaw), // calculate microseconds echo was high
        calculateDistance(actualDistanceRaw)); // calculate actual distance measured

    $finish;
end
endmodule

/* notes
https://www.rfwireless-world.com/calculators/ultrasonic-sensor-calculator
https://chipverify.com/verilog/verilog-conversion-functions
*/