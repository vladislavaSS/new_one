`timescale 1ns / 1ps

module tb_mult #(
	int AW = 4,
	int BW = 4,
	int CW = 4,
	
	localparam int MW = AW + BW
);

logic i_clk = '0;

always #0.5 i_clk = ~i_clk; // simulate clock

logic signed [AW-1:0] i_A = '0;
logic signed [BW-1:0] i_B = '0;
logic signed [CW-1:0] o_C;// = '0;

logic signed [MW-1:0] v_C = '0;

task tk_data;
	begin
		for (int k = -2**(BW-1); k <= 2**(BW-1)-1; k++) begin
			for (int i = -2**(AW-1); i <= 2**(AW-1)-1; i++) begin
				i_A = i;
				i_B = k;
				#1;
			end
		end
	end
endtask : tk_data

initial begin
	#10;
	forever
		tk_data;
end

always_comb
	v_C = i_A * i_B;

//always_ff @(posedge i_clk)
assign
	o_C = v_C[MW-1:MW-CW];

endmodule : tb_mult
