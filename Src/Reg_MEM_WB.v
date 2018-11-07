/********************MangoMIPS32*******************
Filename:	Reg_MEM_WB.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module Reg_MEM_WB
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            flush,

    input  wire [`AddrBus] mem_pc,
    input  wire [`ALUOp  ] mem_aluop, 
    input  wire [`DataBus] mem_alures,
    input  wire [`DataBus] mem_memdata,
    input  wire            mem_wreg,
    input  wire [`RegAddr] mem_wraddr,
    input  wire            mem_whilo,
    input  wire [`DWord  ] mem_hilo,

    output reg  [`AddrBus] wb_pc,
    output reg  [`ALUOp  ] wb_aluop, 
    output reg  [`DataBus] wb_alures,
    output reg  [`DataBus] wb_memdata,
    output reg             wb_wreg,
    output reg  [`RegAddr] wb_wraddr,
    output reg             wb_whilo,
    output reg  [`DWord  ] wb_hilo
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            wb_pc      <= `ZeroWord;
            wb_aluop   <= `ALU_NOP;
            wb_alures  <= `ZeroWord;
            wb_memdata <= `ZeroWord;
            wb_wreg    <= `false;
            wb_wraddr  <= `ZeroReg;
            wb_whilo   <= `false;
            wb_hilo    <= `ZeroDWord;
        end
        else begin
            if(flush) begin
                wb_pc      <= `ZeroWord;
                wb_aluop   <= `ALU_NOP;
                wb_alures  <= `ZeroWord;
                wb_memdata <= `ZeroWord;
                wb_wreg    <= `false;
                wb_wraddr  <= `ZeroReg;
                wb_whilo   <= `false;
                wb_hilo    <= `ZeroDWord;
            end
            else if(!stall) begin
                wb_pc      <= mem_pc;
                wb_aluop   <= mem_aluop;
                wb_alures  <= mem_alures;
                wb_memdata <= mem_memdata;
                wb_wreg    <= mem_wreg;
                wb_wraddr  <= mem_wraddr;
                wb_whilo   <= mem_whilo;
                wb_hilo    <= mem_hilo;
            end
        end
    end

endmodule