arch n64.cpu
endian msb




  macro push(reg) {
  	addi sp,sp,-4		//;Subtract 4 from Stack pointer
  	sw {reg},0(sp)		//;Put the register onto the stack
}
  macro pop(reg) {
     lw {reg},0(sp)            //;Pop the register off the stack
     addi sp,sp,4           // ;Add 4 to the Stack pointer
}
 
//fill $00101000 
macro seek(offset) {
  origin {offset} & 0x3fffff
  base 0xc00000 | {offset}
}

//output "BOOT\BIN\BOOTCODE_BM64.BIN", create




//origin $00000000
//base $A4000040

include "LIB/N64.INC"



// COP0 registers:
constant Index = $00 
constant Random = $01 
constant EntryLo0 = $02 
constant EntryLo1 = $03 
constant Context = $04 
constant PageMask  = $05 
constant Wired = $06 
//constant *RESERVED*($07)
constant BadVAddr = $08 
constant Count = $09 
constant EntryHi = $0A 
constant Compare = $0B 
constant Status = $0C 
constant Cause = $0D 
constant EPC = $0E 
constant PRevID = $0F 
constant Config = $10 
constant LLAddr = $11 
constant WatchLo = $12 
constant WatchHi = $13 
constant XContext = $14 
//constant *RESERVED*($15)
//constant *RESERVED*($16)
//constant *RESERVED*($17)
//constant *RESERVED*($18)
//constant *RESERVED*($19)
constant PErr = $1A 
constant CacheErr = $1B 
constant TagLo = $1C 
constant TagHi = $1D
constant ErrorEPC = $1E
//constant *RESERVED*($1F)


mtc0 r0, Cause
mtc0 r0, Count 
mtc0 r0,Compare


//ipl3_entry // 0xA4000040
lui t0,RI_BASE //0xA470
addiu t0,0x0000
lw t1,RI_SELECT(t0)
bnez t1,A4000410
nop


addiu sp,sp,-0x18
sw s3,(sp)
sw s4,4(sp)
sw s5,8(sp)
sw s6,12(sp)
sw s7,16(sp)


lui t0,RI_BASE //0xA470
addiu t0,0x0000
lui t2,$A3F8
lui t3,RDRAM_BASE //0xa3F0
lui t4,MI_BASE
addiu t4,0
ori t1,r0,$40
sw t1,RI_CONFIG(t0) // WORD[$A4700004] RI_CONFIG = $40
addiu s1,r0,8000 //1F40

A400009C:
nop
subi s1,1
bnez s1,A400009C
nop

sw r0,8(t0) // RI_CURRENT_LOAD
ori t1,r0,20
sw t1,0xc(t0)
sw r0, (t0)
addiu s1,r0,4

A40000C0:
nop
addi s1,s1,-1
bnez s1,A40000C0
nop
ori t1,r0,14
sw t1,(t0)
addiu s1,r0,32



A40000DC:
addi s1,s1,-1
bnez s1,A40000DC
ori t1,r0,$010F

sw t1,(t4)
lui   t1, (0x18082838 >> 16)
ori   t1, (0x18082838 & 0xFFFF)
sw t1,RDRAM_DELAY(t2)
sw r0, RDRAM_REF_ROW(t2)
lui t1,0x8000
sw t1, RDRAM_DEVICE_ID(t2)

or t5,r0,r0
or t6,r0,r0
lui t7,RDRAM_BASE
or t8,r0,r0
lui t9,RDRAM_BASE
lui s6,RDRAM
or s7,r0,r0
lui a2,RDRAM_BASE
lui a3,RDRAM
or s2,r0,r0
lui s4,RDRAM

addiu sp,sp,-0x48
or s8, sp,r0

lui s0, MI_BASE
lw s0,MI_VERSION(s0)
lui s1,$0101
addiu s1,$0101
bne s0,s1,A4000160
nop

addiu s0,r0,$0200
ori s1, t3, $4000
b A4000168
nop





A4000160:

   addiu s0,r0,0x0400
    ori   s1, t3, 0x8000

 

A4000168:
sw t6, 4(s1)
addiu s5,t7, RDRAM_MODE 
jal func_0xA4000778
nop
beqz v0, A400025C//0xA400025C
nop

sw v0,$00(sp)
addiu t1,r0,$2000
sw t1,MI_INIT_MODE(t4)
lw t3, RDRAM_DEVICE_TYPE(t7)
lui t0,0xf0ff
and t3,t0
sw t3,4(sp)
addi sp,sp,8

addiu t1,r0,$1000 
sw t1,MI_INIT_MODE(t4)
lui t0,$b019
bne t3,t0,A40001E0
nop

lui t0, 0x0800
 add t8,t8,t0
 add t9,t9,s0
 add t9,t9,s0
 lui t0,0x20
 add s6,s6,t0
 add s4,s4,t0
 sll s2,1
 addi s2,1
 b A40001E8
 nop



A40001E0:
lui t0,0x0010
add s4,t0


