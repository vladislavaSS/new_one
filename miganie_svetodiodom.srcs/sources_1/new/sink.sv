`timescale 1ns / 1ps

module sink#(
 parameter G_BYT = 1,
 parameter W = 8*G_BYT)
 (
   input i_rst,
   input i_clk,
   input s_valid,
   input [7 : 0] s_data, 
   
   
   output s_ready,
   output o_good,
   output o_error
      );
    
    
    crc #(
		.POLY_WIDTH (W   ), // Size of The Polynomial Vector
		.WORD_WIDTH (W   ), // Size of The Input Words Vector
		.WORD_COUNT (0   ), // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5), // Polynomial Bit Vector
		.INIT_VALUE ('1  ), // Initial Value
		.CRC_REF_IN ('0  ), // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		.CRC_REFOUT ('0  ), // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		.BYTES_RVRS ('0  ), // Input Word Byte Reverse
		.XOR_VECTOR ('0  ), // CRC Final Xor Vector
		.NUM_STAGES (2   )  // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) CRC (
		.i_crc_a_clk_p (i_clk  ), // Rising Edge Clock
		.i_crc_s_rst_p (i_rst), // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0     ), // Input Initial Valid
		.i_crc_ini_dat ('0     ), // Input Initial Value
		.i_crc_wrd_vld (s_valid), // Word Data Valid Flag 
		.o_crc_wrd_rdy (s_ready), // Ready To Recieve Word Data
		.i_crc_wrd_dat (s_data ), // Word Data
		.o_crc_res_vld (m_valid), // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (m_data )  // Output CRC from Each Input Word
	);
	
	
endmodule
