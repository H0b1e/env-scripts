#set_false_path -from [get_pins -hierarchical -filter {NAME =~ *axi4_to_ddr4_design_1_wrapper_987cukl/design_1_i/ddr4_0/inst/u_ddr4_mem_intfc/u_ddr_cal_top/calDone_gated_reg/C}]
#set_false_path -to   [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_regm_rst*/D}]
#set_false_path -to   [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_stream_rst*/D}]
#set_false_path -from [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_regm_rst*/C}]
#set_false_path -from [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_stream_rst*/C}]
#set_false_path -to   [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_regm_rst*/PRE}]
#set_false_path -to   [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_stream_rst*/PRE}]
#set_false_path -to   [get_pins -hierarchical -filter {NAME =~ *ddr4ip_dut_axi_aresetn_2ff*/D}]
#set_false_path -from [get_pins -hierarchical -filter {NAME =~ *ddr4_reg/r_bus_clear_reg/C}]
##################
#
#   foreach pin_names [get_pins                                                        ]{ puts " set_false_path -to \[get_pins $pin_names\] "}
#   foreach pin_names [get_pins -hierarchical -filter {NAME =~ *ddr4_clk/r_regm_rst*/D}]{ puts " set_false_path -to \[get_pins $pin_names\] "}
#
##################
#set_false_path -from [get_pins u_uvw_axi4_to_ddr4_design_1_wrapper_987cukl/design_1_i/ddr4_0/inst/u_ddr4_mem_intfc/u_ddr_cal_top/calDone_gated_reg/C]

set_false_path -from [get_pins u_uvw_axi4_to_ddr4_secondary_top/u_uvw_axi4_to_ddr4_design_1_wrapper_987cukl/design_1_i/ddr4_pl_0/inst/u_ddr4_mem_intfc/u_ddr_mc_cal/calDone_gated_reg/C]

set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[0]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[1]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[2]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[3]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[4]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[5]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[6]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[7]/D}]

set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[0]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[1]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[2]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[3]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[4]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[5]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[6]/D}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[7]/D}]

set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[0]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[1]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[2]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[3]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[4]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[5]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[6]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[7]/C}]

set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[0]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[1]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[2]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[3]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[4]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[5]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[6]/C}]
set_false_path -from [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[7]/C}]

set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[0]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[1]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[2]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[3]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[4]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[5]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[6]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_regm_rst_reg[7]/PRE}]

set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[0]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[1]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[2]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[3]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[4]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[5]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[6]/PRE}]
set_false_path -to [get_pins {u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_clk/r_stream_rst_reg[7]/PRE}]

set_false_path -to [get_pins u_uvw_axi4_to_ddr4_secondary_top/ddr4ip_dut_axi_aresetn_2ff_reg/D]

set_false_path -from [get_pins u_uvw_axi4_to_ddr4_secondary_top/u_ddr4_reg/r_bus_clear_reg/C]

