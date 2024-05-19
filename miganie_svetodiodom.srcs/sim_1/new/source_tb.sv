`timescale 1ns / 1ps

/*interface if_axis #(parameter int N = 1) ();

 localparam W = 8 * N;
 
 logic         tready;
 logic         tvalid;
 logic         tlast;
 logic [W-1:0] tdata;
 
 modport m (input tready, output tvalid, tlast, tdata);
 modport s (output tready, input tvalid, tlast, tdata);

endinterface : if_axis*/

 module source_tb#(
  parameter G_MAX_DATA = 10,
  parameter int G_CNT_WIDTH = $ceil($clog2(G_MAX_DATA + 1)),
  parameter G_BYT = 1,
  parameter W = 8*G_BYT
  );
 
 localparam T_CLK = 1;

 logic i_clk = '0;
 logic i_rst = '0;
 //logic s_ready = '1;
 logic q_ready = '1;
 //logic s_last = '0;
 logic [G_CNT_WIDTH - 1 : 0] Length = '0;
 
 if_axis m_axis();
 
  source #(
     .G_MAX_DATA (G_MAX_DATA),
     .G_BYT(G_BYT)
    )
    UUT_2(
     .i_clk (i_clk),
     .i_rst (i_rst),
     .m_axis (m_axis),//.tready (q_ready),
     //.m_axis.tlast (s_last),
     .Length (Length)
     );

 always #(T_CLK) i_clk = ~i_clk;
 always #(T_CLK*10) m_axis.tready = ~m_axis.tready;
 always_ff @(posedge i_clk) q_ready <= m_axis.tready;
    

 initial begin
    m_axis.tready <= 0;
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
