/********************MangoMIPS32*******************
Filename:	RegFile.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

module RegFile
(
	input  wire            clk,
    input  wire            rst, 

	input  wire            re1, 
	input  wire [`RegAddr] r1addr,
	output reg  [`DataBus] r1data,

	input  wire            re2,
	input  wire [`RegAddr] r2addr,
	output reg  [`DataBus] r2data,

	input  wire [`ByteWEn] we,
	input  wire [`RegAddr] waddr, 
	input  wire [`DataBus] wdata,

	input  wire [`ByteWEn] ex_wreg,
	input  wire [`RegAddr] ex_wraddr,
	input  wire [`DataBus] ex_alures,
	input  wire [`ByteWEn] mem_wreg,
	input  wire [`RegAddr] mem_wraddr,
	input  wire [`DataBus] mem_alures,

	output wire            hazard_ex,
	output wire            hazard_mem
);

	reg [`Word] GPR [0:31];
	integer i;
	
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			for(i = 0; i < 32; i = i + 1)
				GPR[i] <= `ZeroWord;
		end
		else begin
			if(waddr != `ZeroReg) begin
				if(we[0]) GPR[waddr][`Byte0] <= wdata[`Byte0];
				if(we[1]) GPR[waddr][`Byte1] <= wdata[`Byte1];
				if(we[2]) GPR[waddr][`Byte2] <= wdata[`Byte2];
				if(we[3]) GPR[waddr][`Byte3] <= wdata[`Byte3];
			end
		end
	end
	
	//Data transmission
	wire r1_rvalid  = re1 && (r1addr != `ZeroReg);
	wire r1_ex_haz  = ( ex_wreg != `WrDisable) && (r1addr == ex_wraddr);
	wire r1_mem_haz = (mem_wreg != `WrDisable) && (r1addr == mem_wraddr);
	wire r1_wb_haz  = (      we != `WrDisable) && (r1addr == waddr);

	wire r2_rvalid  = re2 && (r2addr != `ZeroReg);
	wire r2_ex_haz  = ( ex_wreg != `WrDisable) && (r2addr == ex_wraddr);
	wire r2_mem_haz = (mem_wreg != `WrDisable) && (r2addr == mem_wraddr);
	wire r2_wb_haz  = (      we != `WrDisable) && (r2addr == waddr);

	wire [`Word] r1_ex_rpl,  r2_ex_rpl;
	wire [`Word] r1_mem_rpl, r2_mem_rpl;
	wire [`Word] r1_wb_rpl,  r2_wb_rpl;

	assign r1_ex_rpl[`Byte0] = ex_wreg[0] ? ex_alures[`Byte0] : GPR[r1addr][`Byte0];
	assign r1_ex_rpl[`Byte1] = ex_wreg[1] ? ex_alures[`Byte1] : GPR[r1addr][`Byte1];
	assign r1_ex_rpl[`Byte2] = ex_wreg[2] ? ex_alures[`Byte2] : GPR[r1addr][`Byte2];
	assign r1_ex_rpl[`Byte3] = ex_wreg[3] ? ex_alures[`Byte3] : GPR[r1addr][`Byte3];

	assign r1_mem_rpl[`Byte0] = mem_wreg[0] ? mem_alures[`Byte0] : GPR[r1addr][`Byte0];
	assign r1_mem_rpl[`Byte1] = mem_wreg[1] ? mem_alures[`Byte1] : GPR[r1addr][`Byte1];
	assign r1_mem_rpl[`Byte2] = mem_wreg[2] ? mem_alures[`Byte2] : GPR[r1addr][`Byte2];
	assign r1_mem_rpl[`Byte3] = mem_wreg[3] ? mem_alures[`Byte3] : GPR[r1addr][`Byte3];

	assign r1_wb_rpl[`Byte0] = we[0] ? wdata[`Byte0] : GPR[r1addr][`Byte0];
	assign r1_wb_rpl[`Byte1] = we[1] ? wdata[`Byte1] : GPR[r1addr][`Byte1];
	assign r1_wb_rpl[`Byte2] = we[2] ? wdata[`Byte2] : GPR[r1addr][`Byte2];
	assign r1_wb_rpl[`Byte3] = we[3] ? wdata[`Byte3] : GPR[r1addr][`Byte3];

	assign r2_ex_rpl[`Byte0] = ex_wreg[0] ? ex_alures[`Byte0] : GPR[r2addr][`Byte0];
	assign r2_ex_rpl[`Byte1] = ex_wreg[1] ? ex_alures[`Byte1] : GPR[r2addr][`Byte1];
	assign r2_ex_rpl[`Byte2] = ex_wreg[2] ? ex_alures[`Byte2] : GPR[r2addr][`Byte2];
	assign r2_ex_rpl[`Byte3] = ex_wreg[3] ? ex_alures[`Byte3] : GPR[r2addr][`Byte3];

	assign r2_mem_rpl[`Byte0] = mem_wreg[0] ? mem_alures[`Byte0] : GPR[r2addr][`Byte0];
	assign r2_mem_rpl[`Byte1] = mem_wreg[1] ? mem_alures[`Byte1] : GPR[r2addr][`Byte1];
	assign r2_mem_rpl[`Byte2] = mem_wreg[2] ? mem_alures[`Byte2] : GPR[r2addr][`Byte2];
	assign r2_mem_rpl[`Byte3] = mem_wreg[3] ? mem_alures[`Byte3] : GPR[r2addr][`Byte3];

	assign r2_wb_rpl[`Byte0] = we[0] ? wdata[`Byte0] : GPR[r2addr][`Byte0];
	assign r2_wb_rpl[`Byte1] = we[1] ? wdata[`Byte1] : GPR[r2addr][`Byte1];
	assign r2_wb_rpl[`Byte2] = we[2] ? wdata[`Byte2] : GPR[r2addr][`Byte2];
	assign r2_wb_rpl[`Byte3] = we[3] ? wdata[`Byte3] : GPR[r2addr][`Byte3];

	always @(*) begin
		casez ({r1_rvalid, r1_ex_haz, r1_mem_haz, r1_wb_haz})
			4'b0???: r1data <= `ZeroWord;
			4'b11??: r1data <= r1_ex_rpl;
			4'b101?: r1data <= r1_mem_rpl;
			4'b1001: r1data <= r1_wb_rpl;
			default: r1data <= GPR[r1addr];
		endcase

		casez ({r2_rvalid, r2_ex_haz, r2_mem_haz, r2_wb_haz})
			4'b0???: r2data <= `ZeroWord;
			4'b11??: r2data <= r2_ex_rpl;
			4'b101?: r2data <= r2_mem_rpl;
			4'b1001: r2data <= r2_wb_rpl;
			default: r2data <= GPR[r2addr];
		endcase
	end

	assign hazard_ex  = (r1_ex_haz  && r1_rvalid) || (r2_ex_haz  && r2_rvalid);
	assign hazard_mem = (r1_mem_haz && r1_rvalid) || (r2_mem_haz && r2_rvalid);

endmodule