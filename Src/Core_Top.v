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
    output wire [`DataBus] dbus_wdata
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
    wire [`DataBus] ex_opr1;
    wire [`DataBus] ex_opr2;
    wire [`ALUOp  ] ex_aluop;
    wire            ex_wreg;
    wire [`RegAddr] ex_wraddr;

    wire [`DataBus] ex_alures;
    
    wire [`AddrBus] mem_pc;
    wire [`ALUOp  ] mem_aluop;
    wire [`DataBus] mem_alures;
    wire            mem_wreg;
    wire [`RegAddr] mem_wraddr;

    wire [`AddrBus] wb_pc;
    wire [`ALUOp  ] wb_aluop;
    wire [`DataBus] wb_alures;
    wire            wb_wreg;
    wire [`RegAddr] wb_wraddr;

    wire [`DataBus] wb_wrdata;
 
    PC pc (
        .clk     (clk      ),
        .rst     (rst      ),

        .pc      (ibus_addr),
        .inst_en (ibus_en  )
    );
    
    IF_ID if_id (
        .clk     (clk       ),
        .rst     (rst       ),

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

        .opr1        (id_opr1    ),
        .opr2        (id_opr2    ),
        .aluop      (id_aluop  ),
        .wreg       (id_wreg   ),
        .wraddr     (id_wraddr ),

        .ex_wreg    (ex_wreg   ),
        .ex_wraddr  (ex_wraddr ),
        .ex_alures  (ex_alures ),

        .mem_wreg   (mem_wreg  ),
        .mem_wraddr (mem_wraddr),
        .mem_alures (mem_alures)
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
        .clk       (clk      ),
        .rst       (rst      ),

        .id_pc     (id_pc    ),
        .id_aluop  (id_aluop ),
        .id_opr1    (id_opr1   ),
        .id_opr2    (id_opr2   ),
        .id_wraddr (id_wraddr),
        .id_wreg   (id_wreg  ),

        .ex_pc     (ex_pc    ),
        .ex_aluop  (ex_aluop ),
        .ex_opr1    (ex_opr1   ),
        .ex_opr2    (ex_opr2   ),
        .ex_wraddr (ex_wraddr),
        .ex_wreg   (ex_wreg  )
    );

    ALU alu (
        .aluop  (ex_aluop ),
        .opr1    (ex_opr1   ),
        .opr2    (ex_opr2   ),
        .alures (ex_alures)
    );

    EX_MEM ex_mem (
        .clk        (clk       ),
        .rst        (rst       ),

        .ex_pc      (ex_pc     ),
        .ex_aluop   (ex_aluop  ),
        .ex_alures  (ex_alures ),
        .ex_wraddr  (ex_wraddr ),
        .ex_wreg    (ex_wreg   ),

        .mem_pc     (mem_pc    ),
        .mem_aluop  (mem_aluop ),
        .mem_alures (mem_alures),
        .mem_wraddr (mem_wraddr),
        .mem_wreg   (mem_wreg  )
    );
    
    MemAccess memaccess (
        .pc         (mem_pc    ),
        .aluop      (mem_aluop ),
        .alures     (mem_alures),
        
        .dbus_en    (dbus_en   ),
        .dbus_addr  (dbus_addr ),
        .dbus_rdata (dbus_rdata),
        .dbus_wen   (dbus_wen  ),
        .dbus_wdata (dbus_wdata)
    );
    
    MEM_WB mem_wb (
        .clk         (clk       ),
        .rst         (rst       ),

        .mem_pc      (mem_pc     ),
        .mem_aluop   (mem_aluop  ),
        .mem_alures  (mem_alures ),
        .mem_wraddr  (mem_wraddr ),
        .mem_wreg    (mem_wreg   ),

        .wb_pc      (wb_pc     ),
        .wb_aluop   (wb_aluop  ),
        .wb_alures  (wb_alures ),
        .wb_wraddr  (wb_wraddr ),
        .wb_wreg    (wb_wreg   )
    );

    WriteBack writeback (
        .alures (wb_alures),
        .wrdata (wb_wrdata)
    );
    
endmodule



