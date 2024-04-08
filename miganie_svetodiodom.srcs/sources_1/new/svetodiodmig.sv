`timescale 1ns / 1ps

module svetodiodmig
#(
    parameter CLK_FREQUENCY = 50.0e6, 
    parameter BLINK_PERIOD = 1.0
    )
    (
        input i_clk,
        input i_rst,
        output logic [3:0] o_led
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
    
        
        o_led[3:1] <= {$size(o_led[3:1]){led_on}};
        o_led[0] <= !led_on;
        
    end
endmodule

















    
     