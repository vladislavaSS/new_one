`timescale 1ns / 1ps

module top_axil(
 input i_clk,
 input [2:0] i_rst,
 input i_rst_reg,
  
 if_axil.s s_axil
);

logic o_error,        
      o_err_mis_tlast,  
      o_err_unx_tlast;

reg [7 : 0] o_len;

(* keep_hierarchy="yes" *) 
top_axi  TOP_AXI
    (
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_lenght (o_len),
    .o_error_top (o_error),        
    .o_err_mis_tlast_top (o_err_mis_tlast),  
    .o_err_unx_tlast_top (o_err_unx_tlast)
    );

 (* keep_hierarchy="yes" *) 
 reg_map REG_MAP (
    .i_error(o_error),        
    .i_err_mis_tlast(o_err_mis_tlast),        
    .i_err_unx_tlast(o_err_unx_tlast),
    .i_clk(i_clk),
    .i_rst(i_rst_reg),

    .o_length(o_len),
    .o_err(),

    .s_axil(s_axil)

 );  



endmodule
