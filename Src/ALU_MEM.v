/********************MangoMIPS32*******************
Filename:	ALU_MEM.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

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
    output reg  [`DWord  ] hilo_o,
    output reg             resnrdy
);
    
    wire [47: 0 ] reslo = mullo[31:0] + (mullo[63:32] << 16);
    wire [47: 0 ] reshi = mulhi[31:0] + (mulhi[63:32] << 16);
    wire [`DWord] umres = reslo + (reshi << 16);
    wire [`DWord] smres = mul_s ? ~umres + 64'b1 : umres;

    always @(*) begin
        resnrdy  <= `false;
        whilo    <= `false;
        hilo_o   <= hilo_i; 
        alures_o <= alures_i;

        case (aluop)
            `ALU_MFHI: alures_o <= hilo_i[`Hi];
            `ALU_MFLO: alures_o <= hilo_i[`Lo];
            `ALU_MUL:  alures_o <= smres[31:0];

            `ALU_MTHI: begin
                whilo    <= `true;
                hilo_o   <= {alures_i, hilo_i[`Lo]};
            end

            `ALU_MTLO: begin
                whilo    <= `true;
                hilo_o   <= {hilo_i[`Hi], alures_i};
            end

            `ALU_MULT: begin
                whilo    <= `true;
                hilo_o   <= smres; 
            end

            `ALU_MULTU: begin
                whilo    <= `true;
                hilo_o   <= umres; 
            end

            `ALU_MADD: begin
                whilo    <= `true;
                hilo_o   <= hilo_i + smres; 
            end

            `ALU_MADDU: begin
                whilo    <= `true;
                hilo_o   <= hilo_i + umres; 
            end

            `ALU_MSUB: begin
                whilo    <= `true;
                hilo_o   <= hilo_i - smres; 
            end

            `ALU_MSUBU: begin
                whilo    <= `true;
                hilo_o   <= hilo_i - umres; 
            end

            `ALU_DIV,
            `ALU_DIVU: begin
                whilo    <= `true;
                hilo_o   <= divres;
            end
            
            `ALU_LB,
            `ALU_LBU,
            `ALU_LH,
            `ALU_LHU,
            `ALU_LW,
            `ALU_LWL,
            `ALU_LWR,
            `ALU_LL: resnrdy <= `true;

            default:  begin
                resnrdy <=  `false;
                whilo    <= `false;
                hilo_o   <= hilo_i; 
                alures_o <= alures_i;
            end
        endcase
    end

endmodule