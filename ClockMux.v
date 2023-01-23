/*************************************************************************************
*   Clock speed INPUT Multiplexer.              *
*************************************************************************************/

module  ClockMux(
    input           MHz2,
    input           MHz1,
    input           KHz31,
    input           Hz250,
    input   [1:0]   sw, 
    output  wire    cpuclk
    );

    
reg     selectedclk;

always @* begin
    if (sw == 2'b11)
        selectedclk = MHz2;
    else if (sw == 2'b01)
        selectedclk = MHz1;
    else if (sw == 2'b10)
        selectedclk = KHz31;
    else
        selectedclk = Hz250;
    end
    
    assign cpuclk = selectedclk;
    
endmodule
    
