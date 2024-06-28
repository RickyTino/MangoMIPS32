`include "mango.svh"

module mango_itlb import mango_pkg::*;
(
    input               clk,
    input               rst_n,

    input               if_vld_i,
    input   [31:12]     if_va_page_i,  
    output              if_itlb_hit_o,
    output  [31:12]     if_pa_page_o,
    output              if_cca_o,

    output              mmu_req_vld_o,
    output  [31:12]     mmu_req_vpn_o,
    input               mmu_resp_vld_i,
    input   [31:12]     mmu_resp_vpn_i,
    input   [31:12]     mmu_resp_ppn_i,
    input   [31:12]     mmu_resp_mask_i,
    input               mmu_resp_cca_i,
    input   mmu_excp_t  mmu_resp_err_i,
    // input               mmu_resp_tlbi_i,
    // input               mmu_resp_tlbm_i,
    // input               mmu_resp_tlbr_i,

    input               cp0_status_erl_i,
    input               cp0_config_k0_i,
    input               cp0_config_k23_i,
    input               cp0_config_ku_i,

    input               tlb_inval_i
);

`ifdef MANGO_CFG_MMU_FIX_MAP

    assign mmu_req_vld_o = 1'b0;

    wire    va_in_kuseg = va_page_i[31   ] == 1'b0;
    wire    va_in_kseg0 = va_page_i[31:29] == 3'b100;
    wire    va_in_kseg1 = va_page_i[31:29] == 3'b101;
    wire    va_in_kseg2 = va_page_i[31:29] == 3'b110;
    wire    va_in_kseg3 = va_page_i[31:29] == 3'b111;
    
    wire    [31:12] pa_page_kseg = {3'b000, va_page_i[28:12]};
    wire    [31:12] pa_page_useg = cp0_status_erl_i ? va_page_i : {va_page_i[31:30] + 2'b01, va_page_i[29:12]};

    assign pa_page_o = 
        (va_in_kseg0 ? pa_page_kseg : '0) |
        (va_in_kseg1 ? pa_page_kseg : '0) |
        (va_in_kseg2 ? va_page_i    : '0) |
        (va_in_kseg3 ? va_page_i    : '0) |
        (va_in_kuseg ? pa_page_useg : '0) ;
          
    assign cca_o = 
        (va_in_kseg0 ? cp0_config_k0_i  : '0) |
        (va_in_kseg2 ? cp0_config_k23_i : '0) |
        (va_in_kseg3 ? cp0_config_k23_i : '0) |
        (va_in_kuseg ? cp0_config_ku_i  : '0) ;

`else // TLB-based MMU

    // ITLB
    logic           [ITLB_SIZE-1:0]     itlb_vld_e;
    logic           [ITLB_SIZE-1:0]     itlb_entry_e;
    logic           [ITLB_SIZE-1:0]     itlb_vld_d;
    itlb_entry_t    [ITLB_SIZE-1:0]     itlb_entry_d;
    logic           [ITLB_SIZE-1:0]     itlb_vld_q;
    itlb_entry_t    [ITLB_SIZE-1:0]     itlb_entry_q;

    for (genvar i = 0; i < ITLB_SIZE; i++) begin : g_itlb_entry
        `DFFPANE ( clk, rst_n, '0, itlb_vld_e  [i], itlb_vld_d  [i], itlb_vld_q  [i] )
        `DFFPNNE ( clk,            itlb_entry_e[i], itlb_entry_d[i], itlb_entry_q[i] )
    end

    // TLB look-up
    logic [ITLB_SIZE-1:0] itlb_match;

    for (genvar i = 0; i < ITLB_SIZE; i++) begin : g_itlb_match
        assign itlb_match[i] = itlb_vld_q[i] & (if_va_page_i & itlb_entry_q[i].mask) == (itlb_entry_q[i].vpn & itlb_entry_q[i].mask);
    end
    
    assign if_itlb_hit_o = |itlb_match;

    itlb_entry_t itlb_hit_entry;

    lib_mux #( .NUM(ITLB_SIZE), .T(itlb_entry_t) )
        u_itlb_mux ( .data_i(itlb_entry_q), .sel_i(itlb_match), .data_o(itlb_hit_entry) );

    // logic [31:12] hit_ppn;
    // logic         hit_cca;

    // `MUX_1H ( itlb_match, itlb_entry_q, hit_ppn )
    // `MUX_1H ( itlb_match, itlb_entry_q, hit_cca )

    // assign pa_page_o = hit_ppn;
    // assign cca_o     = hit_cca;
    assign if_pa_page_o = itlb_hit_entry.ppn;
    assign if_cca_o     = itlb_hit_entry.cca;

    // TLB miss
    wire  mmu_busy_e =  mmu_req_vld_o | mmu_resp_vld_i;
    wire  mmu_busy_d = ~mmu_resp_vld_i;
    logic mmu_busy_q;

    `DFFPANE ( clk, rst_n, 1'b0, mmu_busy_e, mmu_busy_d, mmu_busy_q )

    assign mmu_req_vld_o = if_vld_i & ~if_itlb_hit_o & ~mmu_busy_q;
    assign mmu_req_vpn_o = if_va_page_i;

    // PLRU replacement
    logic [ITLB_SIZE-1:0] itlb_evict;

    // TBD

    // TLB fill
    for (genvar i = 0; i < ITLB_SIZE; i++) begin : gb_itlb_fill
        assign itlb_vld_e  [i]      = itlb_entry_e[i] | tlb_inval_i;
        assign itlb_entry_e[i]      = mmu_resp_vld_i & (~|mmu_resp_err_i) & itlb_evict[i]; 
        assign itlb_vld_d  [i]      = ~tlb_inval_i;
        assign itlb_entry_d[i].vpn  = mmu_resp_vpn_i;
        assign itlb_entry_d[i].ppn  = mmu_resp_ppn_i;
        assign itlb_entry_d[i].mask = mmu_resp_mask_i;
        assign itlb_entry_d[i].cca  = mmu_resp_cca_i;
    end

`endif

endmodule

