/********************MangoMIPS32*******************
Filename:	PC.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

module PC 
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            flush,
    input  wire [`AddrBus] flush_pc,
    input  wire            br_flag,
    input  wire [`AddrBus] br_addr,
    
    output reg  [`AddrBus] pc,
    output wire [`AddrBus] pcp4,
    output reg             i_en
);

    assign pcp4 = pc + 32'd4;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            pc   <= `ZeroWord;
            i_en <= `false;
        end
        else begin
            i_en <= `true;
            casez ({stall, br_flag, flush})
				3'b000: pc <= i_en ? pcp4 : `Entr_Start;
				3'b010: pc <= br_addr;
				3'b??1: pc <= flush_pc;
			endcase
        end
    end

endmodule