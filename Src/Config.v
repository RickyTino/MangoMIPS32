/********************MangoMIPS32*******************
Filename:   Config.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/

//Note: The result is UNPREDICTABLE if values are set out of the range indicated.

// ------------------------------------------------
// Define "No_Branch_Delay_Slot" to disable the execution of delay slot instruction 
// when a branch or jump is taken.
// P.S.: Under this circumstance, there's no difference between branch instructions 
// and branch likely instructions.

//`define No_Branch_Delay_Slot

// ------------------------------------------------
// Define "NSCSCC_Mode" to meet the requirement of NSCSCC-2018 tests.
// Changes includes:
// - Disable Cause.IV (Ignore on write and read as zero)
// - Set the reset state of Config.K0/KU/K23 to 3'd3 (cacheable)

`define NSCSCC_Mode

// ------------------------------------------------
// Define "Fixed_Mapping_MMU" to implement a Fixed Mapping MMU.
// Otherwise implements a standard TLB-Based MMU.

//`define Fixed_Mapping_MMU

// ------------------------------------------------
// Define "Output_Exception_Info" to output exception information to TCL console 
// during simulation when exceptions occur.

//`define Output_Exception_Info

// ------------------------------------------------
// The value of "ICache_N" and "DCache_N" refers to the size of inst-cache and 
// data-cache in the way described below:
// Cache_Size | 2KB     4KB     8KB     16KB    32KB    64KB    128KB
// Cache_N    | 0       1       2       3       4       5       6
// Note that the result is UNPREDICTABLE if this value is set different from the
// actual size of the implemented cache.

`define     ICache_N     2
`define     DCache_N     2

// ------------------------------------------------