A40001E8:
addiu t0,r0,$2000 // T0 = $2000
sw t0,(t4)
lw t1, 0x24(t7)
lw k0, (t7)
addiu t0,r0,4096
sw t0, (t4)
andi t1,t1,0xffff
addiu t0,r0,0x0500
bne t1,t0,A4000230
nop

lui k1, $0100
and k0,k1
bnez k0,A4000230
nop

lui t0,0x101C
ori t0,0x0A04
sw t0,RDRAM_RAS_INTERVAL(t7) 
b A400023C

A4000230:
lui t0,$080c
ori t0,$1204
sw t0,RDRAM_RAS_INTERVAL(t7)


A400023C:
lui t0,$0800 // T0 = $08000000
  add t6,t0 // T6 += $08000000 
  add t7,s0 // T7 += S0*2 ($200/$400 Depending On Version)
  add t7,s0
  addiu t5,1 // T5++
  sltiu	t0,t5,8
  bnez t0,A4000168 // IF (++T5 < 8) GOTO $168
  nop // Delay Slot


A400025C:
  lui t0,$C400 // T0 = $C4000000
  sw t0,RDRAM_MODE(t2) // WORD[$A3F8000C] RDRAM_MODE = $C4000000
  lui t0,$8000 // T0 = $80000000
  sw t0,RDRAM_DEVICE_ID(t2) // WORD[$A3F80004] RDRAM_DEVICE_ID = $80000000

or sp,s8,r0 // SP = FP
or v1,r0,r0 // V1 = 0
A4000274:

lw t1,4(sp) // T1 = TMP2
  lui t0,$B009 // T0 = B0090000
  bne t1,t0,A40002D8 // IF (TMP2 != $B0090000) GOTO $2D8
  nop // Delay Slot

  // ELSE (TMP2 == $B0090000)
  sw t8,4(s1) // WORD[$A3F04004/$A3F08004 Depending On Version] = $08000000
  addiu s5,t9,$C // S5 = T9 + $C
  lw a0,0(sp) // A0 = TMP1
  addi sp,8 // Increment STACK 2 WORDS
  addiu a1,r0,1 // A1 = 1
  jal func_A4000A40 // CALL($A40)(TMP1, 1)
  nop // Delay Slot

  lw t0,0(s6) // T0 = WORD[$A0200000]
  lui t0,$0008 // T0 = $00080000
  add t0,s6 // T0 = $A0280000
  lw t1,0(t0) // T1 = WORD[$A0280000]
  lw t0,0(s6) // T0 = WORD[$A0200000]
  lui t0,$0008 // T0 = $00080000 
  add t0,s6 // T0 = $A0280000
  lw t1,0(t0) // T1 = WORD[$A0280000]
  lui t0,$0400 // T0 = $04000000
  add t6,t0 // T6 += $04000000
  add t9,s0 // T9 += S0 
  lui t0,$0010 // T0 = $00100000
  add s6,t0 // S6 = $A0300000 (3MB RAM)
  b A400035C // GOTO $35C

A40002D8:
  sw s7,4(s1) // WORD[$A3F04004/$A3F08004 Depending On Version] = 0 (Delay Slot)
  addiu s5,a2,$0C // S5 = RDRAM_MODE ($A3F0000C)
  lw a0,0(sp) // A0 = TMP1
  addi sp,8 // Increment STACK 2 WORDS
  addiu	a1,r0,1 // A1 = 1
  jal func_A4000A40 // CALL($A40)(TMP1, 1)
  nop // Delay Slot

  lw t0,0(a3) // T0 = WORD[$A0000000]
  lui t0,$0008 // T0 = $00080000
  add t0,a3 // T0 = $A0080000
  lw t1,0(t0) // T1 = WORD[$A0080000]
  lui t0,$0010 // T0 = $00100000
  add t0,a3 // T0 = $A0010000
  lw t1,0(t0) // T1 = WORD[$A0010000]
  lui t0,$0018 // T0 = $00180000
  add t0,a3 // T0 = $A0180000
  lw t1,0(t0) // T1 = WORD[$A0180000]
  lw t0,0(a3) // T0 = WORD[$A0000000] 
  lui t0,$0008 // T0 = $00080000
  add t0,a3 // T0 = $A0080000
  lw t1,0(t0) // T1 = WORD[$A0080000]
  lui t0,$0010 // T0 = $00100000
  add t0,a3 // T0 = $A0010000
  lw t1,0(t0) // T1 = WORD[$A0010000]
  lui t0,$0018 // T0 = $00180000
  add t0,a3 // T0 = $A0180000
  lw t1,0(t0) // T1 = WORD[$A0180000]
  lui t0,$0800 // T0 = $00800000
  add s7,t0 // S7 = $00800000
  add a2,s0 // A2 += S0*2 ($200/$400 Depending On Version)
  add a2,s0 // A2 = $A3F00400/$A3F00800 Depending On Version
  lui t0,$0020 // T0 = $00200000
  add a3,t0 // A3 = $A0200000 (2MB RAM)

