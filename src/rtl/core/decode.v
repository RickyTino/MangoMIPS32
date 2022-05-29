/********************MangoMIPS32*******************
Filename:   Decode.v
Author:     RickyTino
Version:    v1.1.3
**************************************************/
`include "config.v"
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

    output wire [`DataBus] opr1,
    output wire [`DataBus] opr2,
    output reg  [`ALUOp  ] aluop,
    output reg  [`CacheOp] cacheop,
    output wire [`DataBus] offset,
    output wire [`CP0Addr] cp0sel,
    output reg             wreg,
    output reg  [`RegAddr] wraddr,

    input  wire            ex_resnrdy,
    input  wire            mem_resnrdy,
    input  wire            hazard_ex,
    input  wire            hazard_mem,

    output reg             isbranch,
    input  wire            inslot,
    output reg             clrslot,
    output reg             br_flag,
    output reg  [`AddrBus] br_addr,

    input  wire            usermode,
    input  wire [`DataBus] cp0_Status,
    input  wire [`ExcBus ] excp_i,
    output reg  [`ExcBus ] excp_o,
    output reg  [`CPNum  ] ecpnum,

    output wire            stallreq
);

    wire [ 5: 0] opcode    = inst[31:26];
    wire [ 4: 0] rs        = inst[25:21];
    wire [ 4: 0] rt        = inst[20:16];
    wire [ 4: 0] rd        = inst[15:11];
    wire [ 4: 0] sa        = inst[10: 6];
    wire [ 5: 0] funct     = inst[ 5: 0];
    wire [15: 0] immediate = inst[15: 0];
    wire [25: 0] j_offset  = inst[25: 0];
    wire [ 2: 0] sel       = inst[ 2: 0];

    wire [`Word] zero_ext = {16'b0, immediate};
    wire [`Word] sign_ext = {{16{immediate[15]}}, immediate};
    wire [`Word] lui_ext  = {immediate, 16'b0};

    wire opr1_lez = opr1[31] || (opr1 == `ZeroWord);
    wire opr_eq   = (opr1 ^ opr2) == `ZeroWord;
    wire [`Word] br_target = pcp4 + (sign_ext << 2); 

    reg  [`Word] ext_imme;

    assign offset = sign_ext;
    assign cp0sel = {rd, sel};

    // Exceptions
    reg  instvalid;
    reg  instwait;
    reg  exc_sc, exc_bp, exc_cpu, exc_eret;

    always @(*) begin
        excp_o            <= excp_i;
        excp_o[`Exc_SysC] <= exc_sc;
        excp_o[`Exc_Bp  ] <= exc_bp; 
        excp_o[`Exc_RI  ] <= !instvalid;
        excp_o[`Exc_CpU ] <= exc_cpu;
        excp_o[`Exc_ERET] <= exc_eret;
    end

    // Decode
    always @(*) begin
        instvalid <= `false;
        aluop     <= `ALU_NOP;
        cacheop   <= `COP_NOP;
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
        exc_sc    <= `false;
        exc_bp    <= `false;
        exc_cpu   <= `false;
        exc_eret  <= `false;
        ecpnum    <= `CP0;
        instwait  <= `false;

        case (opcode)
            `OP_SPECIAL: begin
                case (funct)
                    `FUNCT_SP_SLL: if(rs == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLL;
                        r2read    <= `true;
                        wreg      <= `true;
                        ext_imme  <=  sa;
                    end

                    `FUNCT_SP_MOVCI: begin // CP1 instruction
                        instvalid <= `true;
                        exc_cpu   <= !cp0_Status[`CU1];
                        ecpnum    <= `CP1;
                    end

                    `FUNCT_SP_SRL: if(rs == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRL;
                        r2read    <= `true;
                        wreg      <= `true;
                        ext_imme  <=  sa;
                    end

                    `FUNCT_SP_SRA: if(rs == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRA;
                        r2read    <= `true;
                        wreg      <= `true;
                        ext_imme  <=  sa;
                    end

                    `FUNCT_SP_SLLV: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLL;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_SRLV: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRL;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_SRAV: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SRA;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_JR: if({rt, rd} == 10'b0) begin // Supports JR.HB also
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= `true;
                        br_addr   <= opr1;
                    end

                    `FUNCT_SP_JALR: if(rt == 5'b0) begin  // Supports JALR.HB also
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= rd;
                        isbranch  <= `true;
                        br_flag   <= `true;
                        br_addr   <= opr1;
                    end

                    `FUNCT_SP_MOVZ: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MOV;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= (opr2 == `ZeroWord);
                    end

                    `FUNCT_SP_MOVN: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MOV;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= (opr2 != `ZeroWord);
                    end

                    `FUNCT_SP_SYSCALL: begin
                        instvalid <= `true;
                        exc_sc    <= `true;
                    end

                    `FUNCT_SP_BREAK: begin
                        instvalid <= `true;
                        exc_bp    <= `true;
                    end

                    // SYNC temporarily decode as nop
                    `FUNCT_SP_SYNC: if({rs, rt, rd} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_NOP;
                    end

                    `FUNCT_SP_MFHI: if({rs, rt, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MFHI;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_MTHI: if({rt, rd, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MTHI;
                        r1read    <= `true;
                    end

                    `FUNCT_SP_MFLO: if({rs, rt, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MFLO;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_MTLO: if({rt, rd, sa} == 15'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MTLO;
                        r1read    <= `true;
                    end

                    `FUNCT_SP_MULT: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MULT;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_MULTU: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_MULTU;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_DIV: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_DIV;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_DIVU: if({rd, sa} == 10'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_DIVU;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_ADD: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_ADD;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_ADDU: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_ADDU;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_SUB: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SUB;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_SUBU: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SUBU;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_AND: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_AND;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_OR: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_OR;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_XOR: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_XOR;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_NOR: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_NOR;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_SLT: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLT;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_SLTU: if(sa == 5'b0) begin
                        instvalid <= `true;
                        aluop     <= `ALU_SLTU;
                        r1read    <= `true;
                        r2read    <= `true;
                        wreg      <= `true;
                    end

                    `FUNCT_SP_TGE: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TGE;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_TGEU: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TGEU;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_TLT: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TLT;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_TLTU: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TLTU;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_TEQ: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TEQ;
                        r1read    <= `true;
                        r2read    <= `true;
                    end

                    `FUNCT_SP_TNE: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TNE;
                        r1read    <= `true;
                        r2read    <= `true;
                    end
                endcase
            end

            `OP_REGIMM: begin
                case (rt)
                    `RT_REGIMM_BLTZ: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                    end

                    `RT_REGIMM_BGEZ: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                    end

                    `RT_REGIMM_BLTZL: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                        clrslot <= !opr1[31];
                    end

                    `RT_REGIMM_BGEZL: begin
                        instvalid <= `true;
                        r1read    <= `true;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                        clrslot <= opr1[31];
                    end

                    `RT_REGIMM_TGEI: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TGE;
                        r1read    <= `true;
                        ext_imme  <=  sign_ext;
                    end

                    `RT_REGIMM_TGEIU: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TGEU;
                        r1read    <= `true;
                        ext_imme  <=  sign_ext;
                    end
                    
                    `RT_REGIMM_TLTI: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TLT;
                        r1read    <= `true;
                        ext_imme  <=  sign_ext;
                    end
                    
                    `RT_REGIMM_TLTIU: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TLTU;
                        r1read    <= `true;
                        ext_imme  <=  sign_ext;
                    end
                    
                    `RT_REGIMM_TEQI: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TEQ;
                        r1read    <= `true;
                        ext_imme  <=  sign_ext;
                    end
                    
                    `RT_REGIMM_TNEI: begin
                        instvalid <= `true;
                        aluop     <= `ALU_TNE;
                        r1read    <= `true;
                        ext_imme  <=  sign_ext;
                    end

                    `RT_REGIMM_BLTZAL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                    end

                    `RT_REGIMM_BGEZAL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                    end

                    `RT_REGIMM_BLTZALL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= opr1[31];
                        br_addr   <= br_target;
                        clrslot <= !opr1[31];
                    end

                    `RT_REGIMM_BGEZALL: begin
                        instvalid <= `true;
                        aluop     <= `ALU_BAL;
                        r1read    <= `true;
                        wreg      <= `true;
                        wraddr    <= `GPR_ra;
                        isbranch  <= `true;
                        br_flag   <= !opr1[31];
                        br_addr   <= br_target;
                        clrslot <= opr1[31];
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
                br_flag   <= !opr_eq;
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
                aluop     <= `ALU_SLTU;
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
                if(usermode && !cp0_Status[`CU0]) begin
                    exc_cpu <= `true;
                end
                else begin
                    case (rs)
                        `RS_COP0_MFC0: begin
                            instvalid <= `true;
                            aluop     <= `ALU_MFC0;
                            wreg      <= `true;
                            wraddr    <= rt;
                        end

                        `RS_COP0_MTC0: begin
                            instvalid <= `true;
                            aluop     <= `ALU_MTC0;
                            r2read    <= `true;
                        end

                        `RS_COP0_CO: begin
                            case (funct)
                                `FUNCT_COP0_TLBR: begin
                                    instvalid <= `true;
                                    aluop     <= `ALU_TLBR;
                                end

                                `FUNCT_COP0_TLBWI: begin
                                    instvalid <= `true;
                                    aluop     <= `ALU_TLBWI;
                                end

                                `FUNCT_COP0_TLBWR: begin
                                    instvalid <= `true;
                                    aluop     <= `ALU_TLBWR;
                                end

                                `FUNCT_COP0_TLBP: begin
                                    instvalid <= `true;
                                    aluop     <= `ALU_TLBP;
                                end

                                `FUNCT_COP0_ERET: begin
                                    instvalid <= `true;
                                    aluop     <= `ALU_ERET;
                                    exc_eret  <= `true;
                                end

                                `FUNCT_COP0_WAIT: begin
                                    instvalid <= `true;
                                    aluop     <= `ALU_WAIT;
                                end
                            endcase
                        end
                    endcase
                end
            end

            `OP_COP1: begin // CP1 encoding field
                exc_cpu <= !cp0_Status[`CU1];
                ecpnum  <= `CP1;
            end

            `OP_COP2: begin // CP2 encoding field
                exc_cpu <= !cp0_Status[`CU2];
                ecpnum  <= `CP2;
            end

            `OP_COP3: begin // CP3 encoding field
                exc_cpu <= !cp0_Status[`CU3];
                ecpnum  <= `CP3;
            end
            
            `OP_BEQL: begin
                instvalid <= `true;
                r1read    <= `true;
                r2read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr_eq;
                br_addr   <= br_target;
                clrslot <= !opr_eq;
            end

            `OP_BNEL: begin
                instvalid <= `true;
                r1read    <= `true;
                r2read    <= `true;
                isbranch  <= `true;
                br_flag   <= !opr_eq;
                br_addr   <= br_target;
                clrslot <= opr_eq;
            end

            `OP_BLEZL: if(rt == 5'b0) begin
                instvalid <= `true;
                r1read    <= `true;
                isbranch  <= `true;
                br_flag   <= opr1_lez;
                br_addr   <= br_target;
                clrslot <= !opr1_lez;
            end

            `OP_BGTZL: if(rt == 5'b0) begin
                instvalid <= `true;
                r1read    <= `true;
                isbranch  <= `true;
                br_flag   <= !opr1_lez;
                br_addr   <= br_target;
                clrslot <= opr1_lez;
            end

            `OP_SPECIAL2: begin
                if(sa == 5'b0) begin
                    case (funct)
                        `FUNCT_SP2_MADD: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MADD;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `FUNCT_SP2_MADDU: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MADDU;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `FUNCT_SP2_MUL: begin
                            instvalid <= `true;
                            aluop     <= `ALU_MUL;
                            r1read    <= `true;
                            r2read    <= `true;
                            wreg      <= `true;
                        end

                        `FUNCT_SP2_MSUB: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MSUB;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `FUNCT_SP2_MSUBU: if(rd == 5'b0) begin
                            instvalid <= `true;
                            aluop     <= `ALU_MSUBU;
                            r1read    <= `true;
                            r2read    <= `true;
                        end

                        `FUNCT_SP2_CLZ: begin
                            instvalid <= `true;
                            aluop     <= `ALU_CLZ;
                            r1read    <= `true;
                            wreg      <= `true;
                        end

                        `FUNCT_SP2_CLO: begin
                            instvalid <= `true;
                            aluop     <= `ALU_CLO;
                            r1read    <= `true;
                            wreg      <= `true;
                        end
                    endcase
                end
            end

            `OP_LB: begin
                instvalid <= `true;
                aluop     <= `ALU_LB;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end

            `OP_LBU: begin
                instvalid <= `true;
                aluop     <= `ALU_LBU;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end
            
            `OP_LH: begin
                instvalid <= `true;
                aluop     <= `ALU_LH;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end
            
            `OP_LHU: begin
                instvalid <= `true;
                aluop     <= `ALU_LHU;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end
            
            `OP_LW: begin
                instvalid <= `true;
                aluop     <= `ALU_LW;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end
            
            `OP_LWL: begin
                instvalid <= `true;
                aluop     <= `ALU_LWL;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end
            
            `OP_LWR: begin
                instvalid <= `true;
                aluop     <= `ALU_LWR;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end

            `OP_SB: begin
                instvalid <= `true;
                aluop     <= `ALU_SB;
                r1read    <= `true;
                r2read    <= `true;
            end

            `OP_SH: begin
                instvalid <= `true;
                aluop     <= `ALU_SH;
                r1read    <= `true;
                r2read    <= `true;
            end

            `OP_SW: begin
                instvalid <= `true;
                aluop     <= `ALU_SW;
                r1read    <= `true;
                r2read    <= `true;
            end

            `OP_SWL: begin
                instvalid <= `true;
                aluop     <= `ALU_SWL;
                r1read    <= `true;
                r2read    <= `true;
            end

            `OP_SWR: begin
                instvalid <= `true;
                aluop     <= `ALU_SWR;
                r1read    <= `true;
                r2read    <= `true;
            end
            
            `OP_CACHE: begin
                // instvalid <= `true;
                exc_cpu   <= usermode && !cp0_Status[`CU0];
                aluop     <= `ALU_CACHE;
                r1read    <= `true;
                case (rt)
                    `RT_CACHE_III: begin
                        instvalid <= `true;
                        cacheop   <= `COP_III;
                    end

                    `RT_CACHE_DIWI: begin
                        instvalid <= `true;
                        cacheop   <= `COP_DIWI;
                    end

                    `RT_CACHE_IIST: begin
                        instvalid <= `true;
                        cacheop   <= `COP_IIST;
                    end
                    
                    `RT_CACHE_DIST: begin
                        instvalid <= `true;
                        cacheop   <= `COP_DIST;
                    end
                    
                    `RT_CACHE_IHI: begin
                        instvalid <= `true;
                        cacheop   <= `COP_IHI;
                    end
                    
                    `RT_CACHE_DHI: begin
                        instvalid <= `true;
                        cacheop   <= `COP_DHI;
                    end
                    
                    `RT_CACHE_DHWI: begin
                        instvalid <= `true;
                        cacheop   <= `COP_DHWI;
                    end
                endcase
            end

            `OP_LL: begin
                instvalid <= `true;
                aluop     <= `ALU_LL;
                r1read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end
            
            `OP_PREF: begin // PREF Temporarily decode as nop
                instvalid <= `true;
            end

            `OP_SC: begin
                instvalid <= `true;
                aluop     <= `ALU_SC;
                r1read    <= `true;
                r2read    <= `true;
                wreg      <= `true;
                wraddr    <= rt;
            end

            `OP_LWC1,
            `OP_LDC1,
            `OP_SWC1,
            `OP_SDC1: begin // CP1 instructions
                instvalid <= `true;
                exc_cpu   <= !cp0_Status[`CU1];
                ecpnum    <= `CP1;
            end

            `OP_LWC2,
            `OP_LDC2,
            `OP_SWC2,
            `OP_SDC2: begin // CP2 instructions
                instvalid <= `true;
                exc_cpu   <= !cp0_Status[`CU2];
                ecpnum    <= `CP2;
            end

        endcase
    end
    
    assign opr1 = r1read ? r1data : ext_imme;
    assign opr2 = r2read ? r2data : ext_imme;

    // Delaying for hazards
    wire    ex_nrdy = hazard_ex  && ex_resnrdy;
    wire   mem_nrdy = hazard_mem && mem_resnrdy;
    assign stallreq = ex_nrdy || mem_nrdy;

endmodule