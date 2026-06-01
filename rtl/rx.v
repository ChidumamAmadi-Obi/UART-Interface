`include "constants.vh"

module rx (
    input wire clk,
    input wire rx,
    output wire rdy, // signals when msg buffer is filled
    output reg [`MSG_BIT_LENGTH-1:0] msgInP); // output the received msg (packed)

// rx state machine regs
reg [3:0] rxstate = 0; 
reg [12:0] rxcounter = 0; // counts clock pulses (eg up to 234 if 115200 baude rate)
reg [2:0] rxBitNumber = 0; // kep track of how many bits have been read so far
reg [7:0] dataIn = 0; // store byte received
reg byteReady = 0; //high when byte is finished being read

reg [7:0] msgIn [0:`MSG_BUFFER_LENGTH-1]; // store msg in unpacked array
reg [3:0] msgByteNumber = 0; // keeps track of what byte in buffer is being populated ( UP TO 15 )
reg rdyReg = 0;

always @(posedge clk) begin // rx state machine
    rdyReg <= 0; 
    case (rxstate)
        `RX_STATE_IDLE: begin
            if (rx == 0) begin // if rx goes low thats the start bit
                rxstate <= `RX_STATE_START; // start reading
                rxcounter <= 1;
                rxBitNumber <= 0;
                byteReady <= 0; // in the middle of reading data
            end
        end

        `RX_STATE_START: begin // START BIT DETECTED
                if (rxcounter == `HALF_DELAY_FRAMES) begin // if in the middle of reading a uart bit
                    rxstate <= `RX_STATE_READ_WAIT;
                    rxcounter <= 1;
            end else begin rxcounter <= rxcounter + 1; end 
        end

        `RX_STATE_READ_WAIT: begin // WAITING UNTIL RIGHT TIME TO READ UART BIT
            rxcounter <= rxcounter+1;
            if ((rxcounter+1) == `DELAY_FRAMES) begin
                rxstate <= `RX_STATE_READ;
            end
        end 

        `RX_STATE_READ: begin 
            rxcounter <= 1; // clear counter 
            dataIn[rxBitNumber] <= rx; // shift one bit into data in reg
           
            if (rxBitNumber == 7) begin rxstate <= `RX_STATE_STOP; end // if on last bit, full byte has been read so stop reading
            else begin 
                rxstate <= `RX_STATE_READ_WAIT;
                rxBitNumber <= rxBitNumber+1; 
            end // wait to read next bit
        end

        `RX_STATE_STOP: begin 
            rxcounter <= rxcounter+1;
            if ((rxcounter+1) == `DELAY_FRAMES) begin // wait and then set byteready flag to 1
                rxstate <= `RX_STATE_IDLE;
                rxcounter <= 0;
                byteReady <=1;

                msgIn[msgByteNumber] <= dataIn;
                if (msgByteNumber == `MSG_BUFFER_LENGTH-1) begin 
                    msgByteNumber <= 0; 
                    rdyReg <= 1; // set rdy flag high for one clk cycle
                    end else begin msgByteNumber <= msgByteNumber+1; end                      
            end
        end
    endcase
end

integer i;
always @* begin // pack msg array ,combinational
    for (i=0; i < `MSG_BUFFER_LENGTH; i=i+1) begin
        msgInP[i*8 +: 8] = msgIn[i]; // populate packed array byte by byte
    end
end

assign rdy = rdyReg;

endmodule