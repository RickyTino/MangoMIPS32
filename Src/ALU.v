/********************MangoMIPS32*******************
Filename:	ALU.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ALU
(
    input  wire [`AluOp  ] aluop,
    input  wire [`DataBus] op1,
    input  wire [`DataBus] op2,

    output reg  [`DataBus] alures
);

    always @(*) begin
        case(aluop)
            `ALU_SLL:  alures <= opr2 << opr1[4:0];
            `ALU_SRL:  alures <= opr2 >> opr1[4:0];
            `ALU_SRA:  alures <= ($signed(opr2)) >>> opr1[4:0];
            `ALU_MOVZ: alures <= opr1;
            `ALU_MOVN: alures <= opr1;
            `ALU_ADD,
            `ALU_ADDU: alures <= opr1 + opr2;
            `ALU_SUB, 
            `ALU_SUBU: alures <= opr1 - opr2;
            `ALU_AND:  alures <= opr1 & opr2;
            `ALU_OR:   alures <= opr1 | opr2;
            `ALU_XOR:  alures <= opr1 ^ opr2;
            `ALU_NOR:  alures <= ~(opr1 | opr2);
            `ALU_SLT:  alures <= $signed(opr1) < $signed(opr2);
            `ALU_SLTU: alures <= opr1 < opr2;
            default:   alures <= `ZeroWord;
        endcase
    end

endmodule