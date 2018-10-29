/********************MangoMIPS32*******************
Filename:	ALU.v
Author:		RickyTino
Version:	Unreleased 20181029
**************************************************/
`include "defines.v"

module ALU
(
    input  wire [`ALUOp  ] aluop,
    input  wire [`DataBus] opr1,
    input  wire [`DataBus] opr2,

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