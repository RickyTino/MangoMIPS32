/********************MangoMIPS32*******************
Filename:	Core_Top.v
Author:		RickyTino
Version:	Unreleased
**************************************************/
`include "defines.v"

module MangoMIPS_Core_Top
(
    input  wire            clk,
    input  wire            rst,

    output wire            ibus_en,
    output wire [`AddrBus] ibus_addr,
    input  wire [`DataBus] ibus_rdata,

    output wire            dbus_en,
    output wire [`AddrBus] dbus_addr,
    input  wire [`DataBus] dbus_rdata,
    output wire [`ByteWEn] dbus_wen,
    output wire [`DataBus] dbus_wdata,

    output wire [`AddrBus] debug_wb_pc,
    output wire            debug_wb_wreg,
    output wire [`RegAddr] debug_wb_wraddr,
    output wire [`DataBus] debug_wb_wrdata
);

    wire            r1read;
    wire [`RegAddr] r1addr;
    wire [`DataBus] r1data;
    wire            r2read;
    wire [`RegAddr] r2addr;
    wire [`DataBus] r2data;

    wire [`AddrBus] id_pc;
    wire [`DataBus] id_inst;

    wire [`DataBus] id_opr1;
    wire [`DataBus] id_opr2;
    wire [`ALUOp  ] id_aluop;
    wire            id_wreg;
    wire [`RegAddr] id_wraddr;

    wire [`AddrBus] ex_pc;
    wire [`ALUOp  ] ex_aluop;
    wire [`DataBus] ex_opr1;
    wire [`DataBus] ex_opr2;
    wire            ex_wreg;
    wire [`RegAddr] ex_wraddr;

    wire [`DataBus] ex_alures;
    wire            ex_resnrdy;
    wire [`DWord  ] ex_mulhi;
    wire [`DWord  ] ex_mullo;
    wire            ex_mul_s;
    
    wire [`AddrBus] mem_pc;
    wire [`ALUOp  ] mem_aluop;
    wire [`DataBus] mem_alures_i;
    wire [`DWord  ] mem_mulhi;
    wire [`DWord  ] mem_mullo;
    wire            mem_mul_s;
    wire            mem_wreg;
    wire [`RegAddr] mem_wraddr;

    wire [`DataBus] mem_alures_o;
    wire            mem_resnrdy;
    wire            mem_whilo;
    wire [`DWord  ] mem_hilo;

    wire [`AddrBus] wb_pc;
    wire [`ALUOp  ] wb_aluop;
    wire [`DataBus] wb_alures;
    wire            wb_wreg;
    wire [`RegAddr] wb_wraddr;
    wire            wb_whilo;
    wire [`DWord  ] wb_hilo;

    wire [`DataBus] wb_wrdata;
    wire [`DWord  ] hilo;

    wire [`Stages ] stallreq;
    wire [`Stages ] stall;
    wire [`Stages ] flush; 
  
    PC pc (
        .clk     (clk       ),
        .rst     (rst       ),
        .stall   (stall[`IF]),
        .flush   (flush[`IF]),
        .flush_pc (`ZeroWord), //Temp!

        .pc      (ibus_addr ),
        .inst_en (ibus_en   )
    );
    
    //Temp
    assign stallreq[`IF] = `false;

    IF_ID if_id (
        .clk     (clk       ),
        .rst     (rst       ),
        .stall   (stall[`ID]),
        .flush   (flush[`ID]),

        .if_pc   (ibus_addr ),
        .if_inst (ibus_rdata),
        .id_pc   (id_pc     ),
        .id_inst (id_inst   ) 
    );

    Decode decode (
        .pc         (id_pc     ),
        .inst       (id_inst   ),

        .r1read     (r1read    ),
        .r1addr     (r1addr    ),
        .r1data     (r1data    ),
        .r2read     (r2read    ),
        .r2addr     (r2addr    ),
        .r2data     (r2data    ),

        .opr1       (id_opr1   ),
        .opr2       (id_opr2   ),
        .aluop      (id_aluop  ),
        .wreg       (id_wreg   ),
        .wraddr     (id_wraddr ),

        .ex_wreg    (ex_wreg   ),
        .ex_wraddr  (ex_wraddr ),
        .ex_alures  (ex_alures ),
        .ex_resnrdy (ex_resnrdy),

        .mem_wreg   (mem_wreg  ),
        .mem_wraddr (mem_wraddr),
        .mem_alures (mem_alures_o),
        .mem_resnrdy (mem_resnrdy),

        .stallreq(stallreq[`ID])
    );

    RegFile regfile (
        .clk    (clk      ),
        .rst    (rst      ), 

        .re1    (r1read   ), 
        .r1addr (r1addr   ),
        .r1data (r1data   ),

        .re2    (r2read   ),
        .r2addr (r2addr   ),
        .r2data (r2data   ),

        
        .we     (wb_wreg  ),
        .waddr  (wb_wraddr), 
        .wdata  (wb_wrdata)
    );

    ID_EX id_ex (
        .clk       (clk       ),
        .rst       (rst       ),
        .stall     (stall[`EX]),
        .flush     (flush[`EX]),

        .id_pc     (id_pc     ),
        .id_aluop  (id_aluop  ),
        .id_opr1   (id_opr1   ),
        .id_opr2   (id_opr2   ),
        .id_wreg   (id_wreg   ),
        .id_wraddr (id_wraddr ),
        

        .ex_pc     (ex_pc     ),
        .ex_aluop  (ex_aluop  ),
        .ex_opr1   (ex_opr1   ),
        .ex_opr2   (ex_opr2   ),
        .ex_wreg   (ex_wreg   ),
        .ex_wraddr (ex_wraddr )
    );

    ALU alu (
        .aluop  (ex_aluop ),
        .opr1   (ex_opr1  ),
        .opr2   (ex_opr2  ),

        .hilo (hilo),
        .mem_whilo (mem_whilo),
        .mem_hilo  (mem_hilo),

        .alures (ex_alures),
        .resnrdy (ex_resnrdy),
        .mulhi (ex_mulhi),
        .mullo (ex_mullo),
        .mul_s (ex_mul_s),

        .stallreq (stallreq[`EX])
    );

    EX_MEM ex_mem (
        .clk        (clk        ),
        .rst        (rst        ),
        .stall      (stall[`MEM]),
        .flush      (flush[`MEM]),

        .ex_pc      (ex_pc      ),
        .ex_aluop   (ex_aluop   ),
        .ex_alures  (ex_alures  ),
        .ex_mulhi (ex_mulhi),
        .ex_mullo (ex_mullo),
        .ex_mul_s (ex_mul_s),
        .ex_wreg    (ex_wreg    ),
        .ex_wraddr  (ex_wraddr  ),
        
        .mem_pc     (mem_pc     ),
        .mem_aluop  (mem_aluop  ),
        .mem_alures (mem_alures_i ),
        .mem_mulhi (mem_mulhi),
        .mem_mullo (mem_mullo),
        .mem_mul_s (mem_mul_s),
        .mem_wreg   (mem_wreg   ),
        .mem_wraddr (mem_wraddr )
    );
    
    MemAccess memaccess (
        .pc         (mem_pc    ),
        .aluop      (mem_aluop ),
        .alures     (mem_alures_i),
        
        .dbus_en    (dbus_en   ),
        .dbus_addr  (dbus_addr ),
        .dbus_rdata (dbus_rdata),
        .dbus_wen   (dbus_wen  ),
        .dbus_wdata (dbus_wdata),

        .resnrdy (mem_resnrdy),
        .stallreq (stallreq[`MEM])
    );
    
    MultRes multres (
        .aluop (mem_aluop),
        .alures_i (mem_alures_i),
        .mulhi (mem_mulhi),
        .mullo (mem_mullo),
        .mul_s (mem_mul_s),
        .hilo_i (hilo),

        .alures_o (mem_alures_o),
        .whilo  (mem_whilo),
        .hilo_o (mem_hilo)
    );

    MEM_WB mem_wb (
        .clk         (clk       ),
        .rst         (rst       ),
        .stall       (stall[`WB]),
        .flush       (flush[`WB]),

        .mem_pc      (mem_pc    ),
        .mem_aluop   (mem_aluop ),
        .mem_alures  (mem_alures_o),
        .mem_wreg    (mem_wreg  ),
        .mem_wraddr  (mem_wraddr),
        .mem_whilo  (mem_whilo),
        .mem_hilo (mem_hilo),

        .wb_pc      (wb_pc      ),
        .wb_aluop   (wb_aluop   ),
        .wb_alures  (wb_alures  ),
        .wb_wreg    (wb_wreg    ),
        .wb_wraddr  (wb_wraddr  ),
        .wb_whilo  (wb_whilo),
        .wb_hilo (wb_hilo)
    );

    WriteBack writeback (
        .alures (wb_alures),
        .wrdata (wb_wrdata)
    );
    
    HiLo hilounit (
        .clk (clk),
        .rst (rst),
        .whilo (wb_whilo),
        .wdata (wb_hilo),
        .rdata (hilo)
    );
    
    assign stallreq[`WB] = `false;
    
    Control control (
        .stallreq (stallreq),
        .stall    (stall   ),
        .flush    (flush   )
    );

    assign debug_wb_pc     = wb_pc;
    assign debug_wb_wreg   = wb_wreg;
    assign debug_wb_wraddr = wb_wraddr;
    assign debug_wb_wrdata = wb_wrdata;
    
endmodule