A400035C:
  addiu v1,1 // V1++
  slt t0,v1,t5
   bnez t0,A4000274 // IF (V1 < T5) GOTO $274

  nop // Delay Slot

  lui t2,RI_BASE // T2 = RI_BASE ($A4700000)
  sll s2,19 // S2 <<= 19
  lui t1,$0006 // T1 = $00060000
  ori t1,$3634 // T1 = $00063634
  or t1,s2 // T1 |= S2
  sw t1,RI_REFRESH(t2) // WORD[$A4700010] RI_REFRESH = T1 
  lw t1,RI_REFRESH(t2) // T1 = RI_REFRESH WORD[$A4700010]
  lui t0,RDRAM // T0 = RDRAM ($A0000000)
  ori t0,$0300 // T0 = $A0000300
  lui t1,$0FFF // T1 = $0FFF0000
  ori t1,$FFFF // T1 = $0FFFFFFF
  and s6,t1 // S6 = $00300000
  sw s6,$18(t0) // WORD[$A0000318] = $00300000 (osMemSize)

  or sp,s8,r0 // SP = FP

  // Load S3..S7 From STACK
  addiu sp,72 // Increment STACK 18 WORDS
  lw s3,$00(sp)
  lw s4,$04(sp)
  lw s5,$08(sp)
  lw s6,$0C(sp)
  lw s7,$10(sp)
  addiu sp,24 // Increment STACK 6 WORDS

  // Store I-Cache Tag 0/0 For 16KB Of Main Memory In 32 Byte Chunks Starting At $80000000
  lui t0,$8000 // T0 = $80000000
  addiu t0,0 // T0 = $80000000
  addiu t1,t0,$4000 // T1 = $80004000
  subiu t1,32 // T1 -= 32
  mtc0 r0,TagLo
  mtc0 r0,TagHi
  A40003D8:
    cache $08,0(t0) // CACHE 0(T0), I, Index Store Tag ($08)
    sltu at,t0,t1
    bnez at,A40003D8 // IF (T0 < T1) GOTO $3D8
    addiu t0,32 // T0 += 32 (Delay Slot)

  // Store D-Cache Tag 0/0 For 8KB Of Main Memory In 16 Byte Chunks Starting At $80000000
  lui t0,$8000 // T0 = $80000000
  addiu t0,0 // T0 = $80000000
  addiu t1,t0,$2000 // T1 = $80002000
  subiu t1,16 // T1 -= 16
  A40003F8:
    cache $09,0(t0) // CACHE 0(T0), D, Index Store Tag ($09)
    sltu at,t0,t1
    bnez at,A40003F8 // IF (T0 < T1) GOTO $3F8
    addiu t0,16 // T0 += 16 (Delay Slot)
    b A4000458 // GOTO $458
    nop // Delay Slot








A4000410:
  lui t0,$8000 // T0 = $80000000
  addiu t0,0 // T0 = $80000000
  addiu t1,t0,$4000 // T1 = $80004000
  subiu t1,32 // T1 -= 32
  mtc0 r0,TagLo
  mtc0 r0,TagHi
  A4000428:
    cache $08,0(t0) // CACHE 0(T0), I, Index Store Tag ($08)
    sltu at,t0,t1
    bnez at,A4000428 // IF (T0 < T1) GOTO $428
    addiu t0,32 // T0 += 32 (Delay Slot)

  // Store D-Cache Tag 0/0 For 8KB Of Main Memory In 16 Byte Chunks Starting At $80000000
  lui t0,$8000 // T0 = $80000000
  addiu t0,0 // T0 = $80000000
  addiu t1,t0,$2000 // T1 = $80002000
  subiu t1,16 // T1 -= 16
  A4000448:
    cache $01,0(t0) // CACHE 0(T0), D, Index Writeback Invalidate ($01)
    sltu at,t0,t1
    bnez at,A4000448 // IF (T0 < T1) GOTO $3F8
    addiu t0,16 // T0 += 16 (Delay Slot)

// Copy Routine At $4C0-$774 In Bootcode (Lockout Finale & Program Loader) To Uncached RAM, Address Zero, & Jump To It
A4000458:
  lui t2,SP_MEM_BASE // T2 = SP_MEM_BASE ($A4000000)
  addiu t2,0 // T2 = SP_MEM_BASE ($A4000000)
  lui t3,$FFF0 // T3 = $FFF00000
  lui t1,$0010 // T1 = $00100000
  and t2,t3 // T2 = DPC_BASE ($A4100000)
  lui t0,SP_MEM_BASE // T0 = SP_MEM_BASE ($A4000000)
  subiu t1,1 // T1 = $000FFFFF
  lui t3,SP_MEM_BASE // T3 = SP_MEM_BASE ($A4000000) 
  addiu t0,$04C0 // T0 = $A40004C0
  addiu t3,$0774 // T3 = $A4000774
  and t0,t1 // T0 = $000004C0
  and t3,t1 // T3 = $00000774
  lui t1,RDRAM // T1 = RDRAM ($A0000000)
  or t0,t2 // T0 = $A00004C0
  or t3,t2 // T3 = $A0000774
  addiu t1,0 // T1 = RDRAM ($A0000000)
  A4000498:
    lw t5,0(t0) // T5 = WORD[$A00004C0..]
    addiu t0,4 // T0 += 4 (Increment Bootcode Pointer)
    sltu at,t0,t3
    addiu t1,4 // T1 += 4 (Increment RDRAM Pointer)
    bnez at,A4000498
    sw t5,-4(t1) // WORD[$A0000000..] = Bootcode Word T5 (Delay Slot)

  lui t4,$8000 // T4 = $80000000
  addiu t4,0 // T4 = $80000000 
  jr t4 // Jump To Boot Code
  nop // Delay Slot

