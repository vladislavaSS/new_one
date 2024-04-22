`timescale 1ns / 1ps

module source_tb#(
 parameter G_BYT = 1,
 parameter W = 8*G_BYT
 );
 
 localparam T_CLK = 1;

 logic i_clk = '0;
 logic i_rst = '0;
 //logic s_ready = '1;
 
  source #(
    )
    UUT_2(
     .i_clk (i_clk),
     .i_rst (i_rst),
     .s_ready ('1)
     );

 always #(T_CLK) i_clk = ~i_clk;

initial begin
    i_rst = '1;
    #(T_CLK*10)
    i_rst = '0;
end
  
  
endmodule
