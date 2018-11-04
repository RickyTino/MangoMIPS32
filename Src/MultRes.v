/********************MangoMIPS32*******************
Filename:	MultRes.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module MultRes
(
    input  wire [`ALUOp  ] aluop,
    input  wire [`DataBus] alures_i,
    input  wire [`DWord  ] mulhi,
    input  wire [`DWord  ] mullo,
    input  wire [`DWord  ] hilo_i,

    output reg  [`Word   ] alures_o,
    output reg             whilo,
    output reg  [`DWord  ] hilo_o,
);
    
    always @(*) begin
        case (aluop)
            `ALU_MTHI: begin
                whilo  <= `true;
                hilo_o <= {alures, hilo_i[`Lo]};
            end

            `ALU_MTLO: begin
                whilo  <= `true;
                hilo_o <= {hilo_i[`Hi], alures};
            end

            `ALU_MULT: begin
                whilo <= `true;

            `ALU_MULTU:
            `ALU_MUL:
            `ALU_MADD:
            `ALU_MADDU:
            `ALU_MSUB:
            `ALU_MSUBU:
        endcase
    end

endmodule