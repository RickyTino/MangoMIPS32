/********************MangoMIPS32*******************
Filename:	Reg_MEM_WB.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

module Reg_MEM_WB
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            flush,

    input  wire [`AddrBus] mem_pc,
    input  wire [`ALUOp  ] mem_aluop, 
    input  wire [`DataBus] mem_alures,
    input  wire [`DataBus] mem_opr2,
    input  wire [`AddrBus] mem_m_vaddr,
    input  wire [`DataBus] mem_m_rdata,
    input  wire            mem_wreg,
    input  wire [`RegAddr] mem_wraddr,
    input  wire            mem_whilo,
    input  wire [`DWord  ] mem_hilo,

    output reg  [`AddrBus] wb_pc,
    output reg  [`ALUOp  ] wb_aluop, 
    output reg  [`DataBus] wb_alures,
    output reg  [`DataBus] wb_opr2,
    output reg  [`AddrBus] wb_m_vaddr, 
    output reg  [`DataBus] wb_m_rdata,
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
            wb_opr2    <= `ZeroWord;
            wb_m_vaddr <= `ZeroWord;
            wb_m_rdata <= `ZeroWord;
            wb_wreg    <= `false;
            wb_wraddr  <= `ZeroReg;
            wb_whilo   <= `false;
            wb_hilo    <= `ZeroDWord;
        end
        else begin
            case ({flush, stall})
                2'b10, 2'b11: begin
                    wb_pc      <= `ZeroWord;
                    wb_aluop   <= `ALU_NOP;
                    wb_alures  <= `ZeroWord;
                    wb_opr2    <= `ZeroWord;
                    wb_m_vaddr <= `ZeroWord;
                    wb_m_rdata <= `ZeroWord;
                    wb_wreg    <= `false;
                    wb_wraddr  <= `ZeroReg;
                    wb_whilo   <= `false;
                    wb_hilo    <= `ZeroDWord;
                end
                2'b00: begin
                    wb_pc      <= mem_pc;
                    wb_aluop   <= mem_aluop;
                    wb_alures  <= mem_alures;
                    wb_opr2    <= mem_opr2;
                    wb_m_vaddr <= mem_m_vaddr;
                    wb_m_rdata <= mem_m_rdata;
                    wb_wreg    <= mem_wreg;
                    wb_wraddr  <= mem_wraddr;
                    wb_whilo   <= mem_whilo;
                    wb_hilo    <= mem_hilo;
                end
            endcase
        end
    end

endmodule