/********************MangoMIPS32*******************
Filename:   CP0.v
Author:     RickyTino
Version:    Unreleased
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

    reg  [`Word] BadVAddr;
    reg  [`Word] Count;
    reg  [`Word] Compare;
    
    //Status
    reg          Status_CU0;
    reg          Status_BEV;
    reg  [ 7: 0] Status_IM;
    reg          Status_ERL;
    reg          Status_EXL;
    reg          Status_IE;

    wire [`Word] Status = {
        3'b0,
        Status_CU0, //28
        5'b0,
        Status_BEV, //22
        6'b0,
        Status_IM,  //15:8
        5'b0,
        //Status_ERL, //2
        1'b0,
        Status_EXL, //1
        Status_IE   //0
    };

    //Cause
    reg          Cause_BD;
    reg          Cause_IV;
    reg  [ 7: 0] Cause_IP;
    reg  [ 5: 0] Cause_ExcCode;

    wire [`Word] Cause = {
        Cause_BD,       //31
        7'b0,
        Cause_IV,       //23
        7'b0,
        Cause_IP,       //15:8
        1'b0,
        Cause_ExcCode,  //6:2
        2'b0
    };

    wire timer_eq = (Count ^ Compare) == `ZeroWord; 

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            timer_int <= `false;

            BadVAddr <= `ZeroWord;
            Count    <= `ZeroWord;
            Compare  <= `ZeroWord;

            Status_CU0 <= 0;
            Status_BEV <= 1;
            Status_IM  <= 0;
            Status_EXL <= 0;
            Status_IE  <= 0;

            Cause_BD      <= 0;
            Cause_IV      <= 0;
            Cause_IP      <= 0;
            Cause_ExcCode <= 0;
        end
        else begin
            //Count & Compare
            Count <= Count + 32'd1;
            if(Compare != `ZeroWord && timer_eq)
                timer_int <= `true;
            
            //Write
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

                    `CP0_Status: begin
                        Status_CU0 <= wdata[28];
                        Status_BEV <= wdata[22];
                        Status_IM  <= wdata[15:8];
                        Status_EXL <= wdata[ 1];
                        Status_IE  <= wdata[ 0];
                    end

                    `CP0_Cause: begin
                        Cause_BD      <= wdata[31];
                        Cause_IV      <= wdata[23];
                        Cause_IP      <= wdata[15:8];
                        Cause_ExcCode <= wdata[ 6:2];
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
            `CP0_Status:   rdata <= Status;
            `CP0_Cause:    rdata <= Cause;
            default:       rdata <= `ZeroWord;
        endcase
    end

endmodule