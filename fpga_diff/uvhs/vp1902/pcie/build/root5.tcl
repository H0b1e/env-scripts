
set _srcdir [file dirname [file normalize [info script]]]
source [file join $_srcdir prelude.tcl]
source [file join $_srcdir hier5.tcl]
set _prjdir [file normalize [file join $_srcdir .. build_prj xdma_ep_1902]]
file delete -force $_prjdir
create_project xdma_ep_1902 $_prjdir -part xcvp1902-vsva6865-2MP-e-S
create_bd_design xdma_ep
create_hier_cell_qdma_0_support [get_bd_cells /] qdma_0_support
set xdma_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.2 xdma_0]
    set_property -dict [list \
      CONFIG.PF0_DEVICE_ID_mqdma {9048} \
      CONFIG.PF0_SRIOV_VF_DEVICE_ID {A048} \
      CONFIG.PF2_DEVICE_ID_mqdma {9248} \
      CONFIG.PF3_DEVICE_ID_mqdma {9348} \
      CONFIG.axi_data_width {256_bit} \
      CONFIG.axilite_master_en {true} \
      CONFIG.axilite_master_scale {Kilobytes} \
      CONFIG.axilite_master_size 512 \
      CONFIG.axisten_freq 125 \
      CONFIG.bar0_indicator {1} \
      CONFIG.bar1_indicator {0} \
      CONFIG.bar_indicator {BAR_0} \
      CONFIG.cfg_mgmt_if {false} \
      CONFIG.copy_pf0 {true} \
      CONFIG.dma_reset_source_sel {Phy_Ready} \
      CONFIG.en_gt_selection {true} \
      CONFIG.enable_gtwizard {false} \
      CONFIG.mode_selection {Advanced} \
      CONFIG.pcie_blk_locn S0X0Y0 \
      CONFIG.pf0_bar0_64bit {false} \
      CONFIG.pf0_bar0_enabled {true} \
      CONFIG.pf0_bar0_scale {Kilobytes} \
      CONFIG.pf0_bar0_size {128} \
      CONFIG.pf0_bar0_type_mqdma {DMA} \
      CONFIG.pf0_bar1_enabled true \
      CONFIG.pf0_bar1_scale {Kilobytes} \
      CONFIG.pf0_bar1_size {64} \
      CONFIG.pf0_bar1_type {Memory} \
      CONFIG.pf0_bar1_64bit {false} \
      CONFIG.pf0_bar1_prefetchable {false} \
      CONFIG.pf0_base_class_menu {Memory_controller} \
      CONFIG.pf0_base_class_menu_mqdma {Memory_controller} \
      CONFIG.pf0_class_code {058000} \
      CONFIG.pf0_class_code_base {05} \
      CONFIG.pf0_class_code_base_mqdma {05} \
      CONFIG.pf0_class_code_interface {00} \
      CONFIG.pf0_class_code_interface_mqdma {00} \
      CONFIG.pf0_class_code_mqdma {058000} \
      CONFIG.pf0_class_code_sub {80} \
      CONFIG.pf0_class_code_sub_mqdma {80} \
      CONFIG.pf0_device_id {9048} \
      CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
      CONFIG.pl_link_cap_max_link_width X4 \
      CONFIG.plltype {QPLL1} \
      CONFIG.runbit_fix {false} \
      CONFIG.select_quad GTH_Quad_128 \
      CONFIG.xdma_axi_intf_mm {AXI_Stream} \
    ] $xdma_0
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_interconnect_0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1} CONFIG.NUM_CLKS {2}] [get_bd_cells axi_interconnect_0]
set pcie_ep_gt_ref [create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_ep_gt_ref]
set pcie_mgt [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt]
set S00_AXIS_0 [create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S00_AXIS_0]
set_property -dict [list CONFIG.TDATA_NUM_BYTES {32} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1}] $S00_AXIS_0
set M00_AXIS_0 [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M00_AXIS_0]
set_property -dict [list CONFIG.TDATA_NUM_BYTES {32} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1}] $M00_AXIS_0
set XDMA_AXI_LITE [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 XDMA_AXI_LITE]
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.DATA_WIDTH {32}] $XDMA_AXI_LITE
set pcie_ep_perstn [create_bd_port -dir I -type rst pcie_ep_perstn]
set pcie_ep_lnk_up [create_bd_port -dir O pcie_ep_lnk_up]
set TO_DIFFTEST_PCIE_CLK [create_bd_port -dir O -type clk TO_DIFFTEST_PCIE_CLK]
set cpu_clk [create_bd_port -dir I -type clk -freq_hz 25000000 cpu_clk]
set_property CONFIG.ASSOCIATED_BUSIF {XDMA_AXI_LITE} [get_bd_ports cpu_clk]
proc IP {a b} { set rc [catch {connect_bd_intf_net [get_bd_intf_pins $a] [get_bd_intf_pins $b]} e]; if {$rc} { puts "IFAIL $a-$b" } }
proc PP {port pin} { set rc [catch {connect_bd_intf_net [get_bd_intf_ports $port] [get_bd_intf_pins $pin]} e]; if {$rc} { puts "PFAIL $port-$pin" } }
proc NN {args} { set objs {}; foreach a $args { if {[catch {lappend objs [get_bd_pins $a]}] } { lappend objs [get_bd_ports $a] } }; set rc [catch {connect_bd_net {*}$objs} e]; if {$rc} { puts "NFAIL $args" } }
IP qdma_0_support/m_axis_cq xdma_0/m_axis_cq
IP qdma_0_support/m_axis_rc xdma_0/m_axis_rc
IP qdma_0_support/s_axis_cc xdma_0/s_axis_cc
IP qdma_0_support/s_axis_rq xdma_0/s_axis_rq
IP qdma_0_support/pcie_cfg_interrupt xdma_0/pcie4_cfg_interrupt
IP qdma_0_support/pcie_cfg_fc xdma_0/pcie_cfg_fc
IP qdma_0_support/pcie_cfg_mesg_rcvd xdma_0/pcie4_cfg_mesg_rcvd
IP qdma_0_support/pcie_cfg_mesg_tx xdma_0/pcie4_cfg_mesg_tx
IP qdma_0_support/pcie_cfg_control xdma_0/pcie_cfg_control_if
IP qdma_0_support/pcie_cfg_status xdma_0/pcie_cfg_status_if
IP qdma_0_support/pcie_transmit_fc xdma_0/pcie_transmit_fc
PP pcie_ep_gt_ref qdma_0_support/pcie_refclk
PP pcie_mgt qdma_0_support/pcie_mgt
PP S00_AXIS_0 xdma_0/S_AXIS_C2H_0
PP M00_AXIS_0 xdma_0/M_AXIS_H2C_0
IP xdma_0/M_AXI_LITE axi_interconnect_0/S00_AXI
IP axi_interconnect_0/M00_AXI XDMA_AXI_LITE
NN pcie_ep_perstn qdma_0_support/sys_reset
NN qdma_0_support/user_lnk_up pcie_ep_lnk_up
NN qdma_0_support/user_clk xdma_0/user_clk_sd
NN xdma_0/axi_aclk TO_DIFFTEST_PCIE_CLK axi_interconnect_0/aclk
NN cpu_clk axi_interconnect_0/aclk1
NN xdma_0/axi_aresetn axi_interconnect_0/aresetn
puts "===VALIDATE==="
set rc [catch {validate_bd_design} e]
validate_bd_design
assign_bd_address
assign_bd_address -offset 0x00000000 -range 0x80000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs XDMA_AXI_LITE/Reg] -force
save_bd_design
write_bd_tcl -force [file join [file dirname $_prjdir] xdma_ep_regen.tcl]
puts "EXPORT-DONE"
puts "VALIDATE-RC=$rc"
