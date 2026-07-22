##################################################################
# DATA FILE TCL PROCs
##################################################################

proc write_ddr4_file_design_1_ddr4_0_0 { str_filepath } {

   file mkdir [ file dirname "$str_filepath" ]
   set data_file [open $str_filepath  w+]

   puts $data_file {Part type,Part name,Rank,StackHeight,CA Mirror,Data mask,Address width,Row width,Column width,Bank width,Bank group width,CS width,CKE width,ODT width,CK width,Memory speed grade,Memory density,Component density,Memory device width,Memory component width,Data bits per strobe,IO Voltages,Data widths,Min period,Max period,tCKE,tFAW,tFAW_dlr,tMRD,tRAS,tRCD,tREFI,tRFC,tRFC_dlr,tRP,tRRD_S,tRRD_L,tRRD_dlr,tRTP,tWR,tWTR_S,tWTR_L,tXPR,tZQCS,tZQINIT,tCCD_3ds,cas latency,cas write latency,burst length}
   puts $data_file {SODIMMs,KSM26SES8/2133/noecc,1,1,0,1,17,17,10,2,2,1,1,1,1,93,16GB,16Gb,64,8,8,1.2V,64,938,1600,5000 ps,30000 ps,0,8 tck,32000 ps,14250 ps,7800000 ps,350000 ps,0,14250 ps,5300 ps,6400 ps,0,7500 ps,15000 ps,2500 ps,7500 ps,360 ns,128 tck,1024 tck,0,19,14,8}
   puts $data_file {SODIMMs,KSM26SES8/2133,1,1,0,1,17,17,10,2,2,1,1,1,1,93,16GB,16Gb,72,8,8,1.2V,72,938,1600,5000 ps,30000 ps,0,8 tck,32000 ps,14250 ps,7800000 ps,350000 ps,0,14250 ps,5300 ps,6400 ps,0,7500 ps,15000 ps,2500 ps,7500 ps,360 ns,128 tck,1024 tck,0,19,14,8}

   close $data_file
}
# End of write_ddr4_file_design_1_ddr4_0_0()

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design {addr_width data_width id_width wr_outstanding rd_outstanding ddr_ecc_en} {

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
  # add addr_check
    puts "checking config"
    if { ${addr_width} >= 35} {
        puts "--------------------------------------------------------"
        puts "ERROR:json addr config is ${addr_width} ,the max config for addr is 34"
        puts "--------------------------------------------------------"
        exit
    } else {
        puts "addr config successful"
    }
  # end addr_check
    puts "start gen MIG"
  # Create interface ports
  set C0_DDR4_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 C0_DDR4_0 ]
    if {$ddr_ecc_en == 1} {
    puts " --------------------------------------------------------"
    puts " MIG with ecc STEP1"
    puts " --------------------------------------------------------"
  set C0_DDR4_S_AXI_CTRL_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 C0_DDR4_S_AXI_CTRL_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
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
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $C0_DDR4_S_AXI_CTRL_0
    } else {
    puts " --------------------------------------------------------"
    puts " MIG without ecc STEP1"
    puts " --------------------------------------------------------"
    }

  set C0_SYS_CLK_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_SYS_CLK_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $C0_SYS_CLK_0

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
   CONFIG.HAS_REGION {0} \
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
   CONFIG.ADDR_WIDTH {36} \
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
   CONFIG.HAS_REGION {0} \
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

  # Create ports
  set S00_AXI_0_aclk [ create_bd_port -dir I -type clk -freq_hz 200000000 S00_AXI_0_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI_0} \
   CONFIG.ASSOCIATED_RESET {S00_AXI_0_aresetn} \
 ] $S00_AXI_0_aclk
  set S00_AXI_0_aresetn [ create_bd_port -dir I -type rst S00_AXI_0_aresetn ]
  set S01_AXI_0_aclk [ create_bd_port -dir I -type clk -freq_hz 200000000 S01_AXI_0_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI_0} \
   CONFIG.ASSOCIATED_RESET {S01_AXI_0_aresetn} \
 ] $S01_AXI_0_aclk
  set S01_AXI_0_aresetn [ create_bd_port -dir I -type rst S01_AXI_0_aresetn ]
  set c0_init_calib_complete_0 [ create_bd_port -dir O c0_init_calib_complete_0 ]

    if { $ddr_ecc_en == 1 } {
  set ddr4_ui_clk [ create_bd_port -dir O -type clk ddr4_ui_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {C0_DDR4_S_AXI_CTRL_0} \
 ] $ddr4_ui_clk
  set_property CONFIG.ASSOCIATED_BUSIF.VALUE_SRC DEFAULT $ddr4_ui_clk
} else {
  set ddr4_ui_clk [ create_bd_port -dir O -type clk ddr4_ui_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] $ddr4_ui_clk
}

  set ddr4_ui_rst [ create_bd_port -dir O -from 0 -to 0 -type rst ddr4_ui_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $ddr4_ui_rst

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.XBAR_DATA_WIDTH {512} \
 ] $axi_interconnect_0

  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
   # Generate the DDR4 Custom Parts File
   set str_ddr4_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $ddr4_0 ] ] ]
   set str_ddr4_file_name custom_parts_ddr4_KSM26SES8_2666_speed1.csv
   set str_ddr4_file_path ${str_ddr4_folder}/${str_ddr4_file_name}
    if {$ddr_ecc_en == 1} {
    puts " --------------------------------------------------------"
    puts " MIG with ecc STEP2"
    puts " --------------------------------------------------------"
   write_ddr4_file_design_1_ddr4_0_0 $str_ddr4_file_path

  set_property -dict [ list \
   CONFIG.C0.BANK_GROUP_WIDTH {2} \
   CONFIG.C0.DDR4_AxiAddressWidth {34} \
   CONFIG.C0.DDR4_AxiDataWidth {512} \
   CONFIG.C0.DDR4_CLKFBOUT_MULT {8} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {6} \
   CONFIG.C0.DDR4_CasLatency {19} \
   CONFIG.C0.DDR4_CasWriteLatency {14} \
   CONFIG.C0.DDR4_CustomParts {custom_parts_ddr4_KSM26SES8_2666_speed1.csv} \
   CONFIG.C0.DDR4_DIVCLK_DIVIDE {1} \
   CONFIG.C0.DDR4_DataMask {NO_DM_NO_DBI} \
   CONFIG.C0.DDR4_DataWidth {72} \
   CONFIG.C0.DDR4_Ecc {true} \
   CONFIG.C0.DDR4_InputClockPeriod {5002} \
   CONFIG.C0.DDR4_MemoryPart {KSM26SES8/2133} \
   CONFIG.C0.DDR4_MemoryType {SODIMMs} \
   CONFIG.C0.DDR4_TimePeriod {938} \
   CONFIG.C0.DDR4_isCustom {true} \
 ] $ddr4_0
         puts " ---------------------------------------------------------------"
         puts " MIG IP with ECC GEN OK "
         puts " ---------------------------------------------------------------"
 } elseif { $ddr_ecc_en == 0 } {
    puts " --------------------------------------------------------"
    puts " MIG without ecc STEP2"
    puts " --------------------------------------------------------"
    write_ddr4_file_design_1_ddr4_0_0 $str_ddr4_file_path
  set_property -dict [list \
    CONFIG.C0.DDR4_MemoryPart {KSM26SES8/2133/noecc} \
    CONFIG.C0.BANK_GROUP_WIDTH {2} \
    CONFIG.C0.DDR4_AxiAddressWidth {34} \
    CONFIG.C0.DDR4_AxiDataWidth {512} \
    CONFIG.C0.DDR4_CasLatency {19} \
    CONFIG.C0.DDR4_CasWriteLatency {14} \
    CONFIG.C0.DDR4_CustomParts {custom_parts_ddr4_KSM26SES8_2666_speed1.csv} \
    CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
    CONFIG.C0.DDR4_DataWidth {64} \
    CONFIG.C0.DDR4_InputClockPeriod {5002} \
    CONFIG.C0.DDR4_MemoryType {SODIMMs} \
    CONFIG.C0.DDR4_TimePeriod {938} \
    CONFIG.C0.DDR4_isCustom {true} \
  ] $ddr4_0
         puts " ---------------------------------------------------------------"
         puts " MIG IP without ECC GEN OK "
         puts " ---------------------------------------------------------------" 
  } else {
         puts " ---------------------------------------------------------------"
         puts " ERROR: DDR parameter error,please check DDR_ECC_EN parameter"
         puts " ---------------------------------------------------------------"
         exit
         }
  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_2 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_1

  # Create interface connections
  if {$ddr_ecc_en == 1 } {
  connect_bd_intf_net -intf_net C0_DDR4_S_AXI_CTRL_0_1 [get_bd_intf_ports C0_DDR4_S_AXI_CTRL_0] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI_CTRL]
    } else {}
  connect_bd_intf_net -intf_net C0_SYS_CLK_0_1 [get_bd_intf_ports C0_SYS_CLK_0] [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports S00_AXI_0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_0_1 [get_bd_intf_ports S01_AXI_0] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_ports C0_DDR4_0] [get_bd_intf_pins ddr4_0/C0_DDR4]

  # Create port connections
  connect_bd_net -net S01_ARESETN_1 [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins proc_sys_reset_1/peripheral_aresetn]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_ports ddr4_ui_clk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net ddr4_0_c0_init_calib_complete [get_bd_ports c0_init_calib_complete_0] [get_bd_pins ddr4_0/c0_init_calib_complete]
  connect_bd_net -net ext_reset_in_0_1 [get_bd_ports S00_AXI_0_aresetn] [get_bd_pins proc_sys_reset_2/ext_reset_in]
  connect_bd_net -net ext_reset_in_0_2 [get_bd_ports S01_AXI_0_aresetn] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_2/peripheral_aresetn]
  connect_bd_net -net slowest_sync_clk_0_1 [get_bd_ports S00_AXI_0_aclk] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins proc_sys_reset_2/slowest_sync_clk]
  connect_bd_net -net slowest_sync_clk_0_2 [get_bd_ports S01_AXI_0_aclk] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins ddr4_0/sys_rst] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net util_vector_logic_1_Res [get_bd_ports ddr4_ui_rst] [get_bd_pins util_vector_logic_1/Res]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x000400000000 -target_address_space [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x00000000 -range 0x000400000000 -target_address_space [get_bd_addr_spaces S01_AXI_0] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  if {$ddr_ecc_en == 1 } {
  assign_bd_address -offset 0x80000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces C0_DDR4_S_AXI_CTRL_0] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP_CTRL/C0_REG] -force
  } else {}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
