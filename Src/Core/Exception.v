/********************MangoMIPS32*******************
Filename:   Exception.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

module Exception
(
    
    input  wire [`ExcBus ] excp_i,
    input  wire            d_tlbr,
    input  wire            d_tlbi,
    input  wire            d_tlbm,
    input  wire            d_refs,
    input  wire [`DataBus] cp0_Status,
    input  wire [`DataBus] cp0_Cause,

    input  wire [`AddrBus] pc,
    input  wire [`AddrBus] m_vaddr,
    input  wire            nullinst,

    output wire            exc_flag,
    output reg             exc_save,
    output reg  [`ExcType] exc_type,
    output reg  [`AddrBus] exc_baddr
);

    reg [`ExcBus] excp;
 
    wire exc_intr = (cp0_Cause[`IP] & cp0_Status[`IM]) != 8'h00 
                    &&  cp0_Status[`IE ]
                    && ~cp0_Status[`ERL]
                    && ~cp0_Status[`EXL];

    always @(*) begin
        if(nullinst)    excp <= 0;
        else begin
            excp              <= excp_i;
            excp[`Exc_Intr  ] <= exc_intr; 
            excp[`Exc_D_TLBR] <= d_tlbr;
            excp[`Exc_D_TLBI] <= d_tlbi;
            excp[`Exc_D_TLBM] <= d_tlbm;
        end
    end

    assign exc_flag = (excp != `Exc_NoExc); 

    always @(*) begin
        casez (excp)
            // `Exc_W'b?????????????????1: exc_type <= `ExcT_NMI;    //NMI
            `Exc_W'b????????????????10: exc_type <= `ExcT_Intr;
            `Exc_W'b???????????????100: exc_type <= `ExcT_AdE;
            `Exc_W'b??????????????1000: exc_type <= `ExcT_TLBR;
            `Exc_W'b?????????????10000: exc_type <= `ExcT_TLBI;
            `Exc_W'b????????????100000: exc_type <= `ExcT_IBE;
            `Exc_W'b???????????1000000: exc_type <= `ExcT_CpU;
            `Exc_W'b??????????10000000: exc_type <= `ExcT_RI;
            `Exc_W'b?????????100000000: exc_type <= `ExcT_Ov;
            `Exc_W'b????????1000000000: exc_type <= `ExcT_Trap;
            `Exc_W'b???????10000000000: exc_type <= `ExcT_SysC;
            `Exc_W'b??????100000000000: exc_type <= `ExcT_Bp;
            `Exc_W'b?????1000000000000: exc_type <= `ExcT_AdE;
            `Exc_W'b????10000000000000: exc_type <= `ExcT_TLBR;
            `Exc_W'b???100000000000000: exc_type <= `ExcT_TLBI;
            `Exc_W'b??1000000000000000: exc_type <= `ExcT_TLBM;
            `Exc_W'b?10000000000000000: exc_type <= `ExcT_DBE;
            `Exc_W'b100000000000000000: exc_type <= `ExcT_ERET;
            default:                    exc_type <= `ExcT_NoExc;
        endcase

        casez (excp)
            `Exc_W'b???????????????100,
            `Exc_W'b??????????????1000,
            `Exc_W'b?????????????10000: begin
                exc_baddr <= pc;
                exc_save  <= `false;
            end

            `Exc_W'b?????1000000000000,
            `Exc_W'b????10000000000000,
            `Exc_W'b???100000000000000,
            `Exc_W'b??1000000000000000: begin
                exc_baddr <= m_vaddr;
                exc_save  <= d_refs;
            end

            default: begin
                exc_baddr <= `ZeroWord;
                exc_save  <= d_refs;
            end
        endcase
    end

endmodule