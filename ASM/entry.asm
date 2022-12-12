arch n64.cpu
endian msb

//output "Bomberman64U.z64",create
output "BM64U.z64",create
//fill $00800000


 
origin $00000000
base $A4000000


include "HEADER\HEADER_BM64.asm"

include "BOOT\boot.asm"


//insert "BOOT\BIN\BOOTCODE_BM64.BIN"

 
base $80000400


entry_point:

//how entry point get to this address?
L80000400:

j L80000400
nop