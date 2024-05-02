`timescale 1ns / 1ps

module source#(
 parameter int G_MAX_DATA = 10,
 parameter int G_CNT_WIDTH = $ceil($clog2(G_MAX_DATA + 1)),
 parameter G_BYT = 1,
 parameter W = 8*G_BYT)
 (
    input i_rst,
    input i_clk,
    input s_ready,
    
    input logic [G_CNT_WIDTH - 1 : 0] Length, //for input length of data
    
    output logic s_valid = '0,
    output logic [W - 1 : 0] s_data = '0
    );
     
    //int C_MAX_DATA;
    
    logic [G_CNT_WIDTH - 1 : 0] Length_buff = '0;
    
    //localparam int C_MAX_DATA = 10; //  
    localparam int C_MAX_IDLE = 20;
    localparam int C_MAX_PSE = 10;
    
    //localparam int C_DATA = $ceil($clog2(C_MAX_DATA + 1)); //localparam
    localparam int C_IDLE = $ceil($clog2(C_MAX_IDLE + 1));
    localparam int C_PSE = $ceil($clog2(C_MAX_PSE + 1));
    
    
    logic [G_CNT_WIDTH - 1 : 0] q_data_cnt = '0;
    //logic [C_DATA - 1 /*31*/ : 0] q_data_cnt = '0; //C_DATA - 1
    logic [C_PSE - 1 : 0] q_pse_cnt = '0; 
    logic [C_IDLE - 1 : 0] q_idle_cnt = '0;
    logic [W - 1 : 0] m_data = '0; 

	typedef enum {
      S0 = 0,  // Ready
      S1 = 1,  // Header    
      S2 = 2,  // Length    
      S3 = 3,  // Payload   
      S4 = 4,  // CRC_PAUSE 
      S5 = 5,  // CRC_DATA      
      S6 = 6   // Idle      
    } signals;
    
    signals signal = S0;
	
	
	always_ff @(posedge i_clk) begin
	if (i_rst) 
	   signal <= S0;
	else
       case (signal)
         S0:
            begin 
                signal = (s_ready) ? S1 : S0; 
                s_valid <= '0;
//                q_data_cnt <= '0; 
                q_data_cnt <=  1;//'0; 
                q_pse_cnt  <= '0;
                q_idle_cnt <= '0;
            end
         S1: 
            begin
                signal  <= (s_valid && s_ready) ? S2 : S1;
                if (Length_buff == 0)
                    Length_buff <= Length;
//                G_MAX_DATA <= Length_buff;
                
                s_valid <= !(s_valid && s_ready);
                s_data  <= 72;
            end
         S2: 
            begin
                signal  <= (s_valid && s_ready) ? S3 : S2;
                s_valid <= !(s_valid && s_ready);
//                s_data  <= C_MAX_DATA;
                s_data  <= Length_buff;
                
                if (s_valid && s_ready) begin
                    s_data <= q_data_cnt; 
                    q_data_cnt <= q_data_cnt + 1;end
                    
                //s_data <= (s_valid && s_ready) ? 1 : Length_buff;
            end
         S3:
            begin
//                signal  <= ((q_data_cnt == C_MAX_DATA - 1) && (s_valid && s_ready)) ? S4: S3; 
//                s_valid <= !((q_data_cnt == C_MAX_DATA - 1) && (s_valid && s_ready)); 
                signal  <= ((q_data_cnt == Length_buff + 1) && (s_valid && s_ready)) ? S4: S3; 
                s_valid <= !((q_data_cnt == Length_buff + 1) && (s_valid && s_ready)); 
                
                /*s_data  <= 72; */
                
                /*if (s_valid && s_ready) begin
                     s_data  <= (s_valid && s_ready) ? '0 : C_MAX_DATA; end */
                    
//                s_data <= q_data_cnt; //end
                
                if (s_valid && s_ready) begin
                    q_data_cnt <= q_data_cnt + 1;
                    s_data <= q_data_cnt; end 
            end
         S4: 
            begin signal <= S5;
             end 
         S5: 
            begin signal = (s_valid && s_ready) ? S6 : S5;
                  s_valid <= !(s_valid && s_ready);
                  s_data  <= m_data;
            end
         S6: 
            begin 
            signal = (C_MAX_IDLE - 1 == q_idle_cnt) ? S0 : S6; 
            q_idle_cnt <= (q_idle_cnt == C_MAX_IDLE - 1) ? '0 : (q_idle_cnt + 1);
    
              if (m_data == s_data)
                       Length_buff = Length;
            end
            
         default: signal <= S0;
       
      endcase;
    end 


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
		.i_crc_wrd_vld ((s_valid && s_ready && signal != S1) /*|| (s_valid && s_ready && signal == S2)*/), // Word Data Valid Flag 
        .o_crc_wrd_rdy (       ), // Ready To Recieve Word Data
		.i_crc_wrd_dat (s_data ), // Word Data
		.o_crc_res_vld (m_valid), // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (m_data )  // Output CRC from Each Input Word
	);
	 
     
	
endmodule
