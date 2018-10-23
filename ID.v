/********************MangoMIPS32*******************
Filename:	ID.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module ID
(
    input  wire [`Word]    inst,

    output reg             re1,
    output reg  [`RegAddr] r1addr,
    input  wire [`Word]    r1data,

    output reg             re2,
    output reg  [`RegAddr] r2addr,
    input  wire [`Word]    r2data,

    output  reg [`Word]    op1,
    output  reg [`Word]    op2,
    output  reg [`AluOp]   aluop
);

    wire [ 5:0] opcode    = inst[31:26];
    wire [ 4:0] rs        = inst[25:21];
    wire [ 4:0] rt        = inst[20:16];
    wire [ 4:0] rd        = inst[15:11];
    wire [ 4:0] sa        = inst[10: 6];
    wire [ 5:0] funct     = inst[ 5: 0];
    wire [15:0] immediate = inst[15: 0];
    wire [25:0] instindex = inst[25: 0];

    always @(*) begin
        case (opcode)
            `OP_SPECIAL: begin
                if(sa == 5'b00000) begin
                    case (funct) begin
                        `SP_SLL: begin

                        end
                    endcase
                end
            end

            `OP_REGIMM: begin
                case (rt) begin

                endcase
            end

            `OP_SPECIAL2: begin
            
            end
        endcase
    end
    