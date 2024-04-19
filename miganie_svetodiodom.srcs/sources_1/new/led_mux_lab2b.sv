`timescale 1ns / 1ps

module led_mux_lab2b #(
    parameter       CLK_FREQUENCY        = 200.0e6, 
    parameter int   G_LED_WIDTH          = 8, // bit width of LED "bus"
    parameter int   G_CNT_NUM            = 4, // number of independent counters
    parameter int   G_SEL_WIDTH          = $ceil($clog2(G_CNT_NUM)), // selector bit width
    parameter real  G_BLINK_PERIOD [0 : G_CNT_NUM - 1] = '{0: 1, 1: 2, 2: 3, 3: 4}
)

(
    input i_clk_p, // diff clock
    input i_clk_n, // diff clock
    input  wire [G_SEL_WIDTH -1 : 0]  i_sel,  // mux selector
    output logic [G_LED_WIDTH - 1 : 0] o_led = '1
);


IBUFDS #(
      .DIFF_TERM("TRUE"),       
      .IBUF_LOW_PWR("FALSE"),      
      .IOSTANDARD("LVDS") 
   ) IBUFDS_inst (
      .O(w_clk),  
      .I(i_clk_p),  
      .IB(i_clk_n) 
   );
   
   wire [G_CNT_NUM-1:0] w_led;
    
    
genvar i;
generate for (i = 0; i < G_CNT_NUM; i+=1) begin : gen_led
    svetodiodmig #(
	    .G_LED_WIDTH(1),
	    .CLK_FREQUENCY (CLK_FREQUENCY  ),
        .G_BLINK_PERIOD (G_BLINK_PERIOD[i])
        ) LED (
        .i_clk (w_clk),
        .i_rst ('0),
        .o_led (w_led[i])
    );

end : gen_led endgenerate

mux
MUX(
    .i_signal(w_led),
    .i_select(i_sel),
    .o_f(w_res)
);

always @(posedge w_clk)
		o_led <= '{default: w_res};
 
endmodule
