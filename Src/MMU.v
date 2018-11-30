/********************MangoMIPS32*******************
Filename:   MMU.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "Defines.v"

module MMU
(   
    input  wire            en,
    input  wire [`ByteWEn] wen,
    input  wire [`AddrBus] vaddr,
    input  wire [`DataBus] wdata,
    output wire [`DataBus] rdata,

    output wire            bus_en,
    output wire [`ByteWEn] bus_wen,
    output reg  [`AddrBus] bus_paddr,
    output wire [`DataBus] bus_wdata,
    input  wire [`DataBus] bus_rdata,
    input  wire            bus_streq,
    // output reg             bus_cached,

    input  wire            exc_flag,
    input  wire [`DataBus] cp0_Status,
    output wire            stallreq
);
    //Temp
    assign stallreq = bus_streq;

    always @(*) begin
        case (vaddr[`Seg])
            //kseg0: unmapped
            `kseg0: begin
                bus_paddr  <= {3'b000, vaddr[28:0]};
                // bus_cached <= `true;
            end
            
            //kseg1: unmapped, uncached
            `kseg1: begin
                bus_paddr  <= {3'b000, vaddr[28:0]};
                // bus_cached <= `false;
            end
            
            //kseg2 & kseg3: mapped
            `kseg2, `kseg3: begin
                bus_paddr  <= vaddr;
            end

            //kuseg: mapped
            default: begin
                bus_paddr  <= cp0_Status[`ERL] ? vaddr : {vaddr[31:28] + 4'd4, vaddr[27:0]};
                // bus_cached <= `true;
            end
        endcase
    end

    assign bus_en    = en && !exc_flag;
    assign bus_wen   = en ? wen : `WrDisable;
    assign bus_wdata = wdata;

    assign rdata     = en ? bus_rdata : `ZeroWord; 

endmodule