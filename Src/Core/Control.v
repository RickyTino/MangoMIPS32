/********************MangoMIPS32*******************
Filename:   Control.v
Author:     RickyTino
Version:    v1.0.1
**************************************************/
`include "../Config.v"
`include "../Defines.v"

module Control
(
    input  wire [`Stages] stallreq,
    output reg  [`Stages] stall,
    
    input  wire            exc_flag,
    input  wire [`ExcType] exc_type,
    input  wire [`DataBus] cp0_Status,
    input  wire [`DataBus] cp0_Cause,
    input  wire [`DataBus] cp0_EPC,
    
    output reg  [`Stages ] flush,
    output reg  [`AddrBus] flush_pc
);

    wire bev = cp0_Status[`BEV];
    wire exl = cp0_Status[`EXL];
    wire iv  = cp0_Cause [`IV ];

    always @(*) begin
        if(exc_flag) begin
            stall <= 5'b00000;
            flush <= 5'b11111;
            
            case (exc_type)
                `ExcT_Intr: begin
                    case ({bev, iv})
                        2'b00: flush_pc <= `Nml_GenExc;
                        2'b01: flush_pc <= `Nml_SpIntr;
                        2'b10: flush_pc <= `Bts_GenExc;
                        2'b11: flush_pc <= `Bts_SpIntr;
                    endcase
                end

                `ExcT_TLBR: begin
                    case ({bev, exl})
                        2'b00: flush_pc <= `Base_Nml;
                        2'b01: flush_pc <= `Nml_GenExc;
                        2'b10: flush_pc <= `Base_Bts;
                        2'b11: flush_pc <= `Bts_GenExc;
                    endcase
                end

                `ExcT_RI,
                `ExcT_Ov,
                `ExcT_Trap,
                `ExcT_SysC,
                `ExcT_Bp,
                `ExcT_AdE,
                `ExcT_TLBI,
                `ExcT_TLBM,
                // `ExcT_IBE,
                // `ExcT_DBE,
                `ExcT_CpU: begin
                    flush_pc <= bev ? `Bts_GenExc : `Nml_GenExc;
                end

                `ExcT_ERET: begin
                    flush_pc <= cp0_EPC;
                    // flush_pc <= cp0_Status[`ERL] ? cp0_ErrorEPC : cp0_EPC
                end
                
                default: flush_pc <= `ZeroWord;
            endcase
        end
        else begin
            flush_pc <= `ZeroWord;
            casez (stallreq)
                // 5'b00001: stall <= 5'b00011; // IF
                // 5'b0001?: stall <= 5'b00011; // ID
                // 5'b001??: stall <= 5'b00111; // EX
                // 5'b01???: stall <= 5'b01111; // MEM
                // 5'b1????: stall <= 5'b11111; // WB

                5'b00010: stall <= 5'b00011; // ID
                5'b001?0: stall <= 5'b00111; // EX
                5'b00??1: stall <= 5'b00111; // IF
                5'b01???: stall <= 5'b01111; // MEM
                5'b1????: stall <= 5'b11111; // WB
                default:  stall <= 5'b00000;
            endcase

            casez (stallreq)
                // 5'b00001: flush <= 5'b00100; // IF
                // 5'b0001?: flush <= 5'b00100; // ID
                // 5'b001??: flush <= 5'b01000; // EX
                // 5'b01???: flush <= 5'b10000; // MEM

                5'b00010: flush <= 5'b00100; // ID
                5'b001?0: flush <= 5'b01000; // EX
                5'b00??1: flush <= 5'b01000; // IF
                5'b01???: flush <= 5'b10000; // MEM
                default:  flush <= 5'b00000;
            endcase
        end
    end

endmodule