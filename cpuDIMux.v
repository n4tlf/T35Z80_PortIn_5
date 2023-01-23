/********************************************************************
*   FILE:   cpuDIMux.v      Ver 0.1         Oct. 12, 2022           *
*                                                                   *
*   This function selects which device's DATA OUT goes into the Z80 *
*   CPU DATA INPUT bus at any given time. It uses the device's      *
*   select line to enable that device's DATA OUT signals            *
*   The Efinix FPGAs do NOT have internal tri-state buffering       *
*   capabilities, so this is especially important to prevent        *
*   clashing of signals of the Z80 DATA INPUT bus.                  *
********************************************************************/

module cpuDIMux
    (
    input [7:0] romData,
//    input [7:0] ramData,
    input [7:0] s100DataIn,
    input   rom_cs,
//    input   ram_cs,
    input   inPortcon_cs,
    output wire [7:0] outData
    );
    
reg [7:0] selectedData;

always @* begin
    if (rom_cs)
        selectedData <= romData;
    else if(inPortcon_cs)
        selectedData <= s100DataIn;
//    else if (ram_cs)
//        selectedData = ramData;
//    else
//        selectedData = 8'h00;   // otherwisw execute a NOP for now
    end                         // eventually change it to FF
    
    assign outData = selectedData;
    
endmodule
