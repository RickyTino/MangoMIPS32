/********************MangoMIPS32*******************
Filename:   TLBU.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "Defines.v"

module TLBU
(
    input  wire            clk,
    input  wire            rst,

    input  wire            immu_en,
    input  wire [`AddrBus] immu_vaddr,
    output reg             immu_rdy,
    output reg  [`AddrBus] immu_paddr
);

    reg  [`TLBItem] TLB [`TLB_Sel];
    wire [`TLB_Sel] TLBhit;
    wire [`TLB_Sel] TLBmatch;
    wire [`TLB_Sel] TLBvalid;

    genvar gvi;
    generate
        for (gvi = 0; gvi < `TLB_N1; gvi = gvi + 1) begin
            //assign TLBmatch[gvi] = 
        end
    endgenerate

    reg  [ 1: 0] i_state;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            i_state    <= 0;
            immu_rdy   <= `false;
            immu_paddr <= `ZeroWord;
        end
        else begin
            case (i_state)
                2'd0: begin
                    if(immu_en) begin
                        i_state <= 2'd1;
                    end
                end
            endcase
        end
    end
endmodule