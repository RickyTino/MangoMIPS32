/********************MangoMIPS32*******************
Filename :    Inst_Cache.v
Author :      RickyTino
Version :     v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

module Inst_Cache (
    input  wire            aclk,
    input  wire            aresetn,
    output reg  [  3 : 0 ] arid,
    output reg  [ 31 : 0 ] araddr,
    output reg  [  3 : 0 ] arlen,
    output wire [  2 : 0 ] arsize,
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
    output wire [ 31 : 0 ] awaddr,
    output wire [  3 : 0 ] awlen,
    output wire [  2 : 0 ] awsize,
    output wire [  1 : 0 ] awburst,
    output wire [  1 : 0 ] awlock,
    output wire [  3 : 0 ] awcache,
    output wire [  2 : 0 ] awprot,
    output wire            awvalid,
    input  wire            awready,
    output wire [  3 : 0 ] wid,
    output wire [ 31 : 0 ] wdata,
    output wire [  3 : 0 ] wstrb,
    output wire            wlast,
    output wire            wvalid,
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
    output wire            bus_streq,
    input  wire            bus_stall,
    input  wire            bus_cached,

    input  wire [`CacheOp] cacheop,
    input  wire            cop_en,
    input  wire [`AddrBus] cop_addr
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
    
    `ifdef IF_Force_Cached
        assign cached = 1'b1;
    `else
        assign cached = bus_cached;
    `endif
    
    reg             ca_wen;
    reg  [`I_ramad] ca_adw;
    wire [`I_ramad] ca_adr;
    reg  [`DataBus] ca_din;
    wire [`DataBus] ca_dout;

    Inst_Cache_Ram icache_ram (
      .clk  (aclk   ),
      .wen  (ca_wen ),
      .adw  (ca_adw ),
      .adr  (ca_adr ),
      .din  (ca_din ),
      .dout (ca_dout)
    );

    reg  [`I_ptag] ca_ptag  [`I_lnNum];
    reg            ca_valid [`I_lnNum];

    wire [`I_idx ] ad_idx   = bus_addr[`I_addr_idx ];
    wire [`I_ptag] ad_ptag  = bus_addr[`I_addr_ptag];
    wire [`I_ptag] ln_ptag  = ca_ptag [ad_idx];
    wire           ln_valid = ca_valid[ad_idx];
    wire           ln_hit   = (ln_ptag ^ ad_ptag) == 0 && ln_valid;

    //Uncached Channel
    reg [`Word] uc_data;
    reg [`Word] uc_addr;
    reg         uc_valid;
    wire        uc_hit = (uc_addr ^ bus_addr) == 0 && uc_valid;

    assign ca_adr  = bus_addr[`I_addr_ramad];
    wire   r_streq = !bus_en ? `false   : 
                     cached  ? !ln_hit  :  !uc_hit;

    assign bus_streq = r_streq; // hit invalidate?

    reg  [ 3 :  0 ] r_cnt;
    reg  [ 1 :  0 ] r_state;
    reg  [`Word ] rlk_addr;
    reg           rlk_cached;

    wire [`I_idx] rlk_idx = rlk_addr[`I_addr_idx];
    
    integer i;
    initial begin
        for(i = 0; i < `I_lineN; i = i + 1) begin
            ca_ptag [i] <= 0;
            ca_valid[i] <= `false;
        end
    end

    always @(posedge aclk, negedge aresetn) begin
        if(!aresetn) begin
            r_state    <= 0;
            r_cnt      <= 0;
            rlk_addr   <= `ZeroWord;
            rlk_cached <= `false;

            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arvalid  <= 0;

            ca_wen   <= `false;
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
            
            ca_wen   <= `false;
            ca_adw   <= 0;
            ca_din   <= `ZeroWord;

            case (r_state)
                0 :  
                if(cached) begin
                    if(bus_en && !ln_hit) begin
                        rlk_addr   <= {bus_addr[31 : 6], 6'b0};
                        rlk_cached <= `true;
                        r_cnt      <= 0;
                        r_state    <= 1;
                        ca_ptag [ad_idx] <= bus_addr[`I_addr_ptag];
                        ca_valid[ad_idx] <= `false;
                    end
                end
                else begin
                    if(bus_en && !uc_hit) begin
                        rlk_addr   <= bus_addr;
                        rlk_cached <= `false;
                        r_state    <= 1;
                    end
                end

                1 :  
                if(arvalid && arready) r_state <= 2;
                else begin
                    if(rlk_cached) begin
                        arid   <= 4'b0011;
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

                2 : 
                if(rvalid) begin
                    if(rlk_cached) begin
                        ca_wen <= `true;
                        ca_adw <= {rlk_idx, r_cnt};
                        ca_din <= rdata;
                        r_cnt  <= r_cnt + 1;
                        // if(rlast) ca_valid[rlk_idx] <= `true;
                    end
                    else begin
                        uc_data <= rdata;
                        uc_addr <= rlk_addr;
                        if(rlast) uc_valid <= `true;
                    end
                    if(rlast) r_state <= 3;
                end

                3 :  begin
					if(rlk_cached) ca_valid[rlk_idx] <= `true;
					if((bus_stall ^ r_streq) == 0) begin
						r_state <= 0;
						uc_valid <= `false;
					end
				end
                
            endcase
        end
    end

    assign bus_rdata = cached ? ca_dout  :  uc_data;

endmodule