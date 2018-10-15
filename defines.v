/********************MangoMIPS32*******************
Filename:	defines.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
/*--------------------Constant--------------------*/
`define		true				1'b1
`define     false               1'b0
`define     ALUWidth			8

/*--------------------Bus Width--------------------*/
`define		DWord				63:0
`define		Word				31:0
`define		ALUCtrl				`ALUWidth-1:0
`define		

/*--------------------Encoding--------------------*/
//Opcode
`define		OP_SPECIAL			6'b000000
`define		OP_REGIMM			6'b000001
`define		OP_J				6'b000010
`define		OP_JAL				6'b000011
`define		OP_BEQ				6'b000100
`define		OP_BNE				6'b000101
`define		OP_BLEZ				6'b000110
`define		OP_BGTZ				6'b000111
`define		OP_ADDI				6'b001000
`define		OP_ADDIU			6'b001001
`define		OP_SLTI				6'b001010
`define		OP_SLTIU			6'b001011
`define		OP_ANDI				6'b001100
`define		OP_ORI				6'b001101
`define		OP_XORI				6'b001110
`define		OP_LUI				6'b001111
`define		OP_COP0				6'b010000
`define		OP_SPECIAL2			6'b010100
`define		OP_LB				6'b100000
`define		OP_LH				6'b100001
`define		OP_LWL				6'b100010
`define		OP_LW				6'b100011
`define		OP_LBU				6'b100100
`define		OP_LHU				6'b100101
`define		OP_LWR				6'b100110
`define		OP_SB				6'b101000
`define		OP_SH				6'b101001
`define		OP_SWL				6'b101010
`define		OP_SWL				6'b101011
`define		OP_SWR				6'b101110
`define		OP_CACHE			6'b101111
`define		OP_LL				6'b110000
`define		OP_PREF				6'b110011
`define		OP_SC				6'b111000

//Function : Opcode = Special
`define		SP_SLL				6'b000000
`define		SP_SRL				6'b000010
`define		SP_SRA				6'b000011
`define		SP_SLLV				6'b000100
`define		SP_SRLV				6'b000110
`define		SP_SRAV				6'b000111
`define		SP_JR				6'b001000
`define		SP_JALR				6'b001001
`define		SP_MOVZ				6'b001010
`define		SP_MOVN				6'b001011
`define		SP_SYSCALL			6'b001100
`define		SP_BREAK			6'b001101
`define		SP_SYNC				6'b001111
`define		SP_MFHI				6'b010000
`define		SP_MTHI				6'b010001
`define		SP_MFLO				6'b010010
`define		SP_MTLO				6'b010011
`define		SP_MULT				6'b011000
`define		SP_MULTU			6'b011001
`define		SP_DIV				6'b011010
`define		SP_DIVU				6'b011011
`define		SP_ADD				6'b100000
`define		SP_ADDU				6'b100001
`define		SP_SUB				6'b100010
`define		SP_SUBU				6'b100011
`define		SP_AND				6'b100100
`define		SP_OR				6'b100101
`define		SP_XOR				6'b100110
`define		SP_NOR				6'b100111
`define		SP_SLT				6'b101010
`define		SP_SLTU				6'b101011
`define		SP_TGE				6'b110000
`define		SP_TGEU				6'b110001
`define		SP_TLT				6'b110010
`define		SP_TLTU				6'b110011
`define		SP_TEQ				6'b110100
`define		SP_TNE				6'b110110

//Rt : Opcode = RegImm
`define		RI_BLTZ				5'b00000
`define		RI_BGEZ				5'b00001
`define		RI_BLTZL			5'b00010
`define		RI_BGEZL			5'b00011
`define		RI_TGEI				5'b01000
`define		RI_TGEIU			5'b01001
`define		RI_TLTI				5'b01010
`define		RI_TLTIU			5'b01011
`define		RI_TEQI				5'b01100
`define		RI_TNEI				5'b01110
`define		RI_BLTZAL			5'b10000
`define		RI_BGEZAL			5'b10001
`define		RI_BLTZALL			5'b10010
`define		RI_BGEZALL			5'b10011

//Function : Opcode = Special2
`define		SP2_MADD			6'b000000
`define		SP2_MADDU			6'b000001
`define 	SP2_MUL				6'b000010
`define		SP2_MSUB			6'b000100
`define		SP2_MSUBU			6'b000101
`define		SP2_CLZ				6'b100000
`define		SP2_CLO				6'b100001

//Rs : Opcode = COP0
`define		C0_MFC0				5'b00000
`define		C0_MTC0				5'b00100
`define     C0_CO				5'b10000

//Function : Opcode = COP0 and Rs = CO
`define		C0F_TLBR			6'b000001
`define		C0F_TLBWI			6'b000010
`define		C0F_TLBWR			6'b000110
`define		C0F_TLBP			6'b001000
`define		C0F_ERET			6'b011000
`define		C0F_WAIT			6'b100000

/*--------------------ALUCtrl--------------------*/
`define		ALU_NOP				`ALUWidth'h00;
`define		ALU_AND             `ALUWidth'h01;
`define		ALU_OR              `ALUWidth'h02;
`define		ALU_NOR             `ALUWidth'h03;
`define     ALU_XOR             `ALUWidth'h04;