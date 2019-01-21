#********************MangoMIPS32*******************
# Filename:   Cache_test/test.S
# Author:     RickyTino
# Version:    v1.0.1
#**************************************************

# Cache Operation test for MangoMIPS32

.globl _start
.set noreorder
.text
.org 0x0
_start:
    li      $t0, 0x0040FF01
    mtc0    $t0, $12            # Status = 0x0040FF01
    li      $t1, 0x00000003
    mtc0    $t1, $16            # Config.K0 = 3 (Cacheable)
    la      $sp, 0x80008000     # stack pointer: 0x80008000
    la      $t2, 0x80000600
    jalr    $t2
    
.org 0x380
_ex_start:
    mfc0    $k0, $13            # k0 = CP0.Cause
    andi    $k1, $k0, 0x7C
    srl     $k1, $k1, 2         # k1 = CP0.Cause.ExcCode
    
    # li      $k0, 0x08
    # beq     $k0, $k1, _syscall_ex
    # nop
    li      $k0, 0x0D
    beq     $k0, $k1, _trap_ex
    nop
    b       _ex_finish
    nop
    
_trap_ex:
    b       _ex_finish
    nop
    
_ex_finish:
    mfc0    $k0, $14
    addi    $k0, 4
    mtc0    $k0, $14
    eret
    

.org 0x600
_test1:
    # Test 1: ICache - Index Invalidate (0x0)
    la      $t0, 0x80000000
    lw      $t1, 0x800($t0)
    sw      $t1, 0x620($t0)
    cache   0x0, 0x600($t0)
    nop
    # 0x80000620 should be a syscall after cache operation
    
.org 0x640
_test2:
    # Test 2: ICache - Index Store Tag (0x8)
    la      $t0, 0x80000000
    lw      $t1, 0x800($t0)
    sw      $t1, 0x670($t0)     # save a syscall to 0x80000670
    li      $t2, 0x98765400
    mtc0    $t2, $28            # ITagLo = 0x98765400
    nop
    cache   0x8, 0x600($t0)
    nop
    # 0x80000670 should be a syscall after cache operation
    
.org 0x680
_test3: 
    # Test 3: ICache - Hit Invalidate
    
    
.org 0x800
    syscall
    