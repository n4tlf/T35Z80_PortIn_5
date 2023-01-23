/********************************************************************************
*   D style flip flop.
*       inlcludes SET and RESET async inputs                                    *
********************************************************************************/
module  dff (
    input   clk,
    input   pst_n,
    input   clr_n,
    input   din,
    output  q);
//    ,output n_q);
    
    reg     qout;
    
always @(posedge clk)
    if(clr_n == 1'b0)
        qout <= 1'b0;
    else if(pst_n == 1'b0)
        qout <= 1'b1;
    else if(clk == 1'b1)
        qout <= din;
    
assign q = qout;
//assign n_q = !qout;

endmodule 

