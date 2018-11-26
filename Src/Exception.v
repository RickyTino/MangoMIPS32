/********************MangoMIPS32*******************
Filename:   Exception.v
Author:     RickyTino
Version:    Unreleased
**************************************************/
`include "Defines.v"

module Exception
(
    input  wire [`ExcBus ] excp_i,
    input  wire [`HardInt] intr,
    input  wire [`DataBus] cp0_Status,
    input  wire [`DataBus] cp0_Cause,

    output reg             exc_flag,
    output reg  [`ExcType] exc_type,
);

    reg [`ExcBus] excp;

    always @(*) begin
        excp <= excp_i;
        //Preserved for further use
    end

    always @(*) begin
        case (excp)

        endcase
    end


