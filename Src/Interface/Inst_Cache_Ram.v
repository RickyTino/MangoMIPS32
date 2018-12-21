/********************MangoMIPS32*******************
Filename:   Inst_Cache_Ram.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

//`define         N           `ICache_N
//`define         RamAddr     (8 + `N) : 0

module Inst_Cache_Ram (
    input  wire             clk,
    input  wire [`ByteWEn]  wen,
    input  wire [`RamAddr]  adw,
    input  wire [`RamAddr]  adr,
    input  wire [`DataBus]  din,
    output wire [`DataBus]  dout
);

    ICache_Ram_Unit unit0 (
        .clk    (clk            ),
        .we     (wen [0]        ),
        .a      (adw            ),
        .d      (din [`Byte0]   ),
        .dpra   (adr            ),
        .dpo    (dout[`Byte0]   )
    );

    ICache_Ram_Unit unit1 (
        .clk    (clk            ),
        .we     (wen [1]        ),
        .a      (adw            ),
        .d      (din [`Byte1]   ),
        .dpra   (adr            ),
        .dpo    (dout[`Byte1]   )
    );

    ICache_Ram_Unit unit2 (
        .clk    (clk            ),
        .we     (wen [2]        ),
        .a      (adw            ),
        .d      (din [`Byte2]   ),
        .dpra   (adr            ),
        .dpo    (dout[`Byte2]   )
    );
    
    ICache_Ram_Unit unit3 (
        .clk    (clk            ),
        .we     (wen [3]        ),
        .a      (adw            ),
        .d      (din [`Byte3]   ),
        .dpra   (adr            ),
        .dpo    (dout[`Byte3]   )
    );

endmodule