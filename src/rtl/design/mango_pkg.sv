`include "mango.svh"

package mango_pkg;

//-------------------------------- parameters ----------------------------------

    localparam  [31:0]  RESET_PC        = 32'hBFC0_0000;
    localparam  [31:0]  BOOT_BASE_PC    = 32'hBFC0_0200;
    localparam  [31:0]  NORM_BASE_PC    = 32'h8000_0000;
    localparam  [31:0]  BOOT_EXCP_PC    = 32'hBFC0_0380;
    localparam  [31:0]  NORM_EXCP_PC    = 32'h8000_0180;
    localparam  [31:0]  BOOT_SPINTR_PC  = 32'hBFC0_0400;
    localparam  [31:0]  NORM_SPINTR_PC  = 32'h8000_0200;


    localparam  int     ITLB_SIZE       = `MANGO_CFG_ITLB_SIZE;
    localparam  int     DTLB_SIZE       = `MANGO_CFG_ITLB_SIZE;
    localparam  int     JTLB_SIZE       = 32;

//-------------------------------- Cache & TLB ---------------------------------

    typedef struct packed {
        logic   [31:12]     vpn;
        logic   [31:12]     ppn;
        logic   [31:12]     mask;
        logic               cca;       
    } itlb_entry_t;

    typedef struct packed {
        logic   [31:12]     vpn;
        logic   [31:12]     ppn;
        logic   [31:12]     mask;
        logic               d;
        logic               cca;       
    } dtlb_entry_t;

    typedef struct packed {
        logic   [31:13]     vpn2;
        logic   [7:0]       asid;
        logic   [31:12]     mask;
        logic               g;
        logic   [31:12]     ppn0;
        logic               v0;
        logic               d0;
        logic   [2:0]       c0;
        logic   [31:12]     ppn1;
        logic               v1;
        logic               d1;
        logic   [2:0]       c1; 
    } tlb_entry_t;

    typedef enum logic [2:0] {
        TLB_OP_NONE     = 3'd0,
        TLB_OP_TLBR     = 3'd1,
        TLB_OP_TLBWI    = 3'd2,
        TLB_OP_TLBWR    = 3'd3,
        TLB_OP_TLBP     = 3'd4
    } tlb_op_t;

//--------------------------------- exception ----------------------------------

    typedef enum logic [1:0] {
        MMU_EXCP_NONE = 2'b00,
        MMU_EXCP_TLBR = 2'b01,
        MMU_EXCP_TLBI = 2'b10,
        MMU_EXCP_TLBM = 2'b11
    } mmu_excp_t;



//------------------------------ MIPS instruction ------------------------------

    typedef struct packed {
        logic   [5:0]   opcode;
        logic   [4:0]   rs;
        logic   [4:0]   rt;
        logic   [4:0]   rd;
        logic   [4:0]   sa;
        logic   [5:0]   funct;
    } inst_rtype_t;

    typedef struct packed {
        logic   [5:0]   opcode;
        logic   [4:0]   rs;
        logic   [4:0]   rt;
        logic   [15:0]  imm;
    } inst_itype_t;

    typedef struct packed {
        logic   [5:0]   opcode;
        logic   [25:0]  offset;
    } inst_jtype_t;

    typedef union packed {
        inst_rtype_t r;
        inst_itype_t i;
        inst_jtype_t j;
    } inst_t;

//------------------------- MIPS instruction encoding --------------------------

    // Opcode
    typedef enum logic [5:0] {
        OP_SPECIAL          = 6'b000000,
        OP_REGIMM           = 6'b000001,
        OP_J                = 6'b000010,
        OP_JAL              = 6'b000011,
        OP_BEQ              = 6'b000100,
        OP_BNE              = 6'b000101,
        OP_BLEZ             = 6'b000110,
        OP_BGTZ             = 6'b000111,
        OP_ADDI             = 6'b001000,
        OP_ADDIU            = 6'b001001,
        OP_SLTI             = 6'b001010,
        OP_SLTIU            = 6'b001011,
        OP_ANDI             = 6'b001100,
        OP_ORI              = 6'b001101,
        OP_XORI             = 6'b001110,
        OP_LUI              = 6'b001111,
        OP_COP0             = 6'b010000,
        OP_COP1             = 6'b010001,
        OP_COP2             = 6'b010010,
        OP_COP3             = 6'b010011,
        OP_BEQL             = 6'b010100,
        OP_BNEL             = 6'b010101,
        OP_BLEZL            = 6'b010110,
        OP_BGTZL            = 6'b010111,
        OP_SPECIAL2         = 6'b011100,
        OP_LB               = 6'b100000,
        OP_LH               = 6'b100001,
        OP_LWL              = 6'b100010,
        OP_LW               = 6'b100011,
        OP_LBU              = 6'b100100,
        OP_LHU              = 6'b100101,
        OP_LWR              = 6'b100110,
        OP_SB               = 6'b101000,
        OP_SH               = 6'b101001,
        OP_SWL              = 6'b101010,
        OP_SW               = 6'b101011,
        OP_SWR              = 6'b101110,
        OP_CACHE            = 6'b101111,
        OP_LL               = 6'b110000,
        OP_LWC1             = 6'b110001,
        OP_LWC2             = 6'b110010,
        OP_PREF             = 6'b110011,
        OP_LDC1             = 6'b110101,
        OP_LDC2             = 6'b110110,
        OP_SC               = 6'b111000,
        OP_SWC1             = 6'b111001,
        OP_SWC2             = 6'b111010,
        OP_SDC1             = 6'b111101,
        OP_SDC2             = 6'b111110
    } inst_opcode_t;

    // Function : Opcode = Special
    typedef enum logic [5:0] {
        FUNCT_SP_SLL        = 6'b000000,
        FUNCT_SP_MOVCI      = 6'b000001,
        FUNCT_SP_SRL        = 6'b000010,
        FUNCT_SP_SRA        = 6'b000011,
        FUNCT_SP_SLLV       = 6'b000100,
        FUNCT_SP_SRLV       = 6'b000110,
        FUNCT_SP_SRAV       = 6'b000111,
        FUNCT_SP_JR         = 6'b001000,
        FUNCT_SP_JALR       = 6'b001001,
        FUNCT_SP_MOVZ       = 6'b001010,
        FUNCT_SP_MOVN       = 6'b001011,
        FUNCT_SP_SYSCALL    = 6'b001100,
        FUNCT_SP_BREAK      = 6'b001101,
        FUNCT_SP_SYNC       = 6'b001111,
        FUNCT_SP_MFHI       = 6'b010000,
        FUNCT_SP_MTHI       = 6'b010001,
        FUNCT_SP_MFLO       = 6'b010010,
        FUNCT_SP_MTLO       = 6'b010011,
        FUNCT_SP_MULT       = 6'b011000,
        FUNCT_SP_MULTU      = 6'b011001,
        FUNCT_SP_DIV        = 6'b011010,
        FUNCT_SP_DIVU       = 6'b011011,
        FUNCT_SP_ADD        = 6'b100000,
        FUNCT_SP_ADDU       = 6'b100001,
        FUNCT_SP_SUB        = 6'b100010,
        FUNCT_SP_SUBU       = 6'b100011,
        FUNCT_SP_AND        = 6'b100100,
        FUNCT_SP_OR         = 6'b100101,
        FUNCT_SP_XOR        = 6'b100110,
        FUNCT_SP_NOR        = 6'b100111,
        FUNCT_SP_SLT        = 6'b101010,
        FUNCT_SP_SLTU       = 6'b101011,
        FUNCT_SP_TGE        = 6'b110000,
        FUNCT_SP_TGEU       = 6'b110001,
        FUNCT_SP_TLT        = 6'b110010,
        FUNCT_SP_TLTU       = 6'b110011,
        FUNCT_SP_TEQ        = 6'b110100,
        FUNCT_SP_TNE        = 6'b110110
    } inst_funct_sp_t;

    // Rt : Opcode = RegImm
    typedef enum logic [4:0] {
        RT_REGIMM_BLTZ      = 5'b00000,
        RT_REGIMM_BGEZ      = 5'b00001,
        RT_REGIMM_BLTZL     = 5'b00010,
        RT_REGIMM_BGEZL     = 5'b00011,
        RT_REGIMM_TGEI      = 5'b01000,
        RT_REGIMM_TGEIU     = 5'b01001,
        RT_REGIMM_TLTI      = 5'b01010,
        RT_REGIMM_TLTIU     = 5'b01011,
        RT_REGIMM_TEQI      = 5'b01100,
        RT_REGIMM_TNEI      = 5'b01110,
        RT_REGIMM_BLTZAL    = 5'b10000,
        RT_REGIMM_BGEZAL    = 5'b10001,
        RT_REGIMM_BLTZALL   = 5'b10010,
        RT_REGIMM_BGEZALL   = 5'b10011
    } inst_rt_regimm_t;

    // Function : Opcode = Special2
    typedef enum logic [5:0] {
        FUNCT_SP2_MADD      = 6'b000000,
        FUNCT_SP2_MADDU     = 6'b000001,
        FUNCT_SP2_MUL       = 6'b000010,
        FUNCT_SP2_MSUB      = 6'b000100,
        FUNCT_SP2_MSUBU     = 6'b000101,
        FUNCT_SP2_CLZ       = 6'b100000,
        FUNCT_SP2_CLO       = 6'b100001
    } inst_funct_sp2_t;


    // Rs : Opcode = COP0
    typedef enum logic [4:0] {
        RS_COP0_MFC0        = 5'b00000,
        RS_COP0_MTC0        = 5'b00100,
        RS_COP0_CO          = 5'b10000
    } inst_rs_cop0_t;

    // Function : Opcode = COP0 and Rs = CO
    typedef enum logic [5:0] {
        FUNCT_COP0_TLBR     = 6'b000001,
        FUNCT_COP0_TLBWI    = 6'b000010,
        FUNCT_COP0_TLBWR    = 6'b000110,
        FUNCT_COP0_TLBP     = 6'b001000,
        FUNCT_COP0_ERET     = 6'b011000,
        FUNCT_COP0_WAIT     = 6'b100000
    } inst_funct_cop0_t;

    // Rt: Opcode = CACHE
    typedef enum logic [4:0] {
        RT_CACHE_I_IDX_INV      = 5'b00000,
        RT_CACHE_D_IDX_WB_INV   = 5'b00001,
        RT_CACHE_I_IDX_ST_TAG   = 5'b01000,
        RT_CACHE_D_IDX_ST_TAG   = 5'b01001,
        RT_CACHE_I_HIT_INV      = 5'b10000,
        RT_CACHE_D_HIT_INV      = 5'b10001,
        RT_CACHE_D_HIT_WB_INV   = 5'b10101
    } inst_rt_cache_t;

//------------------------------------ CP0 -------------------------------------

    // CP0 register num
    typedef enum logic [7:0] {
        CP0_INDEX       = {5'd00, 3'd0},
        CP0_RANDOM      = {5'd01, 3'd0},
        CP0_ENTRYLO0    = {5'd02, 3'd0},
        CP0_ENTRYLO1    = {5'd03, 3'd0},
        CP0_CONTEXT     = {5'd04, 3'd0},
        CP0_PAGEMASK    = {5'd05, 3'd0},
        CP0_WIRED       = {5'd06, 3'd0},
        CP0_BADVADDR    = {5'd08, 3'd0},
        CP0_COUNT       = {5'd09, 3'd0},
        CP0_ENTRYHI     = {5'd10, 3'd0},
        CP0_COMPARE     = {5'd11, 3'd0},
        CP0_STATUS      = {5'd12, 3'd0},
        CP0_CAUSE       = {5'd13, 3'd0},
        CP0_EPC         = {5'd14, 3'd0},
        CP0_PRID        = {5'd15, 3'd0},
        CP0_EBASE       = {5'd15, 3'd1},
        CP0_CONFIG      = {5'd16, 3'd0},
        CP0_CONFIG1     = {5'd16, 3'd1},
        CP0_TAGLO       = {5'd28, 3'd0},
        CP0_TAGHI       = {5'd29, 3'd0},
        CP0_ERROREPC    = {5'd30, 3'd0}
    } cp0_id_t;

    typedef struct packed {
        logic   [3:0]   cu;         // 31:28    CU3-CU0
        logic   [4:0]   rsvd_27_23; // 27:23    reserved 
        logic           bev;        // 22       BEV
        logic   [5:0]   rsvd_21_16; // 21:16    reserved
        logic   [7:0]   im;         // 15: 8    IM
        logic   [2:0]   rsvd_7_5;   //  7: 5    reserved
        logic           um;         //  4       UM
        logic           rsvd_3;     //  3       reserved
        logic           erl;        //  2       ERL
        logic           exl;        //  1       EXL
        logic           ie;         //  0       IE
    } cp0_status_t;

    typedef struct packed {
        logic           bd;         // 31       BD
        logic           rsvd_30;    // 30       reserved
        logic   [1:0]   ce;         // 29:28    CE
        logic   [3:0]   rsvd_27_24; // 27:24    reserved
        logic           iv;         // 23       IV
        logic   [6:0]   rsvd_22_16; // 22:16    reserved
        logic   [5:0]   ip_hard;    // 15:10    IP (hard interrupt)
        logic   [1:0]   ip_soft;    //  9: 8    IP (soft interrupt)
        logic           rsvd_7;     //  7       reserved
        logic   [4:0]   exccode;    //  6: 2    ExcCode
        logic   [1:0]   rsvd_1_0;   //  1: 0    reserved
    } cp0_cause_t;



endpackage