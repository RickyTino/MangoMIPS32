#********************MangoMIPS32*******************
# Filename:   TLB_test/test.S
# Author:     RickyTino
# Version:    v1.0.0
#**************************************************

# TLB_test for MangoMIPS32

.globl _start
.set noreorder
.text
.org 0x0
_start:
    # initialize test environment
    # Test 0: Mapping when ERL=1
    la      $t1, 0x00000000
    la      $t2, 0x80000000
    la      $sp, 0x80008000     # stack pointer: 0x80008000(p0x8000)
    li      $t3, 0x1314
    sw      $t3, 0x1000($t2)    # save: 0x1314 to v0x80001000(p0x1000)
    lw      $t4, 0x1000($t1)    # load: v0x00001000(p0x1000)
    li      $t0, 0x0040FF01
    mtc0    $t0, $12            # Status = 0x0040FF01
    nop
    tne     $t3, $t4            # Trap if unequal
    li      $t1, 0x00000003
    mtc0    $t1, $16            # Config.K0 = 3 (Cacheable)
    jal     TLB_test            # branch and link to test
    nop
    wait
    
.org 0x200                      # TLB Refill Entrance
    b       excp
    nop
    
.org 0x380
excp:
    addi    $t8, $t8, 1
    mfc0    $s0, $13            # s0 = cp0.cause
    mfc0    $s1, $14            # s1 = cp0.epc
    mfc0    $s2, $12            # s2 = cp0.status
    andi    $s3, $s0, 0x7C
    srl     $s3, $s3, 2         # s3 = cp0.cause.exccode
    
    li      $t0, 0
    beq     $s3, $t0, excp_intr
    nop
    b       excp_end
    nop

excp_intr:
    li      $t0, 0
    mtc0    $t0, $11            # Compare = 0
    b       excp_end
    nop

    
excp_end:
    lui     $t0, 0xFFFF
    addi    $t0, 0xFFF9
    and     $s2, $s2, $t0
    mtc0    $s2, $12            # cp0.status.exl = 0, erl = 0
    addi    $s1, 4
    mtc0    $s1, $14            # EPC = EPC + 4
    eret
    
.org 0x700
TLB_test:
    li      $t0, 0x10
    mtc0    $t0, $6             # Wired = 16
    
    # Test1: Basic translation & tlb instructions (ASID Match)
    li      $t1, 0x0003
    mtc0    $t1, $10            # EntryHi: VPN2=0x00000/2, ASID=0x03
    li      $t2, 0x0046
    mtc0    $t2, $2             # EntryLo0: PFN=0x00001, DV
    li      $t3, 0x0006
    mtc0    $t3, $3             # EntryLo1: PFN=0x00000, DV
    tlbwr
    li      $t0, 0
    mtc0    $t0, $0             # Index=0x00
    li      $t1, 0x2005
    mtc0    $t1, $10            # EntryHi: VPN2=0x00002/2, ASID=0x05
    li      $t2, 0x0007
    mtc0    $t2, $2             # EntryLo0: PFN=0x00000, DVG
    li      $t3, 0x0047
    mtc0    $t3, $3             # EntryLo1: PFN=0x00001, DVG
    tlbwi
    li      $t1, 0x0005
    mtc0    $t1, $10            # EntryHi: VPN2=0x00000/2, ASID=0x05
    tlbp
    mfc0    $t0, $0
    tgei    $t0, 0              # Trap if match
    li      $t1, 0x0003
    mtc0    $t1, $10            # EntryHi: VPN2=0x00000/2, ASID=0x03
    tlbp
    mfc0    $t2, $0
    tlti    $t2, 0              # Trap if unmatch
    li      $s4, 0x1234         # s4 = 0x1234
    sw      $s4, 0x0000         # save 0x1234 to v0x00000000(p0x1000)
    li      $s5, 0x5678         # s5 = 0x5678
    la      $t2, 0x80001004 
    sw      $s5, ($t2)          # save 0x5678 to v0x80001004(p0x1004)
    sync
    lw      $t3, 0x0004         # load from v0x00000004(p0x1004)
    tne     $t3, $s5            # trap if unequal
    la      $t4, 0x80001000 
    lw      $t5, ($t4)          # load from v0x80001000(p0x1000)
    tne     $t5, $s4            # trap if unequal
    lw      $t6, 0x1380         # load from v0x00001380(p0x0380)
    li      $t7, 0x23180001     # <- the first instruction of exception
    tne     $t6, $t7            # trap if unequal
    
    # Test1+: executing instruction in an TLB-translated virtual address space
    sw      $ra, ($sp)          # push ra to stack
    # la      $ra, Label1
    bal     L1                  # ra <= PC 
    nop
