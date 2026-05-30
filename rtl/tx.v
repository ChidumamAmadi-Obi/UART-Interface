`include "constants.vh"

module tx(
    input wire clk,
    input wire rdy, // signals when msg is availible
    input wire [`MSG_BIT_LENGTH-1:0] msgOutP, // receive msg to send out (packed)
    output reg tx);

reg [3:0] txstate=0;
reg [12:0] txcounter=0;
reg [2:0] txBitNumber=0; // bit no of byte to send
reg [3:0] msgByteNumber=0; // byte no of msg to send
reg [7:0] dataOut=0; // send 50 for now
reg byteSent=0;

reg [7:0] msgOut [0:`MSG_BUFFER_LENGTH-1]; // store msg in unpacked array

// unpack msg buffer 
assign msgOut[0]  = msgOutP[0*8 +: 8];
assign msgOut[1]  = msgOutP[1*8 +: 8];
assign msgOut[2]  = msgOutP[2*8 +: 8];
assign msgOut[3]  = msgOutP[3*8 +: 8];
assign msgOut[4]  = msgOutP[4*8 +: 8];
assign msgOut[5]  = msgOutP[5*8 +: 8];
assign msgOut[6]  = msgOutP[6*8 +: 8];
assign msgOut[7]  = msgOutP[7*8 +: 8];
assign msgOut[8]  = msgOutP[8*8 +: 8];
assign msgOut[9]  = msgOutP[9*8 +: 8];
assign msgOut[10] = msgOutP[10*8 +: 8];
assign msgOut[11] = msgOutP[11*8 +: 8];
assign msgOut[12] = msgOutP[12*8 +: 8];
assign msgOut[13] = msgOutP[13*8 +: 8];
assign msgOut[14] = msgOutP[14*8 +: 8];
assign msgOut[15] = msgOutP[15*8 +: 8];

always @(posedge clk) begin
    case (txstate)
        `TX_STATE_IDLE: begin
            if (rdy) begin
                txstate <= `TX_STATE_START;
                txcounter <= 0;
                txBitNumber <= 0;
                byteSent <= 0;
            end else begin tx <= 1; end
        end 

        `TX_STATE_START: begin 
            tx <= 0; // send start bit
            if ((txcounter+1) == `DELAY_FRAMES) begin
                txstate <= `TX_STATE_WRITE;
                dataOut <= msgOut[msgByteNumber];
                txBitNumber <= 0;
                txcounter <= 0;
            end else begin txcounter <= txcounter +1; end
        end

        `TX_STATE_WRITE: begin
            tx <= dataOut[txBitNumber]; // send next bit
            if ((txcounter + 1) == `DELAY_FRAMES) begin // each uart frame...
                if (txBitNumber == 7) begin txstate <= `TX_STATE_STOP; end // check if last bit number 
                else begin // if no tlast bit number write next bit
                    txstate <= `TX_STATE_WRITE;
                    txBitNumber <= txBitNumber+1;
                end 
                txcounter <= 0; // after each frame reset counter
            end else begin txcounter <= txcounter +1; end
        end

        `TX_STATE_STOP: begin
            tx <= 1; // stop bit 
            if ((txcounter +1) == `DELAY_FRAMES) begin
                if (msgByteNumber == `MSG_BUFFER_LENGTH -1) begin // if reached last byte of msg
                    msgByteNumber <= 0;
                    byteSent <= 1;
                    txstate <= `TX_STATE_IDLE;
                end else begin 
                    msgByteNumber <= msgByteNumber+1;
                    txstate <= `TX_STATE_START;
                end
                txcounter <= 0;
            end else begin txcounter <= txcounter+1; end
        end
    endcase
end
endmodule