`timescale 1ns / 1ps

module source#(
 parameter int G_MAX_DATA  = 10,
 parameter int G_CNT_WIDTH = $ceil($clog2(G_MAX_DATA + 1)),
 parameter     G_BYT       = 1,
 parameter     W           = 8*G_BYT)
 (
    input i_rst,
    input i_clk,
    
    if_axis.m m_axis,
        
    input logic [G_CNT_WIDTH - 1 : 0] Length //for input length of data
    );
    
    logic [G_CNT_WIDTH - 1 : 0] Length_buff = '0;
    
    localparam int C_MAX_IDLE = 20;
    localparam int C_MAX_PSE = 10;
    
    localparam int C_IDLE = $ceil($clog2(C_MAX_IDLE + 1));
    localparam int C_PSE = $ceil($clog2(C_MAX_PSE + 1));
    
    
    logic [G_CNT_WIDTH - 1 : 0] q_data_cnt = '0;
    logic [C_PSE - 1 : 0] q_pse_cnt = '0; 
    logic [C_IDLE - 1 : 0] q_idle_cnt = '0;
    logic [W - 1 : 0] m_data = '0;
    logic m_valid;

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
    
    initial begin
      m_axis.tvalid = '0;
      m_axis.tdata = '0;
      m_axis.tlast = '0;
    end
	
	
	always_ff @(posedge i_clk) begin
	if (i_rst) 
	   signal <= S0;
	else
       case (signal)
         S0:
            begin 
                signal = (m_axis.tready) ? S1 : S0; 
                m_axis.tvalid <= '0;
                q_data_cnt <=  1; 
                q_pse_cnt  <= '0;
                q_idle_cnt <= '0;
            end
         S1: 
            begin
                signal <= (m_axis.tvalid && m_axis.tready) ? S2 : S1;
                if (Length_buff == 0)
                    Length_buff <= Length;
                
                m_axis.tvalid <= !(m_axis.tvalid && m_axis.tready);
                m_axis.tdata  <= 72;
            end
         S2: 
            begin
                signal <= (m_axis.tvalid && m_axis.tready) ? S3 : S2;
                m_axis.tvalid <= !(m_axis.tvalid && m_axis.tready);
                m_axis.tdata  <= Length_buff;
                
                if (m_axis.tvalid && m_axis.tready) begin
                    m_axis.tdata <= q_data_cnt; 
                    q_data_cnt <= q_data_cnt + 1;end
                    
            end
         S3:
            begin
                signal  <= ((q_data_cnt == Length_buff + 1) && (m_axis.tvalid && m_axis.tready)) ? S4: S3; 
                m_axis.tvalid <= !((q_data_cnt == Length_buff + 1) && (m_axis.tvalid && m_axis.tready)); 
                
                if (m_axis.tvalid && m_axis.tready) begin
                    q_data_cnt <= q_data_cnt + 1;
                    m_axis.tdata <= q_data_cnt; end 
            end
         S4: 
            begin signal <= S5;
             end 
         S5: 
            begin signal = (m_axis.tvalid && m_axis.tready) ? S6 : S5;
                  m_axis.tlast <= '1;
                  m_axis.tvalid <= !(m_axis.tvalid && m_axis.tready);
                  m_axis.tdata  <= m_data;
            end
         S6: 
            begin 
                  signal = (C_MAX_IDLE - 1 == q_idle_cnt) ? S0 : S6; 
                  m_axis.tlast <= '0;
                  q_idle_cnt <= (q_idle_cnt == C_MAX_IDLE - 1) ? '0 : (q_idle_cnt + 1);
    
              if (m_data == m_axis.tdata)
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
		.i_crc_s_rst_p (m_axis.tvalid && m_axis.tready && signal == S5), // Sync Reset, Active High. Reset CRC To Initial Value.
		.i_crc_ini_vld ('0     ), // Input Initial Valid
		.i_crc_ini_dat ('0     ), // Input Initial Value
		.i_crc_wrd_vld ((m_axis.tvalid && m_axis.tready && signal != S0 && signal != S1) /*|| (s_valid && s_ready && signal == S2)*/), // Word Data Valid Flag 
        .o_crc_wrd_rdy (       ), // Ready To Recieve Word Data
		.i_crc_wrd_dat (m_axis.tdata ), // Word Data
		.o_crc_res_vld (m_valid), // Output Flag of Validity, Active High for Each WORD_COUNT Number
		.o_crc_res_dat (m_data )  // Output CRC from Each Input Word
	);
	 
     
	
endmodule
