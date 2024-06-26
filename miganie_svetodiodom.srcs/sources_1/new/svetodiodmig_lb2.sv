`timescale 1ns / 1ps


module svetodiodmig
#(
    parameter CLK_FREQUENCY = 200.0e6,
    parameter int G_LED_WIDTH = 4, // bit width of LED "bus" 
    parameter G_BLINK_PERIOD  = 1 // s
    )
    (
        input i_clk,
        input i_rst,
        output logic [G_LED_WIDTH-1:0] o_led 
     );
    
    localparam  COUNETR_PERIOD = int'(G_BLINK_PERIOD * CLK_FREQUENCY);
    localparam COUNTER_WIDTH = int'($ceil($clog2(COUNETR_PERIOD + 1)));
    
    logic led_on = 0;
    reg [COUNTER_WIDTH -1 : 0]
    counter_value = '0;
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst || counter_value == COUNETR_PERIOD - 1)
        begin
            counter_value <= 0;
        end
        else begin
            counter_value <= counter_value + 1;
        end; 
    end
    
    always_ff @(posedge i_clk)
    begin
        if(counter_value < COUNETR_PERIOD/2)
        begin
            led_on <= 0;
        end     
        else begin
            led_on <= 1;
        end;
        if (G_LED_WIDTH > 1) begin
                o_led[G_LED_WIDTH-1:1]<={$size(o_led[G_LED_WIDTH-1:1]){led_on}}; // 3 wires will be equal to led_on, except first
                o_led[0]<=!led_on;
            end
            else begin
                o_led[0]<=led_on;
            end;
        end	
					
    
endmodule
/*
module svetodiodmig_2
#(
    parameter CLK_FREQUENCY = 200.0e6, 
    parameter BLINK_PERIOD = 1.0
    )
    (
        input i_clk,
        input i_rst,
        output logic [7:4] o_led_2 
     );
    
    localparam  COUNETR_PERIOD = int(BLINK_PERIOD * CLK_FREQUENCY);
    localparam COUNTER_WIDTH = int($ceil($clog2(COUNETR_PERIOD + 1)));
    
    logic led_on = 0;
    reg [COUNTER_WIDTH -1 : 0]
    counter_value = '0;
    
    always_ff @(posedge i_clk)
    begin
        if (i_rst || counter_value == COUNETR_PERIOD - 1)
        begin
            counter_value <= 0;
        end
        else begin
            counter_value <= counter_value + 1;
        end; 
    
    
        if(counter_value < COUNETR_PERIOD/2)
        begin
            led_on <= 0;
        end     
        else begin
            led_on <= 1;
        end;
    
        
        o_led_2[7:5] <= {$size(o_led_2[7:5]){led_on}};
        o_led_2[4] <= !led_on;
        
    end;	
					
    
endmodule


module big_module #(
    parameter CLK_FREQUENCY = 200.0e6, 
    parameter BLINK_PERIOD = 1.0, 
    parameter int G_LED_WIDTH = 4
)

(
    input i_clk_n, 
    input i_clk_p,
    input [1:0] i_rst,
    output logic [3:0] o_led
    //output logic [7:4] o_led_2
);


//   BUFG BUFG_inst (
//      .O(i_clk), 
//      .I(o_clk_ibufds) 
//   );


   IBUFDS #(
      .DIFF_TERM("TRUE"),       
      .IBUF_LOW_PWR("FALSE"),      
      .IOSTANDARD("LVDS") 
   ) IBUFDS_inst (
      .O(o_clk_ibufds),  
      .I(i_clk_p),  
      .IB(i_clk_n) 
   );
   
   svetodiodmig #(
    .CLK_FREQUENCY (CLK_FREQUENCY), 
    .BLINK_PERIOD (BLINK_PERIOD),
    .G_LED_WIDTH (G_LED_WIDTH)
    ) 
    LED
   (
     .i_clk (o_clk_ibufds),
     .i_rst (i_rst[0]),
     .o_led(o_led)
    );
    
//    svetodiodmig_2 #(
//    .CLK_FREQUENCY (CLK_FREQUENCY), 
//    .BLINK_PERIOD (BLINK_PERIOD)
//    ) 
//    LED_2
//   (
//     .i_clk (i_clk),
//     .i_rst (i_rst[1]),
//     .o_led_2(o_led_2)
//    );

endmodule

*/








    
     