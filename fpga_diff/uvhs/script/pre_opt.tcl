if {$current_fpga == "b0.f3"} {
set_false_path -to [get_pins part_3/xs_core_def/u_pcie_wrapper/inst/u_xilinx_pcie_phy_x4/inst/diablo_gt.diablo_gt_phy_wrapper/phy_rst_i/rst_n_internal*/CLR]
#set_false_path -to [get_nets part_3/xs_core_def/u_pcie_wrapper/inst/perst_n]
#set_false_path -to [get_pins part_3/xs_core_def/u_pcie_wrapper/inst/u_xilinx_pcie_phy_x4/phy_rst_n]
}
