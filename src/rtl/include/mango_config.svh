`ifndef MANGO_CONFIG_SVH
`define MANGO_CONFIG_SVH

// ---------- CONFIGURABLE PARAMETERS ----------

// `MANGO_CFG_IC_WAY: 
// The number of ways to be implemented in L1I cache. Each way is fixed to 4KB. 
`define MANGO_CFG_IC_WAY 4

// `MANGO_CFG_DC_WAY: 
// The number of ways to be implemented in L1D cache. Each way is fixed to 4KB.
`define MANGO_CFG_DC_WAY 4

// `MANGO_CFG_ITLB_SIZE: 
// The number of ITLB entries to be implemented.
`define MANGO_CFG_ITLB_SIZE 4

// `MANGO_CFG_DTLB_SIZE: 
// The number of DTLB entries to be implemented.
`define MANGO_CFG_DTLB_SIZE 4

// ---------- ARCHITECTURAL OPTIONS ----------

// `MANGO_CFG_MMU_FIX_MAP: 
// Implement a fixed-mapping MMU instead of a TLB-based MMU.
`define _MANGO_CFG_MMU_FIX_MAP

// `MANGO_CFG_DISABLE_USER_ADE: 
// Do not report address errors when trying to access kernel memory spaces under 
// user mode. 
`define _MANGO_CFG_DISABLE_USER_ADE

// `MANGO_CFG_RESET_CACHEABLE: 
// Set CP0.Config.K0/KU/K23 to "cacheable"(3'd3) on reset.
`define _MANGO_CFG_RESET_CACHEABLE

// ---------- IMPLEMENTATION OPTIONS ----------
// `MANGO_CFG_XILINX_FPGA:
// Indicates that this design is targeting Xilinx FPGA.
`define _MANGO_CFG_XILINX_FPGA

`ifdef  MANGO_CFG_XILINX_FPGA

// `MANGO_CFG_USE_XILINX_DIST_RAM:
// Use distributed ram instances of Xilinx FPGA in ram wrappers
`define _MANGO_CFG_USE_XILINX_DIST_RAM

// `MANGO_CFG_USE_XILINX_DSP:
// Use DSP components of Xilinx FPGA
`define _MANGO_CFG_USE_XILINX_DSP

`endif // MANGO_CFG_XILINX_FPGA

// ---------- SIMULATION OPTIONS ----------

// define `MANGO_CFG_SIM to enable simulation-only compilation mode
`ifdef MANGO_CFG_SIM

// TBD

`endif // MANGO_CFG_SIM

`endif // MANGO_CONFIG_SVH