##################################################################
# CHECK IPs
##################################################################
proc check_ips {} {
        set bCheckIPsPassed 1
        set bCheckIPs 1
        if { $bCheckIPs == 1 } {
                set list_check_ips "\ 
                xilinx.com:ip:ddr4:2.2\
                xilinx.com:ip:proc_sys_reset:5.0\
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
                        common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
                        return 3
                } else {
                        common::send_gid_msg -ssname BD::TCL -id 2014 -severity "INFO" "Checking IP catalog: $list_check_ips, PASSED!!! "
                }

        }

}

if {0} {
set IP_NAME uvw_axi4_to_ddr4

set ADDR_WIDTH 32
set DATA_WIDTH 256
set ID_WIDTH 24
set WR_OUTSTANDING 8
set RD_OUTSTANDING 8
set PLATFORM_PART xcvu19p-fsva3824-1-e
set IP_LOCATION /home/xinyin/Work/ddr_ip/uvw_axi4_to_ddr4

}

set out_dir $env(PWD)
exec rm -rf .gen  .srcs vivado*

set_part $PLATFORM_PART

add_files -norecurse $IP_LOCATION/src/uvw_axi4_to_ddr4_secondary_top.v
add_files -norecurse $IP_LOCATION/src/tk_pulse_gen.v
add_files -norecurse $IP_LOCATION/src/uvw_axi4_to_ddr4_buf_fwft.v
add_files -norecurse $IP_LOCATION/src/uvw_axi4_to_ddr4.v
add_files -norecurse $IP_LOCATION/src/uvw_ddr4_clk.v
add_files -norecurse $IP_LOCATION/src/uvw_ddr4_reg.v
add_files -norecurse $IP_LOCATION/src/uvw_stream_if.v
#add_files -norecurse $IP_LOCATION/src/uvw_u2_ip_if_wrapper.v
add_files -fileset constrs_1 -norecurse $IP_LOCATION/src/uvw_axi4_to_ddr4.xdc

