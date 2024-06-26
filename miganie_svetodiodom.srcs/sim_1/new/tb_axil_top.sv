`timescale 1ns / 1ps

module tb_axil_top#(
    int G_RM_ADDR_W = 4, 	
    int G_RM_DATA_B = 4
)(
);
 reg [7 : 0] o_length;
 reg [C_RM_DATA_W - 1 : 0]	w_err;

 logic i_clk = '0;
 logic [2:0] i_rst  = '0;
 logic i_rst_reg = '0;

 localparam T_CLK = 1;
 localparam C_RM_DATA_W = 8 * G_RM_DATA_B;

 //if_axil s_axil();

 typedef logic [G_RM_ADDR_W - 1 : 0] t_xaddr;
 typedef logic [C_RM_DATA_W - 1 : 0] t_xdata;


if_axil #(
		.N (G_RM_DATA_B), 
		.A (G_RM_ADDR_W)
		) m_axil ();

task t_axil_init; 
        begin
            m_axil.awvalid  <= '0;
            m_axil.awaddr   <= '0;
            m_axil.wvalid   <= '0;
            m_axil.wdata    <= '0;
            m_axil.wstrb    <= '0;
            m_axil.bready   <= '0;
            m_axil.arvalid  <= '0;
            m_axil.araddr   <= '0;
            m_axil.rready   <= '0;
            m_axil.rresp    <= '0;
        end
    endtask : t_axil_init

`define MACRO_AXIL_HSK(miso, mosi) \
		m_axil.``mosi``= '1; \
		do begin \
			#T_CLK; \
		end while (!(m_axil.``miso`` && m_axil.``mosi``)); \
		m_axil.``mosi`` = '0; \

task t_axil_wr;
		input t_xaddr ADDR;
		input t_xdata DATA;
		begin
		// write address
			m_axil.awaddr = ADDR;
			`MACRO_AXIL_HSK(awready, awvalid);
		// write data
			m_axil.wdata = DATA;
			m_axil.wstrb = '1;
			`MACRO_AXIL_HSK(wready, wvalid);
		// write response
			`MACRO_AXIL_HSK(bvalid, bready);
		end
	endtask : t_axil_wr    

 task t_axil_rd;
		input  t_xaddr ADDR;
		output t_xdata DATA;
		begin
		// read address
			m_axil.araddr = ADDR;
			`MACRO_AXIL_HSK(arready, arvalid);
		// read data
			m_axil.rresp = 2'b00;
			`MACRO_AXIL_HSK(rvalid, rready);
			DATA = m_axil.rdata;
		end
	endtask : t_axil_rd    

localparam t_xaddr LEN_ADDR	= 'h01; 
localparam t_xaddr ERR_ADDR	= 'h04;

initial begin
        i_rst_reg   = 1; 
        #2;
        i_rst_reg   = 0;
	end

   initial begin
		
        t_axil_init;

        #5;
        o_length = 0/*5*/;
        t_axil_wr(.ADDR(LEN_ADDR), .DATA(o_length));
		t_axil_rd(.ADDR(ERR_ADDR), .DATA(w_err));
		#5;
        t_axil_wr(.ADDR(LEN_ADDR), .DATA(o_length /*+ 1*/));
		t_axil_rd(.ADDR(ERR_ADDR), .DATA(w_err));
		#5;
		t_axil_wr(.ADDR(LEN_ADDR), .DATA(o_length /*+ 2*/));
		t_axil_rd(.ADDR(ERR_ADDR), .DATA(w_err));
		#5;
		t_axil_wr(.ADDR(LEN_ADDR), .DATA(o_length /*+ 3*/));
		t_axil_rd(.ADDR(ERR_ADDR), .DATA(w_err));

		#10;
        o_length = 0/*8*/;
        //t_axil_wr(.ADDR(LEN1_ADDR), .DATA(o_length));
		t_axil_rd(.ADDR(ERR_ADDR), .DATA(w_err));

		o_length = 0;

		#10;
		t_axil_rd(.ADDR(LEN_ADDR), .DATA(o_length));

		//#10;
		//t_axil_rd(.ADDR(WRNG_ADDR), .DATA(w_err));

	end

top_axil UUT_2(
    .i_clk (i_clk),
    .i_rst (i_rst),
    .i_rst_reg(i_rst_reg),
    .s_axil (m_axil)
    );


always #(T_CLK/2.0) i_clk = ~i_clk;
  
endmodule
