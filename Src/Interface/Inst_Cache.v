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
    output reg  [31:0] awaddr,
    output reg  [ 3:0] awlen,
    output wire [ 2:0] awsize,
    output wire [ 1:0] awburst,
    output wire [ 1:0] awlock,
    output wire [ 3:0] awcache,
    output wire [ 2:0] awprot,
    output reg         awvalid,
    input  wire        awready,
    output wire [ 3:0] wid,
    output reg  [31:0] wdata,
    output reg  [ 3:0] wstrb,
    output reg         wlast,
    output reg         wvalid,
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
    assign awsize   = 3'b010;
    assign awburst  = 2'b01;
    assign awlock   = 2'b0;
    assign awcache  = 4'b0;
    assign awprot   = 3'b0;
    assign wid      = 4'b0;
    assign bready   = 1'b1;

    wire rreq = bus_en & !refs;

    //Cached Datapath
    reg             ena,   enb;
    reg  [`ByteWEn] wea,   web;
    reg  [`RamAddr] addra, addrb;
    reg  [`DataBus] dina,  dinb;
    wire [`DataBus] douta, doutb;

    Inst_Cache_RAM icacheram (
      .clk      (clk),
      .wpb      (wportb),
      .ena      (ena),
      .wea      (wea),
      .addra    (addra),
      .dina     (dina),
      .douta    (douta),
      .enb      (enb),
      .web      (web),
      .addrb    (addrb),
      .dinb     (dinb),
      .doutb    (doutb)
    );

    reg  [`ptag] ca_ptag  [`lines];
    reg          ca_valid [`lines];
    reg          ca_dirty [`lines];

    wire [`index] ad_index = bus_addr[`ad_idx ];
    wire [`ptag ] ad_ptag  = bus_addr[`ad_ptag];
    wire [`ptag ] ln_ptag  = ca_ptag [ad_index];
    wire          ln_valid = ca_valid[ad_index];
    wire          ln_dirty = ca_dirty[ad_index];
    wire          ln_adhit = ln_ptag == ad_ptag;
    wire          ln_hit   = ln_adhit && ln_valid;
    // wire         ln_wb    = !ln_hit && ln_valid && ln_dirty; 

    //Uncached Datapath
    reg [`Word] uc_data;
    reg [`Word] uc_addr;
    reg         uc_valid;
    wire        uc_hit = (uc_addr ^ bus_addr) == 0 && uc_valid;
    reg         w_rdy;

    reg         r_streq;
    reg         w_streq;


    assign bus_streq = r_streq | w_streq;

    always @(*) begin
        r_streq <= `false;
        w_streq <= `false;
        ena     <= `false;
        wea     <= `false;
        addra   <= `false;
        dina    <= `false;
        
        if(bus_en) begin
            if(bus_cached) begin
                if(ln_hit) begin
                    ena   <= !bus_stall;
                    wea   <= bus_wen;
                    addra <= bus_addr[`ad_ramad];
                    dina  <= bus_wdata;
                end
                else begin
                    r_streq <= `true;
                end
            end
            else begin
                if(refs) w_streq <= !w_rdy;
                else     r_streq <= !uc_hit;
            end
        end
    end

    reg [`Word] rlk_addr;
    reg [`Word] wlk_addr;
    reg [`Word] wlk_data;
    reg [ 3: 0] wlk_strb;
    reg [ 1: 0] r_state, w_state;

    always @(posedge aclk, negedge aresetn) begin
        if(!aresetn) begin
            r_state  <= 0;
            w_state  <= 0;

            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arvalid  <= 0;
            awaddr   <= 0;
            awlen    <= 0;
            awvalid  <= 0;
            wdata    <= 0;
            wstrb    <= 0;
            wlast    <= 0;
            wvalid   <= 0;

            uc_data  <= `ZeroWord;
            uc_addr  <= `ZeroWord;
            uc_valid <= `false;
            w_rdy    <= `false;
            rlk_addr <= `ZeroWord;
            wlk_addr <= `ZeroWord;
            wlk_data <= `ZeroWord;
            wlk_strb <= 0;
        end
        else begin
            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arvalid  <= 0;
            awaddr   <= 0;
            awlen    <= 0;
            awvalid  <= 0;
            wdata    <= 0;
            wstrb    <= 0;
            wlast    <= 0;
            wvalid   <= 0;

            uc_valid <= `false;
            w_rdy    <= `false;

            case (r_state)
                0: 
                if(rreq && !uc_hit) begin
                    rlk_addr <= bus_addr;
                    r_state  <= 1;
                end
                
                1: 
                if(arvalid && arready) r_state <= 2;
                else begin
                    arid    <= 4'b0010;
                    araddr  <= rlk_addr;
                    arlen   <= 4'h0;
                    arvalid <= `true;
                end

                2:
                if(rvalid) begin
                    uc_data <= rdata;
                    uc_addr <= rlk_addr;
                    if(rlast) r_state <= 3;
                end

                3: begin
                    uc_valid <= `true;
                    if((bus_stall ^ r_streq) == 0) r_state <= 0;
                end
            endcase

            case (w_state)
                0:
                if(wreq && !w_rdy) begin
                    wlk_addr <= bus_addr;
                    wlk_data <= bus_wdata;
                    wlk_strb <= bus_wen;
                    w_state  <= 1;
                end

                1:
                if(awvalid && awready) w_state <= 2;
                else begin
                    awaddr  <= wlk_addr;
                    awlen   <= 4'h0;
                    awvalid <= `true;
                end

                2:
                if(wvalid && wready) w_state <= 3;
                else begin
                    wdata  <= wlk_data;
                    wstrb  <= wlk_strb;
                    wvalid <= `true;
                    wlast  <= `true;
                end

                3:
                if(bvalid) begin
                    w_state <= 0;
                    w_rdy  <= `true;
                end
            endcase
        end
    end

    assign bus_rdata = uc_data;

endmodule