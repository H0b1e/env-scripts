# Async-clock constraints applied after infer_clock in the backend flow.
# Each query is quiet so the script remains valid when an optional IP clock
# is absent from a particular FPGA partition.

set cpu_clocks [concat \
    [get_clocks -quiet CPU_CLK_IN] \
    [get_clocks -quiet SOC_GATED_CLK]]
set ddr_clocks [concat \
    [get_clocks -quiet DDR_UI_CLK] \
    [get_clocks -quiet *c0_ddr4_ui_clk*] \
    [get_clocks -quiet *ddr4_ui_clk*] \
    [get_clocks -quiet mmcm_clkout*] \
    [get_clocks -quiet pll_clk*]]
set pcie_ref_clocks [concat \
    [get_clocks -quiet pcie_ep_refclk] \
    [get_clocks -quiet pcie_refclk]]
set pcie_gt_clocks [concat \
    [get_clocks -quiet qpll*outrefclk*] \
    [get_clocks -quiet qpll*outclk*] \
    [get_clocks -quiet GTYE4_CHANNEL_TXOUTCLK*] \
    [get_clocks -quiet */GTYE4_CHANNEL_PRIM_INST/TXOUTCLK] \
    [get_clocks -quiet *bufg_gt_txoutclkmon_inst/O] \
    [get_clocks -quiet xdma_ep_xdma_0_0_pcie4c_ip_gt_top_i_n_*]]
set xdma_pipe_clocks [concat \
    [get_clocks -quiet pipe_clk] \
    [get_clocks -quiet */xdma_ep_i/xdma_0/inst/pcie4c_ip_i/inst/*/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]]
set xdma_axi_clocks [concat \
    [get_clocks -quiet M00_AXIS_ACLK*] \
    [get_clocks -quiet XDMA_AXI_ACLK] \
    [get_clocks -quiet difftest_pcie_clock_bufg_n] \
    [get_clocks -quiet core_def_xdma_ep_i_TO_DIFFTEST_PCIE_CLK_infer] \
    [get_clocks -quiet *TO_DIFFTEST_PCIE_CLK*infer*]]
set difftest_pcie_clocks [concat \
    [get_clocks -quiet DIFFTEST_PCIE_CLK] \
    [get_clocks -quiet clk_out*_xdma_ep_clk_wiz*]]
set sbus_readback_clocks [concat \
    [get_clocks -quiet uvw_sbus_sysclk0] \
    [get_clocks -quiet s_clk_out1]]
set sbus_readback_pins [concat \
    [get_pins -quiet -hierarchical -filter {NAME =~ *U_UVHS_UVW_AXI4_TO_DDR4/u_uvw_axi4_to_ddr4/u_sbus_bridge*/u_sbus3_ip_intf/u_uvw_ur_alp_if/u_uvw_sbus_alp_if_regs/reg_rd_data_reg*/D}] \
    [get_pins -quiet -hierarchical -filter {NAME =~ *u_sbus_bridge*/u_sbus3_ip_intf/u_uvw_ur_alp_if/u_uvw_sbus_alp_if_regs/reg_rd_data_reg*/D}]]

# Top-level external clock domains are independent.
set external_domains [list \
    [list cpu $cpu_clocks] \
    [list ddr $ddr_clocks] \
    [list pcie_ref $pcie_ref_clocks]]
for {set i 0} {$i < [llength $external_domains]} {incr i} {
    set from_domain [lindex $external_domains $i]
    set from_clocks [lindex $from_domain 1]
    for {set j [expr {$i + 1}]} {$j < [llength $external_domains]} {incr j} {
        set to_domain [lindex $external_domains $j]
        set to_clocks [lindex $to_domain 1]
        if {[llength $from_clocks] && [llength $to_clocks]} {
            puts "INFO: async clocks [lindex $from_domain 0] <-> [lindex $to_domain 0]"
            set_false_path -from $from_clocks -to $to_clocks
            set_false_path -from $to_clocks -to $from_clocks
        }
    }
}

# XDMA AXI logic is asynchronous to external board clocks and GT/pipe clocks.
set external_clocks [concat \
    $cpu_clocks $ddr_clocks $pcie_ref_clocks]
set gt_pipe_clocks [concat $pcie_gt_clocks $xdma_pipe_clocks]

if {[llength $xdma_axi_clocks] && [llength $external_clocks]} {
    set_false_path -from $xdma_axi_clocks -to $external_clocks
    set_false_path -from $external_clocks -to $xdma_axi_clocks
}
if {[llength $difftest_pcie_clocks] && [llength $xdma_axi_clocks]} {
    set_false_path -from $difftest_pcie_clocks -to $xdma_axi_clocks
    set_false_path -from $xdma_axi_clocks -to $difftest_pcie_clocks
    set_clock_groups -asynchronous \
        -group $difftest_pcie_clocks \
        -group $xdma_axi_clocks
}
if {[llength $xdma_axi_clocks] && [llength $gt_pipe_clocks]} {
    set_false_path -from $xdma_axi_clocks -to $gt_pipe_clocks
    set_false_path -from $gt_pipe_clocks -to $xdma_axi_clocks
    set_clock_groups -asynchronous \
        -group $xdma_axi_clocks \
        -group $gt_pipe_clocks
}
if {[llength $sbus_readback_clocks] && [llength $sbus_readback_pins]} {
    set_false_path -from $sbus_readback_clocks -to $sbus_readback_pins
}