// This Loader Is Copied To RDRAM Address Zero From $4C0..$774 In The 6102 Bootcode,
// & Executes From RDRAM To Load The 1st 1MB Of The Program, Verify Its integrity, & Execute It

// Read 3rd Word Of Cart Header, Which Is The Program Start Address In RAM
lui t3,CART_DOM1_ADDR2 // T3 = CART_DOM1_ADDR2 ($B0000000)
lw t1,8(t3) // T1 = Boot Address Offset WORD[$B0000008]
lui t2,$1FFF // T2 = $1FFF0000
ori t2,$FFFF // T2 = $1FFFFFFF
lui at,PI_BASE // AT = PI_BASE ($A4600000)
and t1,t2 // T1 = Boot Address Offset & $1FFFFFFF
sw t1,PI_DRAM_ADDR(at) // WORD[$A4600000] PI_DRAM_ADDR = T1

// Check PI Status IO Busy
lui t0,PI_BASE // T0 = PI_BASE ($A4600000)
A40004E0:
  // WHILE ((*$A4600010 & 2)) Loop (Wait For PI No I/O Busy)
  lw t0,PI_STATUS(t0) // T0 = PI_STATUS WORD[$A4600010]
  andi t0,$02 // T0 &= Status IO Busy Bit
  bnezl t0,A40004E0 // IF (T0 != 0) GOTO $4E0
  lui t0,PI_BASE // T0 = PI_BASE ($A4600000) (Delay Slot)

// DMA 1MB Of Program Code, From Cartridge ROM, To RDRAM, Starting At Offset $1000
// *$A4600004 = $10001000 (PI DMA Cart Address)
addiu t0,r0,$1000 // T0 = $1000
add t0,t3 // T0 = $B0001000
and t0,t2 // T0 = $10001000
lui at,PI_BASE // AT = PI_BASE ($A4600000)
sw t0,PI_CART_ADDR(at) // WORD[$A4600004] PI_CART_ADDR = $10001000
// *$A460000C = $000FFFFF (PI DMA Write Length 1MB)
lui t2,$0010 // T2 = $00100000
subiu t2,1 // T2 = $000FFFFF
lui at,PI_BASE // AT = PI_BASE ($A4600000)
sw t2,PI_WR_LEN(at) // WORD[$A460000C] PI_WR_LEN = $000FFFFF

A4000514:
	// wait 28 cycles
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

lui t3,PI_BASE
lw t3,PI_STATUS(t3)
andi t3,1
bnez t3,A4000514
nop

// Starting At Program Start Address In RAM, Perform Checksum Seeded With A1=S6*$5D588B65
// Over 1st $100000 (1MB) Bytes Of Program (Checksum Routine Places Results In A3 & S0)

// CRC Check
lui t3,CART_DOM1_ADDR2
lw a0,8(t3)
or a1,s6,r0
lui at,$5D58
ori at, $8B65
multu a1,at
subiu sp,32
sw ra,$1C(sp)
sw s0, $14(sp)
lui ra,$0010
or v1,r0,r0
or t0,r0,r0
or t1,a0,r0
addiu t5,r0,32
mflo v0
addiu v0,1
or a3,v0,r0
or t2,v0,r0
or t3,v0,r0
or s0,v0,r0
or a2,v0,r0
or t4,v0,r0

// Start Checksum Loop
A40005F0:
// V0 = *T1 (Next Word In Program Code To Checksum)
lw v0,0(t1) // V0 = WORD[Boot Address Offset]
addu v1,a3,v0
sltu at,v1,a3
beqz at,A4000608
or a1,v1,r0
addiu t2,1


A4000608:
 andi v1,v0,$1F
 subu t7,t5,v1
 srlv t8,v0,t7
 sllv t6,v0,v1
 or a0,t6,t8
 sltu at,a2,v0
 or a3,a1,r0
 xor t3,v0
 beqz at, A400063C
 addu s0,a0
 xor t9,a3,v0
 b A4000640
 xor a2 ,t9,a2

 A400063C:
 xor a2,a0

  A4000640:
  	addiu t0,4
  	xor t7,v0,s0
  	addiu t1,4
  	bne t0,ra,A40005F0
  	addu t4,t7,t4

