/************************************************************************
*   File:  portDecoder.v    TFOX    Ver 0.12     Nov.25, 2022           *
*                                                                       *
*       I/O ports come in three flavors for the T35 board:              *
*           Ports within the T35 module itself:                         *
*               INPUT and OUTPUT port enables need to be defined here   *
*           Ports on the Z80 FPGA SBC board, but not within the T35     *
*           Ports on the S100 bus, NOT on the FPGA SBC board or the T35 *
*       All port INPUT ENABLES MUST be specified here, to be used as an *
*           enable/select in the cpuDIMux.v multiplex module (To drive  *
*           the Z80 data input within the T35 board)                    *
*                                                                       *        
************************************************************************/

module portDecoder
    (
//    input           clock,
    input [7:0]     address,
    input           iowrite,
    input           ioread,
    //
    output          outPortFF_cs,
    output          inPortCon_cs 
    );

    //  Z80 FPGA SBC LED port is at 255 (0xFF) FOR INITAL TESTING ONLY
        assign outPortFF_cs = (address[7:0] == 'hFF) && iowrite;
    //  Propeller Console is on S100 bus, in data = port 0x01 
        assign inPortCon_cs = (address[7:0] == 'h01) && ioread;

    endmodule
