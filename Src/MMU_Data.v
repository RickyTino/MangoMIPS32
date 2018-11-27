/********************MangoMIPS32*******************
Filename:   MMU_Data.v
Author:     RickyTino
Version:    Unreleased
**************************************************/
`include "Defines.v"

module MMU_Data
(   
    input  wire            m_en,
    input  wire [`ByteWEn] m_wen,
    input  wire [`AddrBus] m_vaddr,
    input  wire [`DataBus] m_wdata,
    output wire [`DataBus] m_rdata,

    output wire            dbus_en,
    output wire [`ByteWEn] dbus_wen,
    output reg  [`AddrBus] dbus_paddr,
    output wire [`DataBus] dbus_wdata,
    input  wire [`DataBus] dbus_rdata,
    input  wire            dbus_streq,
//    output reg             dbus_cached,
    input  wire            exc_flag,
    output wire            stallreq
);
    //Temp
    assign stallreq = dbus_streq;

    assign dbus_wdata = m_wdata;

    always @(*) begin
        case (m_vaddr[31:28])
            //kseg0: unmapped, cached
            4'h8, 4'h9: begin
                dbus_paddr  <= {3'b000, m_vaddr[28:0]};
                //dbus_cached <= `true;
            end
            
            //kseg1: unmapped, uncached
            4'hA, 4'hB: begin
                dbus_paddr  <= {3'b000, m_vaddr[28:0]};
                //dbus_cached <= `false;
            end
            
            default: begin
                dbus_paddr  <= m_vaddr;
                //dbus_cached <= `true;
            end
        endcase
    end

    assign dbus_en  = m_en && !exc_flag;
    assign dbus_wen = m_en ? m_wen      : `WrDisable;
    assign m_rdata  = m_en ? dbus_rdata : `ZeroWord; 

endmodule