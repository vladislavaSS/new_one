`timescale 1ns / 1ps

interface if_axis #(parameter int N = 1) ();

  localparam W = 8 * N; // TDATA bit width (N - number of bytes)
  
  logic         tready;
  logic         tvalid;
  logic         tlast ;
  logic [W-1:0] tdata ;
  
endinterface

module top_axi
#(
 parameter G_BYT = 1,
 parameter W = 8*G_BYT) // ns // TB constants
  
(
 input i_clk,
 input i_rst_fif,
 input i_rst_src,
 input i_rst_snk,
 input s_data_src, 
 input s_valid_src,
 //input s_ready_src,
 
 output o_good_top,
 output o_error_top
 );

if_axis #(.N(G_BYT)) s_axis (); // создание интерфейса 
if_axis #(.N(G_BYT)) m_axis ();

axis_data_fifo_0 FIFO (
<<<<<<< HEAD
		.s_axis_aresetn     (i_rst_fif), // input wire s_axis_aresetn
		.s_axis_aclk        (i_aclk),    // input wire s_axis_aclk
		
		.s_axis_tready      (s_axis.tready), // output wire s_axis_tready
		.s_axis_tvalid      (s_axis_tvali), // input wire s_axis_tvalid
		.s_axis_tlast       (s_axis.tlast ), // input wire s_axis_tlast
		.s_axis_tdata       (s_axis_tdata), // input wire [7 : 0] s_axis_tdata
		
		.m_axis_tready      (m_axis.tready), // input wire m_axis_tready
		.m_axis_tvalid      (m_axis.tvalid), // output wire m_axis_tvalid
		.m_axis_tlast       (m_axis.tlast ), // output wire m_axis_tlast
		.m_axis_tdata       (m_axis.tdata ), // output wire [7 : 0] m_axis_tdata
		
		.axis_wr_data_count (             ), // output wire [31 : 0] axis_wr_data_count
		.axis_rd_data_count (             ), // output wire [31 : 0] axis_rd_data_count
		.prog_empty         (             ), // output wire prog_empty
		.prog_full          (             )  // output wire prog_full
	);
	
=======
    .s_axis_aresetn     (i_rst_fif), // input wire s_axis_aresetn
    .s_axis_aclk        (i_aclk),    // input wire s_axis_aclk
    
    .s_axis_tready      (s_axis.tready), // output wire s_axis_tready
    .s_axis_tvalid      (s_axis.tvalid), // input wire s_axis_tvalid
    .s_axis_tlast       (s_axis.tlast ), // input wire s_axis_tlast
    .s_axis_tdata       (s_axis.tdata ), // input wire [7 : 0] s_axis_tdata
    
    .m_axis_tready      (m_axis.tready), // input wire m_axis_tready
    .m_axis_tvalid      (m_axis.tvalid), // output wire m_axis_tvalid
    .m_axis_tlast       (m_axis.tlast ), // output wire m_axis_tlast
    .m_axis_tdata       (m_axis.tdata ), // output wire [7 : 0] m_axis_tdata
    
    .axis_wr_data_count (             ), // output wire [31 : 0] axis_wr_data_count
    .axis_rd_data_count (             ), // output wire [31 : 0] axis_rd_data_count
    .prog_empty         (             ), // output wire prog_empty
    .prog_full          (             )  // output wire prog_full
  );
  
>>>>>>> 2f9bf84091cd5df42bf9d792ee2f5db05c601083
    source #(
        .G_BYT(G_BYT),
        .W (W)
        ) SOURCE
    (
        .i_rst (i_rst_src),  
        .i_clk (i_clk),  
        .s_data (s_axis.tdata),
        .s_valid (s_axis.tvalid),
        .s_ready (s_axis.tready)
        
        //.m_valid (s_axis.tvalid)
        //.m_data (s_axis.tdata)
    );

    sink #(
        .G_BYT(G_BYT),
        .W (W)
        ) SINK
    (
        .i_rst (i_rst_snk),
        .i_clk (i_clk),
        .si_valid(m_axis.tvalid),
        .si_data (m_axis.tdata ),
        .si_ready(m_axis.tready),
        .o_good(o_good_top),
        .o_error(o_error_top)
    );

    assign o_good = o_good_top;
    assign o_error = o_error_top;

endmodule