xor t6,a3,t2
xor a3,t6,t3
xor t8,s0,a2
xor s0,t8,t4
lui t3,CART_DOM1_ADDR2 // T3 = CART_DOM1_ADDR2 ($B0000000)
lw t0,$10(t3) // T0 = COMPLEMENT CHECK WORD[$B0000010]

// IF (A3 != To The 1st Checksum Word In Cart Header)
// OR IF (S0 != To 2nd Checksum Word In Cart Header) Loop Forever (Halt)

//bne a3,t0, A4000688
nop
nop

lw t0,$14(t3)
//bne s0,t0,A4000688
nop
nop




// ELSE (COMPLEMENT CHECK/CHECKSUM PASSED)
bgezal r0,A4000690 // GOTO $690
nop // Delay Slot





// Infinite Loop
A4000688:
	bgezal r0, A4000688
	nop

// OS Setup
A4000690:
  // IF RSP Has A PC Other Than Zero, Set RSP Single Step & Clear Halt, Then Set RSP PC To Zero
  lui t1,SP_PC_BASE // T1 = SP_PC_BASE ($A4080000)
  lw t1,SP_PC(t1) // T1 = WORD[$A4080000]
  lw s0,$14(sp) // S0 = STACK WORD[$14] (TMP1)
  lw ra,$1C(sp) // RA = STACK WORD[$1C]
  beqz t1,A40006BC // IF (T1 == 0) GOTO $6BC
  addiu sp,32 // Increment STACK 8 WORDS (Delay Slot)

  // IF (*$A4080000 != 0) Store Zero To RSP PC Reg
  // *$A4040010 = $41 // Set Single Step, Clear Halt
  addiu t2,r0,$41 // T2 = $41
  lui at,SP_BASE // AT = SP_BASE ($A4040000)
  sw t2,SP_STATUS(at) // WORD[$A4040010] SP_STATUS = $41
  // *$A4080000 = 0 (RSP PC = 0)
  lui at,SP_PC_BASE // AT = SP_PC_BASE ($A4080000)
  sw r0,SP_PC(at) // WORD[$A4080000] SP_PC = 0

// Set RSP Halt & Clear All Other RSP Conditions
A40006BC:
  // *$A4040010 = $00AAAAAE (Set Halt, Clear Broke, Clear Intr, Clear SStep)
  lui t3,$00AA // T3 = $00AA0000
  ori t3,$AAAE // T3 = $00AAAAAE
  lui at,SP_BASE // AT = SP_BASE ($A4040000)
  sw t3,SP_STATUS(at) // WORD[$A4040010] SP_STATUS = $00AAAAAE

  // Unmask All MI Interrupts & Clear Each One Individually
  // *$A430000C = $555 (Enable All Interrupts)
  lui at,MI_BASE // AT = MI_BASE ($A4300000)
  addiu t0,r0,$0555 // T0 = $00000555
  sw t0,MI_INTR_MASK(at) // WORD[$A430000C] MI_INTR_MASK = $00000555
  // *$A4800018 = 0 (Clear SI Interrupt)
  lui at,SI_BASE // AT = SI_BASE ($A4800000)
  sw r0,SI_STATUS(at) // WORD[$A4800018] SI_STATUS = 0
  // *$A450000C = 0 (Clear AI Interrupt)
  lui at,AI_BASE // AT = AI_BASE ($A4500000)
  sw r0,AI_STATUS(at) // WORD[$A450000C] AI_STATUS = 0
  // *$A4300000 = $800 (Clear DP Interrupt)
  lui at,MI_BASE // AT = MI_BASE ($A4300000)
  addiu t1,r0,$0800 // T1 = $00000800
  sw t1,MI_INIT_MODE(at) // WORD[$A4300000] MI_INIT_MODE = $00000800
  // *$A4600010 = 2 (Clear PI Interrupt)
  addiu t1,r0,$0002 // T1 = $00000002
  lui at,PI_BASE // AT = PI_BASE ($A4600000)
  lui t0,RDRAM // T0 = RDRAM ($A0000000)
  ori t0,$0300 // T0 = $A0000300
  sw t1,PI_STATUS(at) // WORD[$A4600010] PI_STATUS = $00000002
  // Place Various Parameters To Be Passed To Program To stack At $A0000300
  sw s7,$14(t0) // WORD[$A0000314] = S7
  sw s5,$0C(t0) // WORD[$A000030C] = S5
  sw s3,$04(t0) // WORD[$A0000304] = S3
  beqz s3,A4000728 // IF (S3 == 0) GOTO $728
  sw s4,$00(t0) // WORD[$A0000300] = S4 (Delay Slot)

  lui t1,CART_DOM1_ADDR1 // T1 = CART_DOM1_ADDR1 ($A6000000)
  b A4000730 // GOTO $730
  addiu t1,0 // T1 = CART_DOM1_ADDR1 ($A6000000) (Delay Slot)

A4000728:
  lui t1,CART_DOM1_ADDR2 // T1 = CART_DOM1_ADDR2 ($B0000000)
  addiu t1,0 // T1 = CART_DOM1_ADDR2 ($B0000000)

