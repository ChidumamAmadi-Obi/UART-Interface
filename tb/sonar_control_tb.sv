`include "tb_config.svh"
parameter SPEED_OF_SOUND = 0.0340; // 0.034 cm/us
parameter SYS_CLK_FREQ_MHZ = 27; // 27MHz

module sonar_control_tb;

logic clk, rstn, en, echo0, echo1, echo2; // inputs
logic [21:0] distance0, distance1, distance2; // outputs
logic trig;

real expectedDistance0,expectedDistance1,expectedDistance2;

function automatic real clkCycles2us ( input int clkCycles );
    return $itor(clkCycles)/$itor(SYS_CLK_FREQ_MHZ);
endfunction
task waitUs(input int us);
endtask
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

    $monitor("===================================\n0: DIST: %d STATE: %d CNT: %d\n===================================", 
    sonar_controlInstance.rawDist0, sonar_controlInstance.state0, sonar_controlInstance.cnt0); 

    en = 1'b1; // en is always high when module in use
    clk = 1'b0;
    rstn = 1'b1;

    echo0 = 1'b0;
    echo1 = 1'b0;
    echo2 = 1'b0;

    // since en is high, a pulse is sent to trig_o for `TEN_US clk cycles (10us)

    #(`TEN_US*2); // trig pulse length

    // after pulse is sent, there is a waiting period before it echos back

    #(100); // time to echo back

    echo0 = 1'b1;
    echo1 = 1'b1;
    echo2 = 1'b1;
    #(10);
    echo0 = 1'b0;
    echo1 = 1'b0;
    echo2 = 1'b0;

    // calculateDistance(100,distance0);
    #(10);  // distance is calculated after
    //$display("DISTANCE_E %f, DISTANCE_A %f", calculateDistance(250), sonar_controlInstance.rawDist0);
    //#(500);
    
    $finish;
end
endmodule

/* notes
state transitions are perfect
make model of distance calculation to verify correct distance output later
https://www.rfwireless-world.com/calculators/ultrasonic-sensor-calculator
*/