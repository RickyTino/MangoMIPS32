/********************MangoMIPS32*******************
Filename:	config.v
Author:		RickyTino
Version:	Unreleased
**************************************************/

//Note: The result is UNPREDICTABLE if values are set out of the range indicated.

//------------------------------------------------
/*
Placing the address calculation and branch judgement circuits in ID stage.
This will result in longer intro-clock paths, but avoided the one-cycle 
stall in pipelining branch judgement.
*/
//`define Branch_In_ID
//------------------------------------------------