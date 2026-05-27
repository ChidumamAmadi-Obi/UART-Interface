// https://learn.lushaylabs.com/tang-nano-9k-debugging/

`ifndef _CONSTANTS_ 
`define _CONSTANTS_

localparam BAUD_RATE = 115200; 
localparam DELAY_FRAMES = $floor(27000000/BAUD_RATE); //number of clock pulses needed to reach the desired baud rate
localparam HALF_DELAY_WAIT = DELAY_FRAMES/2;
localparam MESSAGE_BUFFER_LENGTH = 15; // 16 char

// rx state machine
localparam RX_STATE_IDLE = 0;
localparam RX_STATE_START = 1;
localparam RX_STATE_READ_WAIT = 2;
localparam RX_STATE_READ = 3;
localparam RX_STATE_STOP = 4;

`endif