/********************MangoMIPS32*******************
Filename:   Inst_Cache_Ram.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

`define         N           `ICache_N
`define         RamAddr     (8 + `N) : 0

module Inst_Cache_Ram (
    input  wire            clk,
    input  wire            wpb,
    input  wire            ena,   enb,
    input  wire [`ByteWEn] wea,   web,
    input  wire [`RamAddr] addra, addrb,
    input  wire [`DataBus] dina,  dinb,
    output wire [`DataBus] douta, doutb
);

    wire [`ByteWEn] wen = wpb ? web  : wea;
    wire [`DataBus] din = wpb ? dinb : dina;

    ICache_RAM_Unit unit0 (
        .clk    (clk            ),
        .a      (addra          ),
        .dpra   (addrb          ),
        .d      (din  [`Byte0]  ),
        .we     (wen  [0]       ),
        .spo    (douta[`Byte0]  ),
        .dpo    (doutb[`Byte0]  )
    );

    ICache_RAM_Unit unit1 (
        .clk    (clk            ),
        .a      (addra          ),
        .dpra   (addrb          ),
        .d      (din  [`Byte1]  ),
        .we     (wen  [1]       ),
        .spo    (douta[`Byte1]  ),
        .dpo    (doutb[`Byte1]  )
    );

    ICache_RAM_Unit unit2 (
        .clk    (clk            ),
        .a      (addra          ),
        .dpra   (addrb          ),
        .d      (din  [`Byte2]  ),
        .we     (wen  [2]       ),
        .spo    (douta[`Byte2]  ),
        .dpo    (doutb[`Byte2]  )
    );
    
    ICache_RAM_Unit unit3 (
        .clk    (clk            ),
        .a      (addra          ),
        .dpra   (addrb          ),
        .d      (din  [`Byte3]  ),
        .we     (wen  [3]       ),
        .spo    (douta[`Byte3]  ),
        .dpo    (doutb[`Byte3]  )
    );

endmodule

// ICache_RAM_Unit your_instance_name (
//   .a(a),        // input wire [10 : 0] a
//   .d(d),        // input wire [7 : 0] d
//   .dpra(dpra),  // input wire [10 : 0] dpra
//   .clk(clk),    // input wire clk
//   .we(we),      // input wire we
//   .spo(spo),    // output wire [7 : 0] spo
//   .dpo(dpo)    // output wire [7 : 0] dpo
// );