L1:
    andi    $t0, $ra, 0xFFFF
    addi    $t0, $t0, 0x2010    # t0[31:16] = 0x0000, points at Test 2
    jr      $t0
    nop                         # the following instruction is in page 0x00002000
    
    # Test2: field G
    li      $t2, 0x2000
    mtc0    $t2, $10            # EntryHi: VPN2=0x00002/2, ASID=0x00
    tlbp                        # probe for matching page
    nop
    mfc0    $t3, $0
    tlti    $t3, 0              # Trap if unmatch
    lw      $t0, 0x2000         # load from v0x00002000(p0x0000)
    li      $t1, 0x24090000     # <- the very first instruction
    tne     $t0, $t1            # trap if unequal
    lw      $t2, 0x3000         # load from v0x00003000(p0x1000)
    tne     $t2, $s4            # trap if unequal
    lw      $t3, 0x3004         # load from v0x00003004(p0x1004)
    tne     $t3, $s5            # trap if unequal
    li      $s6, 0xABCD         # s6 = 0xABCD
    sw      $s6, 0x3008         # save 0xABCD to v0x00003008(p0x1008)
    
    # Test3: 16KB big page (mask)
    li      $t0, 1
    mtc0    $t0, $0             # Index=0x01
    li      $t1, 0x00010000
    mtc0    $t1, $10            # EntryHi: VPN2=0x00010/2, ASID=0x00
    li      $t2, 0x0006
    mtc0    $t2, $2             # EntryLo0: PFN=0x00000, DV
    li      $t3, 0x0006
    mtc0    $t3, $3             # EntryLo1: PFN=0x00000, DV
    li      $t4, 0x6000
    mtc0    $t4, $5             # PageMask: Mask=0x0003
    tlbwi
    la      $t0, 0x00011000
    lw      $t1, 0x0000($t0)    # load from v0x00011000(p0x1000)
    tne     $t1, $s4
    lw      $t2, 0x0004($t0)    # load from v0x00011004(p0x1004)
    tne     $t2, $s5
    lw      $t3, 0x0008($t0)    # load from v0x00011008(p0x1008)
    tne     $t3, $s6
    la      $t4, 0x80003000
    li      $s7, 0x12ABCDEF     # s7 = 0x12ABCDEF
    sw      $s7, ($t4)          # save 0x12ABCDEF to v0x80003000(p0x3000)
    lw      $t6, 0x2000($t0)    # load from v0x00013000(p0x3000)
    tne     $t6, $s7
    lw      $t7, 0x6000($t0)    # load from v0x00017000(p0x3000)
    tne     $t7, $s7
    
    # Test 4: Cacheability test
    li      $t1, 0x00006000
    mtc0    $t1, $10            # EntryHi: VPN2=0x00006/2, ASID=0x00
    li      $t2, 0x001F
    mtc0    $t2, $2             # EntryLo0: PFN=0x00000, CDVG
    li      $t3, 0x005F
    mtc0    $t3, $3             # EntryLo1: PFN=0x00001, CDVG
    li      $t4, 0x00
    mtc0    $t4, $5             # PageMask: Mask=0x0000
    tlbwr
    la      $t0, 0x600C
    lw      $t1, ($t0)          # load from v0x0000600C(p0x000C)
    la      $t2, 0x7004
    lw      $t3, ($t2)          # load from v0x00007004(p0x1004)
    tne     $t3, $s5
    
    # Test 5: TLB exceptions
    lw      $t0, 0x4000         # load: TLBRefill-TLBL
    sw      $t0, 0x4000         # save: TLBRefill-TLBS
    
    li      $t0, 2
    mtc0    $t0, $0             # Index=0x02
    li      $t1, 0x4000
    mtc0    $t1, $10            # EntryHi: VPN2=0x00004/2, ASID=0x00
    li      $t2, 0x0005
    mtc0    $t2, $2             # EntryLo0: PFN=0x00000, DG
    li      $t3, 0x0043
    mtc0    $t3, $3             # EntryLo1: PFN=0x00001, VG
    tlbwi
    lw      $t0, 0x4000         # load: TLBInvalid-TLBL
    sw      $t0, 0x4000         # save: TLBInvalid-TLBS
    lw      $t1, 0x5000         # load from v0x00005000(p0x1000)
    tne     $t1, $s4
    sw      $t1, 0x5000         # save: TLBModified-TLBS
    sync
    
    # Test 6: Getting back to kseg1 address space
    bal     L2
    nop
L2:
    lui     $t0, 0xBFC0
    addi    $ra, $ra, -0x1FEC
    add     $t0, $t0, $ra
    jr      $t0
    nop
    
    # Test end, return
    lw      $ra, ($sp)
    jr      $ra
    nop
