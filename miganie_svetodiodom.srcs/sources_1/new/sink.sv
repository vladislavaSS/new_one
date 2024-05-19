`timescale 1ns / 1ps

module sink#(
  parameter int G_MAX_DATA = 10,
  parameter int G_CNT_WIDTH = $ceil($clog2(G_MAX_DATA + 1)),
  parameter G_BYT = 1,
  parameter W = 8*G_BYT
 )
 (
   input i_rst,
   input i_clk,
   
   if_axis.s s_axis,
 
   output logic o_good,
   output logic o_error
  );
  
   localparam int C_MAX_IDLE = 20;
   localparam int C_IDLE = $ceil($clog2(C_MAX_IDLE + 1));
   logic [C_IDLE - 1 : 0] q_idle_cnt = '0;
   logic [G_CNT_WIDTH - 1 : 0] q_data_cnt = '0; 
   logic [W - 1 : 0] tdata = '0;
   logic [W - 1 : 0] mi_data;
   logic m_valid;
   logic [W - 1 : 0] length = '0; 
   logic q_clear = '0; 
   
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
    
    initial begin s_axis.tready <= 0; end
    
    //always_ff @(posedge i_clk) q_clear <= (signal == S5) && s_axis.tvalid && s_axis.tready;
	
	always_ff @(posedge i_clk) begin
	if (i_rst) 
	   signal <= S0;
	else
       case (signal)
         S0:
            begin 
                if (s_axis.tvalid) begin  
                   signal <= S1; 
                   //q_data_cnt <= 1;
                   o_good  <= '0;
                   o_error <= '0;
                   s_axis.tready <= '0;
                   //q_clear = '1;
                   //q_idle_cnt <= '0; 
                   end
            end
         S1: 
            begin 
                s_axis.tready <= '1;
                //q_clear = '0;
               
                if (s_axis.tdata == 72 && s_axis.tvalid) begin signal <= S2; s_axis.tready <= '0; end                     
            end
         S2: 
            begin
                s_axis.tready <= '1;
                if (s_axis.tvalid && s_axis.tready) begin
                length <= s_axis.tdata;                //length
                tdata <= s_axis.tdata;
                //q_clear = '0;
                /*tdata <= q_data_cnt;
                q_data_cnt <= q_data_cnt + 1;*/
                signal <= S3;
                s_axis.tready <= '0;  
                end                     
            end
         S3:
            begin
                s_axis.tready <= '1;
                if ((s_axis.tvalid && s_axis.tready) && (tdata == length)) begin signal <= S4; s_axis.tready <= '0; end 
                
                if (s_axis.tvalid && s_axis.tready) begin
                    /*q_data_cnt <= q_data_cnt + 1;
                    tdata <= q_data_cnt; */
                    tdata <= s_axis.tdata; end 
            end
         S4: 
            begin signal <= S5; end 
         S5: begin 
             s_axis.tready <= '1; 
             if (s_axis.tvalid && s_axis.tready) begin signal <= S6; s_axis.tready <= '0; q_clear = '1; end
                  tdata <= mi_data;
            end
         S6: 
            begin 
                  if (C_MAX_IDLE - 1 == q_idle_cnt) signal <= S0; 
                  q_idle_cnt <= (q_idle_cnt == C_MAX_IDLE - 1) ? '0 : (q_idle_cnt + 1);
                
                  if (s_axis.tlast)
                     begin
                         //q_clear = '1;
                         if (mi_data == s_axis.tdata) o_good <= '1;
                         else o_error <= '1;
                     end
            end
         default: 
            signal <= S0;
       
      endcase;
    end 
   
    crc #(
		.POLY_WIDTH (W   ), // Size of The Polynomial Vector
		.WORD_WIDTH (W   ), // Size of The Input Words Vector
		.WORD_COUNT (0   ), // Number of Words To Calculate CRC, 0 - Always Calculate CRC On Every Input Word
		.POLYNOMIAL ('hD5), // Polynomial Bit Vector
		.INIT_VALUE ('1  ), // Initial Value
		/*.CRC_REF_IN ('0  ), // Beginning and Direction of Calculations: 0 - Starting With MSB-First; 1 - Starting With LSB-First
		.CRC_REFOUT ('0  ), // Determines Whether The Inverted Order of The Bits of The Register at The Entrance to The Xor Element
		.BYTES_RVRS ('0  ), // Input Word Byte Reverse*/
		.XOR_VECTOR ('0  ), // CRC Final Xor Vector
		.NUM_STAGES (2   )  // Number of Register Stages, Equivalent Latency in Module. Minimum is 1, Maximum is 3.
	) CRC (
		.i_crc_a_clk_p (i_clk  ), // Rising Edge Clock
		.i_crc_s_rst_p (q_clear/*s_axis.tvalid && s_axis.tready && signal == S5*/), // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0     ), // Input Initial Valid
		.i_crc_ini_dat ('0     ), // Input Initial Value
		.i_crc_wrd_vld (s_axis.tvalid && (signal != S0) && (signal != S1) /*&& (signal != S1) si_valid*/), // Word Data Valid Flag 
		//.o_crc_wrd_rdy (s_axis.tready), // Ready To Recieve Word Data
		.i_crc_wrd_dat (tdata   ), // Word Data
		.o_crc_res_vld (m_valid), // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (mi_data )  // Output CRC from Each Input Word
	);
	
	
endmodule
