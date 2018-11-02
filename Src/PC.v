/********************MangoMIPS32*******************
Filename:	PC.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module PC 
(
    input  wire            clk,
    input  wire            rst,
    input  wire            stall,
    input  wire            flush,
    input  wire [`AddrBus] flush_pc,
    
    output reg  [`AddrBus] pc,
    output reg             inst_en
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            pc      <= `Entr_Start;
            inst_en <= `false;
        end
        else begin
            if(flush) begin
                pc      <= flush_pc;  //Reserved for exception
                inst_en <= `false;
            end
            else if(!stall) begin
                pc      <= inst_en ? pc + `PC_Incr : pc;
                inst_en <= `true;
            end
        end
    end

endmodule