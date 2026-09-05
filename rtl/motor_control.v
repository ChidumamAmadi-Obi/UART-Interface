`include "constants.vh"

module motor_control(
input wire [1:0] direction_i,
input wire [7:0] speed1_i,
input wire [7:0] speed2_i,
/* output wire [] distanceTraveled_o, */

/* input [] encoder1_i, */ // external connections
/* input [] encoder2_i, */
output wire pwm1,
output wire pwm2
);

endmodule