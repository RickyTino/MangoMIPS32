/********************MangoMIPS32*******************
Filename:   AXI_Top.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "Defines.v"
`include "Config.v"

module MangoMIPS_Top
(
    input  wire        aclk,
    input  wire        aresetn,
    input  wire [ 5:0] intr,

    output wire [ 3:0] ibus_arid,
    output wire [31:0] ibus_araddr,
    output wire [ 3:0] ibus_arlen,
    output wire [ 2:0] ibus_arsize,
    output wire [ 1:0] ibus_arburst,
    output wire [ 1:0] ibus_arlock,
    output wire [ 3:0] ibus_arcache,
    output wire [ 2:0] ibus_arprot,
    output wire        ibus_arvalid,
    input  wire        ibus_arready,
    input  wire [ 3:0] ibus_rid,
    input  wire [31:0] ibus_rdata,
    input  wire [ 1:0] ibus_rresp,
    input  wire        ibus_rlast,
    input  wire        ibus_rvalid,
    output wire        ibus_rready,
    output wire [ 3:0] ibus_awid,
    output wire [31:0] ibus_awaddr,
    output wire [ 3:0] ibus_awlen,
    output wire [ 2:0] ibus_awsize,
    output wire [ 1:0] ibus_awburst,
    output wire [ 1:0] ibus_awlock,
    output wire [ 3:0] ibus_awcache,
    output wire [ 2:0] ibus_awprot,
    output wire        ibus_awvalid,
    input  wire        ibus_awready,
    output wire [ 3:0] ibus_wid,
    output wire [31:0] ibus_wdata,
    output wire [ 3:0] ibus_wstrb,
    output wire        ibus_wlast,
    output wire        ibus_wvalid,
    input  wire        ibus_wready,
    input  wire [ 3:0] ibus_bid,
    input  wire [ 1:0] ibus_bresp,
    input  wire        ibus_bvalid,
    output wire        ibus_bready,

    output wire [ 3:0] dbus_arid,
    output wire [31:0] dbus_araddr,
    output wire [ 3:0] dbus_arlen,
    output wire [ 2:0] dbus_arsize,
    output wire [ 1:0] dbus_arburst,
    output wire [ 1:0] dbus_arlock,
    output wire [ 3:0] dbus_arcache,
    output wire [ 2:0] dbus_arprot,
    output wire        dbus_arvalid,
    input  wire        dbus_arready,
    input  wire [ 3:0] dbus_rid,
    input  wire [31:0] dbus_rdata,
    input  wire [ 1:0] dbus_rresp,
    input  wire        dbus_rlast,
    input  wire        dbus_rvalid,
    output wire        dbus_rready,
    output wire [ 3:0] dbus_awid,
    output wire [31:0] dbus_awaddr,
    output wire [ 3:0] dbus_awlen,
    output wire [ 2:0] dbus_awsize,
    output wire [ 1:0] dbus_awburst,
    output wire [ 1:0] dbus_awlock,
    output wire [ 3:0] dbus_awcache,
    output wire [ 2:0] dbus_awprot,
    output wire        dbus_awvalid,
    input  wire        dbus_awready,
    output wire [ 3:0] dbus_wid,
    output wire [31:0] dbus_wdata,
    output wire [ 3:0] dbus_wstrb,
    output wire        dbus_wlast,
    output wire        dbus_wvalid,
    input  wire        dbus_wready,
    input  wire [ 3:0] dbus_bid,
    input  wire [ 1:0] dbus_bresp,
    input  wire        dbus_bvalid,
    output wire        dbus_bready,

    output wire [`AddrBus] debug_wb_pc,
    output wire [`ByteWEn] debug_wb_wreg,
    output wire [`RegAddr] debug_wb_wraddr,
    output wire [`DataBus] debug_wb_wrdata
);

    wire            inst_en;
    wire [`AddrBus] inst_addr;
    wire [`DataBus] inst_rdata;
    wire            inst_streq;
    wire            inst_stall;
    wire            inst_cached;

    wire            data_en;
    wire [`AddrBus] data_addr;
    wire [`DataBus] data_rdata;
    wire [`ByteWEn] data_wen;
    wire [`DataBus] data_wdata;
    wire            data_streq;
    wire            data_stall;
    wire            data_cached;
    
    MangoMIPS_Core_Top mips_core (
        .clk            (aclk       ),
        .rst            (~aresetn   ),
        .intr           (intr       ),
        
        .ibus_en        (inst_en    ),
        .ibus_addr      (inst_addr  ),
        .ibus_rdata     (inst_rdata ),
        .ibus_streq     (inst_streq ),
        .ibus_stall     (inst_stall ),
        .ibus_cached    (inst_cached),
        
        .dbus_en        (data_en    ),
        .dbus_wen       (data_wen   ),
        .dbus_addr      (data_addr  ),
        .dbus_wdata     (data_wdata ),
        .dbus_rdata     (data_rdata ),
        .dbus_streq     (data_streq ),
        .dbus_stall     (data_stall ),
        .dbus_cached    (data_cached),

        .debug_wb_pc    (debug_wb_pc    ),
        .debug_wb_wreg  (debug_wb_wreg  ),
        .debug_wb_wraddr(debug_wb_wraddr),
        .debug_wb_wrdata(debug_wb_wrdata)
    );

    AXI_Interface inst_axi (
        .aclk       (aclk           ),
        .aresetn    (aresetn        ),
        .arid       (ibus_arid      ),
        .araddr     (ibus_araddr    ),
        .arlen      (ibus_arlen     ),
        .arsize     (ibus_arsize    ),
        .arburst    (ibus_arburst   ),
        .arlock     (ibus_arlock    ),
        .arcache    (ibus_arcache   ),
        .arprot     (ibus_arprot    ),
        .arvalid    (ibus_arvalid   ),
        .arready    (ibus_arready   ),
        .rid        (ibus_rid       ),
        .rdata      (ibus_rdata     ),
        .rresp      (ibus_rresp     ),
        .rlast      (ibus_rlast     ),
        .rvalid     (ibus_rvalid    ),
        .rready     (ibus_rready    ),
        .awid       (ibus_awid      ),
        .awaddr     (ibus_awaddr    ),
        .awlen      (ibus_awlen     ),
        .awsize     (ibus_awsize    ),
        .awburst    (ibus_awburst   ),
        .awlock     (ibus_awlock    ),
        .awcache    (ibus_awcache   ),
        .awprot     (ibus_awprot    ),
        .awvalid    (ibus_awvalid   ),
        .awready    (ibus_awready   ),
        .wid        (ibus_wid       ),
        .wdata      (ibus_wdata     ),
        .wstrb      (ibus_wstrb     ),
        .wlast      (ibus_wlast     ),
        .wvalid     (ibus_wvalid    ),
        .wready     (ibus_wready    ),
        .bid        (ibus_bid       ),
        .bresp      (ibus_bresp     ),
        .bvalid     (ibus_bvalid    ),
        .bready     (ibus_bready    ),
        
        .bus_en     (inst_en        ),
        .bus_wen    (`WrDisable     ),
        .bus_addr   (inst_addr      ),
        .bus_rdata  (inst_rdata     ),
        .bus_wdata  (`ZeroWord      ),
        .bus_streq  (inst_streq     ),
        .bus_stall  (inst_stall     ),
        .bus_cached (inst_cached    )
    );

    AXI_Interface data_axi (
        .aclk       (aclk           ),
        .aresetn    (aresetn        ),
        .arid       (dbus_arid      ),
        .araddr     (dbus_araddr    ),
        .arlen      (dbus_arlen     ),
        .arsize     (dbus_arsize    ),
        .arburst    (dbus_arburst   ),
        .arlock     (dbus_arlock    ),
        .arcache    (dbus_arcache   ),
        .arprot     (dbus_arprot    ),
        .arvalid    (dbus_arvalid   ),
        .arready    (dbus_arready   ),
        .rid        (dbus_rid       ),
        .rdata      (dbus_rdata     ),
        .rresp      (dbus_rresp     ),
        .rlast      (dbus_rlast     ),
        .rvalid     (dbus_rvalid    ),
        .rready     (dbus_rready    ),
        .awid       (dbus_awid      ),
        .awaddr     (dbus_awaddr    ),
        .awlen      (dbus_awlen     ),
        .awsize     (dbus_awsize    ),
        .awburst    (dbus_awburst   ),
        .awlock     (dbus_awlock    ),
        .awcache    (dbus_awcache   ),
        .awprot     (dbus_awprot    ),
        .awvalid    (dbus_awvalid   ),
        .awready    (dbus_awready   ),
        .wid        (dbus_wid       ),
        .wdata      (dbus_wdata     ),
        .wstrb      (dbus_wstrb     ),
        .wlast      (dbus_wlast     ),
        .wvalid     (dbus_wvalid    ),
        .wready     (dbus_wready    ),
        .bid        (dbus_bid       ),
        .bresp      (dbus_bresp     ),
        .bvalid     (dbus_bvalid    ),
        .bready     (dbus_bready    ),
        
        .bus_en     (data_en        ),
        .bus_wen    (data_wen       ),
        .bus_addr   (data_addr      ),
        .bus_rdata  (data_rdata     ),
        .bus_wdata  (data_wdata     ),
        .bus_streq  (data_streq     ),
        .bus_stall  (data_stall     ),
        .bus_cached (data_cached    )
    );

endmodule