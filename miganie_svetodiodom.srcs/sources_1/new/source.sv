`timescale 1ns / 1ps
module source#(
 parameter logic [G_CNT_WIDTH - 1 : 0] Length/*G_MAX_DATA*/  = 10,
 parameter int G_CNT_WIDTH = 8, //$ceil($clog2(G_MAX_DATA + 1)),
 parameter     G_BYT       = 1,
 parameter     W           = 8*G_BYT)
 (
    input i_rst,
    input i_clk,
    
    if_axis.m m_axis,
        
    input logic [G_CNT_WIDTH - 1 : 0] length// = Length //for input length of data
    );
    
    //logic [G_CNT_WIDTH - 1 : 0] length = Length;
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
      S0 = 0,  
      S1 = 1,  
      S2 = 2,  
      S3 = 3,  
      S4 = 4,  
      S5 = 5,    
      S6 = 6   
    } signals;
    
    signals signal = S0;
    
    initial begin
      m_axis.tvalid = '0;
      m_axis.tdata = '0;
      m_axis.tlast = '0;
      //length = Length;
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
                    Length_buff <= length;
                
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
                  if (C_MAX_IDLE - 1 == q_idle_cnt) begin
                     signal <= S0;
                     m_axis.tlast <= '0;
                  end
                  /* signal = (C_MAX_IDLE - 1 == q_idle_cnt) ? S0 : S6; 
                  m_axis.tlast <= '0;
                  q_idle_cnt <= (q_idle_cnt == C_MAX_IDLE - 1) ? '0 : (q_idle_cnt + 1);*/
                  q_idle_cnt <= q_idle_cnt + 1;

              if (m_data == m_axis.tdata)
                       Length_buff = length;
            end
            
         default: signal <= S0;
       
      endcase;
    end 


    crc #(
		.POLY_WIDTH (W   ), 
		.WORD_WIDTH (W   ), 
		.WORD_COUNT (0   ), 
		.POLYNOMIAL ('hD5),
		.INIT_VALUE ('1  ), 
		.CRC_REF_IN ('0  ), 
		.CRC_REFOUT ('0  ), 
		.BYTES_RVRS ('0  ), 
		.XOR_VECTOR ('0  ), 
		.NUM_STAGES (2   )  
	) CRC (
		.i_crc_a_clk_p (i_clk  ),
		.i_crc_s_rst_p (/*q_clear*/m_axis.tvalid && m_axis.tready && signal == S5),
		.i_crc_ini_vld ('0     ), 
		.i_crc_ini_dat ('0     ), 
		.i_crc_wrd_vld ((m_axis.tvalid && m_axis.tready && signal != S0 && signal != S1) /*|| (s_valid && s_ready && signal == S2)*/), 
      .o_crc_wrd_rdy (       ), 
		.i_crc_wrd_dat (m_axis.tdata ), 
		.o_crc_res_vld (m_valid), 
		.o_crc_res_dat (m_data ) 
	);
	 
     
	
endmodule
