/********************MangoMIPS32*******************
Filename:	ID.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ID
(
    input  wire [`AddrBus] pc,
    input  wire [`DataBus] inst,

    output reg             re1,
    output reg  [`RegAddr] r1addr,
    input  wire [`DataBus] r1data,

    output reg             re2,
    output reg  [`RegAddr] r2addr,
    input  wire [`DataBus] r2data,

    output  reg [`DataBus] op1,
    output  reg [`DataBus] op2,
    output  reg [`AluOp  ] aluop,
    output  reg            wreg,
    output  reg [`RegAddr] wraddr,

//  input  wire [`AluOp]   ex_aluop,
	input  wire            ex_wreg,
	input  wire [`RegAddr] ex_wraddr,
	input  wire [`DataBus] ex_wrdata,
	
//  input  wire [`AluOp]   mem_aluop,
	input  wire            mem_wreg,
	input  wire [`RegAddr] mem_wraddr,
	input  wire [`DataBus] mem_wrdata,
);

    wire [ 5:0] opcode    = inst[31:26];
    wire [ 4:0] rs        = inst[25:21];
    wire [ 4:0] rt        = inst[20:16];
    wire [ 4:0] rd        = inst[15:11];
    wire [ 4:0] sa        = inst[10: 6];
    wire [ 5:0] funct     = inst[ 5: 0];
    wire [15:0] immediate = inst[15: 0];
    wire [25:0] j_offset  = inst[25: 0];

    wire [31:0] zero_ext = {16'b0, immediate};
    wire [31:0] sign_ext = {{16{immediate[15]}}, immediate};
    wire [31:0] lui_ext  = {immediate, 16'b0};

    reg instvalid;
    reg [31:0] ext_imme;

    //TODO: pcp4/pcp8, 

    always @(*) begin
        instvalid <= `false;
        aluop     <= `ALU_NOP;
        r1read    <= `false;
        r2read    <= `false;
        wreg      <= `false;
        r1addr    <=  rs;
        r2addr    <=  rt;
        wraddr    <=  rd;
        ext_imme  <= `ZeroWord;

        case (opcode)
            `OP_SPECIAL: begin
                if(sa == 5'b00000) begin
                    case (funct) begin
                        `SP_SLLV: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SLL;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_SRLV: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SRL;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_SRAV: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SRA;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_MOVZ: begin
                            instvalid <= `true;
                            aluop     <= `ALU_MOVZ;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= (opr2 == `ZeroWord);
                        end

                        `SP_MOVN: begin
                            instvalid <= `true;
                            aluop     <= `ALU_MOVN;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= (opr2 != `ZeroWord);
                        end

                        `SP_ADD: begin
                            instvalid <= `true;
                            aluop     <= `ALU_ADD;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_ADDU: begin
                            instvalid <= `true;
                            aluop     <= `ALU_ADDU;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_SUB: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SUB;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_SUBU: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SUBU;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_AND: begin
                            instvalid <= `true;
                            aluop     <= `ALU_AND;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_OR: begin
                            instvalid <= `true;
                            aluop     <= `ALU_OR;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_XOR: begin
                            instvalid <= `true;
                            aluop     <= `ALU_XOR;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_NOR: begin
                            instvalid <= `true;
                            aluop     <= `ALU_NOR;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_SLT: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SLT;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP_SLTU: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SLTU;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end
                    endcase
                end
                else if(rs == 5'b00000) begin
                    case (funct) begin
                        `SP_SLL: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SLL;
                            r2read    <= `true;
                            wreg      <= `true;
                            ext_imme  <=  sa;
                        end

                        `SP_SRL: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SRL;
                            r2read    <= `true;
                            wreg      <= `true;
                            ext_imme  <=  sa;
                        end

                        `SP_SRA: begin
                            instvalid <= `true;
                            aluop     <= `ALU_SRA;
                            r2read    <= `true;
                            wreg      <= `true;
                            ext_imme  <=  sa;
                        end
                    endcase
                end
            end

            `OP_REGIMM: begin
                /*
                case (rt) begin

                endcase
                */
            end

            `OP_SPECIAL2: begin
            
            end

            `OP_ADDI: begin
                instvalid <= `true;
                aluop     <= `ALU_ADD;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  sign_ext;
            end

            `OP_ADDIU: begin
                instvalid <= `true;
                aluop     <= `ALU_ADDU;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  sign_ext;
            end

            `OP_SLTI: begin
                instvalid <= `true;
                aluop     <= `ALU_SLT;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  sign_ext;
            end

            `OP_SLTIU: begin
                instvalid <= `true;
                aluop     <= `ALU_SLT;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  sign_ext;
            end

            `OP_ANDI: begin
                instvalid <= `true;
                aluop     <= `ALU_AND;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  zero_ext;
            end

            `OP_ORI: begin
                instvalid <= `true;
                aluop     <= `ALU_OR;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  zero_ext;
            end

            `OP_XORI: begin
                instvalid <= `true;
                aluop     <= `ALU_XOR;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  zero_ext;
            end

            `OP_LUI: begin
                if(rs = 5'b00000) begin
                    instvalid <= `true;
                    aluop     <= `ALU_LUI;
                    wreg      <= `true;
                    wraddr    <=  rt;
                    ext_imme  <=  lui_ext;
                end
            end
        endcase
    end

    wire ex_r1_haz  = ex_wreg  && ( ex_wraddr == r1addr);
    wire ex_r2_haz  = ex_wreg  && ( ex_wraddr == r2addr);
    wire mem_r1_haz = mem_wreg && (mem_wraddr == r1addr);
    wire mem_r2_haz = mem_wreg && (mem_wraddr == r2addr);

    always @(*) begin
        case({r1read, ex_r1_haz, mem_r1_haz})
            3'b110,
            3'b111:  opr1 <= ex_wrdata;
            3'b101:  opr1 <= mem_wrdata;
            3'b100:  opr1 <= r1data;
            default: opr1 <= ext_imme;
        endcase

        case({r2read, ex_r2_haz, mem_r2_haz})
            3'b110,
            3'b111:  opr2 <= ex_wrdata;
            3'b101:  opr2 <= mem_wrdata;
            3'b100:  opr2 <= r2data;
            default: opr2 <= ext_imme;
        endcase
    end

endmodule
    