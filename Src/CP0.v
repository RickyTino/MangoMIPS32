/********************MangoMIPS32*******************
Filename:   CP0.v
Author:     RickyTino
Version:    v1.0.0
**************************************************/
`include "Defines.v"

module CP0
(
    input  wire            clk,
    input  wire            rst,
    input  wire [`HardInt] intr,

    input  wire [`CP0Addr] addr,
    input  wire            wen,
    output reg  [`DataBus] rdata,
    input  wire [`DataBus] wdata,

    input  wire            exc_flag,
    input  wire [`ExcType] exc_type,
    input  wire [`AddrBus] pc,
    input  wire [`AddrBus] exc_baddr,
    input  wire [`CPNum  ] exc_cpnum,
    input  wire            inslot,

    output wire [`DataBus] Status_o,
    output wire [`DataBus] Cause_o,
    output wire [`DataBus] EPC_o,

    output wire            usermode,
    output reg             timer_int
);

    wire [`Word] PrId = 32'h00018000;

    reg  [`Word] BadVAddr;
    reg  [`Word] Count;
    reg  [`Word] Compare;
    reg  [`Word] EPC;
    
    //Status
    reg          Status_CU0;
    reg          Status_BEV;
    reg  [ 7: 0] Status_IM;
    reg          Status_UM;
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
        3'b0,
        Status_UM,  //4
        1'b0,
        Status_ERL, //2
        Status_EXL, //1
        Status_IE   //0
    };

    //Cause
    reg          Cause_BD;
    reg  [ 1: 0] Cause_CE;
    reg          Cause_IV;
    reg  [ 7: 0] Cause_IP;
    reg  [ 4: 0] Cause_ExcCode;

`ifdef NSCSCC_Mode
    wire [`Word] Cause = {
        Cause_BD,       //31 R
        1'b0,
        Cause_CE,       //29:28 R
        12'b0,
        Cause_IP,       //15:8 R[15:10] RW[9:8]
        1'b0,
        Cause_ExcCode,  //6:2 R
        2'b0
    };
`else
    wire [`Word] Cause = {
        Cause_BD,       //31 R
        1'b0,
        Cause_CE,       //29:28 R
        4'b0,
        Cause_IV,       //23 RW
        7'b0,
        Cause_IP,       //15:8 R[15:10] RW[9:8]
        1'b0,
        Cause_ExcCode,  //6:2 R
        2'b0
    };
`endif

    wire [`Word] pcm4     = pc - 32'h4;
    wire         timer_eq = (Count ^ Compare) == `ZeroWord;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            timer_int <= `false;

            BadVAddr <= `ZeroWord;
            Count    <= `ZeroWord;
            Compare  <= `ZeroWord;
            EPC      <= `ZeroWord;

            Status_CU0 <= 0;
            Status_BEV <= 1;
            Status_IM  <= 0;
            Status_UM  <= 0;
            Status_ERL <= 1;
            Status_EXL <= 0;
            Status_IE  <= 0;

            Cause_BD      <= 0;
            Cause_CE      <= 0;
            Cause_IV      <= 0;
            Cause_IP      <= 0;
            Cause_ExcCode <= 0;
        end
        else begin
            //Count & Compare
            Count <= Count + 32'd1;
            if(Compare != `ZeroWord && timer_eq)
                timer_int <= `true;
            
            //Exceptions
            Cause_IP[7:2] <= intr;

            if(exc_flag) begin
                case (exc_type)
                    `ExcT_Intr,
                    `ExcT_CpU,
                    `ExcT_RI,
                    `ExcT_Ov,
                    `ExcT_Trap,
                    `ExcT_SysC,
                    `ExcT_Bp,
                    `ExcT_AdEL,
                    `ExcT_AdES: begin
                        if(!Status_EXL) begin
                            EPC       <= inslot ? pcm4 : pc;
                            Cause_BD  <= inslot;
                        end
                        Status_EXL <= `One;
                    end
                    // `ExcT_TLBR:
                    // `ExcT_TLBI:
                    // `ExcT_TLBM:
                    // `ExcT_IBE:
                    // `ExcT_DBE:
                    `ExcT_ERET: begin
                        Status_EXL <= `Zero;
                    end
                endcase

                case (exc_type)
                    `ExcT_AdEL,
                    `ExcT_AdES: BadVAddr <= exc_baddr;
                    
                    `ExcT_CpU:  Cause_CE <= exc_cpnum;
                endcase

                //ExcCode
                case (exc_type)
                    `ExcT_Intr: Cause_ExcCode <= `ExcC_Intr;
                    `ExcT_CpU:  Cause_ExcCode <= `ExcC_CpU;
                    `ExcT_RI:   Cause_ExcCode <= `ExcC_RI;
                    `ExcT_Ov:   Cause_ExcCode <= `ExcC_Ov;
                    `ExcT_Trap: Cause_ExcCode <= `ExcC_Tr;
                    `ExcT_SysC: Cause_ExcCode <= `ExcC_SysC;
                    `ExcT_Bp:   Cause_ExcCode <= `ExcC_Bp;
                    `ExcT_AdEL: Cause_ExcCode <= `ExcC_AdEL;
                    `ExcT_AdES: Cause_ExcCode <= `ExcC_AdES;
                    // `ExcT_TLBR: Cause_ExcCode <= `ExcC_
                    // `ExcT_TLBI: Cause_ExcCode <= `ExcC_
                    // `ExcT_TLBM: Cause_ExcCode <= `ExcC_TLBS
                    // `ExcT_IBE:  Cause_ExcCode <= `ExcC_
                    // `ExcT_DBE:  Cause_ExcCode <= `ExcC_
                endcase
            end
            else if(wen) begin
                case (addr)
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
                        Status_CU0 <= wdata[`CU0];
                        Status_BEV <= wdata[`BEV];
                        Status_IM  <= wdata[`IM];
                        Status_UM  <= wdata[`UM];
                        Status_ERL <= wdata[`ERL];
                        Status_EXL <= wdata[`EXL];
                        Status_IE  <= wdata[`IE];
                    end

                    `CP0_Cause: begin
                        //Cause_IV      <= wdata[`IV];
                        Cause_IP[1:0] <= wdata[`IPS];
                    end

                    `CP0_EPC: begin
                        EPC <= wdata;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (addr)
            `CP0_BadVAddr: rdata <= BadVAddr;
            `CP0_Count:    rdata <= Count;
            `CP0_Compare:  rdata <= Compare;
            `CP0_Status:   rdata <= Status;
            `CP0_Cause:    rdata <= Cause;
            `CP0_EPC:      rdata <= EPC;
            `CP0_PrId:     rdata <= PrId;
            default:       rdata <= `ZeroWord;
        endcase
    end

    assign usermode = Status_UM & ~(Status_ERL | Status_EXL);
    assign Status_o = Status;
    assign Cause_o  = Cause;
    assign EPC_o    = EPC;

endmodule