A4000730:
  sw t1,$08(t0) // WORD[$A0000308] = $A6000000/$B0000000

// Write Zeros To Entire RSP DMEM & IMEM Regions

// Clear RSP DMEM
lui t0,SP_MEM_BASE // T0 = SP_MEM_BASE ($A4000000)
addiu t0,0 // T0 = SP_MEM_BASE ($A4000000)
addi t1,t0,SP_IMEM // T1 = SP_IMEM ($A4001000)
A4000740:
  addiu t0,$0004 // T0 = $A4000004
  bne t0,t1,A4000740 // IF (T0 != T1) GOTO $740
  sw r0,-4(t0) // WORD[$A4000000..A4001000] = 0 (Delay Slot)

// Clear RSP IMEM
lui t0,SP_MEM_BASE // T0 = SP_MEM_BASE ($A4000000)
addiu t0,SP_IMEM // T0 = SP_IMEM ($A4001000)
addi t1,t0,$1000 // T1 = $A4002000
A4000758:
  addiu t0,$0004 // T0 = $A4000004
  bne t0,t1,A4000758 // IF (T0 != T1) GOTO $758
  sw r0,-4(t0) // WORD[$A4001000..A4002000] = 0 (Delay Slot)

// Jump To Program Start Address In RAM (From Cart Header)
lui t3,CART_DOM1_ADDR2 // T3 = CART_DOM1_ADDR2 ($B0000000)
lw t1,8(t3) // T1 = Boot Address Offset WORD[$B0000008]
jr t1 // GOTO Boot Address Offset
nop // Delay Slot
nop // Delay


func_0xA4000778:
subiu sp,160 // Decrement STACK 40 WORDS
  sw s0,$40(sp) // STACK WORD[$40] = S0
  sw s1,$44(sp) // STACK WORD[$44] = S1
  or s1,r0,r0 // S1 = 0
  or s0,r0,r0 // S0 = 0
  sw v0,$00(sp) // STACK WORD[$00] = V0
  sw v1,$04(sp) // STACK WORD[$04] = V1
  sw a0,$08(sp) // STACK WORD[$08] = A0
  sw a1,$0C(sp) // STACK WORD[$0C] = A1
  sw a2,$10(sp) // STACK WORD[$10] = A2
  sw a3,$14(sp) // STACK WORD[$14] = A3
  sw t0,$18(sp) // STACK WORD[$18] = T0
  sw t1,$1C(sp) // STACK WORD[$1C] = T1
  sw t2,$20(sp) // STACK WORD[$20] = T2
  sw t3,$24(sp) // STACK WORD[$24] = T3
  sw t4,$28(sp) // STACK WORD[$28] = T4
  sw t5,$2C(sp) // STACK WORD[$2C] = T5
  sw t6,$30(sp) // STACK WORD[$30] = T6
  sw t7,$34(sp) // STACK WORD[$34] = T7
  sw t8,$38(sp) // STACK WORD[$38] = T8
  sw t9,$3C(sp) // STACK WORD[$3C] = T9
  sw s2,$48(sp) // STACK WORD[$48] = S2
  sw s3,$4C(sp) // STACK WORD[$4C] = S3
  sw s4,$50(sp) // STACK WORD[$50] = S4
  sw s5,$54(sp) // STACK WORD[$54] = S5
  sw s6,$58(sp) // STACK WORD[$58] = S6
  sw s7,$5C(sp) // STACK WORD[$5C] = S7
  sw s8,$60(sp) // STACK WORD[$60] = S8
  sw ra,$64(sp) // STACK WORD[$64] = RA


A40007EC:

  jal A4000880 // CALL($880)
  nop // Delay Slot
  addiu s0,1 // S0++
  slti t1,s0,4
  bnez t1,A40007EC // IF (S0 < 4) GOTO $7EC
  addu s1,v0 // S1 += V0 (Delay Slot)

  srl a0,s1,2 // A0 = S1 >> 2
 jal func_A4000A40 // CALL($A40)
  addiu a1,r0,1 // A1 = 1 (Delay Slot)

