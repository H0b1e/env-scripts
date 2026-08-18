################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################
proc create_root_design {addr_width data_width id_width wr_outstanding rd_outstanding ecc_en} {

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version [version -short]
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvp1902-vsva6865-2MP-e-S
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:ddr4_pl:1.0\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.

  variable script_folder
  variable design_name
  set parentCell ""

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
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


  # Create interface ports
  set S00_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $addr_width \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $data_width \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH $id_width \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING $rd_outstanding \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING $wr_outstanding \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S00_AXI_0

  set S01_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {35} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {200000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {8} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {32} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {32} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S01_AXI_0

if { $ecc_en == 1 } {
  set C0_DDR4_S_AXI_CTRL_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 C0_DDR4_S_AXI_CTRL_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {250000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $C0_DDR4_S_AXI_CTRL_0
}

  set C0_DDR4_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 C0_DDR4_0 ]

  set C0_SYS_CLK_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_SYS_CLK_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $C0_SYS_CLK_0


  # Create ports
  set S00_AXI_0_aclk [ create_bd_port -dir I -type clk -freq_hz 200000000 S00_AXI_0_aclk ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {design_1_S00_AXI_0_aclk} \
 ] $S00_AXI_0_aclk
  set S00_AXI_0_aresetn [ create_bd_port -dir I -type rst S00_AXI_0_aresetn ]
  set S01_AXI_0_aclk [ create_bd_port -dir I -type clk -freq_hz 200000000 S01_AXI_0_aclk ]
  set_property -dict [ list \
   CONFIG.CLK_DOMAIN {design_1_S01_AXI_0_aclk} \
 ] $S01_AXI_0_aclk
  set S01_AXI_0_aresetn [ create_bd_port -dir I -type rst S01_AXI_0_aresetn ]
  set c0_init_calib_complete_0 [ create_bd_port -dir O c0_init_calib_complete_0 ]
  set ddr4_ui_rst [ create_bd_port -dir O -from 0 -to 0 ddr4_ui_rst ]
  set ddr4_interrupt_0 [ create_bd_port -dir O ddr4_interrupt_0 ]
  set ddr4_ui_clk [ create_bd_port -dir O -type clk ddr4_ui_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {C0_DDR4_S_AXI_CTRL_0} \
   CONFIG.FREQ_HZ {250000000} \
 ] $ddr4_ui_clk
  set_property CONFIG.ASSOCIATED_BUSIF.VALUE_SRC DEFAULT $ddr4_ui_clk


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
    CONFIG.NUM_SI {1} \
    CONFIG.STRATEGY {PERFORMANCE} \
  ] $smartconnect_0


  # Create instance: smartconnect_1, and set properties
  set smartconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1 ]
  set_property -dict [ list \
    CONFIG.NUM_SI {1} \
    CONFIG.STRATEGY {PERFORMANCE} \
  ] $smartconnect_1


  # Create instance: smartconnect_2, and set properties
  set smartconnect_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_2 ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES { __view__ { clocking { SW0 { ASSOCIATED_CLK aclk2 } } }} \
    CONFIG.NUM_CLKS {3} \
    CONFIG.STRATEGY {PERFORMANCE} \
  ] $smartconnect_2


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: ddr4_pl_0, and set properties
if { $ecc_en == 1 } {
  set ddr4_pl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4_pl:1.0 ddr4_pl_0 ]
  set_property -dict [list \
    CONFIG.DDR4_AxiDataWidth {512} \
    CONFIG.DDR4_CASLATENCY {16} \
    CONFIG.DDR4_CASWRITELATENCY {14} \
    CONFIG.DDR4_CA_MIRROR {true} \
    CONFIG.DDR4_DATAWIDTH {72} \
    CONFIG.DDR4_FREQ_SEL {MEMORY_CLK_FROM_SYS_CLK} \
    CONFIG.DDR4_INPUTCLK_PERIOD {4925} \
    CONFIG.DDR4_INPUTCLK_PERIOD_IP {5000} \
    CONFIG.DDR4_INPUT_FREQUENCY {200} \
    CONFIG.DDR4_MEMORY_DEVICETYPE {SODIMMs} \
    CONFIG.DDR4_MEMORY_FREQUENCY {1000} \
    CONFIG.DDR4_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.DDR4_MEM_SIZE {4294967296} \
    CONFIG.DDR4_ORDERING {Strict} \
    CONFIG.DDR4_RANK {2} \
    CONFIG.DDR4_READ_DBI {false} \
    CONFIG.DDR4_ROWADDRESSWIDTH {17} \
    CONFIG.DDR4_SYSTEM_CLOCK {Differential} \
    CONFIG.DDR4_TCCD_L {5} \
    CONFIG.DDR4_TCCD_L_MIN {5} \
    CONFIG.DDR4_TCK {938} \
    CONFIG.DDR4_TCK_OP {1000} \
    CONFIG.DDR4_TRAS_nCK {32} \
    CONFIG.DDR4_TRCD_nCK {14} \
    CONFIG.DDR4_TREFI_nCK {7800} \
    CONFIG.DDR4_TRFC {550000} \
    CONFIG.DDR4_TRFCMIN {550000} \
    CONFIG.DDR4_TRFC_nCK {550} \
    CONFIG.DDR4_TRP_nCK {14} \
    CONFIG.DDR4_TRRD_L {5} \
    CONFIG.DDR4_TRRD_L_MIN {5} \
    CONFIG.DDR4_TWR_nCK {15} \
    CONFIG.DDR4_TWTR_L_nCK {8} \
    CONFIG.DDR4_TWTR_S_nCK {3} \
    CONFIG.DDR4_TXPR {560} \
    CONFIG.DDR4_UI_CLOCK {250000000} \
    CONFIG.DDR4_USER_DEFINED_ADDRESS_MAP {1CS-17RA-2BA-2BG-10CA} \
    CONFIG.DDR4_WRITE_DM_DBI {NO_DM_DBI} \
  ] $ddr4_pl_0
}

