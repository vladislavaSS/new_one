`timescale 1ns / 1ps

module sink_tb#(
 parameter logic [G_CNT_WIDTH - 1 : 0] Length = 10,
 parameter int G_CNT_WIDTH = 8,
 parameter G_BYT = 1,
 parameter W = 8*G_BYT
    );
    
 localparam T_CLK = 1.0;

 logic i_clk = '0;
 logic i_rst = '0;
 //logic si_ready = '1;
 //logic q_ready = '1;
 /*logic si_valid = '0; 
 logic [W - 1 : 0] si_data = '0;*/
 logic             q_valid = '0; 
 logic [W - 1 : 0] q_data = '0;
 //logic si_last = '0;  
 if_axis s_axis();
 
 always_ff @(posedge i_clk) begin
    q_valid <= s_axis.tvalid;
    q_data  <= s_axis.tdata;
 end

 
 sink #(
    .G_BYT(G_BYT)
    )
    UUT_2(
     .i_clk (i_clk),
     .i_rst (i_rst),
     .s_axis(s_axis)
     //.si_ready (q_ready),
     //.si_valid (q_valid),
     //.si_data  (q_data),
     //.si_last  (si_last)
     );
     
 always #(T_CLK/2.0) i_clk = ~i_clk;
 //always #(T_CLK*3) si_ready = ~si_ready;
 //always #(T_CLK*5) si_valid = ~si_valid;
 //always_ff @(posedge i_clk) q_ready <= si_ready;
    


 initial begin
    /*#(T_CLK*10)
    t_hsk(.VALUE(72), .TLAST_ENA(0), .SAMPLE_RATE(1));
    t_hsk(.VALUE(10), .TLAST_ENA(0), .SAMPLE_RATE(1));
    //t_hsk(.VALUE (for (int i = 1; i < 11; i++) s_axis.tdata = i),.TLAST_ENA(0), .SAMPLE_RATE(1));
    /*for (int i = 1; i < 11; i++) 
    begin
        s_axis.tdata = i;
        #(T_CLK);
    end
    s_axis.tdata  = 'h5B;
    s_axis.tlast  = '1;
    #(T_CLK);*/
    
   //S0
    s_axis.tvalid = '0; 
    s_axis.tlast  = '0; 
    s_axis.tdata  = '0;  
 
    // S1
    //#(T_CLK*10)
    s_axis.tvalid = '1;
    #(T_CLK);   // comment?
      // Header 
    s_axis.tdata  = 72;
    //#(T_CLK*2);
    s_axis.tvalid = '0;
    
    // S2
    #(T_CLK*2);
    s_axis.tvalid = '1;
    s_axis.tdata = 10;  //lenght
    //#(T_CLK*2);
    s_axis.tvalid = '0;
    
    // S3
    #T_CLK;
    s_axis.tvalid = '1;
    for (int i = 1; i < 11; i++) 
    begin
        s_axis.tdata = i;
        #(T_CLK*2);
    end
    #(T_CLK*2);
    s_axis.tvalid = '0;

    // S5
    //#(T_CLK * 20)
    s_axis.tvalid = '1;
    s_axis.tdata  = 'h5B;
    s_axis.tlast  = '1;
    #(T_CLK*2);
    s_axis.tvalid = '0;
    s_axis.tlast  = '0;
    s_axis.tdata  = '0; 
    
    end
    
endmodule

  
  
  
  
  
  