module mycpu_top
(
	input  wire        clk, 
    input  wire        resetn, 
	input  wire [ 5:0] int,
	
	input  wire [31:0] inst_sram_rdata,
	output wire        inst_sram_en,
	output wire [ 3:0] inst_sram_wen,
	output wire [31:0] inst_sram_addr,
	output wire [31:0] inst_sram_wdata,
	
	input  wire [31:0] data_sram_rdata,
	output wire        data_sram_en,
	output wire [ 3:0] data_sram_wen,
	output wire [31:0] data_sram_addr,
	output wire [31:0] data_sram_wdata,
	
	output wire [31:0] debug_wb_pc,
	output wire [ 3:0] debug_wb_rf_wen,
	output wire [ 4:0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
);
    wire            ibus_en;
    wire [`AddrBus] ibus_addr;
    wire [`DataBus] ibus_rdata;

    wire            dbus_en;
    wire [`AddrBus] dbus_addr;
    wire [`DataBus] dbus_rdata;
    wire [`ByteWEn] dbus_wen;
    wire [`DataBus] dbus_wdata;

    wire [`AddrBus] debug_wb_pc;
    wire            debug_wb_wreg;
    wire [`RegAddr] debug_wb_wraddr;
    wire [`DataBus] debug_wb_wrdata;
);