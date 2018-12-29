/********************MangoMIPS32*******************
Filename:   Config.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/

//Note: The result is UNPREDICTABLE if values are set out of the range indicated.
//To disable a definition, add a "_" to the name or simply comment out the whole line. 

// ------------------------Core Options------------------------
// Define "No_Branch_Delay_Slot" to disable the execution of delay slot instruction 
// when a branch or jump is taken.
// P.S.: Under this circumstance, there's no difference between branch instructions 
// and branch likely instructions.
`define _No_Branch_Delay_Slot

// ------------------------NSCSCC Options------------------------
// Define "Disable_Cause_IV" to disable the IV field of CP0 Cause register.
// This setting is necessary to pass NSCSCC-2018 tests.
 `define Disable_Cause_IV

// Define "Reset_Cacheable" to set the reset state of Config.K0/KU/K23 to a cacheable
// state (value 3'd3).
`define Reset_Cacheable

// Define "IF_Force_Cached" to set the cacheability of all instruction fetch
// to a cacheable state.
// Note that coherency problems might occur under other circumstances. It is strongly
// not recommended to set this option when applying this CPU to any use other than
// the NSCSCC tests.
 `define _IF_Force_Cached

// ------------------------MMU & Cache Options------------------------
// Define "Fixed_Mapping_MMU" to implement a Fixed Mapping MMU.
// Otherwise implements a standard TLB-Based MMU.
`define _Fixed_Mapping_MMU

// The value of "ICache_N" and "DCache_N" refers to the size of inst-cache and 
// data-cache in the way described below:
// Cache_Size | 2KB     4KB     8KB     16KB    32KB    64KB    128KB
// Cache_N    | 0       1       2       3       4       5       6
// Note that the result is UNPREDICTABLE if this value is set different from the
// actual size of the implemented cache.
`define     ICache_N     1
`define     DCache_N     1

// ------------------------Simulation Options------------------------
// Define "Output_Exception_Info" to output exception information to TCL console 
// during simulation when exceptions occur.
`define _Output_Exception_Info

// ------------------------------------------------