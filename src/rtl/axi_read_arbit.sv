`define     AXI_ID_WIDTH    4
`define     AXI_ID          `AXI_ID_WIDTH-1:0
`define     AXI_ADDR        31:0
`define     AXI_DATA        31:0
`define     AXI_LEN         3:0
`define     AXI_SIZE        2:0
`define     AXI_BURST       1:0
`define     AXI_LOCK        1:0
`define     AXI_CACHE       3:0
`define     AXI_PROT        2:0
`define     AXI_RESP        1:0 

`define     AXI_ID_I        4'b0001
`define     AXI_ID_D        4'b0000

module axi_read_arbit (
    input                   clk,
    input                   rst_n,

    input   [`AXI_ADDR]     i_araddr,
    input   [`AXI_LEN]      i_arlen,
    input   [`AXI_SIZE]     i_arsize,
    input   [`AXI_BURST]    i_arburst,
    input                   i_arvalid,
    output                  i_arready,
    output  [`AXI_DATA]     i_rdata,
    output  [`AXI_RESP]     i_rresp,
    output                  i_rlast,
    output                  i_rvalid,
    input                   i_rready,

    input   [`AXI_ADDR]     d_araddr,
    input   [`AXI_LEN]      d_arlen,
    input   [`AXI_SIZE]     d_arsize,
    input   [`AXI_BURST]    d_arburst,
    input                   d_arvalid,
    output                  d_arready,
    output  [`AXI_DATA]     d_rdata,
    output  [`AXI_RESP]     d_rresp,
    output                  d_rlast,
    output                  d_rvalid,
    input                   d_rready,
    // input   [`AXI_ADDR]     d_awaddr,
    // input   [`AXI_LEN]      d_awlen,
    // input   [`AXI_SIZE]     d_awsize,
    // input   [`AXI_BURST]    d_awburst,
    // input                   d_awvalid,
    // output                  d_awready,
    // input   [`AXI_DATA]     d_wdata,
    // input   [`AXI_STRB]     d_wstrb,
    // input                   d_wlast,
    // input                   d_wvalid,
    // output                  d_wready,

    output  [`AXI_ID]       m_arid,
    output  [`AXI_ADDR]     m_araddr,
    output  [`AXI_LEN]      m_arlen,
    output  [`AXI_SIZE]     m_arsize,
    output  [`AXI_BURST]    m_arburst,
    output  [`AXI_LOCK]     m_arlock,
    output  [`AXI_CACHE]    m_arcache,
    output  [`AXI_PROT]     m_arprot,
    output                  m_arvalid,
    input                   m_arready,
    input   [`AXI_ID]       m_rid,
    input   [`AXI_DATA]     m_rdata,
    input   [`AXI_RESP]     m_rresp,
    input                   m_rlast,
    input                   m_rvalid,
    output                  m_rready
);

    // arbitration
    wire   ar_grant_i = ~d_arvalid;
    assign i_arready  = m_arready & ar_grant_i;
    assign d_arready  = m_arready;

    assign m_arid     = ar_grant_i ? `AXI_ID_I : `AXI_ID_D;
    assign m_araddr   = ar_grant_i ? i_araddr  : d_araddr;
    assign m_arlen    = ar_grant_i ? i_arlen   : d_arlen;
    assign m_arsize   = ar_grant_i ? i_arsize  : d_arsize;
    assign m_arburst  = ar_grant_i ? i_arburst : d_arburst;
    assign m_arlock   = '0;
    assign m_arcache  = '0;
    assign m_arprot   = '0;
    assign m_arvalid  = ar_grant_i ? i_arvalid : d_arvalid;

    wire   r_to_i     = m_rid == `AXI_ID_I;
    assign m_rready   = r_to_i ? i_rready : d_rready;

    assign i_rdata    = m_rdata;
    assign i_rresp    = m_rresp;
    assign i_rlast    = m_rlast;
    assign i_rvalid   = m_rvalid & r_to_i;

    assign d_rdata    = m_rdata;
    assign d_rresp    = m_rresp;
    assign d_rlast    = m_rlast;
    assign d_rvalid   = m_rvalid & ~r_to_i;

endmodule
