`include "constants.vh"

module rx(
    input wire clk,
    input wire rx,
    output reg [7:0] message [0:MESSAGE_BUFFER_LENGTH-1]
);

// rx state machine regs
reg [3:0] rxstate = 0; 
reg [12:0] rxcounter = 0; // counts clock pulses (eg up to 234 if 115200 baude rate)
reg [2:0] rxBitNumber = 0; // kep track of how many bits have been read so far
reg [7:0] dataIn = 0; // store byte received
reg byteReady = 0; //high when byte is finished being read

reg [3:0] messageBitNumber = 0; // keeps track of what bit in buffer is being populated ( UP TO 15 )

always @(posedge clk) begin // rx state machine
    case (rxstate)
        RX_STATE_IDLE: begin
            if (rx == 0) begin // if rx goes low thats the start bit
                rxstate <= RX_STATE_START; // start reading
                rxcounter <= 1;
                rxBitNumber <= 0;
                byteReady <= 0; // in the middle of reading data
            end
        end

        RX_STATE_START: begin // START BIT DETECTED
                if (rxcounter == HALF_DELAY_WAIT) begin // if in the middle of reading a uart bit
                    rxstate <= RX_STATE_READ_WAIT;
                    rxcounter <= 1;
            end else begin rxcounter <= rxcounter + 1; end 
        end

        RX_STATE_READ_WAIT: begin // WAITING UNTIL RIGHT TIME TO READ UART BIT
            rxcounter <= rxcounter+1;
            if ((rxcounter+1) == DELAY_FRAMES) begin
                rxstate <= RX_STATE_READ;
            end
        end

        RX_STATE_READ: begin 
            rxcounter <= 1; // clear counter 
            dataIn <= {rx, dataIn[7:1]}; // shift one bit into data in reg
            rxBitNumber <= rxBitNumber+1;

            if (rxBitNumber == 7) rxstate <= RX_STATE_STOP; // if on last bit, full byte has been read so stop reading
            else                       rxstate <= RX_STATE_READ_WAIT; // wait to read next bit
        end

        RX_STATE_STOP: begin 
            rxcounter <= rxcounter +1;
            if ((rxcounter+1) == DELAY_FRAMES) begin // wait and then set byteready flag to 1
                rxstate <= RX_STATE_IDLE;
                rxcounter <= 0;
                byteReady <=1;
            end
        end
    endcase
end

always @(posedge clk) begin // filling message buffer
    if (byteReady == 1) begin
        message[messageBitNumber] <= dataIn;

        if (messageBitNumber == 15) begin messageBitNumber <= 0; end
        else                        begin messageBitNumber <= messageBitNumber+1; end
    end
end

endmodule