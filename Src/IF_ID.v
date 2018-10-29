/********************MangoMIPS32*******************
Filename:	IF_ID.v
Author:		RickyTino
Version:	Unreleased 20181029
**************************************************/
`include "defines.v"

module IF_ID
(
    input  wire         clk,
    input  wire         rst,

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
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule