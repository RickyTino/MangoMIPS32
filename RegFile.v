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
	input  wire [`Word]    wdata,

	input  wire            re1, 
	input  wire [`RegAddr] r1addr,
	output reg  [`Word]    r1data,

	input  wire            re2,
	input  wire [`RegAddr] r2addr,
	output reg  [`Word]    r2data
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
	
    wire r1zero = r1addr == `ZeroReg;
    wire r1whaz = (r1addr == waddr) && we;
    wire r2zero = r2addr == `ZeroReg;
    wire r2whaz = (r2addr == waddr) && we;
    wire r1case = {r1zero, r1whaz, re1};
    wire r2case = {r2zero, r2whaz, re2};

	always @(*) begin
		case (r1case)
            3'b011:  r1data <= wdata;
            3'b001:  r1data <= GPR[r1addr];
            default: r1data <= `ZeroWord;
        endcase
		
        case (r2case)
            3'b011:  r2data <= wdata;
            3'b001:  r2data <= GPR[r2addr];
            default: r2data <= `ZeroWord;
        endcase
	end
	
endmodule