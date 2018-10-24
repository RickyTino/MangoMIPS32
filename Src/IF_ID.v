/********************MangoMIPS32*******************
Filename:	IF_ID.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module IF_ID
(
    input  wire         clk,
    input  wire         rst,

    input  wire [`Word] if_pc,
    input  wire [`Word] if_inst,

    output reg  [`Word] id_pc,
    output reg  [`Word] id_inst
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule