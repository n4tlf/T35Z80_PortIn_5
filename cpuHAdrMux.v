/********************************************************************
*   FILE:   cpuHAdrMux.v      Ver 0.1         Oct. 27, 2022         *
*                                                                   *
********************************************************************/

module cpuHAdrMux
    (
    input [7:0] cpuHighAdr,
    input   sOUT,
    input   sINP,   
    output wire [7:0] HighAdr
    );
    
reg [7:0] selectedAdr;

always @* begin
    if (sOUT | sINP)
        selectedAdr <= 8'b0;
    else
        selectedAdr <= cpuHighAdr;  
    end
    
    assign HighAdr = selectedAdr;
    
endmodule
