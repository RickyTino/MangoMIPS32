/********************MangoMIPS32*******************
Filename:	ID_EX.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ID_EX
(
    input  wire  clk,
    input  wire  rst,

    input  wire [`AddrBus] id_pc,
    input  wire [`AluOp  ] id_aluop,
    input  wire [`DataBus] id_op1,
    input  wire [`DataBus] id_op2,
    input  wire [`RedAddr] id_wraddr,
    input  wire            id_wreg,

    output reg  [`AddrBus] ex_pc,
    output reg  [`AluOp  ] ex_aluop,
    output reg  [`DataBus] ex_op1,
    output reg  [`DataBus] ex_op2,
    output reg  [`RedAddr] ex_wraddr,
    output reg             ex_wreg
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            ex_pc     <= `ZeroWord;
            ex_aluop  <= `ALU_NOP;
            ex_op1    <= `ZeroWord;
            ex_op2    <= `ZeroWord;
            ex_wraddr <= `ZeroReg;
            ex_wreg   <= `false;
        end
        else begin
            ex_pc     <= id_pc;
            ex_aluop  <= id_aluop;
            ex_op1    <= id_op1;
            ex_op2    <= id_op2;
            ex_wraddr <= id_wraddr;
            ex_wreg   <= id_wreg;
        end
    end

endmodule