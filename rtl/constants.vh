// https://learn.lushaylabs.com/tang-nano-9k-debugging/

`ifndef _CONSTANTS_ 
`define _CONSTANTS_

`define DELAY_FRAMES 234 // 27,000,000 (27Mhz) / 115200 Baud rate
`define HALF_DELAY_WAIT DELAY_FRAMES/2
`define MESSAGE_BUFFER_LENGTH 16 // 16 char

`endif