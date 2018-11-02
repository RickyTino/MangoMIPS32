/********************MangoMIPS32*******************
Filename:	Control.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module Control
(
    input  wire [`Stages] stallreq,
    output reg  [`Stages] stall,
    output reg  [`Stages] flush
);

    always @(*) begin
        casez (stallreq)
            5'b00001: stall <= 5'b00011;
			5'b0001?: stall <= 5'b00011;
			5'b001??: stall <= 5'b00111;
			5'b01???: stall <= 5'b01111;
			5'b1????: stall <= 5'b11111;
			default:  stall <= 5'b00000;
        endcase

        casez (stallreq)
            5'b00001: flush <= 5'b00100;
			5'b0001?: flush <= 5'b00100;
			5'b001??: flush <= 5'b01000;
			5'b01???: flush <= 5'b10000;
			default:  flush <= 5'b00000;
        endcase
    end

endmodule