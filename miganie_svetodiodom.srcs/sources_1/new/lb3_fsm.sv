`timescale 1ns / 1ps

module lb3_fsm#(
    parameter CLK_FREQUENCY = 200.0e6
)
(
    input i_clk,
    input i_rst,
    input logic [1:0] T,   
    output logic [1:0] L1, L2 = '0
);

typedef enum {
  S0 = 0,
  S1 = 1,
  S2 = 2,
  S3 = 3
} signals_l;

signals_l next_signal, signal = S0;

localparam CNT = 10;
localparam int CNT_WIDTH = $ceil($clog2(CNT));

logic [CNT_WIDTH-1:0] q_cnt = '0;

always_comb begin
  next_signal = signal;
  case (signal)
     S0: next_signal = (!T[0] && (q_cnt == CNT)) ? S1 : S0;
     S1: next_signal = S2;
     S2: next_signal = (!T[1] && (q_cnt == CNT)) ? S3 : S2;
     S3: next_signal = S0;
     default: next_signal = S0;
  endcase
end

always_ff @(posedge i_clk)
    case(signal)
        S0, S2: if (q_cnt < CNT) q_cnt <= q_cnt + 1;
        default: q_cnt <= '0;
    endcase
        
always_ff @(posedge i_clk)
    signal <= (i_rst) ? S0 : next_signal;
  
always_ff @(posedge i_clk)
    case (signal)
     S0: begin L1 = 2'b00; L2 = 2'b10; end // 00 - з, 10 - к, 01 - ж
     S1: begin L1 = 2'b01; L2 = 2'b01; end
     S2: begin L1 = 2'b10; L2 = 2'b00; end
     S3: begin L1 = 2'b01; L2 = 2'b01; end
    endcase

endmodule