`include "constants.vh"

/* ref https://github.com/x-heep/x-heep/blob/05f4721fd07c587337a53a2508f3fb957dff5f14/hw/vendor/xheep/obi_spi_slave/spi_slave_cmd_parser.sv
*/
module cmd_decoder (
    input wire clk_i,
    input wire rstn_i,
    input wire [31:0] cmd_i,

    output wire [7:0] address_o,
    output wire [15:0] data_o,
    output wire rw_o // read/write 1: read, 0: write    
);

reg [15:0] data;
reg [7:0] address;
reg rw;

always @* begin
    if (~rstn_i) begin
        address = 8'h0; 
        rw = 1'b0;
        data = 16'b0;
    end else begin 
        case (cmd_i[31:24]) // 4th byte is cmd
            `CMD_NONE: begin  
                address = 8'h0; 
                rw = 1'b0;
                data = 16'b0;
            end                
            `CMD_READ_SONAR_DISTANCE0: begin  
                address = `ADDR_SONAR_DIST_0; 
                rw = 1'b1;
                data = 16'b0;
            end
            `CMD_READ_SONAR_DISTANCE1: begin  
                address = `ADDR_SONAR_DIST_1; 
                rw = 1'b1;
                data = 16'b0;
            end
            `CMD_READ_SONAR_DISTANCE2: begin  
                address = `ADDR_SONAR_DIST_2; 
                rw = 1'b1;
                data = 16'b0;
            end
            `CMD_READ_TEST_REG: begin 
                address = `ADDR_TEST_REG;
                rw = 1'b1;
                data = 16'b0;
            end
            `CMD_READ_STATUS_REG: begin 
                address = `ADDR_STATUS_REG;
                rw = 1'b1;
                data = 16'b0;
            end


            `CMD_WRITE_STATUS_REG: begin 
                address = `ADDR_STATUS_REG;
                rw = 1'b0;
                data = cmd_i[15:0];
            end

            default: begin  
                address = 8'h0; 
                rw = 1'b0;    
                data = 16'b0;
            end     
        endcase        
    end
end    

assign address_o = address;
assign data_o = data;
assign rw_o = rw;

endmodule