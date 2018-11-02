/********************MangoMIPS32*******************
Filename:	MemAccess.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module MemAccess
(   
    input  wire [`AddrBus] pc,
    input  wire [`ALUOp  ] aluop,
    input  wire [`DataBus] alures,

    output wire            dbus_en,
    output wire [`AddrBus] dbus_addr,
    input  wire [`DataBus] dbus_rdata,
    output wire [`ByteWEn] dbus_wen,
    output wire [`DataBus] dbus_wdata,

    output wire            stallreq
);
    //Temp
    assign stallreq   = `false;

    assign dbus_addr  = `ZeroWord;
    assign dbus_en    = `false;
    assign dbus_wen   = `WrDisable;
    assign dbus_wdata = `ZeroWord;

endmodule