/********************MangoMIPS32*******************
Filename:	Reg_IF_ID.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module Reg_IF_ID
(
    input  wire         clk,
    input  wire         rst,
    input  wire         stall,
    input  wire         flush,

    input  wire [`AddrBus] if_pc,
    input  wire [`DataBus] if_inst,

    output reg  [`AddrBus] id_pc,
    output reg  [`DataBus] id_inst
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else begin
            if(flush) begin
                id_pc   <= `ZeroWord;
                id_inst <= `ZeroWord;
            end
            else if(!stall) begin
                id_pc   <= if_pc;
                id_inst <= if_inst;
            end
        end
    end

endmodule