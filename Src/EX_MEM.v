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
    input  wire            stall,
    input  wire            flush,

    input  wire [`AddrBus] ex_pc,
    input  wire [`ALUOp  ] ex_aluop, 
    input  wire [`DataBus] ex_alures,
    input  wire [`DWord  ] ex_mulhi,
    input  wire [`DWord  ] ex_mullo,
    input  wire            ex_mul_s,
    input  wire            ex_wreg,
    input  wire [`RegAddr] ex_wraddr,
    
    output reg  [`AddrBus] mem_pc,
    output reg  [`ALUOp  ] mem_aluop, 
    output reg  [`DataBus] mem_alures,
    output reg  [`DWord  ] mem_mulhi,
    output reg  [`DWord  ] mem_mullo,
    output reg             mem_mul_s,
    output reg             mem_wreg,
    output reg  [`RegAddr] mem_wraddr
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            mem_pc     <= `ZeroWord;
            mem_aluop  <= `ALU_NOP;
            mem_alures <= `ZeroWord;
            mem_mulhi  <= `ZeroDWord;
            mem_mullo  <= `ZeroDWord;
            mem_mul_s  <= `Zero;
            mem_wreg   <= `false;
            mem_wraddr <= `ZeroReg;
        end
        else begin
            if(flush) begin
                mem_pc     <= `ZeroWord;
                mem_aluop  <= `ALU_NOP;
                mem_alures <= `ZeroWord;
                mem_mulhi  <= `ZeroDWord;
                mem_mullo  <= `ZeroDWord;
                mem_mul_s  <= `Zero;
                mem_wreg   <= `false;
                mem_wraddr <= `ZeroReg;
            end
            else if(!stall) begin
                mem_pc     <= ex_pc;
                mem_aluop  <= ex_aluop;
                mem_alures <= ex_alures;
                mem_mulhi  <= ex_mulhi;
                mem_mullo  <= ex_mullo;
                mem_mul_s  <= ex_mul_s;
                mem_wreg   <= ex_wreg;
                mem_wraddr <= ex_wraddr;
            end
        end
    end

endmodule