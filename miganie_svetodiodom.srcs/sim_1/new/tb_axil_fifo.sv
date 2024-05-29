`timescale 1ns / 1ps
module tb_axil_fifo#(
	int G_RM_ADDR_W = 12, // AXIL xADDR bit width
	int G_RM_DATA_B = 8, // AXIL xDATA number of bytes (B)
	
	int G_CG_L      = 39 * 8, // codogram length (L), bytes //source 8*1?
	int G_USER_W    = 1, // sync-pulse-as-TUSER bit width (W)
	int G_CG_DATA_B = 1, // codogram TDATA number of bytes (B) //source 1? 
	int G_DG_DATA_B = 32 // datagram TDATA number of bytes (B)
)
();

// constants
localparam T_CLK = 1; // clock period ns
localparam C_RM_DATA_W = 8 * G_RM_DATA_B; // AXIL xDATA bit width
localparam C_CG_DATA_W = 8 * G_CG_DATA_B; // codogram TDATA bit width
localparam C_DG_DATA_W = 8 * G_DG_DATA_B; // datagram TDATA bit width

reg [C_CG_DATA_W-1:0] v_cdg_ram [0:8*G_CG_L-1];// = '{default: '0};

logic i_clk   = '1; // clock             ='0
reg [2:0] i_rst = '1; // reset, active-low 


/*

//??? //  AXI4 Memory Mapped (lite) Parameters to Define the Signal Widths:
/*???*/ //    N - Data Bus Width in Bytes;
/*???*/ //    A - Address Width;
/*???*/ //    PAYMASK - Payload Mask: { awprot, wstrb, bresp, arprot, rresp }
/*???*/ if_axil #(
			.N(G_RM_DATA_B), 
			.A(G_RM_ADDR_W)//, 
			//.PAYMASK(5'b01101)
		) s_axil (); // AXIL control interface (register map)


		if_axil #(
			.N(G_RM_DATA_B), 
			.A(G_RM_ADDR_W)//, 
			//.PAYMASK(5'b01101)
		) m_axil (); 


typedef logic [C_RM_DATA_W-1:0] t_xdata;
typedef logic [G_RM_ADDR_W-1:0] t_xaddr;

// initialize AXIL
task t_axil_init;
	begin
		s_axil.awvalid = '0;   //Write address valid
		s_axil.awaddr  = '0;   //Write address
		s_axil.wvalid  = '0;   //Write valid
		s_axil.wdata   = '0;   //Write data
		s_axil.wstrb   = '0;   //Write strobes. This signal indicates which byte lanes hold valid data
		s_axil.bready  = '0;   //Response ready. This signal indicates that the master can accept a write response
		s_axil.arvalid = '0;   //Read address valid
		s_axil.araddr  = '0;   //Read address
		s_axil.rready  = '0;   //Read ready
		s_axil.rresp   = '0;   //Read response
		
		s_axil.rdata   = '0;
		s_axil.awready = '1;
		s_axil.wready  = '1;
		s_axil.bvalid  = '1;
		s_axil.bresp   = 2'b00;
		s_axil.arready = '1;
		s_axil.rvalid  = '1;
		s_axil.rdata   = '0;      //delite comments??
	
		m_axil.awvalid = '0;   //Write address valid
		m_axil.awaddr  = '0;   //Write address
		m_axil.wvalid  = '0;   //Write valid
		m_axil.wdata   = '0;   //Write data
		m_axil.wstrb   = '0;   //Write strobes. This signal indicates which byte lanes hold valid data
		m_axil.bready  = '0;   //Response ready. This signal indicates that the master can accept a write response
		m_axil.arvalid = '0;   //Read address valid
		m_axil.araddr  = '0;   //Read address
		m_axil.rready  = '0;   //Read ready
		m_axil.rresp   = '0;   //Read response
		
		m_axil.rdata   = '0;
		m_axil.awready = '1;
		m_axil.wready  = '1;
		m_axil.bvalid  = '1;
		m_axil.bresp   = 2'b00;
		m_axil.arready = '1;
		m_axil.rvalid  = '1;
		m_axil.rdata   = '0;      //delite comments??
	end
endtask : t_axil_init

// AXIL basic handshake macro                ?????????????????????
`define MACRO_AXIL_HSK(miso, mosi) \
	s_axil.``mosi``= '1; \
	do begin \
		#T_CLK; \
	end while (!(s_axil.``miso`` && s_axil.``mosi``)); \
	s_axil.``mosi`` = '0; \

