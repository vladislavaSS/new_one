`timescale 1ns / 1ps


module mux#(
    parameter int G_SIG_WIDTH = 4, // Bus input i_selector
    parameter int G_SEL_WIDTH = $ceil($clog2(G_SIG_WIDTH))
)
   (
    input bit [G_SEL_WIDTH - 1 :0] i_select,
    input bit [G_SIG_WIDTH - 1 :0] i_signal,
    output bit o_f
    );
    
    always_comb 
        o_f = i_signal[i_select];
    
    
endmodule
