/********************MangoMIPS32*******************
Filename:	PC.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module PC 
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            br_flag,
    input  wire            br_addr,
    input  wire            flush,
    input  wire [`AddrBus] flush_pc,
    
    output reg  [`AddrBus] pc,
    output wire [`AddrBus] pcp4,
    output reg             inst_en
);

    assign pcp4 = pc + 32'd4;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            pc      <= `ZeroWord;
            inst_en <= `false;
        end
        else begin
            casez ({stall, br_flag, flush})
				3'b000: pc <= pcp4;
				3'b010: pc <= br_ addr;
				3'b??1: pc <= flush_pc;
			endcase
        end
    end

endmodule