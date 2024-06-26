`timescale 1ns / 1ps

module sink#(
  parameter logic [G_CNT_WIDTH - 1 : 0] Length = 10,
  parameter int G_CNT_WIDTH = 8,//$ceil($clog2(Length + 1)),
  parameter G_BYT = 1,
  parameter W = 8*G_BYT
 )
 (
   input i_rst,
   input i_clk,
   
   if_axis.s s_axis,
 
   output logic o_good,         
   output logic o_error,             // CRC error, when received CRC != calculated CRC
   output logic o_err_mis_tlast,     // Tlast error, when expected tlast, but not found
   output logic o_err_unx_tlast      // Tlast error, when unexpected tlast, but found  
                        

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

   // logic q_err_mis_tlast = 0;          
   // logic q_err_unx_tlast = 0;         
   
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
    
    /*initial begin s_axis.tready <= 0; end*/
    
    //always_ff @(posedge i_clk) q_clear <= (signal == S5) && s_axis.tvalid && s_axis.tready;
	
	always_ff @(posedge i_clk) begin
	if (i_rst) 
	   signal <= S0;
	else
       case (signal)
         S0:
            begin 
                   signal <= S1; 
                   q_data_cnt <= 1;
                   o_good  <= '0;
                   o_error <= '0;
                   o_err_mis_tlast <= '0;
                   o_err_unx_tlast <= '0;
            end
         S1: 
            begin 
                tdata <= s_axis.tdata;
                if (/*s_axis.tdata == 72 &&*/ s_axis.tvalid) begin signal <= S2; end                     
            end
         S2: 
            begin
                if (s_axis.tvalid) begin
                length <= s_axis.tdata;                //length
                tdata <= s_axis.tdata;
                signal <= S3;
                end                     
            end
         S3:
            begin
                if ((s_axis.tvalid) && (q_data_cnt == length)) begin signal <= S4; end 
                
                if (s_axis.tvalid) begin
                    q_data_cnt <= q_data_cnt + 1;
                    tdata <= s_axis.tdata; end 
            end
         S4: 
            begin signal <= S5; end 
         S5: begin 
            signal <= S6;
            end
         S6: 
            begin 
                  if (s_axis.tlast)
                     begin
                         signal <= S0;
                         if (mi_data == s_axis.tdata) o_good <= '1;
                         else o_error <= '1;
                     end   
            end
         default: 
            signal <= S0;
       
      endcase;
    end 

     always_ff @(posedge i_clk) begin 
      if ((signal == S5) && !s_axis.tlast) o_err_mis_tlast <= '1;
      if ((signal == S3) && (q_data_cnt < length) && s_axis.tlast) o_err_unx_tlast <= '1;
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
		.i_crc_s_rst_p (signal == S5), 
		.i_crc_ini_vld ('0     ), 
		.i_crc_ini_dat ('0     ), 
		.i_crc_wrd_vld (s_axis.tvalid && (signal != S0) && (signal != S1) && (tdata != 72)),  
		.o_crc_wrd_rdy (s_axis.tready),
		.i_crc_wrd_dat (tdata   ),
		.o_crc_res_vld (m_valid), 
		.o_crc_res_dat (mi_data ) 
	);
	
	
endmodule