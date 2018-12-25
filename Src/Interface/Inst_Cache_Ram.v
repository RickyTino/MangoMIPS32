/********************MangoMIPS32*******************
Filename:   Inst_Cache_Ram.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

module Inst_Cache_Ram (
    input  wire             clk,
    input  wire             wen,
    input  wire [`I_ramad]  adw,
    input  wire [`I_ramad]  adr,
    input  wire [`DataBus]  din,
    output wire [`DataBus]  dout
);

    ICache_Ram_IP icache_ram (
        .clk    (clk            ),
        .we     (wen            ),
        .a      (adw            ),
        .d      (din            ),
        .dpra   (adr            ),
        .dpo    (dout           )
    );
    
endmodule