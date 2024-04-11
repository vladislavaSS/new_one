`timescale 1ns/1ps

module fronts_tb
#(
    parameter CLK_FREQUENCY = 200.0e6,
    parameter T_CLK = int(1.0e9 / CLK_FREQUENCY)
    );

    bit i_clk = 1'b0; 
    
    fronts
    #(
    .CLK_FREQUENCY(CLK_FREQUENCY))
    UUT (
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .i_clk (i_clk ),
        .o_signal (o_signal),
        .o_signal_dly (o_signal_dly),
        .o_pos (o_pos),
        .o_nes (o_nes)
    );

    always #(T_CLK/2) i_clk = ~i_clk;



endmodule