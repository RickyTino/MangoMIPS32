/********************MangoMIPS32*******************
Filename:	RegFile.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module RegFile
(
	input  wire            clk,
    input  wire            rst, 

	input  wire            we,
	input  wire [`RegAddr] waddr, 
	input  wire [`DataBus] wdata,

	input  wire            re1, 
	input  wire [`RegAddr] r1addr,
	output reg  [`DataBus] r1data,

	input  wire            re2,
	input  wire [`RegAddr] r2addr,
	output reg  [`DataBus] r2data
);

	reg [`Word] GPR [0:31];
	integer i;
	
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			for(i = 0; i < 32; i = i + 1)
				GPR[i] <= `ZeroWord;
		end
		else begin
			if(we && (waddr != `ZeroReg))
				GPR[waddr] <= wdata;
		end
	end
	
    wire r1_zero = r1addr == `ZeroReg;
    wire r1w_haz = (r1addr == waddr) && we;
    wire r2_zero = r2addr == `ZeroReg;
    wire r2w_haz = (r2addr == waddr) && we;

	always @(*) begin
		case ({r1_zero, r1w_haz, re1})
            3'b011:  r1data <= wdata;
            3'b001:  r1data <= GPR[r1addr];
            default: r1data <= `ZeroWord;
        endcase
		
        case ({r2_zero, r2w_haz, re2})
            3'b011:  r2data <= wdata;
            3'b001:  r2data <= GPR[r2addr];
            default: r2data <= `ZeroWord;
        endcase
	end
	
endmodule