// Load Registers From STACK
lw ra,$64(sp) // RA = STACK WORD[$64]
srl v0,s1,2 // V0 = S1 >> 2
lw s1,$44(sp) // S1 = STACK WORD[$44]
lw v1,$04(sp) // V1 = STACK WORD[$04]
lw a0,$08(sp) // A0 = STACK WORD[$08]
lw a1,$0C(sp) // A1 = STACK WORD[$0C]
lw a2,$10(sp) // A2 = STACK WORD[$10]
lw a3,$14(sp) // A3 = STACK WORD[$14]
lw t0,$18(sp) // T0 = STACK WORD[$18]
lw t1,$1C(sp) // T1 = STACK WORD[$1C]
lw t2,$20(sp) // T2 = STACK WORD[$20]
lw t3,$24(sp) // T3 = STACK WORD[$24]
lw t4,$28(sp) // T4 = STACK WORD[$28]
lw t5,$2C(sp) // T5 = STACK WORD[$2C]
lw t6,$30(sp) // T6 = STACK WORD[$30]
lw t7,$34(sp) // T7 = STACK WORD[$34]
lw t8,$38(sp) // T8 = STACK WORD[$38]
lw t9,$3C(sp) // T9 = STACK WORD[$3C]
lw s0,$40(sp) // S0 = STACK WORD[$40]
lw s2,$48(sp) // S2 = STACK WORD[$48]
lw s3,$4C(sp) // S3 = STACK WORD[$4C]
lw s4,$50(sp) // S4 = STACK WORD[$50]
lw s5,$54(sp) // S5 = STACK WORD[$54]
lw s6,$58(sp) // S6 = STACK WORD[$58]
lw s7,$5C(sp) // S7 = STACK WORD[$5C]
lw s8,$60(sp) // S8 = STACK WORD[$60]
jr ra // GOTO RA
addiu sp,160 // Increment STACK 40 WORDS

A4000880:
addiu sp,sp,-32 // Decrement STACK 8 WORDS
 sw ra,$1C(sp) // STACK WORD[$1C] = RA
  or t1,r0,r0 // T1 = 0
  or t3,r0,r0 // T3 = 0
  or t4,r0,r0 // T4 = 0


A4000894:

	slti k0,t4,64 // FOR (T4 = 0; T4 < 64;)
    beqzl k0,A40008FC // IF (K0 == 0) GOTO $8FC
    or v0,r0,r0 // V0 = 0 (Delay Slot)

    jal A400090C // CALL($90C)(S4)
    or a0,t4,r0 // A0 = T4 (Delay Slot)

    blezl v0,A40008CC // IF (V0 <= 0) GOTO $8CC
    slti k0,t1,$50 // Delay Slot
    subu k0,v0,t1 // K0 = V0 - T1
    multu k0,t4 // K0 * T4
    or t1,v0,r0 // T1 = V0
    mflo k0 // K0 = K0 * T4
    addu t3,k0 // T3 += K0
    nop // Delay Slot

    slti k0,t1,$50 // IF (T1 >= $50) Continue FOR

 A40008CC:
bnez k0,A4000894 
addiu t4,1

sll a0,t3,2 // A0 = T3 << 2
subu a0,t3 // A0 -= T3
sll a0,2 // A0 <<= 2
subu a0,t3 // A0 -= T3
sll a0,1 // A0 <<= 1
jal func_A4000980 // CALL($980)(A0, A1, S5)
subiu a0,880 // A0 -= 880

b A4000900 // GOTO $900
lw ra,$1C(sp) // RA = STACK WORD[$1C] (Delay Slot)

or v0,r0,r0 // V0 = 0

A40008FC:

lw ra,$1c(sp) // RA = STACK WORD[$1C]


A4000900:
  addiu sp,32 // Increment STACK 8 WORDS
  jr ra // GOTO RA
  nop // Delay Slot

A400090C:
  subiu sp,40 // Decrement STACK 10 WORDS
  sw ra,$1C(sp) // STACK WORD[$1C] = RA
  or v0,r0,r0 // V0 = 0
  jal func_A4000A40 // CALL($A40)(A0, A1, S5)
  addiu a1,r0,2 // A1 = 2 (Delay Slot)

or s8,r0,r0 // S8 = 0
subiu k0,r0,1 // K0 = $FFFFFFFF
A4000928:
  sw k0,4(s4) // WORD[S4 + 4] = K0 ($FFFFFFFF)
  lw v1,4(s4) // V1 = WORD[S4 + 4] ($FFFFFFFF)
  sw k0,0(s4) // WORD[S4 + 0] = K0
  sw k0,0(s4) // WORD[S4 + 0] = K0
  or gp,r0,r0 // GP = 0
  srl v1,16 // V1 >>= 16 ($0000FFFF)

A4000940:

andi k0,v1,1
beqzl k0,A4000954

addiu gp,1
addiu v0,1
addiu gp,1


    A4000954:
      slti k0,gp,8 // WHILE ((V1 & 1) && GP++ < 8, V1 >>= 1) 
      bnez k0,A4000940 // IF (K0 != 0) GOTO $940
      srl v1,1 // V1 >>= 1 (Delay Slot)

    addiu s8,1 // FP++
    slti k0,s8,10 // WHILE (FP < 10)
    bnezl k0,A4000928 // IF (K0 != 0) GOTO $928
    subiu k0,r0,1 // K0 = $FFFFFFFF (Delay Slot)

lw ra,$1C(sp) // RA = STACK WORD[$1C]
addiu sp,40 // Increment STACK 10 WORDS
jr ra // GOTO RA
nop // Delay Slot





