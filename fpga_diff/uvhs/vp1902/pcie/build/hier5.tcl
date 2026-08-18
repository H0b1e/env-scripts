proc create_hier_cell_qdma_0_support { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_qdma_0_support() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_cq

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_cfg_fc_rtl:1.1 pcie_cfg_fc

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_interrupt_rtl:1.0 pcie_cfg_interrupt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_msg_received_rtl:1.0 pcie_cfg_mesg_rcvd

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_mesg_tx_rtl:1.0 pcie_cfg_mesg_tx

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_cc

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rq

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie5_cfg_control_rtl:1.0 pcie_cfg_control

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_msix_rtl:1.0 pcie_cfg_external_msix_without_msi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_mgmt_rtl:1.0 pcie_cfg_mgmt

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie5_cfg_status_rtl:1.0 pcie_cfg_status

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_transmit_fc_rtl:1.0 pcie_transmit_fc


  # Create pins
  create_bd_pin -dir I -type rst sys_reset
  create_bd_pin -dir O phy_rdy_out
  create_bd_pin -dir O -type clk user_clk
  create_bd_pin -dir O user_lnk_up
  create_bd_pin -dir O -type rst user_reset

  # Create instance: pcie, and set properties
  set pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_versal:1.1 pcie ]
  set_property -dict [list \
    CONFIG.AXISTEN_IF_CQ_ALIGNMENT_MODE {Address_Aligned} \
    CONFIG.AXISTEN_IF_RQ_ALIGNMENT_MODE {DWORD_Aligned} \
    CONFIG.MSI_X_OPTIONS {MSI-X_External} \
    CONFIG.PF0_AER_CAP_ECRC_GEN_AND_CHECK_CAPABLE {false} \
    CONFIG.PF0_DEVICE_ID {B048} \
    CONFIG.PF0_INTERRUPT_PIN {INTA} \
    CONFIG.PF0_LINK_STATUS_SLOT_CLOCK_CONFIG {true} \
    CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF0_MSIX_CAP_PBA_OFFSET {34000} \
    CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {30000} \
    CONFIG.PF0_MSIX_CAP_TABLE_SIZE {007} \
    CONFIG.PF0_REVISION_ID {00} \
    CONFIG.PF0_SRIOV_VF_DEVICE_ID {C048} \
    CONFIG.PF0_SUBSYSTEM_ID {0007} \
    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF0_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF1_DEVICE_ID {913F} \
    CONFIG.PF1_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF1_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF1_MSI_CAP_MULTIMSGCAP {1_vector} \
    CONFIG.PF1_REVISION_ID {00} \
    CONFIG.PF1_SUBSYSTEM_ID {0007} \
    CONFIG.PF1_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF1_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF2_DEVICE_ID {B248} \
    CONFIG.PF2_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF2_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF2_MSI_CAP_MULTIMSGCAP {1_vector} \
    CONFIG.PF2_REVISION_ID {00} \
    CONFIG.PF2_SUBSYSTEM_ID {0007} \
    CONFIG.PF2_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF2_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF3_DEVICE_ID {B348} \
    CONFIG.PF3_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF3_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF3_MSI_CAP_MULTIMSGCAP {1_vector} \
    CONFIG.PF3_REVISION_ID {00} \
    CONFIG.PF3_SUBSYSTEM_ID {0007} \
    CONFIG.PF3_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF3_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PL_DISABLE_LANE_REVERSAL {TRUE} \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {16.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
    CONFIG.REF_CLK_FREQ {100_MHz} \
    CONFIG.SRIOV_CAP_ENABLE {false} \
    CONFIG.TL_PF_ENABLE_REG {1} \
    CONFIG.VFG0_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.VFG0_MSIX_CAP_PBA_OFFSET {4800} \
    CONFIG.VFG0_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.VFG0_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.VFG0_MSIX_CAP_TABLE_SIZE {007} \
    CONFIG.VFG1_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.VFG2_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.VFG3_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.acs_ext_cap_enable {false} \
    CONFIG.all_speeds_all_sides {NO} \
    CONFIG.axisten_freq {250} \
    CONFIG.axisten_if_enable_client_tag {true} \
    CONFIG.axisten_if_enable_msg_route {1EFFF} \
    CONFIG.axisten_if_enable_msg_route_override {true} \
    CONFIG.axisten_if_width {512_bit} \
    CONFIG.cfg_ext_if {false} \
    CONFIG.cfg_mgmt_if {true} \
    CONFIG.copy_pf0 {true} \
    CONFIG.dedicate_perst {false} \
    CONFIG.device_port_type {PCI_Express_Endpoint_device} \
    CONFIG.en_dbg_descramble {false} \
    CONFIG.en_ext_clk {FALSE} \
    CONFIG.en_l23_entry {false} \
    CONFIG.en_parity {false} \
    CONFIG.en_transceiver_status_ports {false} \
    CONFIG.enable_auto_rxeq {False} \
    CONFIG.enable_ccix {FALSE} \
    CONFIG.enable_code {0000} \
    CONFIG.enable_dvsec {FALSE} \
    CONFIG.enable_gen4 {true} \
    CONFIG.enable_gtwizard {false} \
    CONFIG.enable_ibert {false} \
    CONFIG.enable_jtag_dbg {false} \
    CONFIG.enable_more_clk {false} \
    CONFIG.enable_replay_bram {false} \
    CONFIG.ext_pcie_cfg_space_enabled {false} \
    CONFIG.extended_tag_field {true} \
    CONFIG.insert_cips {false} \
    CONFIG.lane_order {Bottom} \
    CONFIG.legacy_ext_pcie_cfg_space_enabled {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_blk_locn {S0X0Y2} \
    CONFIG.pcie_link_debug {false} \
    CONFIG.pcie_link_debug_axi4_st {false} \
    CONFIG.pf0_ari_enabled {false} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_enabled {true} \
    CONFIG.pf0_bar0_prefetchable {false} \
    CONFIG.pf0_bar0_scale {Kilobytes} \
    CONFIG.pf0_bar0_size {256} \
    CONFIG.pf0_bar2_64bit {true} \
    CONFIG.pf0_bar2_enabled {true} \
    CONFIG.pf0_bar2_prefetchable {false} \
    CONFIG.pf0_bar2_scale {Kilobytes} \
    CONFIG.pf0_bar2_size {4} \
    CONFIG.pf0_bar2_type {Memory} \
    CONFIG.pf0_bar4_enabled {false} \
    CONFIG.pf0_bar5_enabled {false} \
    CONFIG.pf0_base_class_menu {Memory_controller} \
    CONFIG.pf0_class_code_base {05} \
    CONFIG.pf0_class_code_interface {00} \
    CONFIG.pf0_class_code_sub {80} \
    CONFIG.pf0_dll_feature_cap_enabled {true} \
    CONFIG.pf0_expansion_rom_enabled {false} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_pl32_cap_enabled {false} \
    CONFIG.pf0_sriov_bar0_64bit {true} \
    CONFIG.pf0_sriov_bar0_enabled {true} \
    CONFIG.pf0_sriov_bar0_prefetchable {true} \
    CONFIG.pf0_sriov_bar0_scale {Kilobytes} \
    CONFIG.pf0_sriov_bar0_size {32} \
    CONFIG.pf0_sriov_bar2_64bit {true} \
    CONFIG.pf0_sriov_bar2_enabled {true} \
    CONFIG.pf0_sriov_bar2_prefetchable {true} \
    CONFIG.pf0_sriov_bar2_scale {Kilobytes} \
    CONFIG.pf0_sriov_bar2_size {4} \
    CONFIG.pf0_sriov_bar2_type {Memory} \
    CONFIG.pf0_sriov_bar4_enabled {false} \
    CONFIG.pf0_sriov_bar5_enabled {false} \
    CONFIG.pf0_sriov_bar5_prefetchable {false} \
    CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_base_class_menu {Memory_controller} \
    CONFIG.pf1_class_code_base {05} \
    CONFIG.pf1_class_code_interface {00} \
    CONFIG.pf1_class_code_sub {80} \
    CONFIG.pf1_msix_enabled {true} \
    CONFIG.pf1_sriov_bar5_prefetchable {false} \
    CONFIG.pf1_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_vendor_id {10EE} \
    CONFIG.pf2_base_class_menu {Memory_controller} \
    CONFIG.pf2_class_code_base {05} \
    CONFIG.pf2_class_code_interface {00} \
    CONFIG.pf2_class_code_sub {80} \
    CONFIG.pf2_msix_enabled {true} \
    CONFIG.pf2_sriov_bar5_prefetchable {false} \
    CONFIG.pf2_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf2_vendor_id {10EE} \
    CONFIG.pf3_base_class_menu {Memory_controller} \
    CONFIG.pf3_class_code_base {05} \
    CONFIG.pf3_class_code_interface {00} \
    CONFIG.pf3_class_code_sub {80} \
    CONFIG.pf3_msix_enabled {true} \
    CONFIG.pf3_sriov_bar5_prefetchable {false} \
    CONFIG.pf3_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf3_vendor_id {10EE} \
    CONFIG.pipe_line_stage {2} \
    CONFIG.pipe_sim {false} \
    CONFIG.replace_uram_with_bram {false} \
    CONFIG.sys_reset_polarity {ACTIVE_LOW} \
    CONFIG.userclk2_freq {500} \
    CONFIG.vendor_id {10EE} \
    CONFIG.vfg0_msix_enabled {true} \
    CONFIG.warm_reboot_sbr_fix {false} \
    CONFIG.xlnx_ref_board {None} \
  ] $pcie


  # Create instance: pcie_phy, and set properties
  # Match the xdma split-side interface: 256-bit CQ/RC/CC/RQ and the same
  # alignment modes (CQ address-aligned, RQ dword-aligned).
  set_property -dict [list CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} CONFIG.axisten_if_width {256_bit} CONFIG.AXISTEN_IF_CQ_ALIGNMENT_MODE {Address_Aligned}] [get_bd_cells pcie]
  set pcie_phy [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_phy_versal:1.1 pcie_phy ]
  set_property -dict [list \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {16.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
    CONFIG.aspm {No_ASPM} \
    CONFIG.async_mode {SRNS} \
    CONFIG.disable_double_pipe {YES} \
    CONFIG.en_gt_pclk {false} \
    CONFIG.enable_gtwizard {false} \
    CONFIG.ins_loss_profile {Add-in_Card} \
    CONFIG.lane_order {Bottom} \
    CONFIG.lane_reversal {false} \
    CONFIG.phy_async_en {true} \
    CONFIG.phy_coreclk_freq {500_MHz} \
    CONFIG.phy_refclk_freq {100_MHz} \
    CONFIG.phy_userclk2_freq {500_MHz} \
    CONFIG.phy_userclk_freq {250_MHz} \
    CONFIG.pipeline_stages {2} \
    CONFIG.sim_model {NO} \
    CONFIG.tx_preset {4} \
  ] $pcie_phy
  set_property -dict [list CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4}] [get_bd_cells pcie_phy]


  # Create instance: const_1b1, and set properties
  set const_1b1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_1b1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
    CONFIG.CONST_WIDTH {1} \
  ] $const_1b1


  # Create instance: const_1b0, and set properties
  set const_1b0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_1b0 ]

  # Create instance: bufg_gt_sysclk, and set properties
  set bufg_gt_sysclk [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 bufg_gt_sysclk ]
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] $bufg_gt_sysclk


  # Create instance: refclk_ibuf, and set properties
  set refclk_ibuf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 refclk_ibuf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $refclk_ibuf


  # Create instance: gt_quad_0, and set properties
  set gt_quad_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gt_quad_base:1.1 gt_quad_0 ]
  set_property -dict [list \
    CONFIG.APB3_CLK_FREQUENCY {200.0} \
    CONFIG.CHANNEL_ORDERING {/qdma_0_support/gt_quad_0/TX0_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_TX0.0 /qdma_0_support/gt_quad_0/TX1_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_TX1.1\
/qdma_0_support/gt_quad_0/TX2_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_TX2.2 /qdma_0_support/gt_quad_0/TX3_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_TX3.3 /qdma_0_support/gt_quad_0/RX0_GT_IP_Interface\
qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_RX0.0 /qdma_0_support/gt_quad_0/RX1_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_RX1.1 /qdma_0_support/gt_quad_0/RX2_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_RX2.2\
/qdma_0_support/gt_quad_0/RX3_GT_IP_Interface qdma_ep_pcie_phy_0./qdma_0_support/pcie_phy/GT_RX3.3} \
    CONFIG.GT_TYPE {GTYP} \
    CONFIG.PORTS_INFO_DICT {LANE_SEL_DICT {PROT0 {RX0 RX1 RX2 RX3 TX0 TX1 TX2 TX3}} GT_TYPE GTYP REG_CONF_INTF APB3_INTF BOARD_PARAMETER { }} \
    CONFIG.PROT0_ENABLE {true} \
    CONFIG.PROT0_GT_DIRECTION {DUPLEX} \
    CONFIG.PROT0_LR0_SETTINGS {GT_DIRECTION DUPLEX TX_PAM_SEL NRZ TX_HD_EN 0 TX_GRAY_BYP true TX_GRAY_LITTLEENDIAN true TX_PRECODE_BYP true TX_PRECODE_LITTLEENDIAN false TX_LINE_RATE 2.5 TX_PLL_TYPE LCPLL\
TX_REFCLK_FREQUENCY 100 TX_ACTUAL_REFCLK_FREQUENCY 100.000000000000 TX_FRACN_ENABLED false TX_FRACN_OVRD false TX_FRACN_NUMERATOR 0 TX_REFCLK_SOURCE R0 TX_DATA_ENCODING 8B10B TX_USER_DATA_WIDTH 16 TX_INT_DATA_WIDTH\
20 TX_BUFFER_MODE 0 TX_BUFFER_BYPASS_MODE Fast_Sync TX_PIPM_ENABLE false TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TXPROGDIV_FREQ_VAL 500.000 TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_64B66B_SCRAMBLER false TX_64B66B_ENCODER false TX_64B66B_CRC false TX_RATE_GROUP A TX_LANE_DESKEW_HDMI_ENABLE false TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE GT_TYPE GTYP PRESET None RX_PAM_SEL NRZ\
RX_HD_EN 0 RX_GRAY_BYP true RX_GRAY_LITTLEENDIAN true RX_PRECODE_BYP true RX_PRECODE_LITTLEENDIAN false INTERNAL_PRESET None XPU_MODE 0 RX_LINE_RATE 2.5 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 100 RX_ACTUAL_REFCLK_FREQUENCY\
100.000000000000 RX_FRACN_ENABLED false RX_FRACN_OVRD false RX_FRACN_NUMERATOR 0 RX_REFCLK_SOURCE R0 RX_DATA_DECODING 8B10B RX_USER_DATA_WIDTH 16 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RXPROGDIV_FREQ_ENABLE false RXPROGDIV_FREQ_SOURCE LCPLL RXPROGDIV_FREQ_VAL 125.000000 RXRECCLK_FREQ_ENABLE false RXRECCLK_FREQ_VAL 0 INS_LOSS_NYQ 20 RX_EQ_MODE LPM RX_COUPLING AC RX_TERMINATION\
PROGRAMMABLE RX_RATE_GROUP A RX_TERMINATION_PROG_VALUE 800 RX_PPM_OFFSET 0 RX_64B66B_DESCRAMBLER false RX_64B66B_DECODER false RX_64B66B_CRC false OOB_ENABLE true RX_COMMA_ALIGN_WORD 1 RX_COMMA_SHOW_REALIGN_ENABLE\
true PCIE_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_M_ENABLE true RX_COMMA_DOUBLE_ENABLE false RX_COMMA_P_VAL 1010000011 RX_COMMA_M_VAL 0101111100 RX_COMMA_MASK 1111111111 RX_SLIDE_MODE OFF RX_SSC_PPM\
0 RX_CB_NUM_SEQ 0 RX_CB_LEN_SEQ 1 RX_CB_MAX_SKEW 1 RX_CB_MAX_LEVEL 1 RX_CB_MASK 00000000 RX_CB_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CB_K 00000000 RX_CB_DISP\
00000000 RX_CB_MASK_0_0 false RX_CB_VAL_0_0 00000000 RX_CB_K_0_0 false RX_CB_DISP_0_0 false RX_CB_MASK_0_1 false RX_CB_VAL_0_1 00000000 RX_CB_K_0_1 false RX_CB_DISP_0_1 false RX_CB_MASK_0_2 false RX_CB_VAL_0_2\
00000000 RX_CB_K_0_2 false RX_CB_DISP_0_2 false RX_CB_MASK_0_3 false RX_CB_VAL_0_3 00000000 RX_CB_K_0_3 false RX_CB_DISP_0_3 false RX_CB_MASK_1_0 false RX_CB_VAL_1_0 00000000 RX_CB_K_1_0 false RX_CB_DISP_1_0\
false RX_CB_MASK_1_1 false RX_CB_VAL_1_1 00000000 RX_CB_K_1_1 false RX_CB_DISP_1_1 false RX_CB_MASK_1_2 false RX_CB_VAL_1_2 00000000 RX_CB_K_1_2 false RX_CB_DISP_1_2 false RX_CB_MASK_1_3 false RX_CB_VAL_1_3\
00000000 RX_CB_K_1_3 false RX_CB_DISP_1_3 false RX_CC_NUM_SEQ 1 RX_CC_LEN_SEQ 1 RX_CC_PERIODICITY 5000 RX_CC_KEEP_IDLE ENABLE RX_CC_PRECEDENCE ENABLE RX_CC_REPEAT_WAIT 0 RX_CC_MASK 00000000 RX_CC_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000011100\
RX_CC_K 00000001 RX_CC_DISP 00000000 RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_K_0_0 true RX_CC_DISP_0_0 false RX_CC_MASK_0_1 false RX_CC_VAL_0_1 00000000 RX_CC_K_0_1 false RX_CC_DISP_0_1 false\
RX_CC_MASK_0_2 false RX_CC_VAL_0_2 00000000 RX_CC_K_0_2 false RX_CC_DISP_0_2 false RX_CC_MASK_0_3 false RX_CC_VAL_0_3 00000000 RX_CC_K_0_3 false RX_CC_DISP_0_3 false RX_CC_MASK_1_0 false RX_CC_VAL_1_0\
00000000 RX_CC_K_1_0 false RX_CC_DISP_1_0 false RX_CC_MASK_1_1 false RX_CC_VAL_1_1 00000000 RX_CC_K_1_1 false RX_CC_DISP_1_1 false RX_CC_MASK_1_2 false RX_CC_VAL_1_2 00000000 RX_CC_K_1_2 false RX_CC_DISP_1_2\
false RX_CC_MASK_1_3 false RX_CC_VAL_1_3 00000000 RX_CC_K_1_3 false RX_CC_DISP_1_3 false PCIE_USERCLK2_FREQ 250 PCIE_USERCLK_FREQ 250 RX_JTOL_FC 1 RX_JTOL_LF_SLOPE -20 RX_BUFFER_BYPASS_MODE Fast_Sync RX_BUFFER_BYPASS_MODE_LANE\
MULTI RX_BUFFER_RESET_ON_CB_CHANGE ENABLE RX_BUFFER_RESET_ON_COMMAALIGN DISABLE RX_BUFFER_RESET_ON_RATE_CHANGE ENABLE RESET_SEQUENCE_INTERVAL 0 RX_COMMA_PRESET K28.5 RX_COMMA_VALID_ONLY 0} \
    CONFIG.PROT0_LR10_SETTINGS {NA NA} \
    CONFIG.PROT0_LR11_SETTINGS {NA NA} \
    CONFIG.PROT0_LR12_SETTINGS {NA NA} \
    CONFIG.PROT0_LR13_SETTINGS {NA NA} \
    CONFIG.PROT0_LR14_SETTINGS {NA NA} \
    CONFIG.PROT0_LR15_SETTINGS {NA NA} \
    CONFIG.PROT0_LR1_SETTINGS {GT_DIRECTION DUPLEX TX_PAM_SEL NRZ TX_HD_EN 0 TX_GRAY_BYP true TX_GRAY_LITTLEENDIAN true TX_PRECODE_BYP true TX_PRECODE_LITTLEENDIAN false TX_LINE_RATE 5.0 TX_PLL_TYPE LCPLL\
TX_REFCLK_FREQUENCY 100 TX_ACTUAL_REFCLK_FREQUENCY 100.000000000000 TX_FRACN_ENABLED false TX_FRACN_OVRD false TX_FRACN_NUMERATOR 0 TX_REFCLK_SOURCE R0 TX_DATA_ENCODING 8B10B TX_USER_DATA_WIDTH 16 TX_INT_DATA_WIDTH\
20 TX_BUFFER_MODE 0 TX_BUFFER_BYPASS_MODE Fast_Sync TX_PIPM_ENABLE false TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TXPROGDIV_FREQ_VAL 500.000 TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_64B66B_SCRAMBLER false TX_64B66B_ENCODER false TX_64B66B_CRC false TX_RATE_GROUP A TX_LANE_DESKEW_HDMI_ENABLE false TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE GT_TYPE GTYP PRESET None RX_PAM_SEL NRZ\
RX_HD_EN 0 RX_GRAY_BYP true RX_GRAY_LITTLEENDIAN true RX_PRECODE_BYP true RX_PRECODE_LITTLEENDIAN false INTERNAL_PRESET None XPU_MODE 0 RX_LINE_RATE 5.0 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 100 RX_ACTUAL_REFCLK_FREQUENCY\
100.000000000000 RX_FRACN_ENABLED false RX_FRACN_OVRD false RX_FRACN_NUMERATOR 0 RX_REFCLK_SOURCE R0 RX_DATA_DECODING 8B10B RX_USER_DATA_WIDTH 16 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RXPROGDIV_FREQ_ENABLE false RXPROGDIV_FREQ_SOURCE LCPLL RXPROGDIV_FREQ_VAL 250.000000 RXRECCLK_FREQ_ENABLE false RXRECCLK_FREQ_VAL 0 INS_LOSS_NYQ 20 RX_EQ_MODE LPM RX_COUPLING AC RX_TERMINATION\
PROGRAMMABLE RX_RATE_GROUP A RX_TERMINATION_PROG_VALUE 800 RX_PPM_OFFSET 0 RX_64B66B_DESCRAMBLER false RX_64B66B_DECODER false RX_64B66B_CRC false OOB_ENABLE true RX_COMMA_ALIGN_WORD 1 RX_COMMA_SHOW_REALIGN_ENABLE\
true PCIE_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_M_ENABLE true RX_COMMA_DOUBLE_ENABLE false RX_COMMA_P_VAL 1010000011 RX_COMMA_M_VAL 0101111100 RX_COMMA_MASK 1111111111 RX_SLIDE_MODE OFF RX_SSC_PPM\
0 RX_CB_NUM_SEQ 0 RX_CB_LEN_SEQ 1 RX_CB_MAX_SKEW 1 RX_CB_MAX_LEVEL 1 RX_CB_MASK 00000000 RX_CB_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CB_K 00000000 RX_CB_DISP\
00000000 RX_CB_MASK_0_0 false RX_CB_VAL_0_0 00000000 RX_CB_K_0_0 false RX_CB_DISP_0_0 false RX_CB_MASK_0_1 false RX_CB_VAL_0_1 00000000 RX_CB_K_0_1 false RX_CB_DISP_0_1 false RX_CB_MASK_0_2 false RX_CB_VAL_0_2\
00000000 RX_CB_K_0_2 false RX_CB_DISP_0_2 false RX_CB_MASK_0_3 false RX_CB_VAL_0_3 00000000 RX_CB_K_0_3 false RX_CB_DISP_0_3 false RX_CB_MASK_1_0 false RX_CB_VAL_1_0 00000000 RX_CB_K_1_0 false RX_CB_DISP_1_0\
false RX_CB_MASK_1_1 false RX_CB_VAL_1_1 00000000 RX_CB_K_1_1 false RX_CB_DISP_1_1 false RX_CB_MASK_1_2 false RX_CB_VAL_1_2 00000000 RX_CB_K_1_2 false RX_CB_DISP_1_2 false RX_CB_MASK_1_3 false RX_CB_VAL_1_3\
00000000 RX_CB_K_1_3 false RX_CB_DISP_1_3 false RX_CC_NUM_SEQ 1 RX_CC_LEN_SEQ 1 RX_CC_PERIODICITY 5000 RX_CC_KEEP_IDLE ENABLE RX_CC_PRECEDENCE ENABLE RX_CC_REPEAT_WAIT 0 RX_CC_MASK 00000000 RX_CC_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000011100\
RX_CC_K 00000001 RX_CC_DISP 00000000 RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_K_0_0 true RX_CC_DISP_0_0 false RX_CC_MASK_0_1 false RX_CC_VAL_0_1 00000000 RX_CC_K_0_1 false RX_CC_DISP_0_1 false\
RX_CC_MASK_0_2 false RX_CC_VAL_0_2 00000000 RX_CC_K_0_2 false RX_CC_DISP_0_2 false RX_CC_MASK_0_3 false RX_CC_VAL_0_3 00000000 RX_CC_K_0_3 false RX_CC_DISP_0_3 false RX_CC_MASK_1_0 false RX_CC_VAL_1_0\
00000000 RX_CC_K_1_0 false RX_CC_DISP_1_0 false RX_CC_MASK_1_1 false RX_CC_VAL_1_1 00000000 RX_CC_K_1_1 false RX_CC_DISP_1_1 false RX_CC_MASK_1_2 false RX_CC_VAL_1_2 00000000 RX_CC_K_1_2 false RX_CC_DISP_1_2\
false RX_CC_MASK_1_3 false RX_CC_VAL_1_3 00000000 RX_CC_K_1_3 false RX_CC_DISP_1_3 false PCIE_USERCLK2_FREQ 250 PCIE_USERCLK_FREQ 250 RX_JTOL_FC 1 RX_JTOL_LF_SLOPE -20 RX_BUFFER_BYPASS_MODE Fast_Sync RX_BUFFER_BYPASS_MODE_LANE\
MULTI RX_BUFFER_RESET_ON_CB_CHANGE ENABLE RX_BUFFER_RESET_ON_COMMAALIGN DISABLE RX_BUFFER_RESET_ON_RATE_CHANGE ENABLE RESET_SEQUENCE_INTERVAL 0 RX_COMMA_PRESET K28.5 RX_COMMA_VALID_ONLY 0} \
    CONFIG.PROT0_LR2_SETTINGS {GT_DIRECTION DUPLEX TX_PAM_SEL NRZ TX_HD_EN 0 TX_GRAY_BYP true TX_GRAY_LITTLEENDIAN true TX_PRECODE_BYP true TX_PRECODE_LITTLEENDIAN false TX_LINE_RATE 8.0 TX_PLL_TYPE LCPLL\
TX_REFCLK_FREQUENCY 100 TX_ACTUAL_REFCLK_FREQUENCY 100.000000000000 TX_FRACN_ENABLED false TX_FRACN_OVRD false TX_FRACN_NUMERATOR 0 TX_REFCLK_SOURCE R0 TX_DATA_ENCODING 128B130B TX_USER_DATA_WIDTH 32 TX_INT_DATA_WIDTH\
32 TX_BUFFER_MODE 0 TX_BUFFER_BYPASS_MODE Fast_Sync TX_PIPM_ENABLE false TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TXPROGDIV_FREQ_VAL 500.000 TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_64B66B_SCRAMBLER false TX_64B66B_ENCODER false TX_64B66B_CRC false TX_RATE_GROUP A TX_LANE_DESKEW_HDMI_ENABLE false TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE GT_TYPE GTYP PRESET None RX_PAM_SEL NRZ\
RX_HD_EN 0 RX_GRAY_BYP true RX_GRAY_LITTLEENDIAN true RX_PRECODE_BYP true RX_PRECODE_LITTLEENDIAN false INTERNAL_PRESET None XPU_MODE 0 RX_LINE_RATE 8.0 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 100 RX_ACTUAL_REFCLK_FREQUENCY\
100.000000000000 RX_FRACN_ENABLED false RX_FRACN_OVRD false RX_FRACN_NUMERATOR 0 RX_REFCLK_SOURCE R0 RX_DATA_DECODING 128B130B RX_USER_DATA_WIDTH 32 RX_INT_DATA_WIDTH 32 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RXPROGDIV_FREQ_ENABLE false RXPROGDIV_FREQ_SOURCE LCPLL RXPROGDIV_FREQ_VAL 250.000000 RXRECCLK_FREQ_ENABLE false RXRECCLK_FREQ_VAL 0 INS_LOSS_NYQ 20 RX_EQ_MODE DFE RX_COUPLING AC RX_TERMINATION\
PROGRAMMABLE RX_RATE_GROUP A RX_TERMINATION_PROG_VALUE 800 RX_PPM_OFFSET 0 RX_64B66B_DESCRAMBLER false RX_64B66B_DECODER false RX_64B66B_CRC false OOB_ENABLE true RX_COMMA_ALIGN_WORD 1 RX_COMMA_SHOW_REALIGN_ENABLE\
true PCIE_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_M_ENABLE true RX_COMMA_DOUBLE_ENABLE false RX_COMMA_P_VAL 1010000011 RX_COMMA_M_VAL 0101111100 RX_COMMA_MASK 1111111111 RX_SLIDE_MODE OFF RX_SSC_PPM\
0 RX_CB_NUM_SEQ 0 RX_CB_LEN_SEQ 1 RX_CB_MAX_SKEW 1 RX_CB_MAX_LEVEL 1 RX_CB_MASK 00000000 RX_CB_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CB_K 00000000 RX_CB_DISP\
00000000 RX_CB_MASK_0_0 false RX_CB_VAL_0_0 00000000 RX_CB_K_0_0 false RX_CB_DISP_0_0 false RX_CB_MASK_0_1 false RX_CB_VAL_0_1 00000000 RX_CB_K_0_1 false RX_CB_DISP_0_1 false RX_CB_MASK_0_2 false RX_CB_VAL_0_2\
00000000 RX_CB_K_0_2 false RX_CB_DISP_0_2 false RX_CB_MASK_0_3 false RX_CB_VAL_0_3 00000000 RX_CB_K_0_3 false RX_CB_DISP_0_3 false RX_CB_MASK_1_0 false RX_CB_VAL_1_0 00000000 RX_CB_K_1_0 false RX_CB_DISP_1_0\
false RX_CB_MASK_1_1 false RX_CB_VAL_1_1 00000000 RX_CB_K_1_1 false RX_CB_DISP_1_1 false RX_CB_MASK_1_2 false RX_CB_VAL_1_2 00000000 RX_CB_K_1_2 false RX_CB_DISP_1_2 false RX_CB_MASK_1_3 false RX_CB_VAL_1_3\
00000000 RX_CB_K_1_3 false RX_CB_DISP_1_3 false RX_CC_NUM_SEQ 1 RX_CC_LEN_SEQ 1 RX_CC_PERIODICITY 5000 RX_CC_KEEP_IDLE ENABLE RX_CC_PRECEDENCE ENABLE RX_CC_REPEAT_WAIT 0 RX_CC_MASK 00000000 RX_CC_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000011100\
RX_CC_K 00000000 RX_CC_DISP 00000000 RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_K_0_0 false RX_CC_DISP_0_0 false RX_CC_MASK_0_1 false RX_CC_VAL_0_1 00000000 RX_CC_K_0_1 false RX_CC_DISP_0_1 false\
RX_CC_MASK_0_2 false RX_CC_VAL_0_2 00000000 RX_CC_K_0_2 false RX_CC_DISP_0_2 false RX_CC_MASK_0_3 false RX_CC_VAL_0_3 00000000 RX_CC_K_0_3 false RX_CC_DISP_0_3 false RX_CC_MASK_1_0 false RX_CC_VAL_1_0\
00000000 RX_CC_K_1_0 false RX_CC_DISP_1_0 false RX_CC_MASK_1_1 false RX_CC_VAL_1_1 00000000 RX_CC_K_1_1 false RX_CC_DISP_1_1 false RX_CC_MASK_1_2 false RX_CC_VAL_1_2 00000000 RX_CC_K_1_2 false RX_CC_DISP_1_2\
false RX_CC_MASK_1_3 false RX_CC_VAL_1_3 00000000 RX_CC_K_1_3 false RX_CC_DISP_1_3 false PCIE_USERCLK2_FREQ 500 PCIE_USERCLK_FREQ 250 RX_JTOL_FC 1 RX_JTOL_LF_SLOPE -20 RX_BUFFER_BYPASS_MODE Fast_Sync RX_BUFFER_BYPASS_MODE_LANE\
MULTI RX_BUFFER_RESET_ON_CB_CHANGE ENABLE RX_BUFFER_RESET_ON_COMMAALIGN DISABLE RX_BUFFER_RESET_ON_RATE_CHANGE ENABLE RESET_SEQUENCE_INTERVAL 0 RX_COMMA_PRESET K28.5 RX_COMMA_VALID_ONLY 0} \
    CONFIG.PROT0_LR3_SETTINGS {GT_DIRECTION DUPLEX TX_PAM_SEL NRZ TX_HD_EN 0 TX_GRAY_BYP true TX_GRAY_LITTLEENDIAN true TX_PRECODE_BYP true TX_PRECODE_LITTLEENDIAN false TX_LINE_RATE 16.0 TX_PLL_TYPE LCPLL\
TX_REFCLK_FREQUENCY 100 TX_ACTUAL_REFCLK_FREQUENCY 100.000000000000 TX_FRACN_ENABLED false TX_FRACN_OVRD false TX_FRACN_NUMERATOR 0 TX_REFCLK_SOURCE R0 TX_DATA_ENCODING 128B130B TX_USER_DATA_WIDTH 32 TX_INT_DATA_WIDTH\
32 TX_BUFFER_MODE 0 TX_BUFFER_BYPASS_MODE Fast_Sync TX_PIPM_ENABLE false TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TXPROGDIV_FREQ_VAL 500.000 TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_64B66B_SCRAMBLER false TX_64B66B_ENCODER false TX_64B66B_CRC false TX_RATE_GROUP A TX_LANE_DESKEW_HDMI_ENABLE false TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE GT_TYPE GTYP PRESET None RX_PAM_SEL NRZ\
RX_HD_EN 0 RX_GRAY_BYP true RX_GRAY_LITTLEENDIAN true RX_PRECODE_BYP true RX_PRECODE_LITTLEENDIAN false INTERNAL_PRESET None XPU_MODE 0 RX_LINE_RATE 16.0 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 100 RX_ACTUAL_REFCLK_FREQUENCY\
100.000000000000 RX_FRACN_ENABLED false RX_FRACN_OVRD false RX_FRACN_NUMERATOR 0 RX_REFCLK_SOURCE R0 RX_DATA_DECODING 128B130B RX_USER_DATA_WIDTH 32 RX_INT_DATA_WIDTH 32 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RXPROGDIV_FREQ_ENABLE false RXPROGDIV_FREQ_SOURCE LCPLL RXPROGDIV_FREQ_VAL 500.000000 RXRECCLK_FREQ_ENABLE false RXRECCLK_FREQ_VAL 0 INS_LOSS_NYQ 20 RX_EQ_MODE DFE RX_COUPLING AC RX_TERMINATION\
PROGRAMMABLE RX_RATE_GROUP A RX_TERMINATION_PROG_VALUE 800 RX_PPM_OFFSET 0 RX_64B66B_DESCRAMBLER false RX_64B66B_DECODER false RX_64B66B_CRC false OOB_ENABLE true RX_COMMA_ALIGN_WORD 1 RX_COMMA_SHOW_REALIGN_ENABLE\
true PCIE_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_M_ENABLE true RX_COMMA_DOUBLE_ENABLE false RX_COMMA_P_VAL 1010000011 RX_COMMA_M_VAL 0101111100 RX_COMMA_MASK 1111111111 RX_SLIDE_MODE OFF RX_SSC_PPM\
0 RX_CB_NUM_SEQ 0 RX_CB_LEN_SEQ 1 RX_CB_MAX_SKEW 1 RX_CB_MAX_LEVEL 1 RX_CB_MASK 00000000 RX_CB_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 RX_CB_K 00000000 RX_CB_DISP\
00000000 RX_CB_MASK_0_0 false RX_CB_VAL_0_0 00000000 RX_CB_K_0_0 false RX_CB_DISP_0_0 false RX_CB_MASK_0_1 false RX_CB_VAL_0_1 00000000 RX_CB_K_0_1 false RX_CB_DISP_0_1 false RX_CB_MASK_0_2 false RX_CB_VAL_0_2\
00000000 RX_CB_K_0_2 false RX_CB_DISP_0_2 false RX_CB_MASK_0_3 false RX_CB_VAL_0_3 00000000 RX_CB_K_0_3 false RX_CB_DISP_0_3 false RX_CB_MASK_1_0 false RX_CB_VAL_1_0 00000000 RX_CB_K_1_0 false RX_CB_DISP_1_0\
false RX_CB_MASK_1_1 false RX_CB_VAL_1_1 00000000 RX_CB_K_1_1 false RX_CB_DISP_1_1 false RX_CB_MASK_1_2 false RX_CB_VAL_1_2 00000000 RX_CB_K_1_2 false RX_CB_DISP_1_2 false RX_CB_MASK_1_3 false RX_CB_VAL_1_3\
00000000 RX_CB_K_1_3 false RX_CB_DISP_1_3 false RX_CC_NUM_SEQ 1 RX_CC_LEN_SEQ 1 RX_CC_PERIODICITY 5000 RX_CC_KEEP_IDLE ENABLE RX_CC_PRECEDENCE ENABLE RX_CC_REPEAT_WAIT 0 RX_CC_MASK 00000000 RX_CC_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000011100\
RX_CC_K 00000000 RX_CC_DISP 00000000 RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_K_0_0 false RX_CC_DISP_0_0 false RX_CC_MASK_0_1 false RX_CC_VAL_0_1 00000000 RX_CC_K_0_1 false RX_CC_DISP_0_1 false\
RX_CC_MASK_0_2 false RX_CC_VAL_0_2 00000000 RX_CC_K_0_2 false RX_CC_DISP_0_2 false RX_CC_MASK_0_3 false RX_CC_VAL_0_3 00000000 RX_CC_K_0_3 false RX_CC_DISP_0_3 false RX_CC_MASK_1_0 false RX_CC_VAL_1_0\
00000000 RX_CC_K_1_0 false RX_CC_DISP_1_0 false RX_CC_MASK_1_1 false RX_CC_VAL_1_1 00000000 RX_CC_K_1_1 false RX_CC_DISP_1_1 false RX_CC_MASK_1_2 false RX_CC_VAL_1_2 00000000 RX_CC_K_1_2 false RX_CC_DISP_1_2\
false RX_CC_MASK_1_3 false RX_CC_VAL_1_3 00000000 RX_CC_K_1_3 false RX_CC_DISP_1_3 false PCIE_USERCLK2_FREQ 500 PCIE_USERCLK_FREQ 250 RX_JTOL_FC 1 RX_JTOL_LF_SLOPE -20 RX_BUFFER_BYPASS_MODE Fast_Sync RX_BUFFER_BYPASS_MODE_LANE\
MULTI RX_BUFFER_RESET_ON_CB_CHANGE ENABLE RX_BUFFER_RESET_ON_COMMAALIGN DISABLE RX_BUFFER_RESET_ON_RATE_CHANGE ENABLE RESET_SEQUENCE_INTERVAL 0 RX_COMMA_PRESET K28.5 RX_COMMA_VALID_ONLY 0} \
    CONFIG.PROT0_LR4_SETTINGS {NA NA} \
    CONFIG.PROT0_LR5_SETTINGS {NA NA} \
    CONFIG.PROT0_LR6_SETTINGS {NA NA} \
    CONFIG.PROT0_LR7_SETTINGS {NA NA} \
    CONFIG.PROT0_LR8_SETTINGS {NA NA} \
    CONFIG.PROT0_LR9_SETTINGS {NA NA} \
    CONFIG.PROT0_NO_OF_LANES {4} \
    CONFIG.PROT0_RX_MASTERCLK_SRC {RX0} \
    CONFIG.PROT0_TX_MASTERCLK_SRC {TX0} \
    CONFIG.PROT_OUTCLK_VALUES {CH0_RXOUTCLK 500 CH0_TXOUTCLK 500 CH1_RXOUTCLK 500 CH1_TXOUTCLK 500 CH2_RXOUTCLK 500 CH2_TXOUTCLK 500 CH3_RXOUTCLK 500 CH3_TXOUTCLK 500} \
    CONFIG.QUAD_USAGE {TX_QUAD_CH {TXQuad_0_/qdma_0_support/gt_quad_0 {/qdma_0_support/gt_quad_0 qdma_ep_pcie_phy_0.IP_CH0,qdma_ep_pcie_phy_0.IP_CH1,qdma_ep_pcie_phy_0.IP_CH2,qdma_ep_pcie_phy_0.IP_CH3\
MSTRCLK 0,0,0,0 IS_CURRENT_QUAD 0}} RX_QUAD_CH {RXQuad_0_/qdma_0_support/gt_quad_0 {/qdma_0_support/gt_quad_0 qdma_ep_pcie_phy_0.IP_CH0,qdma_ep_pcie_phy_0.IP_CH1,qdma_ep_pcie_phy_0.IP_CH2,qdma_ep_pcie_phy_0.IP_CH3\
MSTRCLK 0,0,0,0 IS_CURRENT_QUAD 0}}} \
    CONFIG.REFCLK_LIST {} \
    CONFIG.REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_RPLLGTREFCLK0\
refclk_PROT0_R0_100_MHz_unique1} \
    CONFIG.RX0_LANE_SEL {PROT0} \
    CONFIG.RX1_LANE_SEL {PROT0} \
    CONFIG.RX2_LANE_SEL {PROT0} \
    CONFIG.RX3_LANE_SEL {PROT0} \
    CONFIG.TX0_LANE_SEL {PROT0} \
    CONFIG.TX1_LANE_SEL {PROT0} \
    CONFIG.TX2_LANE_SEL {PROT0} \
    CONFIG.TX3_LANE_SEL {PROT0} \
  ] $gt_quad_0

  set_property -dict [list \
    CONFIG.APB3_CLK_FREQUENCY.VALUE_MODE {auto} \
    CONFIG.CHANNEL_ORDERING.VALUE_MODE {auto} \
    CONFIG.GT_TYPE.VALUE_MODE {auto} \
    CONFIG.PROT0_ENABLE.VALUE_MODE {auto} \
    CONFIG.PROT0_GT_DIRECTION.VALUE_MODE {auto} \
    CONFIG.PROT0_LR0_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR10_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR11_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR12_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR13_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR14_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR15_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR1_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR2_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR3_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR4_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR5_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR6_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR7_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR8_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_LR9_SETTINGS.VALUE_MODE {auto} \
    CONFIG.PROT0_NO_OF_LANES.VALUE_MODE {auto} \
    CONFIG.PROT0_RX_MASTERCLK_SRC.VALUE_MODE {auto} \
    CONFIG.PROT0_TX_MASTERCLK_SRC.VALUE_MODE {auto} \
    CONFIG.QUAD_USAGE.VALUE_MODE {auto} \
    CONFIG.REFCLK_LIST.VALUE_MODE {auto} \
    CONFIG.RX0_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.RX1_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.RX2_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.RX3_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX0_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX1_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX2_LANE_SEL.VALUE_MODE {auto} \
    CONFIG.TX3_LANE_SEL.VALUE_MODE {auto} \
  ] $gt_quad_0




  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins refclk_ibuf/CLK_IN_D] [get_bd_intf_pins pcie_refclk]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins pcie_phy/pcie_mgt] [get_bd_intf_pins pcie_mgt]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins pcie/m_axis_cq] [get_bd_intf_pins m_axis_cq]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins pcie/m_axis_rc] [get_bd_intf_pins m_axis_rc]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins pcie/pcie_cfg_fc] [get_bd_intf_pins pcie_cfg_fc]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins pcie/pcie_cfg_interrupt] [get_bd_intf_pins pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins pcie/pcie_cfg_mesg_rcvd] [get_bd_intf_pins pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins pcie/pcie_cfg_mesg_tx] [get_bd_intf_pins pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins pcie/s_axis_cc] [get_bd_intf_pins s_axis_cc]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins pcie/s_axis_rq] [get_bd_intf_pins s_axis_rq]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins pcie/pcie_cfg_control] [get_bd_intf_pins pcie_cfg_control]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins pcie/pcie_cfg_external_msix_without_msi] [get_bd_intf_pins pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins pcie/pcie_cfg_mgmt] [get_bd_intf_pins pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins pcie/pcie_cfg_status] [get_bd_intf_pins pcie_cfg_status]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins pcie/pcie_transmit_fc] [get_bd_intf_pins pcie_transmit_fc]
  connect_bd_intf_net -intf_net gt_quad_0_GT0_BUFGT [get_bd_intf_pins pcie_phy/GT_BUFGT] [get_bd_intf_pins gt_quad_0/GT0_BUFGT]
  connect_bd_intf_net -intf_net gt_quad_0_GT_Serial [get_bd_intf_pins pcie_phy/GT0_Serial] [get_bd_intf_pins gt_quad_0/GT_Serial]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX0 [get_bd_intf_pins pcie_phy/GT_RX0] [get_bd_intf_pins gt_quad_0/RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX1 [get_bd_intf_pins pcie_phy/GT_RX1] [get_bd_intf_pins gt_quad_0/RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX2 [get_bd_intf_pins pcie_phy/GT_RX2] [get_bd_intf_pins gt_quad_0/RX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX3 [get_bd_intf_pins pcie_phy/GT_RX3] [get_bd_intf_pins gt_quad_0/RX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX0 [get_bd_intf_pins pcie_phy/GT_TX0] [get_bd_intf_pins gt_quad_0/TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX1 [get_bd_intf_pins pcie_phy/GT_TX1] [get_bd_intf_pins gt_quad_0/TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX2 [get_bd_intf_pins pcie_phy/GT_TX2] [get_bd_intf_pins gt_quad_0/TX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX3 [get_bd_intf_pins pcie_phy/GT_TX3] [get_bd_intf_pins gt_quad_0/TX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_gt_rxmargin_q0 [get_bd_intf_pins pcie_phy/gt_rxmargin_q0] [get_bd_intf_pins gt_quad_0/gt_rxmargin_intf]
  connect_bd_intf_net -intf_net pcie_phy_mac_rx [get_bd_intf_pins pcie_phy/phy_mac_rx] [get_bd_intf_pins pcie/phy_mac_rx]
  connect_bd_intf_net -intf_net pcie_phy_mac_tx [get_bd_intf_pins pcie_phy/phy_mac_tx] [get_bd_intf_pins pcie/phy_mac_tx]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_command [get_bd_intf_pins pcie_phy/phy_mac_command] [get_bd_intf_pins pcie/phy_mac_command]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_rx_margining [get_bd_intf_pins pcie_phy/phy_mac_rx_margining] [get_bd_intf_pins pcie/phy_mac_rx_margining]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_status [get_bd_intf_pins pcie_phy/phy_mac_status] [get_bd_intf_pins pcie/phy_mac_status]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_drive [get_bd_intf_pins pcie_phy/phy_mac_tx_drive] [get_bd_intf_pins pcie/phy_mac_tx_drive]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_eq [get_bd_intf_pins pcie_phy/phy_mac_tx_eq] [get_bd_intf_pins pcie/phy_mac_tx_eq]

  # Create port connections
  connect_bd_net -net bufg_gt_sysclk_BUFG_GT_O  [get_bd_pins bufg_gt_sysclk/BUFG_GT_O] \
  [get_bd_pins pcie/sys_clk] \
  [get_bd_pins pcie_phy/phy_refclk]
  connect_bd_net -net const_1b0_dout  [get_bd_pins const_1b0/dout] \
  [get_bd_pins gt_quad_0/apb3clk]
  connect_bd_net -net const_1b1_dout  [get_bd_pins const_1b1/dout] \
  [get_bd_pins bufg_gt_sysclk/BUFG_GT_CE]
  connect_bd_net -net gt_quad_0_ch0_phyready  [get_bd_pins gt_quad_0/ch0_phyready] \
  [get_bd_pins pcie_phy/ch0_phyready]
  connect_bd_net -net gt_quad_0_ch0_phystatus  [get_bd_pins gt_quad_0/ch0_phystatus] \
  [get_bd_pins pcie_phy/ch0_phystatus]
  connect_bd_net -net gt_quad_0_ch0_rxoutclk  [get_bd_pins gt_quad_0/ch0_rxoutclk] \
  [get_bd_pins pcie_phy/gt_rxoutclk]
  connect_bd_net -net gt_quad_0_ch0_txoutclk  [get_bd_pins gt_quad_0/ch0_txoutclk] \
  [get_bd_pins pcie_phy/gt_txoutclk]
  connect_bd_net -net gt_quad_0_ch1_phyready  [get_bd_pins gt_quad_0/ch1_phyready] \
  [get_bd_pins pcie_phy/ch1_phyready]
  connect_bd_net -net gt_quad_0_ch1_phystatus  [get_bd_pins gt_quad_0/ch1_phystatus] \
  [get_bd_pins pcie_phy/ch1_phystatus]
  connect_bd_net -net gt_quad_0_ch2_phyready  [get_bd_pins gt_quad_0/ch2_phyready] \
  [get_bd_pins pcie_phy/ch2_phyready]
  connect_bd_net -net gt_quad_0_ch2_phystatus  [get_bd_pins gt_quad_0/ch2_phystatus] \
  [get_bd_pins pcie_phy/ch2_phystatus]
  connect_bd_net -net gt_quad_0_ch3_phyready  [get_bd_pins gt_quad_0/ch3_phyready] \
  [get_bd_pins pcie_phy/ch3_phyready]
  connect_bd_net -net gt_quad_0_ch3_phystatus  [get_bd_pins gt_quad_0/ch3_phystatus] \
  [get_bd_pins pcie_phy/ch3_phystatus]
  connect_bd_net -net pcie_pcie_ltssm_state  [get_bd_pins pcie/pcie_ltssm_state] \
  [get_bd_pins pcie_phy/pcie_ltssm_state]
  connect_bd_net -net pcie_phy_gt_pcieltssm  [get_bd_pins pcie_phy/gt_pcieltssm] \
  [get_bd_pins gt_quad_0/pcieltssm]
  connect_bd_net -net pcie_phy_gtrefclk  [get_bd_pins pcie_phy/gtrefclk] \
  [get_bd_pins gt_quad_0/GT_REFCLK0]
  connect_bd_net -net pcie_phy_pcierstb  [get_bd_pins pcie_phy/pcierstb] \
  [get_bd_pins gt_quad_0/ch0_pcierstb] \
  [get_bd_pins gt_quad_0/ch1_pcierstb] \
  [get_bd_pins gt_quad_0/ch2_pcierstb] \
  [get_bd_pins gt_quad_0/ch3_pcierstb]
  connect_bd_net -net pcie_phy_phy_coreclk  [get_bd_pins pcie_phy/phy_coreclk] \
  [get_bd_pins pcie/phy_coreclk]
  connect_bd_net -net pcie_phy_phy_mcapclk  [get_bd_pins pcie_phy/phy_mcapclk] \
  [get_bd_pins pcie/phy_mcapclk]
  connect_bd_net -net pcie_phy_phy_pclk  [get_bd_pins pcie_phy/phy_pclk] \
  [get_bd_pins gt_quad_0/ch0_txusrclk] \
  [get_bd_pins gt_quad_0/ch1_txusrclk] \
  [get_bd_pins gt_quad_0/ch2_txusrclk] \
  [get_bd_pins gt_quad_0/ch3_txusrclk] \
  [get_bd_pins gt_quad_0/ch0_rxusrclk] \
  [get_bd_pins gt_quad_0/ch1_rxusrclk] \
  [get_bd_pins gt_quad_0/ch2_rxusrclk] \
  [get_bd_pins gt_quad_0/ch3_rxusrclk] \
  [get_bd_pins pcie/phy_pclk]
  connect_bd_net -net pcie_phy_phy_userclk  [get_bd_pins pcie_phy/phy_userclk] \
  [get_bd_pins pcie/phy_userclk]
  connect_bd_net -net pcie_phy_phy_userclk2  [get_bd_pins pcie_phy/phy_userclk2] \
  [get_bd_pins pcie/phy_userclk2]
  connect_bd_net -net pcie_phy_rdy_out  [get_bd_pins pcie/phy_rdy_out] \
  [get_bd_pins phy_rdy_out]
  connect_bd_net -net pcie_user_clk  [get_bd_pins pcie/user_clk] \
  [get_bd_pins user_clk]
  connect_bd_net -net pcie_user_lnk_up  [get_bd_pins pcie/user_lnk_up] \
  [get_bd_pins user_lnk_up]
  connect_bd_net -net pcie_user_reset  [get_bd_pins pcie/user_reset] \
  [get_bd_pins user_reset]
  connect_bd_net -net refclk_ibuf_IBUF_DS_ODIV2  [get_bd_pins refclk_ibuf/IBUF_DS_ODIV2] \
  [get_bd_pins bufg_gt_sysclk/BUFG_GT_I]
  connect_bd_net -net refclk_ibuf_IBUF_OUT  [get_bd_pins refclk_ibuf/IBUF_OUT] \
  [get_bd_pins pcie/sys_clk_gt] \
  [get_bd_pins pcie_phy/phy_gtrefclk]
  connect_bd_net -net sys_reset_1  [get_bd_pins sys_reset] \
  [get_bd_pins pcie/sys_reset] \
  [get_bd_pins pcie_phy/phy_rst_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
