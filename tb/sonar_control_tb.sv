`include "tb_config.svh"

module sonar_control_tb;

logic clk, rstn, en, echo0, echo1, echo2; // inputs
logic [21:0] distance0, distance1, distance2; // outputs
logic trig;

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
    $monitor("STATE0: %d, STATE1: %d, STATE2: %d trig %d", 
    sonar_controlInstance.state0, 
    sonar_controlInstance.state1, 
    sonar_controlInstance.state2,
    trig);

    /* $monitor ("%d %d %d",
    sonar_controlInstance.inTRIG0,
    sonar_controlInstance.inTRIG1,
    sonar_controlInstance.inTRIG2,); */

    /* $monitor("%d %d %d", 
    sonar_controlInstance.rawDist0,
    sonar_controlInstance.rawDist1,
    sonar_controlInstance.rawDist2); */

    /* $monitor("CNT0: %d ECHO0: %d, CNT1: %d ECHO1: %d, CNT2: %d ECHO2: %d",
    sonar_controlInstance.cnt0,
    sonar_controlInstance.echo0_i,
    sonar_controlInstance.cnt1,
    sonar_controlInstance.echo1_i,
    sonar_controlInstance.cnt2,
    sonar_controlInstance.echo2_i); */

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

    // distance is calculated after

    #(50) $finish;
end
endmodule

/* notes
state transitions are perfect
make model of distance calculation to verify correct distance output later

*/