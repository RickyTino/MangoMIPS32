/********************MangoMIPS32*******************
Filename:	ID_EX.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ID_EX
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            flush,

    input  wire [`AddrBus] id_pc,
    input  wire [`ALUOp  ] id_aluop,
    input  wire [`DataBus] id_opr1,
    input  wire [`DataBus] id_opr2,
    input  wire [`RegAddr] id_wraddr,
    input  wire            id_wreg,

    output reg  [`AddrBus] ex_pc,
    output reg  [`ALUOp  ] ex_aluop,
    output reg  [`DataBus] ex_opr1,
    output reg  [`DataBus] ex_opr2,
    output reg  [`RegAddr] ex_wraddr,
    output reg             ex_wreg
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            ex_pc      <= `ZeroWord;
            ex_aluop   <= `ALU_NOP;
            ex_opr1    <= `ZeroWord;
            ex_opr2    <= `ZeroWord;
            ex_wraddr  <= `ZeroReg;
            ex_wreg    <= `false;
        end
        else begin
            if(flush) begin
                ex_pc      <= `ZeroWord;
                ex_aluop   <= `ALU_NOP;
                ex_opr1    <= `ZeroWord;
                ex_opr2    <= `ZeroWord;
                ex_wraddr  <= `ZeroReg;
                ex_wreg    <= `false;
            end
            else if(!stall) begin
                ex_pc      <= id_pc;
                ex_aluop   <= id_aluop;
                ex_opr1    <= id_opr1;
                ex_opr2    <= id_opr2;
                ex_wraddr  <= id_wraddr;
                ex_wreg    <= id_wreg;
            end
        end
    end

endmodule