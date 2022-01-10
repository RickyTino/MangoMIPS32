# MangoMIPS32
MangoMIPS32是一个用Verilog HDL编写的软处理器核，兼容MIPS32 release 1架构。

MangoMIPS32 is a soft-core microprocessor written in Verilog HDL. It is compliant to MIPS32 release 1 architecture.

## 当前版本 Current Version
MangoMIPS32 v1.1.3  
该版本可运行Linux Kernel 5.6.14  
This version succeded running Linux Kernel 5.6.14

## 设计方案 Scheme
- 支持下述100条MIPS32r1指令
- 单发射顺序执行五级流水架构
- 参考主频：在Xilinx的XC7A200T-2FBG676上可达到100MHz（NSCSCC环境）
- 暂无浮点执行单元 
  
- Supports 100 MIPS32r1 instructions in ISA (Listed below)
- Single-issued in-order 5-stage pipeline structure
- Speed: 100MHz on XC7A200T-2FBG676 (NSCSCC environment)
- No floating point units

## 接口与缓存 Interface and Caches
- 实现AMBA-AXI总线接口
- 使用Xilinx Distributed RAM IP核构建的直接映射的L1 I-cache和L1 D-cache
- D-cache写策略：写回、按写分配
- 大小从2KB-128KB可配置
  
- Implemented AMBA-AXI as on-chip bus interface
- Direct-Mapped L1 I-cache and L1 D-cache build with Xilinx Distributed Ram IP Core 
- D-cache write strategy: Write-back, write-allocate
- size-configurable (2KB-128KB)

## 特权资源 Privilege Resources
- 实现了20个协处理器0（CP0）寄存器
- 支持用户模式（可通过宏禁用）
- 避免了所有CP0相关

- Implemented 20 coprocessor 0 (CP0) registers
- Support user mode (could be disabled with macros)
- Avoided all CP0 Execution Hazards

## 地址映射 Address Mapping
- 支持固定映射模式和页表(TLB)映射的MMU
- 32项全相连TLB
- 支持4KB等多种页面大小

- Supports both Fixed-mapping MMU and TLB-based MMU
- 32-entry full-associative TLB
- Support multiple page sizes starting from 4KB

## 细节 Details
支持的指令 / Instructions supported:
- SLL/SRL/SRA/SLLV/SRLV/SRAV
- SYNC/PREF (Decode as NOP)
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
  - I-Index Invalidate  
  - D-Index Writeback Invalidate  
  - I-Index Store Tag  
  - D-Index Store Tag  
  - I-Hit Invalidate  
  - D-Hit Invalidate  
  - D-Hit Writeback Invalidate  

CP0 寄存器 / CP0 Registers：  

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

支持的异常（按优先级排列）：/ Exceptions (prioritized)：
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

## 相关作品 Related Work
MangoMIPS32对外实现为一个AXI master接口，已适配以下环境：
MangoMIPS32 has an AXI master interface and can fit in these designs:
- [NSCSCC](http://www.nscscc.org/) Environments
- [HypoSoC_IoT](https://github.com/hitwh-nscscc/hyposoc_iot)
- [CatnipSoC](https://github.com/RickyTino/CatnipSoC)