func_A4000980:
  addiu sp,sp,-40 // Decrement STACK 10 WORDS
  sw ra,$1C(sp) // STACK WORD[$1C] = RA
  sw a0,$20(sp) // STACK WORD[$20] = A0
  sb r0,$27(sp) // STACK BYTE[$27] = 0
  or t0,r0,r0 // T0 = 0
  or t2,r0,r0 // T2 = 0
  ori t5,r0,$C800 // T5 = $C800
  or t6,r0,r0 // T6 = 0
  slti k0,t6,64 // WHILE (T6 < 64)

 A40009A4:
    bnezl k0,A40009B8 // IF (K0 != 0) GOTO $9B8
    or a0,t6,r0 // A0 = T6 (Delay Slot)

    b A4000A30 // GOTO $A30
    or v0,r0,r0 // V0 = 0 (Delay Slot)

    or a0,t6,r0 // A0 = T6
    A40009B8:
      jal func_A4000A40 // CALL($A40)

      addiu a1,r0,1 // A1 = 1
      jal A4000AD0 // CALL($AD0)
      addiu a0,sp,$27 // A0 = SP + $27 (Delay Slot)

      jal A4000AD0 // CALL($AD0)
      addiu a0,sp,$27 // A0 = SP + $27 (Delay Slot)

    lbu k0,$27(sp) // K0 = STACK BYTE[$27]
    addiu k1,r0,$0320 // K1 = $0320
    lw a0,$20(sp) // A0 = STACK WORD[$20]
    multu k0,k1 // K0 * K1
    mflo t0 // T0 = K0 * K1
    subu k0,t0,a0 // K0 = T0 + A0
    bgezl k0,A40009F8 // IF (K0 >= 0) GOTO $9F8
    slt k1,k0,t5 // WHILE (K0 < T5) (Delay Slot)

    subu k0,a0,t0 // K0 = A0 - T0
    slt k1,k0,t5 // WHILE (K0 < T5)

    A40009F8:
      beqzl k1,A4000A0C // IF (K1 == 0) GOTO $A0C
      lw a0,$20(sp) // A0 = STACK WORD[$20] (Delay Slot)

      or t5,k0,r0 // T5 = K0
      or t2,t6,r0 // T2 = T6
      lw a0,$20(sp) // A0 = STACK WORD[$20]

      A4000A0C:
        slt k1,t0,a0 // WHILE (T0 < A0)
        beqzl k1,A4000A2C // IF (K1 == 0) GOTO $A2C
        addu v0,t2,t6 // V0 = T2 + T6 (Delay Slot)

    addiu t6,1 // T6++
    slti k1,t6,$41 // WHILE (T6 < $41)
    bnezl k1,A40009A4
    slti k0,t6,$40 // WHILE (T6 < $40) (Delay Slot)

  addu v0,t2,t6 // V0 = T2 + T6
A4000A2C:
  srl v0,1 // V0 >>= 1

A4000A30:
  lw ra,$1C(sp) // RA = STACK WORD[$1C]
  addiu sp,40 // Increment STACK 10 WORDS
  jr ra // GOTO RA
  nop // Delay Slot






func_A4000A40:
addiu sp,sp,-40
andi a0,$FF
addiu k1,r0,1
xori a0,$3F
sw ra,$1C(sp)
bne a1,k1,A4000A64 
lui t7,$4600

lui k0,$8000
or t7,k0


A4000A64:

andi k0,a0,1
sll k0,6
or t7,k0
andi k0,a0,2
sll k0,13
or t7,k0
andi k0,a0,4
sll k0,20
or t7,k0
andi k0,a0,8
sll k0,4
or t7,k0
andi k0,a0,$10
sll k0,11
or t7,k0
andi k0,a0,$20
sll k0,18
or t7,k0
addiu k1,r0,1
bne a1,k1,A4000AC0
sw t7,0(s5)





lui k0,MI_BASE
sw r0,MI_INIT_MODE(k0) 

A4000AC0:
lw ra,$1C(sp)
addiu sp,40
jr ra
nop








A4000AD0:
  addiu sp,sp, -0x28
  sw ra,$1C(sp)
  addiu k0,r0,$2000
  lui k1,MI_BASE
  sw k0,MI_INIT_MODE(k1)
  or s8,r0,r0
  lw s8,0(s5)
  addiu k0,r0,$1000
  sw k0,MI_INIT_MODE(k1)
  addiu k1,r0,$40
  and k1,s8
  srl k1,6
  or k0,r0,r0
  or k0,k1
  addiu k1,r0,$4000
  and k1,s8
  srl k1,13
  or k0,k1
   lui k1,$0040
   and k1,s8
   srl k1,20
  or k0,k1
    addiu k1,r0,$80 // K1 = $80
and k1,s8
srl k1,4
or k0,k1
 ori  k1,r0,$8000
 and k1,s8
  srl k1,11 // K1 >>= 11
  or k0,k1
  lui k1,$0080
 and k1,s8
 srl k1,18
 or k0,k1
 sb k0,0(a0)
  lw ra,$1c(sp)
 addiu sp,40
 jr ra
 nop
 
A4000B6C:
  nop // Delay



//A4000B70
include "BOOT\FONT\IPL3Font.asm" // IPL3 Font Data