set_property PACKAGE_PIN E15 [get_ports {o_led[0]}]
set_property PACKAGE_PIN D15 [get_ports {o_led[1]}]
set_property PACKAGE_PIN W17 [get_ports {o_led[2]}]
set_property PACKAGE_PIN W5 [get_ports {o_led[3]}]
set_property PACKAGE_PIN V7 [get_ports {o_led_2[4]}]
set_property PACKAGE_PIN W10 [get_ports {o_led_2[5]}]
set_property PACKAGE_PIN P18 [get_ports {o_led_2[6]}]
set_property PACKAGE_PIN P17 [get_ports {o_led_2[7]}]

set_property PACKAGE_PIN G19 [get_ports {i_rst[0]}]
set_property PACKAGE_PIN F19 [get_ports {i_rst[1]}]

set_property IOSTANDARD LVCMOS25 [get_ports {o_led_2[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led_2[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led_2[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led_2[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_led[0]}]

set_property IOSTANDARD LVCMOS25 [get_ports {i_rst[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {i_rst[1]}]

set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports i_clk_p]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports i_clk_n]

set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS25} [get_ports i_sel[1]]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS25} [get_ports i_sel[0]]