if { $ecc_en == 0 } {
  set ddr4_pl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4_pl:1.0 ddr4_pl_0 ]
  set_property -dict [list \
    CONFIG.DDR4_AxiDataWidth {512} \
    CONFIG.DDR4_CASLATENCY {16} \
    CONFIG.DDR4_CASWRITELATENCY {14} \
    CONFIG.DDR4_CA_MIRROR {true} \
    CONFIG.DDR4_DATAWIDTH {64} \
    CONFIG.DDR4_FREQ_SEL {MEMORY_CLK_FROM_SYS_CLK} \
    CONFIG.DDR4_INPUTCLK_PERIOD {4925} \
    CONFIG.DDR4_INPUTCLK_PERIOD_IP {5000} \
    CONFIG.DDR4_INPUT_FREQUENCY {200} \
    CONFIG.DDR4_MEMORY_DEVICETYPE {SODIMMs} \
    CONFIG.DDR4_MEMORY_FREQUENCY {1000} \
    CONFIG.DDR4_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.DDR4_MEM_SIZE {4294967296} \
    CONFIG.DDR4_ORDERING {Strict} \
    CONFIG.DDR4_RANK {2} \
    CONFIG.DDR4_READ_DBI {false} \
    CONFIG.DDR4_ROWADDRESSWIDTH {17} \
    CONFIG.DDR4_SYSTEM_CLOCK {Differential} \
    CONFIG.DDR4_TCCD_L {5} \
    CONFIG.DDR4_TCCD_L_MIN {5} \
    CONFIG.DDR4_TCK {938} \
    CONFIG.DDR4_TCK_OP {1000} \
    CONFIG.DDR4_TRAS_nCK {32} \
    CONFIG.DDR4_TRCD_nCK {14} \
    CONFIG.DDR4_TREFI_nCK {7800} \
    CONFIG.DDR4_TRFC {550000} \
    CONFIG.DDR4_TRFCMIN {550000} \
    CONFIG.DDR4_TRFC_nCK {550} \
    CONFIG.DDR4_TRP_nCK {14} \
    CONFIG.DDR4_TRRD_L {5} \
    CONFIG.DDR4_TRRD_L_MIN {5} \
    CONFIG.DDR4_TWR_nCK {15} \
    CONFIG.DDR4_TWTR_L_nCK {8} \
    CONFIG.DDR4_TWTR_S_nCK {3} \
    CONFIG.DDR4_TXPR {560} \
    CONFIG.DDR4_UI_CLOCK {250000000} \
    CONFIG.DDR4_USER_DEFINED_ADDRESS_MAP {1CS-17RA-2BA-2BG-10CA} \
    CONFIG.DDR4_WRITE_DM_DBI {DM_NO_DBI} \
  ] $ddr4_pl_0
}

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property CONFIG.C_OPERATION {not} $util_vector_logic_0


  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_2 ]

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_1

