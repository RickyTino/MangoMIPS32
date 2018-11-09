/********************MangoMIPS32*******************
Filename:	Reg_IF_ID.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module Reg_IF_ID
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            flush,
    input  wire            clrslot,

    input  wire [`AddrBus] if_pc,
    input  wire [`AddrBus] if_pcp4,
    input  wire [`DataBus] if_inst,
    input  wire            id_isbranch,


    output reg  [`AddrBus] id_pc,
    output reg  [`AddrBus] id_pcp4,
    output reg  [`DataBus] id_inst,
    output reg             id_inslot
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            id_pc     <= `ZeroWord;
            id_pcp4   <= `ZeroWord;
            id_inst   <= `ZeroWord;
            id_inslot <= `false;
        end
        else begin
            casez ({flush, stall, clrslot})
                3'b1??, 3'b001: begin
                    id_pc     <= `ZeroWord;
                    id_pcp4   <= `ZeroWord;
                    id_inst   <= `ZeroWord;
                    id_inslot <= `false;
                end
                3'b000: begin
                    id_pc     <= if_pc;
                    id_pcp4   <= if_pcp4;
                    id_inst   <= if_inst;
                    id_inslot <= id_isbranch;
                end
            endcase
        end
    end

endmodule