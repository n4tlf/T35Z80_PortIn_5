/********************************************************************
*   FILE:   LEDBarMux.v      Ver 0.1         Oct. 12, 2022          *
*                                                                   *
********************************************************************/

module LedBarMux
    (
    input [7:0] cpuDO,
    input [7:0] cpuDI,
    input [7:0] portFFDO,
    input [7:0] debugreg,
    input [1:0]	sw,
//    input   ram_cs,   
    output wire [7:0] LEDoutData
    );
    
reg [7:0] selectedData;

always @* begin
    if (sw == 2'b0)
        selectedData = cpuDO;
    else if (sw == 2'b01)
        selectedData = cpuDI;
    else if (sw == 2'b10)
        selectedData = debugreg;
    else
        selectedData = portFFDO;   // otherwisw execute a NOP for now
    end                         // eventually change it to FF
    
    assign LEDoutData = ~selectedData;
    
endmodule
