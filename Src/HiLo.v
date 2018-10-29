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
	input  wire          whi,
    input  wire          wlo,
	input  wire [`DWord] wdata,
    output wire [`DWord] rdata
);
	reg [`DWord] hilo;

	always @(posedge clk, posedge rst) begin
		if(rst) 
			hilo <= `ZeroDWord;
		else begin
            if(whi) hilo[`Hi] <= wdata[`Hi];
            if(wlo) hilo[`Lo] <= wdata[`Lo];
        end
	end

    assign rdata[`Hi] = whi ? wdata[`Hi] : hilo[`Hi];
    assign rdata[`Lo] = wlo ? wdata[`Lo] : hilo[`Lo];
	
endmodule
