`timescale 1ns/1ps

module svetodiodmig_tb 
#(
    parameter CLK_FREQUENCY = 50.0e6, parameter BLINK_PERIOD = 100e-6);

    localparam T_CLK = 1.0e9 / CLK_FREQUENCY;

    bit i_clk = 1'b0; bit i_rst = 1'b1;

    svetodiodmig
    #( 
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BLINK_PERIOD (BLINK_PERIOD)) UUT_2 (
    .i_clk (i_clk ),
    .i_rst(i_rst),
    .o_led ()
    );

    always #(T_CLK/2) i_clk = ~i_clk;
    
    initial begin i_rst = 1'b1;
        #10e3 i_rst = 1'b0; #(20*T_CLK) i_rst = 1'b0;
    end 
 endmodule