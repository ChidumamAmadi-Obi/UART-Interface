// tang nano uart guide https://learn.lushaylabs.com/tang-nano-9k-debugging/
// https://stackoverflow.com/questions/79551528/in-a-testbench-is-there-a-way-to-see-the-internal-declared-regs-wires-of-a-modu

`ifndef _CONSTANTS_ 
`define _CONSTANTS_

localparam BAUD_RATE = 115200; 
localparam DELAY_FRAMES = $floor(27000000/BAUD_RATE); //number of clock pulses needed to reach the desired baud rate
localparam DELAY_TB = DELAY_FRAMES*2;
localparam HALF_DELAY_WAIT = DELAY_FRAMES/2;
localparam MESSAGE_BUFFER_LENGTH = 16; // holds 16 chars at a time

// rx state machine
localparam RX_STATE_IDLE = 0;
localparam RX_STATE_START = 1;
localparam RX_STATE_READ_WAIT = 2;
localparam RX_STATE_READ = 3;
localparam RX_STATE_STOP = 4;

`endif