add_files -norecurse $IP_LOCATION/src/uvw_tk/uvw_sbus_alp_if_regs.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/uvw_sbus_3_0_ip_if_wrapper.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/uvw_ur_alp_if.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/uvw_sbus_register_branch.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/uvw_axis_register_slice.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/axis_infrastructure_v1_1_vl_rfs.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/axis_register_slice_v1_1_vl_rfs.v
add_files -norecurse $IP_LOCATION/src/uvw_tk/axis_infrastructure_v1_1_1.vh
#ip generation
import_ip $IP_LOCATION/src/sfifo_72bx512_fwft.xci
upgrade_ip [get_ips sfifo_72bx512_fwft]
generate_target synthesis [get_files sfifo_72bx512_fwft.xci]
synth_ip [get_files sfifo_72bx512_fwft.xci]

#block design
set design_name design_1
create_bd_design $design_name
current_bd_design $design_name
check_ips

#add ecc option
#if user define ecc option ,default value is ecc off
if {![info exists DDR_ECC_EN]} {
    puts "Variable DDR_ECC_EN is not defined"
    set DDR_ECC_EN 0
} else {
    puts "Variable DDR_ECC_EN is defined"
}
#end add





create_root_design $ADDR_WIDTH $DATA_WIDTH $ID_WIDTH $WR_OUTSTANDING $RD_OUTSTANDING $DDR_ECC_EN
make_wrapper -force -files [get_files $design_name.bd] -top -import
generate_target synthesis [get_files $design_name.bd]
save_bd_design

#synthesis

synth_design -top $IP_NAME \
            -mode out_of_context \
            -no_iobuf \
            -verilog_define XSDB_SLV_DIS \
            -verilog_define AXI4_ID_WIDTH=$ID_WIDTH \
            -verilog_define AXI4_ADDR_WIDTH=$ADDR_WIDTH \
            -verilog_define AXI4_DATA_WIDTH=$DATA_WIDTH \
            -verilog_define DDR_ECC_EN=$DDR_ECC_EN
#output
write_xdc -exclude_physical $out_dir/$IP_NAME.xdc
reset_timing
source $out_dir/$IP_NAME.xdc
write_checkpoint -force $out_dir/$IP_NAME.dcp
write_verilog -mode synth_stub $out_dir/uvw_axi4_to_ddr4_stub.v
report_utilization -file $out_dir/uvw_axi4_to_ddr4_resource.txt

exit
