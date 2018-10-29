/********************MangoMIPS32*******************
Filename:	ALU.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ALU
(
    input  wire [`ALUOp  ] aluop,
    input  wire [`DataBus] opr1,
    input  wire [`DataBus] opr2,

    output reg  [`DataBus] alures
);
    //CLO/CLZ
    reg  [`Word] clzopr;
    reg  [`Word] clzres;

	wire [15:0] part1 = clzres[4] ? clzopr[31:16] : clzopr[15:0];
	wire [ 7:0] part2 = clzres[3] ? part1 [15: 8] : part1 [ 7:0];
	wire [ 3:0] part3 = clzres[2] ? part2 [ 7: 4] : part2 [ 3:0];
	
	always @(*) begin
		if(clzopr == `ZeroWord) clzres <= 32'd32;
		else begin
			clzres[31:5] <= 27'b0;
			clzres[4]    <= (clzopr[31:16] == 16'b0);
			clzres[3]    <= (part1 [15: 8] ==  8'b0);
			clzres[2]    <= (part2 [ 7: 4] ==  4'b0);
			casez (part3)
				4'b0001: clzres[1:0] <= 2'b11;
				4'b001?: clzres[1:0] <= 2'b10;
				4'b01??: clzres[1:0] <= 2'b01;
				default: clzres[1:0] <= 2'b00;
			endcase
		end
	end

    //General
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

            `ALU_CLO: begin
                clzopr <= ~opr1;
                alures <= clzres;
            end

            `ALU_CLZ: begin
                clzopr <= opr1;
                alures <= clzres;
            end
            
            default:   alures <= `ZeroWord;
        endcase
    end

endmodule