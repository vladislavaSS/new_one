`timescale 1ns / 1ps


module fronts
    #(
    parameter CLK_FREQUENCY = 200.0e6    
    )

    (
    input i_clk
    );
    
    bit o_pos;
    bit  o_nes;
    reg  o_signal;
    reg  o_signal_dly;

    always_ff@(posedge i_clk)
    begin
        o_signal_dly <= o_signal;
    end;

    always_comb
    begin
        if (~o_signal_dly * o_signal == 1)
        begin
            o_pos <= 1;
        end;  

        if (o_signal_dly * ~o_signal == 1)
        begin
            o_nes <= 1;
        end;
    end;   

endmodule