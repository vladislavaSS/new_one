`timescale 1ns / 1ps


module mux
   (
    input bit [1:0] i_select,
    input bit [3:0] i_signal,
    output bit o_f
    );
    
    always_comb 
        o_f = i_signal[i_select];
    
    
endmodule
