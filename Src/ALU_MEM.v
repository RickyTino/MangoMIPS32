/********************MangoMIPS32*******************
Filename:	ALU_MEM.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ALU_MEM
(
    input  wire [`ALUOp  ] aluop,
    input  wire [`DataBus] alures_i,
    input  wire [`DWord  ] mulhi,
    input  wire [`DWord  ] mullo,
    input  wire            mul_s,
    input  wire [`DWord  ] divres,
    input  wire [`DWord  ] hilo_i,

    output reg  [`DataBus] alures_o,
    output reg             whilo,
    output reg  [`DWord  ] hilo_o
);
    
    wire [47: 0 ] reslo = mullo[31:0] + (mullo[63:32] << 16);
    wire [47: 0 ] reshi = mulhi[31:0] + (mulhi[63:32] << 16);
    wire [`DWord] umres = reslo + (reshi << 16);
/*
    wire [`DWord] umres = mullo + (mulhi << 16);
*/
    wire [`DWord] smres = mul_s ? ~umres + 64'b1 : umres;

    always @(*) begin
        case (aluop)
            `ALU_MFHI: begin
                whilo    <= `false;
                hilo_o   <= hilo_i; 
                alures_o <= hilo_i[`Hi];
            end

            `ALU_MFLO: begin
                whilo    <= `false;
                hilo_o   <= hilo_i; 
                alures_o <= hilo_i[`Lo];
            end

            `ALU_MTHI: begin
                whilo    <= `true;
                hilo_o   <= {alures_i, hilo_i[`Lo]};
                alures_o <= `ZeroWord;
            end

            `ALU_MTLO: begin
                whilo    <= `true;
                hilo_o   <= {hilo_i[`Hi], alures_i};
                alures_o <= `ZeroWord;
            end

            `ALU_MULT: begin
                whilo    <= `true;
                hilo_o   <= smres; 
                alures_o <= `ZeroWord;
            end

            `ALU_MULTU: begin
                whilo    <= `true;
                hilo_o   <= umres; 
                alures_o <= `ZeroWord;
            end

            `ALU_MUL: begin
                whilo    <= `false;
                hilo_o   <= hilo_i; 
                alures_o <= smres[31:0];
            end

            `ALU_MADD: begin
                whilo    <= `true;
                hilo_o   <= hilo_i + smres; 
                alures_o <= `ZeroWord;
            end

            `ALU_MADDU: begin
                whilo    <= `true;
                hilo_o   <= hilo_i + umres; 
                alures_o <= `ZeroWord;
            end

            `ALU_MSUB: begin
                whilo    <= `true;
                hilo_o   <= hilo_i - smres; 
                alures_o <= `ZeroWord;
            end

            `ALU_MSUBU: begin
                whilo    <= `true;
                hilo_o   <= hilo_i - umres; 
                alures_o <= `ZeroWord;
            end

            `ALU_DIV,
            `ALU_DIVU: begin
                whilo    <= `true;
                hilo_o   <= divres;
                alures_o <= `ZeroWord;
            end
            
            default:  begin
                whilo    <= `false;
                hilo_o   <= hilo_i; 
                alures_o <= alures_i;
            end
        endcase
    end

endmodule