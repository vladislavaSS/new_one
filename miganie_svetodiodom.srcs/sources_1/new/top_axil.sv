`timescale 1ns / 1ps

module top_axil(
 input i_clk,
 input [2:0] i_rst,
 
 if_axil.s s_axil;
);

 logic  o_good,        
        o_err_mis_tlast,  
        o_err_unx_tlast;

reg [7 : 0] o_len;

(* keep_hierarchy="yes" *) 
top_axi UUT_2 (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_length (o_len),

    .o_err_crc (o_good),        
    .o_err_mis_tlast (o_err_mis_tlast),  
    .o_err_unx_tlast (o_err_unx_tlast)
    );



endmodule
