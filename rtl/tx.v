`include "constants.vh"

module tx(
    input wire clk,
    input wire rdy, // signals when msg is availible
    input reg [7:0] msg [0:MSG_BUFFER_LENGTH-1],
    output reg tx
);

reg [3:0] txstate=0;
reg [12:0] txcounter=0;
reg [2:0] txBitNumber=0; // bit no of byte to send
reg [3:0] msgByteNumber=0; // byte no of msg to send
reg [7:0] dataOut=0; // send 50 for now
reg byteSent=0;

always @(posedge clk) begin
    case (txstate)
        TX_STATE_IDLE: begin
            if (rdy) begin
                txstate <= TX_STATE_START;
                txcounter <= 0;
                txBitNumber <= 0;
            end else begin tx <= 1; end
        end 

        TX_STATE_START: begin 
            tx <= 0; // send start bit
            if ((txcounter+1) == DELAY_FRAMES) begin
                txstate <= TX_STATE_WRITE;
                dataOut <= msg[msgByteNumber];
                txBitNumber <= 0;
                txcounter <= 0;
            end else begin txcounter <= txcounter +1; end
        end

        TX_STATE_WRITE: begin
            tx <= dataOut[txBitNumber]; // send next bit
            if ((txcounter + 1) == DELAY_FRAMES) begin // each uart frame...
                if (txBitNumber == 7) begin txstate <= TX_STATE_STOP; end // check if last bit number 
                else begin // if no tlast bit number write next bit
                    txstate <= TX_STATE_WRITE;
                    txBitNumber <= txBitNumber+1;
                end 
                txcounter <= 0; // after each frame reset counter
            end else begin txcounter <= txcounter +1; end
        end

        TX_STATE_STOP: begin
            tx <= 1; // stop bit 
            if ((txcounter +1) == DELAY_FRAMES) begin
                if (msgByteNumber == MSG_BUFFER_LENGTH -1) begin // if reached last byte of msg
                    msgByteNumber <= 0;
                    txstate <= TX_STATE_IDLE;
                end else begin 
                    msgByteNumber <= msgByteNumber+1;
                    txstate <= TX_STATE_START;
                end
                txcounter <= 0;
            end else begin txcounter <= txcounter+1; end
        end
    endcase
end
endmodule