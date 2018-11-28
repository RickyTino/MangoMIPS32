/********************MangoMIPS32*******************
Filename:   Exception.v
Author:     RickyTino
Version:    Unreleased
**************************************************/
`include "Defines.v"

module Exception
(
    
    input  wire [`ExcBus ] excp_i,
    input  wire [`DataBus] cp0_Status,
    input  wire [`DataBus] cp0_Cause,

    input  wire [`AddrBus] pc,
    input  wire [`AddrBus] m_vaddr,

    output wire            exc_flag,
    output reg  [`ExcType] exc_type,
    output reg  [`AddrBus] exc_baddr
);

    reg [`ExcBus] excp;
 
    wire exc_intr = (cp0_Cause[`IP] & cp0_Status[`IM]) != 8'h00 
                    &&  cp0_Status[`IE ]
                    && ~cp0_Status[`ERL]
                    && ~cp0_Status[`EXL];

    always @(*) begin
        excp            <= excp_i;
        excp[`Exc_Intr] <= exc_intr;
    end

    assign exc_flag = (excp != `Exc_NoExc); 

    always @(*) begin
        casez (excp)
            // `Exc_W'b00000000000000000001: exc_type <= `ExcT_NMI;    //NMI
            `Exc_W'b0000000000000000001?: exc_type <= `ExcT_Intr;
            `Exc_W'b000000000000000001??: exc_type <= `ExcT_AdEL;
            // `Exc_W'b00000000000000001???: exc_type <= `ExcT_TLBR;
            // `Exc_W'b0000000000000001????: exc_type <= `ExcT_TLBI;
            // `Exc_W'b000000000000001?????: exc_type <= `ExcT_BusE;
            `Exc_W'b00000000000001??????: exc_type <= `ExcT_CpU;
            `Exc_W'b0000000000001???????: exc_type <= `ExcT_RI;
            `Exc_W'b000000000001????????: exc_type <= `ExcT_Ov;
            `Exc_W'b00000000001?????????: exc_type <= `ExcT_Trap;
            `Exc_W'b0000000001??????????: exc_type <= `ExcT_SysC;
            `Exc_W'b000000001???????????: exc_type <= `ExcT_Bp;
            `Exc_W'b00000001????????????: exc_type <= `ExcT_AdEL;
            `Exc_W'b0000001?????????????: exc_type <= `ExcT_AdES;
            // `Exc_W'b000001??????????????: exc_type <= `ExcT_TLBR;
            // `Exc_W'b00001???????????????: exc_type <= `ExcT_TLBI;
            // `Exc_W'b0001????????????????: exc_type <= `ExcT_TLBM;
            // `Exc_W'b001?????????????????: exc_type <= `ExcT_BusE;
            `Exc_W'b01??????????????????: exc_type <= `ExcT_ERET;
            // `Exc_W'b1???????????????????: exc_type <= `ExcT_NoExc;
            default:                      exc_type <= `ExcT_NoExc;
        endcase

        casez ({excp[`Exc_I_AdEL], excp[`Exc_D_AdEL], excp[`Exc_D_AdES]})
            3'b000: exc_baddr <= `ZeroWord;
            3'b001,
            3'b010,
            3'b011: exc_baddr <= m_vaddr;
            3'b1??: exc_baddr <= pc;
        endcase
    end

endmodule