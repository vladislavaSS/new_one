`timescale 1ns / 1ps

module lb3_fsm_tb#(
//    parameter T_CLK = int'(1.0e9 / 50e6)
    parameter T_CLK = 1.0
);


logic i_clk = '0;
logic i_rst = '0;
logic [1:0] T = '0;
bit [1:0] L1, L2 = '0;
// logic next_signal = '0;
// logic signal = '0;
 
 lb3_fsm #(
    .T_CLK(T_CLK)
  ) 
  UUT_2(
     .i_clk(i_clk),
     .i_rst(i_rst),
     .T(T),
     .L1(L1),
     .L2(L2)
//     .next_signal(next_signal),
//     .signal(signal)
);

 always #(T_CLK/2.0) i_clk = ~i_clk;
 
// always #(T_CLK*10) T += 1;
 always #(T_CLK*11) T[0] = ~T[0];
 always #(T_CLK*27) T[1] = ~T[1];
 
// always #(T_CLK) T[0] += 1;
// always #(T_CLK + T_CLK/2) T[1] += 1;
 
// always #(T_CLK) L1[0] += 1;
// always #(T_CLK +T_CLK/5) L[1] += 1;
endmodule