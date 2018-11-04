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

    output reg  [`DataBus] alures,
    output reg             resnrdy,
    output wire [`DWord  ] mulhi,
    output wire [`DWord  ] mullo,
    output reg             mul_s,

    input  wire [`DWord  ] hilo,
    input  wire            mem_whilo,
    input  wire [`DWord  ] mem_hilo,

    output wire            stallreq
);
    //Temp
    assign stallreq = `false;

    wire opr1_s = opr1[31];
    wire opr2_s = opr2[31];
    wire res_s = alures[31]; 

    //CLO/CLZ
    reg  [`Word] clzopr;
    reg  [`Word] clzres;

	wire [15:0] part1 = clzres[4] ? clzopr[31:16] : clzopr[15:0];
	wire [ 7:0] part2 = clzres[3] ? part1 [15: 8] : part1 [ 7:0];
	wire [ 3:0] part3 = clzres[2] ? part2 [ 7: 4] : part2 [ 3:0];
	
	always @(*) begin
        case (aluop)
            `ALU_CLO:  clzopr <= ~opr1;
            `ALU_CLZ:  clzopr <= opr1;
            default:   clzopr <= `ZeroWord;
        endcase

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

    //Multiply
    reg [`Word] mopr1, mopr2;

    always @(*) begin
        case (aluop)
            `ALU_MUL,
			`ALU_MULT,
			`ALU_MADD,
			`ALU_MSUB: begin
                mopr1   <= opr1_s ? ~opr1 + 32'd1 : opr1;
                mopr2   <= opr2_s ? ~opr2 + 32'd1 : opr2;
                mul_s   <= (opr1_s ^ opr2_s);
            end

            `ALU_MULTU,
			`ALU_MADDU,
			`ALU_MSUBU: begin
				mopr1 <= opr1;
				mopr2 <= opr2;
				mul_s <= `Zero;
			end

            default: begin
                mopr1 <= `ZeroWord;
				mopr2 <= `ZeroWord;
				mul_s <= `Zero;
            end
        endcase
    end

    assign mullo[`Lo] = mopr1[15: 0] * mopr2[15: 0];
    assign mullo[`Hi] = mopr1[31:16] * mopr2[15: 0];
    assign mulhi[`Lo] = mopr1[15: 0] * mopr2[31:16];
    assign mulhi[`Hi] = mopr1[31:16] * mopr2[31:16]; 

    //General
    always @(*) begin
        case (aluop)
            `ALU_SLL:  alures <= opr2 << opr1[4:0];
            `ALU_SRL:  alures <= opr2 >> opr1[4:0];
            `ALU_SRA:  alures <= ($signed(opr2)) >>> opr1[4:0];
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
            `ALU_MOV,
            `ALU_MTHI,
            `ALU_MTLO: alures <= opr1;
            `ALU_MFHI: alures <= mem_whilo ? mem_hilo[`Hi] : hilo[`Hi];
            `ALU_MFLO: alures <= mem_whilo ? mem_hilo[`Lo] : hilo[`Lo];
            `ALU_CLO:  alures <= clzres;
            `ALU_CLZ:  alures <= clzres;
            default:   alures <= `ZeroWord;
        endcase

        case (aluop)
            /*
            `ALU_LB,
            `ALU_LBU,
            `ALU_LH,
            `ALU_LHU,
            `ALU_LW,
            `ALU_LWL,
            `ALU_LWR,
            `ALU_LL,
            */
            `ALU_MUL: resnrdy <= `true;
            
            default:  resnrdy <= `false;
        endcase
    end

endmodule