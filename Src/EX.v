/********************MangoMIPS32*******************
Filename:	EX.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module EX
(
    input  wire [`AluOp  ] aluop,
    input  wire [`DataBus] op1,
    input  wire [`DataBus] op2,
 //   input  wire [`RegAddr] wraddr_i,
 //   input  wire            wreg_i,

 //   output reg  [`RegAddr] wraddr_o,
 //   output reg             wreg_o,
    output reg  [`DataBus] aluout
);

    always @(*) begin
        case(aluop)
            `ALU_SLL:  aluout <= opr2 << opr1[4:0];
            `ALU_SRL:  aluout <= opr2 >> opr1[4:0];
            `ALU_SRA:  aluout <= ($signed(opr2)) >>> opr1[4:0];
            `ALU_MOVZ: aluout <= opr1;
            `ALU_MOVN: aluout <= opr1;
            `ALU_ADD,
            `ALU_ADDU: aluout <= opr1 + opr2;
            `ALU_SUB, 
            `ALU_SUBU: aluout <= opr1 - opr2;
            `ALU_AND:  aluout <= opr1 & opr2;
            `ALU_OR:   aluout <= opr1 | opr2;
            `ALU_XOR:  aluout <= opr1 ^ opr2;
            `ALU_NOR:  aluout <= ~(opr1 | opr2);
            `ALU_SLT:  aluout <= $signed(opr1) < $signed(opr2);
            `ALU_SLTU: aluout <= opr1 < opr2;
            `ALU_LUI:  aluout <= opr2;
            default:   aluout <= `ZeroWord;
        endcase
    end

endmodule