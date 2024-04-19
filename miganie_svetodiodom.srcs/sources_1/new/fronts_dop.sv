`timescale 1ns / 1ps


module fronts
    #(
    parameter CLK_FREQUENCY = 200.0e6    
    )

    (
    output bit o_nes,
    output bit o_pos,
    input i_clk,
    input bit o_signal,
    input bit o_signal_dly
    );
    

    always_ff@(posedge i_clk)
    begin
        o_signal_dly <= o_signal;
    end;

    always_comb
    begin
        if (o_signal == 1)
        begin
            o_pos <= 1;
        end 
        else begin
            o_nes <= 1;
        end;

        if (o_signal_dly == 1)
        begin
            o_pos <= 0;
        end 
        else begin
            o_nes <= 0;
        end;
    end;   

endmodule