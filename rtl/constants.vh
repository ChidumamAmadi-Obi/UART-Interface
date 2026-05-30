// tang nano uart guide https://learn.lushaylabs.com/tang-nano-9k-debugging/
// https://stackoverflow.com/questions/79551528/in-a-testbench-is-there-a-way-to-see-the-internal-declared-regs-wires-of-a-modu
`ifndef _CONSTANTS_
`define _CONSTANTS_

`define BAUD_RATE 115200 
`define DELAY_FRAMES $floor(27000000/`BAUD_RATE) //number of clock pulses needed to reach the desired baud rate
`define DELAY_TB `DELAY_FRAMES*2 // delay in tb to get one uart frame
`define HALF_DELAY_WAIT `DELAY_FRAMES/2
`define MSG_BUFFER_LENGTH 16 // holds 16 chars at a time
`define LAST_MSG_BIT_NO `MSG_BUFFER_LENGTH-1

// rx state machine
`define RX_STATE_IDLE 0
`define RX_STATE_START 1
`define RX_STATE_READ_WAIT 2
`define RX_STATE_READ 3
`define RX_STATE_STOP 4

// tx state machine
`define TX_STATE_IDLE 0
`define TX_STATE_START 1
`define TX_STATE_WRITE 2
`define TX_STATE_STOP 3

`endif