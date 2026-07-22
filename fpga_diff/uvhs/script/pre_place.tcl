if {$current_fpga == "b0.f3"} {
create_pblock pblock_u_xilinx_pcie_phy_x4
add_cells_to_pblock pblock_u_xilinx_pcie_phy_x4 [get_cells [list part_3/xs_core_def/u_pcie_wrapper/inst/u_xilinx_pcie_phy_x4]]
#resize_pblock pblock_u_xilinx_pcie_phy_x4 -add CLOCKREGION_X7Y16:CLOCKREGION_X8Y17
resize_pblock pblock_u_xilinx_pcie_phy_x4 -add CLOCKREGION_X6Y16:CLOCKREGION_X8Y18
}
