/********************MangoMIPS32*******************
Filename:	MMU_Inst.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

module MMU_Inst
(   
    input  wire            i_en,
    input  wire [`AddrBus] i_vaddr,
    output wire [`DataBus] i_rdata,

    output wire            ibus_en,
    output reg  [`AddrBus] ibus_paddr,
    input  wire [`DataBus] ibus_rdata,
//    output reg             ibus_cached,
    output wire            stallreq
);
    //Temp
    assign stallreq   = `false;

    always @(*) begin
        case (i_vaddr[31:28])
			//kseg0: unmapped, cached
			4'h8, 4'h9: begin
				ibus_paddr  <= {3'b000, i_vaddr[28:0]};
				//ibus_cached <= `true;
			end
			
			//kseg1: unmapped, uncached
			4'hA, 4'hB: begin
				ibus_paddr  <= {3'b000, i_vaddr[28:0]};
				//ibus_cached <= `false;
			end
			
			default: begin
				ibus_paddr  <= i_vaddr;
				//ibus_cached <= `true;
			end
		endcase
    end

    assign ibus_en  = i_en;
    assign i_rdata  = i_en ? ibus_rdata : `ZeroWord; 

endmodule