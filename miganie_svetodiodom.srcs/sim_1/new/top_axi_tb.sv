`timescale 1ns / 1ps

module top_axi_tb#(
 parameter logic [G_CNT_WIDTH - 1 : 0] Length = 10,
 parameter int G_CNT_WIDTH = 8,//$ceil($clog2(G_MAX_DATA + 1)),
 parameter G_BYT = 1,
 parameter W = 8*G_BYT
 )();
 
 bit i_clk = '0;
 bit [2:0] i_rst  = '0;
 localparam T_CLK = 1;
 
 top_axi #(
     //.G_MAX_DATA (G_MAX_DATA),
     .G_BYT (G_BYT)
     //.Length(Length)
    )
    UUT_2(
     .i_clk (i_clk),
     .i_rst (i_rst)
     );

  always #(T_CLK) i_clk = ~i_clk;
  
  //initial begin #(T_CLK*20); i_rst = 3'b001; #(T_CLK*10); i_rst = 3'b000; /*#(T_CLK*120); i_rst = 3'b100; #(T_CLK*10); i_rst = 3'b000; */end
  
endmodule
