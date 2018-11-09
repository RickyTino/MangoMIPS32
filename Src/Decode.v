/********************MangoMIPS32*******************
Filename:	Decode.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module Decode
(
    input  wire [`AddrBus] pc,
    input  wire [`AddrBus] pcp4,
    input  wire [`DataBus] inst,

    output reg             r1read,
    output reg  [`RegAddr] r1addr,
    input  wire [`DataBus] r1data,

    output reg             r2read,
    output reg  [`RegAddr] r2addr,
    input  wire [`DataBus] r2data,

    output  reg [`DataBus] opr1,
    output  reg [`DataBus] opr2,
    output  reg [`ALUOp  ] aluop,
    output  reg            wreg,
    output  reg [`RegAddr] wraddr,

	input  wire            ex_wreg,
	input  wire [`RegAddr] ex_wraddr,
	input  wire [`DataBus] ex_alures,
    input  wire            ex_resnrdy,

	input  wire            mem_wreg,
	input  wire [`RegAddr] mem_wraddr,
	input  wire [`DataBus] mem_alures,
    input  wire            mem_resnrdy,

    output reg             isbranch,
    input  wire            inslot,
    output reg             clrslot,
    output reg             br_flag,
    output reg  [`AddrBus] br_addr,

    output wire            stallreq
);

    wire [ 5:0] opcode    = inst[31:26];
    wire [ 4:0] rs        = inst[25:21];
    wire [ 4:0] rt        = inst[20:16];
    wire [ 4:0] rd        = inst[15:11];
    wire [ 4:0] sa        = inst[10: 6];
    wire [ 5:0] funct     = inst[ 5: 0];
    wire [15:0] immediate = inst[15: 0];
    wire [25:0] j_offset  = inst[25: 0];

    wire [`Word] zero_ext = {16'b0, immediate};
    wire [`Word] sign_ext = {{16{immediate[15]}}, immediate};
    wire [`Word] lui_ext  = {immediate, 16'b0};

    wire opr1_lez = opr1[31] || (opr1 == `ZeroWord);
    wire opr_eq   = (opr1 & ~opr2) == `ZeroWord;
    wire [`Word] br_target = pcp4 + (sign_ext << 2); 

    reg instvalid;
    reg [`Word] ext_imme;

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
        isbranch  <= `false;
        br_flag   <= `false;
        br_addr   <= `ZeroWord;
        clrslot   <= `false;

        case (opcode)
            `OP_SPECIAL: begin
                case (funct)
                    `SP_SLLV: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLL;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SRLV: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRL;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SRAV: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRA;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_JR: if({rt, rd, sa} == 15'b0) begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= `true;
                        br_addr   <= opr1;
                    end

                    `SP_JALR: if({rt, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= (rd == `ZeroReg) ? `GPR_ra : rd;
                        isbranch  <= `true;
                        br_flag   <= `true;
                        br_addr   <= opr1;
                    end

                    `SP_MOVZ: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MOV;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= (opr2 == `ZeroWord);
                    end

                    `SP_MOVN: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MOV;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= (opr2 != `ZeroWord);
                    end

                    `SP_MFHI: if({rs, rt, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MFHI;
                        wreg      <= `true;
                    end

                    `SP_MTHI: if({rt, rd, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MTHI;
                        r1read    <= `true;
                    end

                    `SP_MFLO: if({rs, rt, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MFLO;
                        wreg      <= `true;
                    end

                    `SP_MTLO: if({rt, rd, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MTLO;
                        r1read    <= `true;
                    end

                    `SP_MULT: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MULT;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `SP_MULTU: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MULTU;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `SP_DIV: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_DIV;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `SP_DIVU: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_DIVU;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `SP_ADD: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_ADD;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_ADDU: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_ADDU;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SUB: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SUB;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SUBU: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SUBU;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_AND: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_AND;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_OR: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_OR;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_XOR: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_XOR;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_NOR: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_NOR;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SLT: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLT;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SLTU: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLTU;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `SP_SLL: if(rs == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLL;
                        r2read    <= `true;
                        wreg      <= `true;
                        ext_imme  <=  sa;
                    end

                    `SP_SRL: if(rs == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRL;
                        r2read    <= `true;
                        wreg      <= `true;
                        ext_imme  <=  sa;
                    end

                    `SP_SRA: if(rs == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRA;
                        r2read    <= `true;
                        wreg      <= `true;
                        ext_imme  <=  sa;
                    end

                    //SYNC temporarily decode as nop
                    `SP_SYNC: if({rs, rt, rd} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_NOP;
                    end
                endcase
            end

            `OP_REGIMM: begin
                case (rt)
                    `RI_BLTZ: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                    end

                    `RI_BGEZ: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                    end

                    `RI_BLTZL: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                        clrslot   <= opr1[31];
                    end

                    `RI_BGEZL: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                        clrslot   <= !opr1[31];
                    end

                    `RI_BLTZAL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                    end

                    `RI_BGEZAL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                    end

                    `RI_BLTZALL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                        clrslot   <= opr1[31];
                    end

                    `RI_BGEZALL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                        clrslot   <= !opr1[31];
                    end
                endcase
            end

            `OP_J: begin
                instvalid <= `true;
                isbranch  <= `true;
                br_flag   <= `true;
                br_addr   <= {pcp4[31:28], j_offset, 2'b00};
            end

            `OP_JAL: begin
                instvalid <= `true;
                aluop     <= `ALU_BAL;
                wreg      <= `true;
                wraddr    <= `GPR_ra;
                isbranch  <= `true;
                br_flag   <= `true;
                br_addr   <= {pcp4[31:28], j_offset, 2'b00};
            end

            `OP_BEQ: begin
                instvalid <= `true;
                r1read    <= `true;
                r2read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr_eq;
                br_addr   <= br_target;
            end

            `OP_BNE: begin
                instvalid <= `true;
                r1read    <= `true;
                r2read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr_eq;
                br_addr   <= br_target;
            end

            `OP_BLEZ: if(rt == 5'b0) begin
                instvalid <= `true;
                r1read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr1_lez;
                br_addr   <= br_target;
            end

            `OP_BGTZ: if(rt == 5'b0) begin
                instvalid <= `true;
                r1read    <= `true;
                isbranch  <= `true;
                br_flag   <= !opr1_lez;
                br_addr   <= br_target;
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

            `OP_LUI: if(rs == 5'b0) begin
                instvalid <= `true;
                aluop     <= `ALU_OR;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <=  rt;
                ext_imme  <=  lui_ext;
            end

            `OP_COP0: begin

            end
            
            `OP_BEQL: begin
                instvalid <= `true;
                r1read    <= `true;
                r2read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr_eq;
                br_addr   <= br_target;
                clrslot   <= opr_eq;
            end

            `OP_BNEL: begin
                instvalid <= `true;
                r1read    <= `true;
                r2read    <= `true;
                isbranch  <= `true;
                br_flag   <= !opr_eq;
                br_addr   <= br_target;
                clrslot   <= !opr_eq;
            end

            `OP_BLEZL: if(rt == 5'b0) begin
                instvalid <= `true;
                r1read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr1_lez;
                br_addr   <= br_target;
                clrslot   <= opr1_lez;
            end

            `OP_BGTZL: if(rt == 5'b0) begin
                instvalid <= `true;
                r1read    <= `true;
                isbranch  <= `true;
                br_flag   <= !opr1_lez;
                br_addr   <= br_target;
                clrslot   <= !opr1_lez;
            end

            `OP_SPECIAL2: begin
                if(sa == 5'b0) begin
                    case (funct)
                        `SP2_MADD: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MADD;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `SP2_MADDU: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MADDU;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `SP2_MUL: begin
                            instvalid <= `true;
                            aluop     <= `ALU_MUL;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `SP2_MSUB: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MSUB;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `SP2_MSUBU: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MSUBU;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `SP2_CLZ: begin
                            instvalid <= `true;
                            aluop     <= `ALU_CLZ;
                            r1read    <= `true;
                            wreg      <= `true;
                        end

                        `SP2_CLO: begin
                            instvalid <= `true;
                            aluop     <= `ALU_CLO;
                            r1read    <= `true;
                            wreg      <= `true;
                        end
                    endcase
                end
            end

            `OP_PREF: begin //Temporarily decode as nop
                instvalid <= `true;
            end

            `OP_CACHE: begin //Temporarily decode as nop
                instvalid <= `true;
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
            3'b111:  opr1 <= ex_alures;
            3'b101:  opr1 <= mem_alures;
            3'b100:  opr1 <= r1data;
            default: opr1 <= ext_imme;
        endcase

        case({r2read, ex_r2_haz, mem_r2_haz})
            3'b110,
            3'b111:  opr2 <= ex_alures;
            3'b101:  opr2 <= mem_alures;
            3'b100:  opr2 <= r2data;
            default: opr2 <= ext_imme;
        endcase

    end

    wire    ex_nrdy = ( ex_r1_haz ||  ex_r2_haz) &&  ex_resnrdy;
    wire   mem_nrdy = (mem_r1_haz || mem_r2_haz) && mem_resnrdy;
    assign stallreq = ex_nrdy || mem_nrdy;

endmodule
    