`timescale 1ns / 1ps

module top_axi
#(
 parameter int G_MAX_DATA = 10,
 parameter int G_CNT_WIDTH = $ceil($clog2(G_MAX_DATA + 1)),
 parameter G_BYT = 1,
 parameter W = 8*G_BYT, // ns // TB constants
 parameter logic [G_CNT_WIDTH-1:0] G_LENGTH = G_MAX_DATA // LENGTH of data pack
 )
(
 input i_clk,
 input [2:0] i_rst,
// input i_rst_fif,
// input i_rst_src,
// input i_rst_snk,
// input s_data_src, 
// input s_valid_src,
//input s_ready_src,
 
 output o_good_top,
 output o_error_top
 );

if_axis #(.N(G_BYT)) sl_axis (); // создание интерфейса 
if_axis #(.N(G_BYT)) ms_axis ();

(* keep_hierarchy="yes" *) 
 axis_fifo #(
        .PACKET_MODE ("True"     ),     // Init packet_mode
        .RESET_SYNC  ("True"     ),     // Init reset_sync
        .FEATURES    (8'b01100111),     // Enable features from list: [ reserved, read count, prog. empty flag, almost empty, reserved, write count, prog. full flag, almost full flag ]
        .DEPTH       (256        ),     // Set Depth
        .PROG_FULL   (32         )      // Set prog. full
    ) AXIS_FIFO (
        .i_fifo_a_rst_n     (!i_rst[1]),

        .s_axis_a_clk_p     (i_clk),
        .s_axis_a_rst_n     ('1   ),

        .m_axis_a_clk_p     (i_clk),
        .m_axis_a_rst_n     ('1   ),
        
        .s_axis             (ms_axis),
        .m_axis             (sl_axis),

        .o_fifo_a_tfull     (o_fifo_a_tfull),     // Almost full flag
        .o_fifo_p_tfull     (o_fifo_p_tfull),     // Programmable full flag
        .o_fifo_w_count     (o_fifo_w_count),     // Write data count

        .o_fifo_a_empty     (o_fifo_a_empty),     // Almost empty flag
        .o_fifo_p_empty     (o_fifo_p_empty),     // Programmable empty flag
        .o_fifo_r_count     (o_fifo_r_count)      // Read data count, if dual clock mode is false - output count is the same with write data count

    );
  
   (* keep_hierarchy="yes" *) 
    source #(
        .G_BYT(G_BYT),
        .W (W)
        ) SOURCE
    (
        .i_rst   (i_rst [0]    ),  
        .i_clk   (i_clk        ), 
        .m_axis  (ms_axis      ),
        .Length  (G_LENGTH     )
        /*.s_data  (s_axis.tdata ),
        .s_valid (s_axis.tvalid),
        .s_ready (s_axis.tready),
        .s_last  (s_axis.tlast )*/
    );

   (* keep_hierarchy="yes" *) 
    sink #(
        .G_BYT(G_BYT),
        .W (W)
        ) SINK
    (
        .i_rst    (i_rst [2]    ),
        .i_clk    (i_clk        ),
        .s_axis   (sl_axis       ),
        /*.si_valid (m_axis.tvalid),
        .si_data  (m_axis.tdata ),
        .si_last  (m_axis.tlast ),
        .si_ready (m_axis.tready),*/
        .o_good   (o_good_top   ),
        .o_error  (o_error_top  )
    );

    //assign o_good = o_good_top;
    //assign o_error = o_error_top;

endmodule