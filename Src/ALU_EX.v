/********************MangoMIPS32*******************
Filename:	ALU_EX.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

module ALU_EX
(
    input  wire [`AddrBus] pc,
    input  wire [`ALUOp  ] aluop,
    input  wire [`DataBus] opr1,
    input  wire [`DataBus] opr2,
    input  wire [`DataBus] offset,

    output reg             div_start,
    output reg             div_signed,
    input  wire            div_ready,

    output reg  [`DataBus] alures,
    output reg             resnrdy,
    output wire [`DWord  ] mulhi,
    output wire [`DWord  ] mullo,
    output reg             mul_s,

    output reg             m_en,
    output reg  [`ByteWEn] m_wen, 
    output reg  [`AddrBus] m_vaddr,
    output reg  [`DataBus] m_wdata,

    input  wire            wreg,
    output reg  [`ByteWEn] wregsel,

    output wire            stallreq
);

    assign stallreq = div_start;

    //Signs
    wire opr1_s = opr1[31];
    wire opr2_s = opr2[31];
    wire res_s  = alures[31]; 

    wire [`Word] abs_opr1 = opr1_s ? ~opr1 + 32'd1 : opr1;
    wire [`Word] abs_opr2 = opr2_s ? ~opr2 + 32'd1 : opr2;

    //CLO/CLZ
    reg  [`Word] clzopr;
    reg  [`Word] clzres;

	wire [15:0] part1 = clzres[4] ? clzopr[15: 0] : clzopr[31:16];
	wire [ 7:0] part2 = clzres[3] ? part1 [ 7: 0] : part1 [15: 8];
	wire [ 3:0] part3 = clzres[2] ? part2 [ 3: 0] : part2 [ 7: 4];
	
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

    //Multiply first stage
    reg [`Word] mopr1, mopr2;

    always @(*) begin
        case (aluop)
            `ALU_MUL,
			`ALU_MULT,
			`ALU_MADD,
			`ALU_MSUB: begin
                mopr1   <= abs_opr1;
                mopr2   <= abs_opr2;
                mul_s   <= opr1_s ^ opr2_s;
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
    
    assign mullo[31: 0] = mopr1[15: 0] * mopr2[15: 0];
    assign mullo[63:32] = mopr1[31:16] * mopr2[15: 0];
    assign mulhi[31: 0] = mopr1[15: 0] * mopr2[31:16];
    assign mulhi[63:32] = mopr1[31:16] * mopr2[31:16]; 
/*
    wire [`Word] mul_ll = mopr1[15: 0] * mopr2[15: 0];
    wire [`Word] mul_hl = mopr1[31:16] * mopr2[15: 0];
    wire [`Word] mul_lh = mopr1[15: 0] * mopr2[31:16];
    wire [`Word] mul_hh = mopr1[31:16] * mopr2[31:16]; 
    assign mullo = mul_ll + (mul_hl << 16);
    assign mulhi = mul_lh + (mul_hh << 16);
*/
    //Divider
    always @(*) begin
        case (aluop)
            `ALU_DIV: begin
                div_signed <= `true;
				div_start  <= !div_ready;
            end

            `ALU_DIVU: begin
                div_signed <= `false;
				div_start  <= !div_ready;
            end

            default: begin
                div_signed <= `false;
				div_start  <= `false;
            end
        endcase
    end

    //Memory Data Prepare
    wire [`AddrBus] sl_addr = opr1 + offset;
    reg  [`ByteWEn] sel_l, sel_r;

    always @(*) begin
        m_en    <= `false;
        m_wen   <= `WrDisable;
        m_vaddr <= `ZeroWord;
        m_wdata <= `ZeroWord;
        wregsel <= {4{wreg}};

        case (aluop)
            `ALU_LB,
            `ALU_LBU:begin
                m_en    <= `true;
                m_vaddr <= sl_addr;
            end

            `ALU_LH,
            `ALU_LHU: begin
                m_en    <= `true;
                m_vaddr <= sl_addr;
            end

            `ALU_LW:  begin
                m_en    <= `true;
                m_vaddr <= sl_addr;
            end

            `ALU_LWL: begin
                m_en    <= `true;
                //m_vaddr <= {sl_addr[31:2], 2'b00};
                m_vaddr <= sl_addr;
                wregsel <= sel_l;
            end

            `ALU_LWR: begin
                m_en    <= `true;
                //m_vaddr <= {sl_addr[31:2], 2'b00};
                m_vaddr <= sl_addr;
                wregsel <= sel_r;
            end

            `ALU_SB: begin
                m_en <= `true;
                m_vaddr <= sl_addr;
                m_wdata <= {4{opr2[7:0]}};
                case (sl_addr[1:0])
                    2'b00: m_wen <= 4'b0001;
                    2'b01: m_wen <= 4'b0010;
                    2'b10: m_wen <= 4'b0100;
                    2'b11: m_wen <= 4'b1000;
                endcase
            end

            `ALU_SH: begin
                m_en <= `true;
                m_vaddr <= sl_addr;
                m_wdata <= {2{opr2[15:0]}};
                case (sl_addr[1:0])
                    2'b00:   m_wen <= 4'b0011;
                    2'b10:   m_wen <= 4'b1100;
                    default: m_wen <= `WrDisable;
                endcase
                //if(sl_addr[0]) begin
                //Reserved for exception
                //end
            end

            `ALU_SW:  begin
                m_en    <= `true;
                m_vaddr <= sl_addr;
                m_wdata <= opr2;
                m_wen   <= 4'b1111;
            end

            `ALU_SWL: begin
                m_en    <= `true;
                m_vaddr <= {sl_addr[31:2], 2'b00};
                case (sl_addr[1:0])
                    2'b00: begin
                        m_wen   <= 4'b0001;
                        m_wdata <= {24'b0, opr2[31:24]};
                    end
                    2'b01: begin
						m_wen   <= 4'b0011;
						m_wdata <= {16'b0, opr2[31:16]};
					end
					2'b10: begin
						m_wen   <= 4'b0111;
						m_wdata <= { 8'b0, opr2[31: 8]};
					end
					2'b11: begin
						m_wen   <= 4'b1111;
						m_wdata <= opr2;
					end
                endcase
            end

            `ALU_SWR: begin
				m_en    <= `true;
				m_vaddr <= {sl_addr[31:2], 2'b00};
				case (sl_addr[1:0])
					2'b00: begin
						m_wen   <= 4'b1111;
						m_wdata <= opr2;
					end
					2'b01: begin
						m_wen   <= 4'b1110;
						m_wdata <= {opr2[23:0],  8'b0};
					end	
					2'b10: begin
						m_wen   <= 4'b1100;
						m_wdata <= {opr2[15:0], 16'b0};
					end
					2'b11: begin
						m_wen   <= 4'b1000;
						m_wdata <= {opr2[ 7:0], 24'b0};
					end
				endcase
			end
            //`ALU_LL:
            //`ALU_SC:
            default: begin
                m_en    <= `false;
                m_wen   <= `WrDisable;
                m_vaddr <= `ZeroWord;
                m_wdata <= `ZeroWord;
            end
        endcase

        case (sl_addr[1:0])
            2'b00: begin sel_l <= 4'b1000; sel_r <= 4'b1111; end
            2'b01: begin sel_l <= 4'b1100; sel_r <= 4'b0111; end
            2'b10: begin sel_l <= 4'b1110; sel_r <= 4'b0011; end
            2'b11: begin sel_l <= 4'b1111; sel_r <= 4'b0001; end
        endcase
    end

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
            `ALU_CLO,
            `ALU_CLZ:  alures <= clzres;
            `ALU_BAL:  alures <= pc + 32'd8;
            default:   alures <= `ZeroWord;
        endcase
        
        case (aluop)
            `ALU_LB,
            `ALU_LBU,
            `ALU_LH,
            `ALU_LHU,
            `ALU_LW,
            `ALU_LWL,
            `ALU_LWR,
            `ALU_LL,
            `ALU_MFHI,
            `ALU_MFLO,
            `ALU_MUL: resnrdy <= `true;
            default:  resnrdy <= `false;
        endcase
    end

endmodule