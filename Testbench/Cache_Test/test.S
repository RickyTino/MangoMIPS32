#********************MangoMIPS32*******************
# Filename:   Cache_test/test.S
# Author:     RickyTino
# Version:    v1.0.0
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
    nop
    wait
    
.org 0x380
_ex_start:
    mfc0    $k0, $13            # k0 = CP0.Cause
    andi    $k1, $k0, 0x7C
    srl     $k1, $k1, 2         # k1 = CP0.Cause.ExcCode
    
    # li      $k0, 0x08
    # beq     $k0, $k1, _syscall_ex
    # nop
    # li      $k0, 0x0D
    # beq     $k0, $k1, _trap_ex
    # nop
    # b       _ex_finish
    # nop
    
# _trap_ex:
    # b       _ex_finish
    # nop
    
_ex_finish:
    mfc0    $k0, $14
    addi    $k0, 4
    mtc0    $k0, $14
    eret
    
# Test 1: ICache - Index Invalidate (0x0)
_test1:
.org 0x600
    la      $s0, 0x80000000     # s0 = 0x80000000, kseg0 base
    la      $s1, 0xA0000000     # s1 = 0xA0000000, kseg1 base
    li      $s2, 0xC            # s2 = 0x0000000C (syscall)
    li      $s3, 0xD            # s3 = 0x0000000D (break)
    sw      $s2, 0x630($s1)     # save a syscall to 0xA0000630
    cache   0x0, 0x60A($s0)
    nop
    # 0x80000630 should be a syscall after cache operation

# Test 2: ICache - Index Store Tag (0x8)
_test2:
.org 0x640
    sw      $s2, 0x670($s1)     # save a syscall to 0xA0000670
    li      $t0, 0x98765400
    mtc0    $t0, $28            # ITagLo = 0x98765400
    cache   0x8, 0x658($s0)
    nop
    # 0x80000670 should be a syscall after cache operation

# Test 3: ICache - Hit Invalidate (0x10)
_test3:
.org 0x680 
    sw      $s3, 0x6A0($s1)     # save a break to 0xA00006A0
    la      $t0, 0x81000000
    cache   0x10, 0x6AC($t0)    # should be an unhit
    nop
    # newly-added break at 0x800006A0 should not be executed.
.org 0x6C0
    sw      $s2, 0x6F0($s1)     # save a break to 0xA00006F0
    cache   0x10, 0x6F4($s0)    # should be a hit
    nop
    # 0x800006F0 should be a syscall after cache operation

# Test 4: DCache - Index Writeback Invalidate (0x1)
_test4:
.org 0x700
    li      $t0, 0x10
    li      $t1, 0
    
    # loop1: save 0x1 to 0x10 to 0x80001000 ~ 0x80001010, 16 Bytes, cached
loop1:
    add     $t2, $t1, $s0
    sb      $t1, 0x1000($t2)
    slt     $t3, $t1, $t0
    bne     $t3, $zero, loop1
    addi    $t1, $t1, 1
    # DCache data after loop1: 
    #               +0      +2      +4      +6
    # 0x80001000    00  01  02  03  04  05  06  07
    # 0x80001008    08  09  0A  0B  0C  0D  0E  0F
    
    li      $t0, 0x13121110         # t0 = 0x13121110
    sw      $t0, 0x1000($s1)        # uncached save t0 to 0x80001000
    cache   0x1, 0x1000($s0)        # DCache Index Writeback Invalidate
    lw      $t1, 0x1000($s0)        # uncached load from 0x80001004
    teq     $t1, $t0                # t0 should be overwritten
    lw      $t2, 0x1000($s1)        # data in cache is now the same with data in RAM
    tne     $t1, $t2                # trap if unequal
    nop
    
# Test 5: DCache - Index Store Tag (0x9)
_test5:
    li      $t0, 0x27262524
    sw      $t0, 0x1004($s0)        # save 0x27262524 to DCache id1004
    li      $t1, 0x17161514
    sw      $t1, 0x1004($s1)        # save 0x17161514 to RAM 0x1004
    li      $t2, 0
    mtc0    $t2, $28, 2             # DTagLo = 0x00000000
    cache   0x9, 0x1010($s0)        # store tag to index
    nop
    lw      $t3, 0x1004($s0)        # load from 0x80001000, fill cache
    tne     $t3, $t1                # t3 should equal t1
    teq     $t3, $t0                # t3 should not equal t0
    nop
    
# Test 6: DCache - Hit Invalidate (0x11)
_test6:
    li      $t0, 0x2B2A2928
    sw      $t0, 0x1008($s0)        # save 0x2B2A2928 to DCache id1008
    li      $t1, 0x1B1A1918
    sw      $t1, 0x1008($s1)        # save 0x1B1A1918 to RAM 0x1008
    li      $t2, 0x81000000         # wrong tag 0x81000000
    cache   0x11, 0x1014($t2)       # should be an unhit
    nop
    lw      $t3, 0x1008($s0)        # load from 0x80001008, cache
    teq     $t3, $t1                # t3 should not equal t1
    tne     $t3, $t0                # t3 should equal t0
    nop
    cache   0x11, 0x1016($s0)       # should be a hit
    nop
    lw      $t3, 0x1008($s0)        # load from 0x80001008, fill cache
    tne     $t3, $t1                # t3 should equal t1
    teq     $t3, $t0                # t3 should not equal t0

# Test 7: DCache - Hit Writeback Invalidate (0x15)
_test7:
    li      $t0, 0x2F2E2D2C
    sw      $t0, 0x100C($s0)        # save 0x2F2E2D2C to DCache id100C
    li      $t1, 0x1F1E1D1C
    sw      $t1, 0x100C($s1)        # save 0x1F1E1D1C to RAM 0x100C
    li      $t2, 0x82000000         # wrong tag 0x81000000
    cache   0x15, 0x101C($t2)       # should be an unhit
    nop
    lw      $t3, 0x100C($s1)        # load from 0x80001008, RAM
    teq     $t3, $t0                # t3 should not equal t0
    tne     $t3, $t1                # t3 should equal t1
    nop
    cache   0x15, 0x1016($s0)       # should be a hit writeback
    nop
    lw      $t3, 0x100C($s1)        # load from 0x80001008, RAM
    tne     $t3, $t0                # t3 should equal t0
    teq     $t3, $t1                # t3 should not equal t1
    nop
    
# Cache test end, return
_test_return:
    jr      $ra
    nop
