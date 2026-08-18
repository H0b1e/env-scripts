
################################################################
# This is a generated script based on design: sfifo_72bx512_fwft
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

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
# source sfifo_72bx512_fwft_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvp1902-vsva6865-2MP-e-S
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name sfifo_72bx512_fwft

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
xilinx.com:ip:emb_fifo_gen:1.0\
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
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

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

  # Create ports
  set full [ create_bd_port -dir O full ]
  set din [ create_bd_port -dir I -from 71 -to 0 din ]
  set wr_en [ create_bd_port -dir I wr_en ]
  set empty [ create_bd_port -dir O empty ]
  set dout [ create_bd_port -dir O -from 71 -to 0 dout ]
  set rd_en [ create_bd_port -dir I rd_en ]
  set rst [ create_bd_port -dir I rst ]
  set clk [ create_bd_port -dir I -type clk clk ]
  set prog_full [ create_bd_port -dir O prog_full ]
  set data_count [ create_bd_port -dir O -from 9 -to 0 data_count ]

  # Create instance: emb_fifo_gen_0, and set properties
  set emb_fifo_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:emb_fifo_gen:1.0 emb_fifo_gen_0 ]
  set_property -dict [list \
    CONFIG.ENABLE_ALMOST_EMPTY {false} \
    CONFIG.ENABLE_ALMOST_FULL {false} \
    CONFIG.ENABLE_OVERFLOW {false} \
    CONFIG.ENABLE_PROGRAMMABLE_EMPTY {false} \
    CONFIG.ENABLE_READ_DATA_VALID {false} \
    CONFIG.ENABLE_UNDERFLOW {false} \
    CONFIG.ENABLE_WRITE_ACK {false} \
    CONFIG.FIFO_MEMORY_TYPE {BRAM} \
    CONFIG.FIFO_WRITE_DEPTH {512} \
    CONFIG.PROG_FULL_THRESH {500} \
    CONFIG.READ_DATA_WIDTH {72} \
    CONFIG.READ_MODE {FWFT} \
    CONFIG.WRITE_DATA_WIDTH {72} \
  ] $emb_fifo_gen_0


  # Create port connections
  connect_bd_net -net din_0_1  [get_bd_ports din] \
  [get_bd_pins emb_fifo_gen_0/din]
  connect_bd_net -net emb_fifo_gen_0_data_count  [get_bd_pins emb_fifo_gen_0/data_count] \
  [get_bd_ports data_count]
  connect_bd_net -net emb_fifo_gen_0_dout  [get_bd_pins emb_fifo_gen_0/dout] \
  [get_bd_ports dout]
  connect_bd_net -net emb_fifo_gen_0_empty  [get_bd_pins emb_fifo_gen_0/empty] \
  [get_bd_ports empty]
  connect_bd_net -net emb_fifo_gen_0_full  [get_bd_pins emb_fifo_gen_0/full] \
  [get_bd_ports full]
  connect_bd_net -net emb_fifo_gen_0_prog_full  [get_bd_pins emb_fifo_gen_0/prog_full] \
  [get_bd_ports prog_full]
  connect_bd_net -net rd_en_0_1  [get_bd_ports rd_en] \
  [get_bd_pins emb_fifo_gen_0/rd_en]
  connect_bd_net -net rst_0_1  [get_bd_ports rst] \
  [get_bd_pins emb_fifo_gen_0/rst]
  connect_bd_net -net wr_clk_0_1  [get_bd_ports clk] \
  [get_bd_pins emb_fifo_gen_0/wr_clk]
  connect_bd_net -net wr_en_0_1  [get_bd_ports wr_en] \
  [get_bd_pins emb_fifo_gen_0/wr_en]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

set_property synth_checkpoint_mode None [get_files  $str_bd_filepath]
generate_target all [get_files $str_bd_filepath]
make_wrapper -files [get_files $str_bd_filepath] -top
add_files ${str_bd_folder}/${design_name}/hdl/${design_name}_wrapper.v
