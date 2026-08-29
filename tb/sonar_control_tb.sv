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

always #1 clk = ~clk; 
initial begin
    $monitor("STATE0: %d, STATE1: %d, STATE2: %d ", 
    sonar_controlInstance.state0, 
    sonar_controlInstance.state1, 
    sonar_controlInstance.state2);

    en = 1'b1;
    clk = 1'b0;
    rstn = 1'b1;

    echo0 = 1'b0;
    echo1 = 1'b0;
    echo2 = 1'b0;

    #(20);

    echo0 = 1'b1;
    echo1 = 1'b1;
    echo2 = 1'b1;
    #(1);
    echo0 = 1'b0;
    echo1 = 1'b0;
    echo2 = 1'b0;

    #(10);
    $finish;
end
endmodule