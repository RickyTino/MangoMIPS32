/********************MangoMIPS32*******************
Filename:   Data_Cache_Ram.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

`define         N           `DCache_N
`define         RamAddr     (8 + `N) : 0

module Data_Cache_Ram (
    input  wire             clk,
    input  wire             enb,
    input  wire [`ByteWEn]  wea,    web,
    input  wire [`RamAddr]  addra,  addrb,
    input  wire [`DataBus]  dina,   dinb,
    output wire [`DataBus]  douta,  doutb
);
    
    wire [`RamAddr] addr = enb ? addrb : addra;
    wire [`ByteWEn] wen  = enb ? web   : wea;
    wire [`DataBus] din  = enb ? dinb  : dina;
    wire [`DataBus] dout;
    
    assign douta = dout;
    assign doutb = dout;
    
    DCache_Ram_Unit unit0 (
        .clk    (clk            ),
        .we     (wen [0]        ),
        .a      (addr           ),
        .d      (din [`Byte0]   ),
        .spo    (dout[`Byte0]   )
    );

    DCache_Ram_Unit unit1 (
        .clk    (clk            ),
        .we     (wen [1]        ),
        .a      (addr           ),
        .d      (din [`Byte1]   ),
        .spo    (dout[`Byte1]   )
    );

    DCache_Ram_Unit unit2 (
        .clk    (clk            ),
        .we     (wen [2]        ),
        .a      (addr           ),
        .d      (din [`Byte2]   ),
        .spo    (dout[`Byte2]   )
    );
    
    DCache_Ram_Unit unit3 (
        .clk    (clk            ),
        .we     (wen [3]        ),
        .a      (addr           ),
        .d      (din [`Byte3]   ),
        .spo    (dout[`Byte3]   )
    );

endmodule