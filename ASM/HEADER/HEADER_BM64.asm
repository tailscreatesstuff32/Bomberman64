





db  0x80, 0x37, 0x12, 0x40   ///* PI BSD Domain 1 register */
dw  0x0000000F               ///* Clockrate setting*/
//dw  $80100400//entry_point           //   /* Entrypoint */
//dw $80000400      //entry_point		//   /* Entrypoint */
dw entry_point		//   /* Entrypoint */

dw  0x00001448

//dw  0xF568D51E              // /* Checksum 1 */
//dw  0x7E49BA1E              // /* Checksum 2 */
//db "CRC1"
//db "CRC2"
//dd $CD7559ACB26CF5AE

dd $F568D51E7E49BA1E



dw  0x00000000              // /* Unknown */
dw  0x00000000              // /* Unknown */

db "BOMBERMAN64U        "

dw 0             // /* Unknown */
dw 'N'             // /* Unknown */
db "BM"            // /* Cartridge */
db 'E'       // /* NTSC-U (North America) */
                

db  0x00                // /* Version */
