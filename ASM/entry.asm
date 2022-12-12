arch n64.cpu
endian msb

//output "Bomberman64U.z64",create
output "BM64U.z64",create
fill $00800000


 
origin $00000000
base $A4000000


include "HEADER\HEADER_BM64.asm"

include "BOOT\boot.asm"


//insert "BOOT\BIN\BOOTCODE_BM64.BIN"

 
base $80000400


entry_point:
lui t0,$8002
addiu t0,t0,-$4040
ori t1,r0,$c4a0

L8000040C:
addi t1,t1,-$8
sw $0, $0(t0)
sw $40,$4(t0)
bne t1,$0,$8000040c
addi t0,t0,$8
lui t2,$8000
lui sp,$8002
addiu t2,t2,$19a0
jr t2
addiu sp,sp,$44b0
nop
nop
nop
nop
nop
nop
nop
//j L80000400
j L8000040C
nop



