`timescale 1ns / 1ps

 module source_tb#(
  parameter G_MAX_DATA = 10,
  parameter int G_CNT_WIDTH = $ceil($clog2(G_MAX_DATA + 1)),
  parameter G_BYT = 1,
  parameter W = 8*G_BYT
  );
 
 localparam T_CLK = 1;

 logic i_clk = '0;
 logic i_rst = '0;
 logic s_ready = '1;
 logic q_ready = '1;
 logic [G_CNT_WIDTH - 1 : 0] Length = 0;
 
  source #(
     .G_MAX_DATA (G_MAX_DATA),
     .G_BYT(G_BYT)
    )
    UUT_2(
     .i_clk (i_clk),
     .i_rst (i_rst),
     .s_ready (q_ready),
     .Length (Length)
     );

 always #(T_CLK) i_clk = ~i_clk;
 always #(T_CLK*10) s_ready = ~s_ready;
 always_ff @(posedge i_clk) q_ready <= s_ready;
    

 initial begin
    i_rst = '1;
    #(T_CLK*15)
    i_rst = '0;
    Length = G_MAX_DATA; 
//    #(T_CLK*60);
//    Length += 10;
//    #(T_CLK*60);
//    Length += 10;
//    #(T_CLK*60);
//    Length += 10;
//    #(T_CLK*60);
//    Length = 10;
 end
  
  
 endmodule
