/****************************************************************************
*   File:   memAdrDecoder.V     TFOX    Ver 0.12     Nov. 25, 2022          *
*   Memory Address Decoder  For Monanahan S100 Z80 FPGA SBC                 *                                    
*   This is for a VERY BASIC ROM beginning at memory location h0000         *
****************************************************************************/

module memAdrDecoder
    (
    input [15:0]    address,        // use only Z80 A0-A15 for now
    input           n_memread,
    //
    output          rom_cs
     );

//  The TEST ROM is in memory location starting at h0000,only up to 16 bytes 
    assign rom_cs = (address[15:4] == 12'b0) && !n_memread;

    
endmodule
