`timescale 1ns/1ps

module smux_tb 
#(
    parameter CLK_FREQUENCY = 25.0e6,
    parameter t_clk = int(1.0e9 / CLK_FREQUENCY)
 );

    bit [1:0] i_select = '0; bit [3:0] i_signal = '0;

    mux 
    UUT(
    .i_signal (i_signal ),
    .i_select(i_select),
    .o_f ()
    );

    always #(t_clk) i_signal[3] = ~ i_signal[3];
    always #((t_clk + (1.0e9 / 20e6)) / 3) i_signal[2] = ~ i_signal[3];
    always #(t_clk - (1.0e9 / 33e7) + 2*(1.0e9 / 50.0e7)) i_signal[1] = ~ i_signal[1];
    always #(2**3 * t_clk - (1.0e9 / 34.48e5)) i_signal[0] = ~ i_signal[0];
    always #(t_clk * 10) i_select += 1;

 endmodule