/********************MangoMIPS32*******************
Filename:	EX_MEM.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module EX_MEM
(
    input  wire            clk,
    input  wire            rst,

    input  wire [`AddrBus] ex_pc,
    input  wire [`AluOp  ] ex_aluop, 
    input  wire [`DataBus] ex_alures,
    input  wire [`RegAddr] ex_wraddr,
    input  wire            ex_wreg,

    output reg  [`AddrBus] mem_pc,
    output reg  [`AluOp  ] mem_aluop, 
    output reg  [`DataBus] mem_alures,
    output reg  [`RegAddr] mem_wraddr,
    output reg             mem_wreg
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            mem_pc     <= `ZeroWord;
            mem_aluop  <= `ALU_NOP;
            mem_alures <= `ZeroWord;
            mem_wraddr <= `ZeroReg;
            mem_wreg   <= `false;
        end
        else begin
            mem_pc     <= ex_pc;
            mem_aluop  <= ex_aluop;
            mem_alures <= ex_alures;
            mem_wraddr <= ex_wraddr;
            mem_wreg   <= ex_wreg;
        end
    end

endmodule