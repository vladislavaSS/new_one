`timescale 1ns / 1ps

module led_mux_lab2_tb();

    localparam CLK_FREQUENCY = 1e9; 
	localparam real G_BLINK_PERIOD [0:3] = '{1e-6, 2e-6, 3e-6, 4e-6}; 
	localparam int  G_CNT_NUM = $size(G_BLINK_PERIOD); 
	localparam int  G_SEL_WIDTH = $ceil($clog2(G_CNT_NUM)); 
	localparam int  G_LED_WIDTH = 8; 

	localparam      T_CLK = 1e9 / CLK_FREQUENCY; 
	
	logic i_clk = '0;
	logic [G_SEL_WIDTH-1:0] i_sel = '0; 
	logic [G_LED_WIDTH-1:0] o_led = '0;

	always #(T_CLK/2) i_clk = ~i_clk; 
	always #1e4 i_sel = i_sel + 1; 
	
	led_mux_lab2b #(
	       .CLK_FREQUENCY  (CLK_FREQUENCY ),
           .G_LED_WIDTH    (G_LED_WIDTH   ),
           .G_CNT_NUM      (G_CNT_NUM     ),
           .G_SEL_WIDTH    (G_SEL_WIDTH   ),
           .G_BLINK_PERIOD (G_BLINK_PERIOD))
           u_uut (
            .i_clk_p(i_clk),
            .i_clk_n(~i_clk),
            .i_sel(i_sel),
            .o_led(o_led)
            );
	
endmodule
