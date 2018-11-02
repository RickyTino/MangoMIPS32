/********************MangoMIPS32*******************
Filename:	HiLo.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module HiLo
(
    input  wire          clk,
    input  wire          rst,
	input  wire          whilo,
	input  wire [`DWord] wdata,
    output wire [`DWord] rdata
);
	reg [`DWord] hilo;

	always @(posedge clk, posedge rst) begin
		if(rst)
            hilo <= `ZeroDWord;
		else if(whilo)
            hilo <= wdata;
	end

    assign rdata = whilo ? wdata : hilo;
	
endmodule
