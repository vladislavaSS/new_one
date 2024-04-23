`timescale 1ns / 1ps

module source#(
 parameter G_BYT = 1,
 parameter W = 8*G_BYT)
 (
    input i_rst,
    input i_clk,
    input s_ready,
    
    input int Length, //for input length of data
    input int Length_buff,
    
    output logic s_valid = '0,
    output logic [7:0] s_data = '0
    );
    
//     if (Length > 0) begin  
//        assign Length_buff = Length; end
     
    int C_MAX_DATA;
    
    //localparam int C_MAX_DATA = 10;
    localparam int C_MAX_IDLE = 50;
    localparam int C_MAX_PSE = 10;
    
    int C_DATA = $ceil($clog2(C_MAX_DATA - 1)); //localparam
    localparam int C_IDLE = $ceil($clog2(C_MAX_IDLE - 1));
    localparam int C_PSE = $ceil($clog2(C_MAX_PSE - 1));
    
    logic [31 : 0] q_data_cnt = '0; //C_DATA - 1
    logic [C_IDLE - 1 : 0] q_pse_cnt = '0;
    logic [C_PSE - 1 : 0] q_idle_cnt = '0;
    logic [7:0] m_data = '0; 

    
	typedef enum {
      S0 = 0,
      S1 = 1,
      S2 = 2,
      S3 = 3,
      S4 = 4,
      S5 = 5,
      S6 = 6
    } signals;
    
    signals signal = S0;
	
	
	
	always_ff @(posedge i_clk) begin
	if (i_rst) 
	   signal <= S0;
	else
//	   if (Length < 0)//(m_data == s_data && s_valid == 1)   
//            assign Length_buff = Length; 
       case (signal)
         S0:
            begin 
//                if (m_data == s_data)
//                    assign Length_buff = Length;
                C_MAX_DATA <= Length_buff;
                
                signal = (s_ready) ? S1 : S0; 
                s_valid <= '0;
                q_data_cnt <= '0;
                q_pse_cnt  <= '0;
                q_idle_cnt <= '0;
            end
         S1: 
            begin
                signal  <= (s_valid && s_ready) ? S2 : S1;
                s_valid <= !(s_valid && s_ready);
                s_data  <= 72;
            end
         S2: 
//            begin signal <= (s_ready && s_valid) ? S3 : S2; end
            begin
                signal  <= (s_valid && s_ready) ? S3 : S2;
                s_valid <= !(s_valid && s_ready);
                s_data  <= (s_valid && s_ready) ? '0 : C_DATA;
            end
         S3:
            begin
                signal  <= ((q_data_cnt == C_DATA - 1) && (s_valid && s_ready)) ? S4: S3; 
                s_valid <= !((q_data_cnt == C_DATA - 1) && (s_valid && s_ready)); 
                if (s_valid && s_ready) begin
                    q_data_cnt <= q_data_cnt + 1;
                    s_data <= q_data_cnt + 1;
                end
            end
         S4: 
            begin signal <= S5; end //S6 change S5
//            begin signal <= (q_pse_cnt == C_PSE - 1) ? S5 : S4; //S6 change S5
//            q_pse_cnt <= (q_pse_cnt == C_MAX_PSE - 1) ? '0 : (q_pse_cnt + 1); end
         S5: 
            begin signal = (s_valid && s_ready) ? S6 : S5;
            s_valid <= !(s_valid && s_ready);
            s_data  <= m_data; end
         S6: 
            begin 
            if (m_data == s_data)
                    assign Length_buff = Length;
            
            signal = (C_IDLE - 1 == q_idle_cnt) ? S0 : S6; 
            q_idle_cnt <= (q_idle_cnt == C_MAX_PSE - 1) ? '0 : (q_idle_cnt + 1);
            
                 end
         default: signal <= S0;
       
      endcase;
    end 
   
//   always_comb begin 
//        if (signal == S4) begin q_pse_cnt = (q_pse_cnt == C_MAX_PSE - 1) ? '0 : (q_pse_cnt + 1); end
//        if (signal == S6) begin q_pse_cnt = (q_idle_cnt == C_MAX_PSE - 1) ? '0 : (q_idle_cnt + 1); end
//   end     
   
//     always_ff @(posedge i_clk)
//         signal <= (i_rst) ? S0 : signal;   



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
		.i_crc_s_rst_p (s_valid && s_ready && signal == S5), // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0     ), // Input Initial Valid
		.i_crc_ini_dat ('0     ), // Input Initial Value
		.i_crc_wrd_vld (s_valid && s_ready), // Word Data Valid Flag 
        .o_crc_wrd_rdy (       ), // Ready To Recieve Word Data
		.i_crc_wrd_dat (s_data ), // Word Data
		.o_crc_res_vld (m_valid), // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (m_data )  // Output CRC from Each Input Word
	);
	 
     
	
endmodule
