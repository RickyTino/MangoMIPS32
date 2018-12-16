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
