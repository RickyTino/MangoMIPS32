/********************MangoMIPS32*******************
Filename:   Inst_Cache.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

`define         N           `ICache_N
`define         lineN       2 ** (5 + `N)
`define         lines       `lineN - 1 : 0
`define         ad_ptag     31 : (11 + `N)
`define         ad_idx      (10 + `N) : 6
`define         ad_ramad    (10 + `N) : 2
`define         index       ( 4 + `N) : 0
`define         ptag        (20 - `N) : 0
`define         RamAddr     ( 8 + `N) : 0

module Inst_Cache (
    input  wire        aclk,
    input  wire        aresetn,
    output reg  [ 3:0] arid,
    output reg  [31:0] araddr,
    output reg  [ 3:0] arlen,
    output wire [ 2:0] arsize,
    output wire [ 1:0] arburst,
    output wire [ 1:0] arlock,
    output wire [ 3:0] arcache,
    output wire [ 2:0] arprot,
    output reg         arvalid,
    input  wire        arready,
    input  wire [ 3:0] rid,
    input  wire [31:0] rdata,
    input  wire [ 1:0] rresp,
    input  wire        rlast,
    input  wire        rvalid,
    output wire        rready,
    output wire [ 3:0] awid,
    output wire [31:0] awaddr,
    output wire [ 3:0] awlen,
    output wire [ 2:0] awsize,
    output wire [ 1:0] awburst,
    output wire [ 1:0] awlock,
    output wire [ 3:0] awcache,
    output wire [ 2:0] awprot,
    output wire        awvalid,
    input  wire        awready,
    output wire [ 3:0] wid,
    output wire [31:0] wdata,
    output wire [ 3:0] wstrb,
    output wire        wlast,
    output wire        wvalid,
    input  wire        wready,
    input  wire [ 3:0] bid,
    input  wire [ 1:0] bresp,
    input  wire        bvalid,
    output wire        bready,

    input  wire        bus_en,
    input  wire [ 3:0] bus_wen,
    input  wire [31:0] bus_addr,
    output wire [31:0] bus_rdata,
    input  wire [31:0] bus_wdata,
    output wire        bus_streq,
    input  wire        bus_stall,
    input  wire        bus_cached
);

    assign arsize   = 3'b010;
    assign arburst  = 2'b01;
    assign arlock   = 2'b0;
    assign arcache  = 4'b0;
    assign arprot   = 3'b0;
    assign rready   = 1'b1;
    assign awid     = 4'b0;
    assign awaddr   = 32'b0;
    assign awlen    = 4'b0;
    assign awsize   = 3'b010;
    assign awburst  = 2'b01;
    assign awlock   = 2'b0;
    assign awcache  = 4'b0;
    assign awprot   = 3'b0;
    assign awvalid  = 1'b0;
    assign wid      = 4'b0;
    assign wdata    = 32'b0;
    assign wstrb    = 4'b0;
    assign wlast    = 1'b0;
    assign wvalid   = 1'b0;
    assign bready   = 1'b1;

    //Cached Channel
    wire            cached;
    
    `ifdef NSCSCC_Mode
        assign cached = 1'b1;
    `else
        assign cached = bus_cached;
    `endif
    
    reg  [`ByteWEn] ca_wen;
    reg  [`RamAddr] ca_adw;
    reg  [`RamAddr] ca_adr;
    reg  [`DataBus] ca_din;
    wire [`DataBus] ca_dout;

    Inst_Cache_Ram icacheram (
      .clk  (aclk   ),
      .wen  (ca_wen ),
      .adw  (ca_adw ),
      .adr  (ca_adr ),
      .din  (ca_din ),
      .dout (ca_dout)
    );

    reg  [`ptag] ca_ptag  [`lines];
    reg          ca_valid [`lines];

    wire [`index] ad_index = bus_addr[`ad_idx ];
    wire [`ptag ] ad_ptag  = bus_addr[`ad_ptag];
    wire [`ptag ] ln_ptag  = ca_ptag [ad_index];
    wire          ln_valid = ca_valid[ad_index];
    wire          ln_adhit = ln_ptag == ad_ptag;
    wire          ln_hit   = ln_adhit && ln_valid;

    //Uncached Channel
    reg [`Word] uc_data;
    reg [`Word] uc_addr;
    reg         uc_valid;
    wire        uc_hit = (uc_addr ^ bus_addr) == 0 && uc_valid;

    reg         r_streq;
    assign bus_streq = r_streq; // hit invalidate?

    always @(*) begin
        r_streq <= `false;
        ca_adr   <= 0;
        
        if(bus_en) begin
            if(cached) begin
                if(ln_hit) ca_adr <= bus_addr[`ad_ramad];
                else r_streq <= `true;
            end
            else r_streq <= !uc_hit;
        end
    end

    reg  [ 3: 0 ] r_cnt;
    reg  [ 1: 0 ] r_state;
    reg  [`Word ] rlk_addr;
    reg           rlk_cached;
    wire [`index] rlk_index = rlk_addr[`ad_idx];
	
	integer i;
    always @(posedge aclk, negedge aresetn) begin
        if(!aresetn) begin
            for(i = 0; i < `lineN; i = i + 1) begin
                ca_ptag [i] <= 0;
                ca_valid[i] <= `false;
            end
            r_state    <= 0;
            r_cnt      <= 0;
            rlk_addr   <= `ZeroWord;
            rlk_cached <= `false;

            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arvalid  <= 0;

            ca_wen   <= `WrDisable;
            ca_adw   <= 0;
            ca_din   <= `ZeroWord;

            uc_data  <= `ZeroWord;
            uc_addr  <= `ZeroWord;
            uc_valid <= `false;
        end
        else begin
            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arvalid  <= 0;

            // uc_valid <= `false;

            case (r_state)
                0: 
                if(cached) begin
                    if(bus_en && !ln_hit) begin
                        rlk_addr   <= {bus_addr[31:6], 6'b0};
                        rlk_cached <= cached;
                        r_cnt      <= 0;
                        r_state    <= 1;
                        ca_ptag [ad_index] <= bus_addr[`ad_ptag];
                        ca_valid[ad_index] <= `false;
                    end
                end
                else begin
                    if(bus_en && !uc_hit) begin
                        rlk_addr   <= bus_addr;
                        rlk_cached <= cached;
                        r_state    <= 1;
                    end
                end

                1: 
                if(arvalid && arready) r_state <= 2;
                else begin
                    if(rlk_cached) begin
                        arid   <= 4'b0001;
                        araddr  <= rlk_addr;
                        arlen   <= 4'hF;
                    end
                    else begin
                        arid    <= 4'b0010;
                        araddr  <= rlk_addr;
                        arlen   <= 4'h0;
                    end
                    arvalid <= `true;
                end

                2:
                if(rvalid) begin
                    if(rlk_cached) begin
                        ca_wen <= 4'hF;
                        ca_adw <= {rlk_index, r_cnt};
                        ca_din <= rdata;
                        r_cnt  <= r_cnt + 1;
                        if(rlast) ca_valid[rlk_index] <= `true;
                    end
                    else begin
                        uc_data <= rdata;
                        uc_addr <= rlk_addr;
                        if(rlast) uc_valid <= `true;
                    end
                    if(rlast) r_state <= 3;
                end

                3:
                if((bus_stall ^ r_streq) == 0) begin
					r_state <= 0;
					uc_valid <= `false;
				end
                
            endcase
        end
    end

    assign bus_rdata = rlk_cached ? ca_dout : uc_data;

endmodule