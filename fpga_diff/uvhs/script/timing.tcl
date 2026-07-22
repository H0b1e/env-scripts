create_clock -name soc_clk      -per 100    [get_ports fpga_top_debug.clk6_p]
#create_clock -name ddr_ref_clk 	-per 5  	[get_ports xs_fpga_top_debug.clk7_p]
create_clock -name pcie_refclk 	-per 10 	[get_ports fpga_top_debug.pcie_ep_gt_ref_clk_p]
create_clock -name phy_pclk 	-per 8 	[get_pins fpga_top_debug.core_def.xdma_ep_i.TO_DIFFTEST_PCIE_CLK]

##DDR4 output clock begin
#create_clock -name soc_clk -per 20 [get_pins xs_fpga_top_debug.xs_core_def.U_JTAG_DDR_SUBSYS.SOC_CLK]
#create_clock -name soc_clk -per 20 [get_pins xs_core_def/U_JTAG_DDR_SUBSYS/jtag_ddr_subsys_i/SOC_CLK ]
#create_clock -name mac_clk -per 20 [get_pins xs_core_def/U_JTAG_DDR_SUBSYS/jtag_ddr_subsys_i/MAC_CLK]

#set_clock_groups -asynchronous -name async_group1 -group [get_clocks jtag_vclk -include_generated_clocks]
#set_clock_groups -asynchronous -name async_group2 -group [get_clocks -include_generated_clocks CPU_CLK_IN] -group [get_clocks -include_generated_clocks TMCLK]
#set_clock_groups -asynchronous -name async_group3 -group [get_clocks -include_generated_clocks CPU_CLK_IN] -group [get_clocks -include_generated_clocks DEBUG_CLK_IN]
#set_clock_groups -asynchronous -name async_group4 -group [get_clocks -include_generated_clocks TMCLK] -group [get_clocks -include_generated_clocks DEBUG_CLK_IN]

set_clock_groups -asynchronous -name async_group1 \
	-group [get_clocks -include_generated_clocks soc_clk] \
	-group [get_clocks -include_generated_clocks phy_pclk] \
	-group [get_clocks -include_generated_clocks pcie_refclk]
#	-group [get_clocks -include_generated_clocks ddr_ref_clk]

#set_false_path -from [get_ports clk2] -to [get_pins {xs_core_def/u_icn/onchip_subsys/rtcTick_reg[0]/D}]

#set_clock_groups -asynchronous -name asyn_group0 -group {clk2} -group {clk7} -group {clk6} -group {clk5} -group {JTAG_TCK} -group {ddr4_soc_clk}
#set_clock_groups -asynchronous -group [get_clocks clk7]
#set_clock_groups -asynchronous -group [get_clocks clk6]
#set_clock_groups -asynchronous -group [get_clocks clk5]
#set_clock_groups -asynchronous -group [get_clocks JTAG_TCK]
#set_clock_groups -asynchronous -group [get_clocks ddr4_soc_clk]
#set_clock_groups -asynchronous -group [get_clocks ddr4_mac_clk]
#set_clock_groups -asynchronous -group [get_clocks UART_CLK]


#create_clock -name chipset_clk -per 20  [get_pins system.chipset.clk_mmcm.chipset_clk] ; #support [get_net system.clk]
#create_clock -name sd_sys_clk  -per 125 [get_pins system.chipset.clk_mmcm.sd_sys_clk]
#create_clock -name ui_clk      -per 10  [get_pins system.chipset.chipset_impl.mc_top.i_ddr4_0.c0_ddr4_ui_clk]
#set_input_delay 10 -clock [get_clocks chipset_clk] [all_inputs]
#set_output_delay 0 -clock [get_clocks chipset_clk] [all_outputs]
#set_input_delay -add_delay 10 -clock [get_clocks sd_sys_clk] [all_inputs]
#set_output_delay -add_delay 0 -clock [get_clocks sd_sys_clk] [all_outputs]
#set_input_delay -add_delay 10 -clock [get_clocks ui_clk] [all_inputs]
#set_output_delay -add_delay 0 -clock [get_clocks ui_clk] [all_outputs]
##set_false_path -to [get_cells -hierarchical *afifo_ui_rst_r*]
##set_false_path -to [get_cells -hierarchical *ui_clk_sync_rst_r*]
##set_false_path -to [get_cells -hierarchical *ui_clk_syn_rst_delayed*]
##set_false_path -to [get_cells -hierarchical *init_calib_complete_f*]
##set_false_path -to [get_cells -hierarchical *chipset_rst_n*]
##set_false_path -to [get_cells chipset/chipset_impl/mc_top/afifo_ui_rst_r_r_reg chipset/chipset_impl/mc_top/afifo_ui_rst_r_reg]
##set_clock_groups -logically_exclusive -group [get_clocks {sd_fast_clk sd_clk_out}] -group [get_clocks {sd_slow_clk sd_clk_out_1}]


