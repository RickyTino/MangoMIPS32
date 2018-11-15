/********************MangoMIPS32*******************
Filename:	CP0.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "Defines.v"

module CP0
(
    input  wire            clk,
    input  wire            rst,

    input  wire            wen,
    input  wire [`CP0Addr] waddr,
    input  wire [`DataBus] wdata,
    input  wire [`CP0Addr] raddr,
    output reg  [`DataBus] rdata,

    output reg             timer_int
);

    reg [`Word] BadVAddr;
    reg [`Word] Count;
    reg [`Word] Compare;

    wire count_eq_compare = (Count ^ Compare) == `ZeroWord; 

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            timer_int <= `false;
        end
        else begin
            Count <= Count + 32'd1;
            if(Compare != `ZeroWord && count_eq_compare)
                timer_int <= `true;
            
            if(wen) begin
                case (waddr)
                    `CP0_BadVAddr: begin
                        BadVAddr <= wdata;
                    end

                    `CP0_Count: begin
                        Count <= wdata;
                    end

                    `CP0_Compare: begin
                        Compare   <= wdata;
                        timer_int <= `false;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (raddr)
            `CP0_BadVAddr: rdata <= BadVAddr;
            `CP0_Count:    rdata <= Count;
            `CP0_Compare:  rdata <= Compare;
            default:       rdata <= `ZeroWord;
        endcase
    end

endmodule