if { $ecc_en == 1 } {
  connect_bd_intf_net -intf_net C0_DDR4_S_AXI_CTRL_0_1 [get_bd_intf_ports C0_DDR4_S_AXI_CTRL_0] [get_bd_intf_pins ddr4_pl_0/DDR4_S_AXI_CTRL]
  connect_bd_net -net ddr4_pl_0_ddr4_interrupt  [get_bd_pins ddr4_pl_0/ddr4_interrupt] \
  [get_bd_ports ddr4_interrupt_0]
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces C0_DDR4_S_AXI_CTRL_0] [get_bd_addr_segs ddr4_pl_0/DDR4_MEMORY_MAP_CTRL/REG] -force
}	

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports S00_AXI_0] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_1_1 [get_bd_intf_ports S01_AXI_0] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net SYS_CLK_0_1 [get_bd_intf_ports C0_SYS_CLK_0] [get_bd_intf_pins ddr4_pl_0/SYS_CLK]
  connect_bd_intf_net -intf_net ddr4_pl_0_DDR4 [get_bd_intf_ports C0_DDR4_0] [get_bd_intf_pins ddr4_pl_0/DDR4]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins smartconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins smartconnect_2/S01_AXI]
  connect_bd_intf_net -intf_net smartconnect_2_M00_AXI [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins ddr4_pl_0/DDR4_S_AXI]

  # Create port connections
  connect_bd_net -net Net  [get_bd_ports S00_AXI_0_aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins smartconnect_2/aclk]
  connect_bd_net -net Net1  [get_bd_ports S01_AXI_0_aclk] \
  [get_bd_pins smartconnect_1/aclk] \
  [get_bd_pins proc_sys_reset_1/slowest_sync_clk] \
  [get_bd_pins smartconnect_2/aclk1]
  connect_bd_net -net ddr4_pl_0_ddr4_ui_clk  [get_bd_pins ddr4_pl_0/ddr4_ui_clk] \
  [get_bd_ports ddr4_ui_clk] \
  [get_bd_pins proc_sys_reset_2/slowest_sync_clk] \
  [get_bd_pins smartconnect_2/aclk2]
  connect_bd_net -net ddr4_pl_0_ddr4_ui_clk_sync_rst  [get_bd_pins ddr4_pl_0/ddr4_ui_clk_sync_rst] \
  [get_bd_pins proc_sys_reset_2/ext_reset_in]
  connect_bd_net -net ddr4_pl_0_init_calib_complete  [get_bd_pins ddr4_pl_0/init_calib_complete] \
  [get_bd_ports c0_init_calib_complete_0]
  connect_bd_net -net ext_reset_in_0_1  [get_bd_ports S00_AXI_0_aresetn] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net ext_reset_in_1_1  [get_bd_ports S01_AXI_0_aresetn] \
  [get_bd_pins util_vector_logic_0/Op1] \
  [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins proc_sys_reset_1/peripheral_aresetn] \
  [get_bd_pins smartconnect_1/aresetn]
  connect_bd_net -net proc_sys_reset_2_interconnect_aresetn  [get_bd_pins proc_sys_reset_2/interconnect_aresetn] \
  [get_bd_pins smartconnect_2/aresetn]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn  [get_bd_pins proc_sys_reset_2/peripheral_aresetn] \
  [get_bd_pins util_vector_logic_1/Op1] \
  [get_bd_pins ddr4_pl_0/ddr4_aresetn]
  connect_bd_net -net util_vector_logic_0_Res  [get_bd_pins util_vector_logic_0/Res] \
  [get_bd_pins ddr4_pl_0/sys_rst]
  connect_bd_net -net util_vector_logic_1_Res  [get_bd_pins util_vector_logic_1/Res] \
  [get_bd_ports ddr4_ui_rst]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs ddr4_pl_0/DDR4_MEMORY_MAP/DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x00000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces S01_AXI_0] [get_bd_addr_segs ddr4_pl_0/DDR4_MEMORY_MAP/DDR4_ADDRESS_BLOCK] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design

  set_property synth_checkpoint_mode None [get_files  $str_bd_filepath]
  generate_target all [get_files $str_bd_filepath]
  make_wrapper -files [get_files $str_bd_filepath] -top
  add_files ${str_bd_folder}/${design_name}/hdl/${design_name}_wrapper.v

}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

#create_root_design ""


