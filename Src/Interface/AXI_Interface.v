`include "../Config.v"
`include "../Defines.v"

module AXI_Interface (
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
    output reg  [ 31 : 0 ] wdata,
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
    input  wire            bus_cached
);

    //assign arsize   = 3'b010;
    assign arburst  = 2'b01;
    assign arlock   = 2'b0;
    assign arcache  = 4'b0;
    assign arprot   = 3'b0;
    assign rready   = 1'b1;
    assign awid     = 4'b0;
    //assign awsize   = 3'b010;
    assign awburst  = 2'b01;
    assign awlock   = 2'b0;
    assign awcache  = 4'b0;
    assign awprot   = 3'b0;
    assign wid      = 4'b0;
    assign bready   = 1'b1;

    wire refs = bus_wen != `WrDisable;
    wire rreq = bus_en & !refs;
    wire wreq = bus_en &  refs;

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
        
        if(bus_en) begin
            if(refs) w_streq <= !w_rdy;
            else     r_streq <= !uc_hit;
        end
    end

    reg [`Word] rlk_addr;
    reg [`Word] wlk_addr;
    reg [`Word] wlk_data;
    reg [ 3: 0] wlk_strb;
    reg [ 1: 0] rlk_size, wlk_size;
    reg [ 1: 0] r_state,  w_state;

    always @(posedge aclk, negedge aresetn) begin
        if(!aresetn) begin
            r_state  <= 0;
            w_state  <= 0;

            arid     <= 0;
            araddr   <= 0;
            arlen    <= 0;
            arsize   <= 0;
            arvalid  <= 0;
            awaddr   <= 0;
            awlen    <= 0;
            awsize   <= 0;
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
            rlk_size <= `ASize_Word;
            wlk_size <= `ASize_Word;
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
            // wdata    <= 0;
            // wstrb    <= 0;
            // wlast    <= 0;
            wvalid   <= 0;

            uc_valid <= `false;
            w_rdy    <= `false;

            case (r_state)
                0: 
                if(rreq && !uc_hit) begin
                    rlk_addr <= bus_addr;
                    rlk_size <= bus_size;
                    r_state  <= 1;
                end
                
                1: 
                if(arvalid && arready) r_state <= 2;
                else begin
                    arid    <= 4'b0010;
                    araddr  <= rlk_addr;
                    arlen   <= 4'h0;
                    arsize  <= {1'b0, rlk_size};
                    arvalid <= `true;
                end

                2:
                if(rvalid) begin
                    uc_data <= rdata;
                    uc_addr <= rlk_addr;
                    uc_valid <= `true;
                    if(rlast) r_state <= 3;
                end

                3: if((bus_stall ^ r_streq) == 0) r_state <= 0;

            endcase

            case (w_state)
                0:
                if(wreq && !w_rdy) begin
                    wlk_addr <= bus_addr;
                    wlk_data <= bus_wdata;
                    wlk_strb <= bus_wen;
                    wlk_size <= bus_size;
                    w_state  <= 1;
                end

                1:
                if(awvalid && awready) w_state <= 2;
                else begin
                    awaddr  <= wlk_addr;
                    awlen   <= 4'h0;
                    awsize  <= {1'b0, wlk_size};
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