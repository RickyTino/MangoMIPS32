/********************MangoMIPS32*******************
Filename:   Data_Cache.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

module Data_Cache (
    input  wire            aclk,
    input  wire            aresetn,
    output reg  [  3 : 0 ] arid,
    output reg  [ 31 : 0 ] araddr,
    output reg  [  3 : 0 ] arlen,
    output reg  [  2 : 0 ] arsize,
    output wire [  1 : 0 ] arburst,
    output wire [  1 : 0 ] arlock,
    output wire [  3 : 0 ] arcache,
    output wire [  2 : 0 ] arprot,
    output reg             arvalid,
    input  wire            arready,
    input  wire [  3 : 0 ] rid,
    input  wire [ 31 : 0 ] rdata,
    input  wire [  1 : 0 ] rresp,
    input  wire            rlast,
    input  wire            rvalid,
    output wire            rready,
    output wire [  3 : 0 ] awid,
    output reg  [ 31 : 0 ] awaddr,
    output reg  [  3 : 0 ] awlen,
    output reg  [  2 : 0 ] awsize,
    output wire [  1 : 0 ] awburst,
    output wire [  1 : 0 ] awlock,
    output wire [  3 : 0 ] awcache,
    output wire [  2 : 0 ] awprot,
    output reg             awvalid,
    input  wire            awready,
    output wire [  3 : 0 ] wid,
    output wire [ 31 : 0 ] wdata,
    output reg  [  3 : 0 ] wstrb,
    output reg             wlast,
    output reg             wvalid,
    input  wire            wready,
    input  wire [  3 : 0 ] bid,
    input  wire [  1 : 0 ] bresp,
    input  wire            bvalid,
    output wire            bready,

    input  wire            bus_en,
    input  wire [`ByteWEn] bus_wen,
    input  wire [`AddrBus] bus_addr,
    output wire [`DataBus] bus_rdata,
    input  wire [`DataBus] bus_wdata,
    input  wire [`AXISize] bus_size,
    output wire            bus_streq,
    input  wire            bus_stall,
    input  wire            bus_cached,

    input  wire [`CacheOp] cacheop
);
    assign arburst  = 2'b01;
    assign arlock   = 2'b0;
    assign arcache  = 4'b0;
    assign arprot   = 3'b0;
    assign rready   = 1'b1;
    assign awid     = 4'b0;
    assign awburst  = 2'b01;
    assign awlock   = 2'b0;
    assign awcache  = 4'b0;
    assign awprot   = 3'b0;
    assign wid      = 4'b0;
    assign bready   = 1'b1;

    wire refs = bus_wen != `WrDisable;
    wire rreq = bus_en & !refs;
    wire wreq = bus_en &  refs;

    //Cached Channel
    reg             ca_rbusy, ca_wbusy;
    reg  [`ByteWEn] ca_wea,   ca_web;
    reg  [`D_ramad] ca_ada,   ca_adb;
    reg  [`DataBus] ca_dina,  ca_dinb;
    wire [`DataBus] ca_dout;

    wire            ca_enb  = ca_wbusy || ca_rbusy;

    Data_Cache_Ram dcache_ram (
        .clk    (aclk       ),
        .enb    (ca_enb     ),
        .wea    (ca_wea     ),
        .web    (ca_web     ),
        .ada    (ca_ada     ),
        .adb    (ca_adb     ),
        .dina   (ca_dina    ),
        .dinb   (ca_dinb    ),
        .dout   (ca_dout    )
    );

    reg [`D_ptag] ca_ptag  [`D_lnNum];
    reg           ca_valid [`D_lnNum];
    reg           ca_dirty [`D_lnNum];

    wire [`D_idx ] ad_idx   = bus_addr[`D_addr_idx ];
    wire [`D_ptag] ad_ptag  = bus_addr[`D_addr_ptag];
    wire [`D_ptag] ln_ptag  = ca_ptag [ad_idx];
    wire           ln_valid = ca_valid[ad_idx];
    wire           ln_dirty = ca_dirty[ad_idx];
    wire           ln_hit   = (ln_ptag ^ ad_ptag) == 0 && ln_valid;
    wire           ln_wb    = !ln_hit && ln_valid && ln_dirty;

    //Uncached Channel
    reg [`Word] uc_data;
    reg [`Word] uc_addr;
    reg         uc_valid;
    wire        uc_hit = (uc_addr ^ bus_addr) == 0 && uc_valid;
    reg         uc_wrdy;

    reg         r_streq;
    reg         w_streq;

    assign bus_streq = r_streq || w_streq || ca_enb;

    always @(*) begin
        r_streq <= `false;
        w_streq <= `false;
        ca_ada  <= bus_addr[`D_addr_ramad];
        ca_dina <= bus_wdata;
        ca_wea  <= `WrDisable;
        
        if(bus_en) begin
            if(bus_cached) begin
                ca_wea  <= ln_hit ? bus_wen : `WrDisable;
                w_streq <= ln_wb;
                r_streq <= !ln_hit;
            end
            else begin
                if(refs) w_streq <= !uc_wrdy;
                else     r_streq <= !uc_hit;
            end
        end
    end

    reg [`Word] rlk_addr,   wlk_addr;
    reg         rlk_cached, wlk_cached;
    reg [ 1: 0] rlk_size,   wlk_size;
    reg [`Word] wlk_data;
    reg [ 3: 0] wlk_strb;
    reg [ 3: 0] r_cnt,   w_cnt;
    reg [ 1: 0] r_state, w_state;

    wire [`D_idx] rlk_idx = rlk_addr[`D_addr_idx];
    wire [`D_idx] wlk_idx = wlk_addr[`D_addr_idx];
    
    integer i;
    initial begin
        for(i = 0; i < `I_lineN; i = i + 1) begin
            ca_ptag [i] <= 0;
            ca_valid[i] <= `false;
            ca_dirty[i] <= `false;
        end
    end

    always @(posedge aclk, negedge aresetn) begin
        if(!aresetn) begin
            r_state  <= 0;
            w_state  <= 0;
            r_cnt    <= 0;
            w_cnt    <= 0;
            ca_rbusy   <= `false;
            ca_wbusy   <= `false;

            rlk_addr   <= `ZeroWord;
            wlk_addr   <= `ZeroWord;
            rlk_cached <= `false;
            wlk_cached <= `false;
            rlk_size   <= `ASize_Word;
            wlk_size   <= `ASize_Word;
            wlk_data   <= `ZeroWord;
            wlk_strb   <= `WrDisable;

            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arsize   <= 0;
            arvalid  <= 0;
            awaddr   <= 0;
            awlen    <= 0;
            awsize   <= 0;
            awvalid  <= 0;
            wstrb    <= 0;
            wlast    <= 0;
            wvalid   <= 0;

            ca_web   <= `WrDisable;
            ca_adb   <= `ZeroWord;
            ca_dinb  <= `ZeroWord;

            uc_data  <= `ZeroWord;
            uc_addr  <= `ZeroWord;
            uc_valid <= `false;
            uc_wrdy    <= `false;
        end
        else begin
            // arid     <= 0;
            // araddr   <= 0;
            // arlen    <= 0;
            // arsize   <= 0;
            arvalid  <= 0;
            // awaddr   <= 0;
            // awlen    <= 0;
            // awsize   <= 0;
            awvalid  <= 0;
            // wstrb    <= 0;
            // wlast    <= 0;
            wvalid   <= 0;

            ca_web   <= `WrDisable;
            ca_adb   <= `ZeroWord;
            ca_dinb  <= `ZeroWord;

            uc_valid <= `false;
            uc_wrdy  <= `false;

            case (r_state)
                0: 
                if(bus_cached) begin
                    if(bus_en && !ln_hit && !ln_wb) begin
                        rlk_addr   <= {bus_addr[31:6], 6'b0};
                        rlk_cached <= `true;
                        r_cnt      <= 0;
                        r_state    <= 1;
                        ca_ptag [ad_idx] <= bus_addr[`I_addr_ptag];
                        ca_valid[ad_idx] <= `false;
                        ca_rbusy         <= `true;
                    end
                end
                else begin
                    if(rreq && !uc_hit) begin
                        rlk_addr   <= bus_addr;
                        rlk_cached <= `false;
                        rlk_size   <= bus_size;
                        r_state    <= 1;
                    end
                end
                
                1: 
                if(arvalid && arready) r_state <= 2;
                else begin
                    if(rlk_cached) begin
                        arid   <= 4'b0101;
                        araddr <= rlk_addr;
                        arlen  <= 4'hF;
                        arsize <= 3'b010;
                    end
                    else begin
                        arid   <= 4'b0100;
                        araddr <= rlk_addr;
                        arlen  <= 4'h0;
                        arsize <= {1'b0, rlk_size};
                    end
                    arvalid <= `true;
                end

                2:
                if(rvalid) begin
                    if(rlk_cached) begin
                        ca_web  <= 4'hF;
                        ca_adb  <= {rlk_idx, r_cnt};
                        ca_dinb <= rdata;
                        r_cnt   <= r_cnt + 1;
                    end
                    else begin
                        uc_data <= rdata;
                        uc_addr <= rlk_addr;
                        if(rlast) uc_valid <= `true;
                    end
                    if(rlast) r_state <= 3;
                end

                3: begin
                    if(rlk_cached) begin
                        ca_valid[rlk_idx] <= `true;
                        ca_rbusy          <= `false;
                    end
                    if((bus_stall ^ r_streq) == 0) begin
                        r_state  <= 0;
                        uc_valid <= `false;
                    end
                end
            endcase

            case (w_state)
                0:
                if(bus_cached) begin
                    if(wreq && ln_hit) 
                        ca_dirty[ad_idx] <= `true;
                    if(bus_en && ln_wb) begin
                        wlk_addr   <= {ln_ptag, ad_idx, 6'b0};
                        wlk_cached <= `true;
                        w_cnt      <= 0;
                        w_state    <= 1;
                        ca_wbusy   <= `true;
                    end
                end
                else begin
                    if(wreq && !uc_wrdy) begin
                        wlk_addr   <= bus_addr;
                        wlk_data   <= bus_wdata;
                        wlk_strb   <= bus_wen;
                        wlk_cached <= `false;
                        wlk_size   <= bus_size;
                        w_state    <= 1;
                    end
                end

                1:
                if(awvalid && awready) w_state <= 2;
                else begin
                    awaddr  <= wlk_addr;
                    awlen   <= wlk_cached ? 4'hF   : 4'h0;
                    awsize  <= wlk_cached ? 3'b010 : {1'b0, wlk_size};
                    awvalid <= `true;
                end

                2:
                if(wvalid && wready) begin
                    if(wlk_cached) begin
                        if(w_cnt == 4'hF) w_state <= 3;
                        else w_cnt <= w_cnt + 1;
                    end
                    else w_state <= 3;
                end
                else begin
                    if(wlk_cached) begin
                        ca_adb <= {wlk_idx, w_cnt};
                        wstrb  <= 4'hF;
                        wvalid <= `true;
                        wlast  <= w_cnt == 4'hF;
                    end
                    else begin
                        wstrb  <= wlk_strb;
                        wvalid <= `true;
                        wlast  <= `true;
                    end
                end

                3:
                if(bvalid) begin
                    w_state <= 0;
                    if(wlk_cached) begin
                        ca_dirty[wlk_idx] <= `false;
                        ca_wbusy          <= `false;
                    end
                    else uc_wrdy  <= `true;
                end
            endcase
        end
    end

    assign bus_rdata = bus_cached ? ca_dout : uc_data;
    assign wdata     = wlk_cached ? ca_dout : wlk_data;


endmodule