// AXIL write transaction
task t_axil_wr;
	input t_xaddr ADDR;
	input t_xdata DATA;
	begin
	// write address
		s_axil.awaddr = ADDR;
		`MACRO_AXIL_HSK(awready, awvalid);
	// write data
		s_axil.wdata = DATA;
		s_axil.wstrb = '1;
		`MACRO_AXIL_HSK(wready, wvalid);
	// write response
		`MACRO_AXIL_HSK(bvalid, bready);
	end
endtask : t_axil_wr

// AXIL read transaction
task t_axil_rd;
	input  t_xaddr ADDR;
//	output t_xdata DATA;
	begin
	// read address
		s_axil.araddr = ADDR;
		`MACRO_AXIL_HSK(arready, arvalid);
	// read data
		s_axil.rresp = 2'b00;
		`MACRO_AXIL_HSK(rvalid, rready);
//		DATA = s_axil.rdata;
	end
endtask : t_axil_rd


//                 ?????????????????

localparam t_xaddr RW_TRN_ENA = 'h000; // 0 - truncation enable
localparam t_xaddr WR_TRN_TBL = 'h008; // truncation table: 31:24 - scan mode id, 23:0 - max period?
localparam t_xaddr RW_GLU_ENA = 'h100; // 0 - gluing enable
localparam t_xaddr RW_GLU_OFS = 'h108; // 7:0 - gluing offset for SId#0, 15:8 - gluing offset for SId#1, etc
localparam t_xaddr RW_DWS_PRM = 'h200; // 15:8 - decimation phase, 7:0 - decimation factor





/////////////////////////////////////////////////////////////////
// simulate read/write AXIL transactions
initial begin
	t_axil_init; #150; 
	t_axil_rd(.ADDR(RW_TRN_ENA)); #10;
	t_axil_rd(.ADDR(WR_TRN_TBL)); #10;
	t_axil_rd(.ADDR(RW_GLU_ENA)); #10;
	t_axil_rd(.ADDR(RW_GLU_OFS)); #10;
	t_axil_rd(.ADDR(RW_DWS_PRM)); #10;
	
	t_axil_wr(.ADDR(RW_TRN_ENA), .DATA(1'b0)); #10; // 0 - truncation enable
	t_axil_wr(.ADDR(WR_TRN_TBL), .DATA({8'(0), 24'(625)})); #10; // truncation table: 31:24 - scan mode id, 23:0 - max period?
	t_axil_wr(.ADDR(RW_GLU_ENA), .DATA(1'b0)); #10; // 0 - gluing enable
//	t_axil_wr(.ADDR(RW_DWS_PRM), .DATA({8'(0), 8'(1)})); #10; // 15:8 - decimation phase, 7:0 - decimation factor
	
	t_axil_rd(.ADDR(RW_TRN_ENA)); #10;
	t_axil_rd(.ADDR(WR_TRN_TBL)); #10;
	t_axil_rd(.ADDR(RW_GLU_ENA)); #10;
	t_axil_rd(.ADDR(RW_GLU_OFS)); #10;
	t_axil_rd(.ADDR(RW_DWS_PRM)); #10;
end
///////////////////////////////////////////////////////////////////




//  AXI4-Stream Parameters to Define the Signal Widths:
//    N - Data Bus Width in Bytes;
//    I - TID Width. Recommended Maximum is 8-bits;
//    D - TDEST Width. Recommended Maximum is 4-bits;
//    U - TUSER Width. Recommended Number of Bits is an Integer Multiple of the Width of the Interface in Bytes.
//    PAYMASK - Payload Mask: { TDATA, TSTRB, TKEEP, TLAST }
if_axis #(.N(G_CG_DATA_B), .U(G_USER_W), .PAYMASK(4'b1001)) s_axis_cg (); // input codogram AXIS
if_axis #(.N(G_DG_DATA_B), .U(G_USER_W), .PAYMASK(4'b1001)) s_axis_dg (); // input datagram AXIS

// initialize AXIS
`define MACRO_AXIS_INIT(if_suffix) \
	s_axis_``if_suffix``.tvalid = '0; \
	s_axis_``if_suffix``.tlast  = '0; \
	s_axis_``if_suffix``.tdata  = '0; \
	s_axis_``if_suffix``.tuser  = '0; \
	s_axis_``if_suffix``.tready = '1; \

