# MangoMIPS32
A soft-core microprocessor written by Verilog HDL, which is compliant with MIPS32 release 1 architecture.

## Current Version
MangoMIPS32 v1.1.1  
This version is capable for running Linux 2.6.32

## CPU Core 
- Implemented 100 instructions from MIPS32r1 ISA
- Single-issued 5-stage pipeline structure
- Clock frequency up to 100MHz
- No floating point coprocessors

## Interface and Caches
- Uses AMBA-AXI as the bus interface
- Instruction cache and data cache build with Xilinx Distributed Ram IP Core
- Write-back, write-allocate, direct-mapped
- size-configurable (2KB-128KB)

## Privilege Resources
- Implemented 20 coprocessor 0 (CP0) registers
- Support user mode which could be disabled
- No CP0 Execution Hazards

## Address Mapping
- Fixed-mapping MMU and TLB-based MMU is supported
- TLB with 32 items
- Support all kind of page sizes except 1KB page

## Details
ISA:
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
    I-Index Invalidate  
    D-Index Writeback Invalidate  
    I-Index Store Tag  
    D-Index Store Tag  
    I-Hit Invalidate  
    D-Hit Invalidate  
    D-Hit Writeback Invalidate  

CP0 Registers：  

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

Exceptions sorted by priority：
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

## P.S.
This project is being continuously developed and it aims to be completely compliant with the MIPS32r1 Architecture.
