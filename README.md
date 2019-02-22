# MangoMIPS32
轻量级CPU软核，兼容MIPS32 release 1架构

## 当前版本
MangoMIPS32 v1.1.0
该版本可成功启动Linux 2.6.32

## CPU核心参数
- 指令集：100条MIPS32 release 1指令
- 微架构：单发射，顺序执行，经典五级流水线架构
- FPGA上主频可达100MHz
- 不含浮点部件

## 接口与缓存资源
- 对外使用AMBA AXI总线接口
- 分布式RAM作为缓存，使用Xilinx IP核
- 指令/数据缓存均直接映射，大小可配置（2KB-128KB）

## 特权资源
- 实现了20个CP0寄存器，12种例外处理
- 支持两种运行模式：用户态与核心态，可以配置禁用用户态
- 不产生CP0 Execution Hazard

## 虚实地址映射
- 可配置使用固定映射MMU或TLB-MMU
- 32项全相连JTLB
- 支持除1KB以外所有页大小

## 详细信息
目前实现的指令及操作：
- SLL/SRL/SRA/SLLV/SRLV/SRAV
- SYNC/PREF (作为空指令)
- AND/OR/XOR/NOR
- MOVZ/MOVN/MFHI/MFLO/MTHI/MTLO
- ANDI/ORI/XORI/LUI
- ADD/ADDU/SUB/SUBU/SLT/SLTU/CLO/CLZ
- ADDI/ADDIU/SLTI/SLTIU
- MUL/MULT/MULTU/MADD/MADDU/MSUB/MSUBU/DIV/DIVU
- J/JAL/JR/JALR
- BEQ/BNE/BGTZ/BLEZ/BGEZ/BGEZAL/BLTZ/BLTZAL
- BEQL/BNEL/BGTZL/BLEZL/BGEZL/BGEZALL/BLTZL/BLTZALL
- LB/LBU/LH/LHU/LW/LWL/LWR/LL
- SB/SH/SW/SWL/SWR/SC
- MFC0/MTC0
- SYSCALL/BREAK/ERET/WAIT
- TEQ/TNE/TGE/TGEU/TLT/TLTU
- TEQI/TNEI/TGEI/TGEIU/TLTI/TLTIU
- TLBP/TLBWI/TLBWR/TLBR
- CACHE:  
    I-Index Invalidate  
    D-Index Writeback Invalidate  
    I-Index Store Tag  
    D-Index Store Tag  
    I-Hit Invalidate  
    D-Hit Invalidate  
    D-Hit Writeback Invalidate  

实现的CP0寄存器：
|   Name   |Reg#|Sel#|
|:---------|:--:|:--:|
| Index    | 0  | 0  |
| Random   | 1  | 0  |
| EntryLo0 | 2  | 0  |
| EntryLo1 | 3  | 0  |
| Context  | 4  | 0  |
| PageMask | 5  | 0  |
| Wired    | 6  | 0  |
| BadVAddr | 8  | 0  |
| Count    | 9  | 0  |
| EntryHi  | 10 | 0  |
| Compare  | 11 | 0  |
| Status   | 12 | 0  |
| Cause    | 13 | 0  |
| EPC      | 14 | 0  |
| PrId     | 15 | 0  |
| Config   | 16 | 0  |
| Config1  | 16 | 1  |
| TagLo    | 28 | 0  |
| TagHi    | 29 | 0  |
| ErrorEPC | 30 | 0  |

实现的例外处理及优先级：
- Reset
- Interrupt
- I-Address Error
- I-TLB Refill
- I-TLB Invalid
- Coprocessor Unusable
- Reserved Instruction
- Overflow / Trap / Syscall / Breakpoint
- D-Address Error
- D-TLB Refill
- D-TLB Invalid
- D-TLB Modified
- ERET

## 作者注
持续更新中，计划最终实现完整的MIPS32r1兼容。