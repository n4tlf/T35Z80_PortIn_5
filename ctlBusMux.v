/********************************************************************
*   FILE:   cltBusMux.v      Ver 0.1         Nov. 6, 2022           *
*                                                                   *
********************************************************************/

module ctlBusMux
    (
    input [4:0] controlin,
    input   select,
    output wire [4:0] controlout
    );
    
reg [4:0] control;

always @* begin
    if (select)
        control <= 5'b0;
    else
        control <= controlin;  
    end
    
    assign controlout = control;
    
endmodule

