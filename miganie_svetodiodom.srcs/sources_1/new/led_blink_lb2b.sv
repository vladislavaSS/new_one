`timescale 1ns / 1ps

module lab2_led_blink #(
	parameter     G_CLK_FREQUENCY = 200e6, // Hz
	parameter     G_BLINK_PERIOD  = 1, // s
	parameter int G_LED_WIDTH     = 4
) (
	input  wire                    i_clk,
	input  wire                    i_rst, // reset, active-high
	output logic [G_LED_WIDTH-1:0] o_led
);

	localparam int C_CNT_PERIOD = G_BLINK_PERIOD * G_CLK_FREQUENCY;
	localparam int C_CNT_WIDTH  = $ceil($clog2(C_CNT_PERIOD +1));

// sync reset
	(* MARK_DEBUG="true" *) reg q_rst = '0; // reset, active-high
	always @(posedge i_clk)
		q_rst <= i_rst;

// clock cycles counter
	(* MARK_DEBUG="true" *) reg [C_CNT_WIDTH-1:0] q_cnt = '0;
	always @(posedge i_clk)
		if (q_rst)
			q_cnt <= '0;
		else
			q_cnt <= (q_cnt == 0) ? C_CNT_PERIOD - 1 : q_cnt - 1;

// LED state decode
	(* MARK_DEBUG="true" *) reg q_led = '0;
	always @(posedge i_clk)
		q_led <= (q_cnt < C_CNT_PERIOD / 2) ? 0 : 1;

// revert odd/even LEDs polarity
	integer i;
	always_comb
		for (i = 0; i < $size(o_led); i = i + 1)
			o_led[i] <= q_led ^ (i % 2 == 1);
//			o_led[i] <= (i % 2 == 1) ? q_led : ~q_led;

endmodule : lab2_led_blink