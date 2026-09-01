// tang nano uart guide https://learn.lushaylabs.com/tang-nano-9k-debugging/
// https://stackoverflow.com/questions/79551528/in-a-testbench-is-there-a-way-to-see-the-internal-declared-regs-wires-of-a-modu
// https://cal-poly-ramp.github.io/_static/pdf/tools/verilator-guide.pdf
// https://youtu.be/4Y7zG48uHRo?si=Gn_Co_ruN7TMuxRH pid
// https://youtu.be/4dg_s4zlm9U?si=ri7SOzUWV-scAUAf pid

`ifndef _CONSTANTS_
`define _CONSTANTS_

`timescale 1ns/1ps

// UART CONSTANTS
    `define BAUD_RATE 115200 
    `define DELAY_FRAMES (27000000/`BAUD_RATE) //number of clock pulses needed to reach the desired baud rate
    `define HALF_DELAY_FRAMES `DELAY_FRAMES/2
    `define MSG_BUFFER_LENGTH 16 // holds 16 chars/bytes at a time
    `define MSG_BIT_LENGTH `MSG_BUFFER_LENGTH*8

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

// SPI CONSTANTS
// SENSOR CONSTANTS
    `define SONAR_CTRL_IDLE 0
    `define SONAR_CTRL_TRIG 1
    `define SONAR_CTRL_WAIT 2
    `define SONAR_CTRL_ECHO 3

    // `define TRIG_INTERVAL clk cycles inbetween trig pulses
    `define TEN_US 9'd270 // amount of clk cycles (at 27MHz) it takes to reach ten microseconds
    `define RAW_DIST_MAX 20'd635295 // max amount of clk cycles echo can be high (for 400cm distance)
    `define RAW_DIST_MIN 20'd3177 // min amount of clk cycles echo can be high (for 2cm distance)
`endif