// AXIS handshake
`define MACRO_AXIS_HSK(if_suffix, value, sync_en, tlast_en) \
	s_axis_``if_suffix``.tvalid = '1; \
	s_axis_``if_suffix``.tlast  = ``tlast_en``; \
	s_axis_``if_suffix``.tdata  = ``value``; \
	s_axis_``if_suffix``.tuser  = ``sync_en``; \
	do begin \
		#T_CLK; \
	end while (!(s_axis_``if_suffix``.tvalid && s_axis_``if_suffix``.tready)); \
	s_axis_``if_suffix``.tvalid = '0; \
	s_axis_``if_suffix``.tlast  = '0; \
	s_axis_``if_suffix``.tuser  = '0; \
	v_``if_suffix``_cnt++; \

logic [C_CG_DATA_W-1:0] v_cg_data = '0;
logic [2*C_CG_DATA_W-1:0] v_dg_len  = '0;
int v_cg_cnt = 0;

task t_axis_cg;
	input int k;
	begin
		for (int i = 0; i < G_CG_L; i++) begin
			v_cg_data = v_cdg_ram[G_CG_L * k + i];
			`MACRO_AXIS_HSK(cg, v_cg_data, (i == 0), (i == G_CG_L-1));
			if (i == 40)
				v_dg_len = v_cg_data;
			else if (i == 41)
				v_dg_len = v_cg_data << C_CG_DATA_W | v_dg_len;
		end
	end
endtask : t_axis_cg

localparam int C_RX_CHAN_N = C_DG_DATA_W / 32; // number of Rx channels
logic [C_RX_CHAN_N-1:0][31:0] v_dg_data = '0;
int v_dg_cnt = 0;

task t_axis_dg;
	begin
		for (int n = 0; n < v_dg_len; n++) begin
			for (int j = 0; j < C_RX_CHAN_N; j++)
				v_dg_data[j] = C_RX_CHAN_N * n + j;
			`MACRO_AXIS_HSK(dg, v_dg_data, (n == 0), (n == v_dg_len-1));
			#(15*T_CLK);
		end
	end
endtask : t_axis_dg

// simulate codograms and datagrams
initial begin
	`MACRO_AXIS_INIT(cg);
	`MACRO_AXIS_INIT(dg); #500;
	for (int k = 0; k < 8; k++) begin
		t_axis_cg(k); #100;
		t_axis_dg; #100;
	end
	
end

axil_fifo #()
UUT_2(
	.i_fifo_rst_n (i_fifo_rst),

    .s_axi_aclk_p (i_clk  ),
    .m_axi_aclk_p (i_clk  ),

    .s_axi_arst_n (i_rst),
    .m_axi_arst_n (i_rst),

    .s_axi (s_axil),
    .m_axi (m_axil)
);

always #(T_CLK) i_clk <= ~i_clk;

endmodule : tb_axil_fifo

