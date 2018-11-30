# MangoMIPS32
轻量级CPU软核，兼容MIPS32 release 1架构

## 当前版本
MangoMIPS32 v1.0.1

## CPU核心参数
- ISA & PRA: MIPS32 release 1
- 单发射，顺序执行，五级流水
- 可配置是否启用延迟槽（配置项位于Config.v中）
- 暂时只提供NSCSCC-2018 SRAM接口版本

## 指令集
实现了95种MIPS32 release 1指令，包含：
- 算术、逻辑、移动、空指令
- 乘、除、乘加指令
- 跳转、分支、branch likely指令
- 对齐/非对齐加载存储指令、原子操作指令
- 自陷指令
- 其他特殊指令

## 特权资源
- 实现了7个CP0寄存器，11种例外处理
- 支持用户态与核心态的切换
- 除数据相关外，不处理CP0相关
- 异常处理入口地址参见MIPS32手册

## 地址空间
- 暂无TLB，使用固定映射方式
- 暂无缓存

## 详细信息
目前实现的指令列表：
- SLL/SRL/SRA/SLLV/SRLV/SRAV
- SYNC/PREF/CACHE (作为空指令)
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
- SYSCALL/BREAK/ERET
- TEQ/TNE/TGE/TGEU/TLT/TLTU
- TEQI/TNEI/TGEI/TGEIU/TLTI/TLTIU

实现的CP0寄存器：
- BadVAddr (Register  8, Select 0)
- Count    (Register  9, Select 0)
- Compare  (Register 11, Select 0)
- Status   (Register 12, Select 0)
- Cause    (Register 13, Select 0)
- EPC      (Register 14, Select 0)
- PrId     (Register 15, Select 0)

实现的异常处理及优先级：
- Reset
- Int
- I-AdEL
- CpU
- RI
- Ov, Trap, Syscall, Bp,
- D-AdEL/AdES
- ERET

## 作者注
持续更新中，计划最终实现完整的MIPS32r1兼容。
