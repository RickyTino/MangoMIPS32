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
    
    output reg  [`AddrBus] pc,
    output reg             inst_en
);

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            pc      <= `Entr_Start;
            inst_en <= `false;
        end
        else begin
            pc      <= pc + `PC_Incr;
            inst_en <= `true;
        end
    end

endmodule