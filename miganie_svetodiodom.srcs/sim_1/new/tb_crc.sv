`timescale 1ns / 1ps

module tb_crc #(
	int DW = 64 // data width
);

logic          i_clk = '0;

always #0.5 i_clk = ~i_clk; // simulate clock

logic          i_vld = '0;
logic [DW-1:0] i_dat = '0;

int fd = 0;

initial begin
	fd = $fopen("pkt_01.dat", "r");
	
	if (fd == 0) begin
		$display("Error: File not found!");
		$finish;
	end
	
	#9.6;
	
	while (!$feof(fd)) begin
		i_vld = '1;
		$fscanf(fd, "%h\n", i_dat);
		#1;
		i_vld = '0;
	end
	
	$fclose(fd);
end

endmodule : tb_crc
