proc run_prj { ADDR_WIDTH DATA_WIDTH ID_WIDTH WR_OUTSTANDING RD_OUTSTANDING ECC_EN IP_LOCATION PLATFORM_PART IP_NAME} {
################################################################################

# Output file loc
set ipDir       $IP_LOCATION/src/ip
set srcDir      $IP_LOCATION/src
set tclDir      $IP_LOCATION/script
set tempDir     $IP_LOCATION/work
set bitDir      $IP_LOCATION/bitfile
set dcpDir      $IP_LOCATION/dcp
################################################################################
set prjName     $IP_NAME
set prjDir      ./$prjName
set part        $PLATFORM_PART

set top_module uvw_axi4_to_ddr4

################################################################################

    create_project $prjName $prjDir -part $part
    source $tclDir/run_src_manage.tcl
    src_manage $ADDR_WIDTH $DATA_WIDTH $ID_WIDTH $WR_OUTSTANDING $RD_OUTSTANDING $ECC_EN $IP_LOCATION
    add_files -fileset sources_1 -norecurse ./design_1_wrapper.dcp
    set_property IS_ENABLED 0 [get_drc_checks NSTD-1] 
 
    synth_design -top $top_module \
		 -mode out_of_context \
	         -no_iobuf \
		 -verilog_define AXI4_ID_WIDTH=$ID_WIDTH \
                 -verilog_define AXI4_ADDR_WIDTH=$ADDR_WIDTH \
                 -verilog_define AXI4_DATA_WIDTH=$DATA_WIDTH \
   		 -verilog_define DDR_ECC_EN=$ECC_EN
    #implement_mig_cores
    #reset_property LOC [get_cells -hierarchical -filter { IS_LOC_FIXED == "TRUE" }] 
    #reset_property PACKAGE_PIN [get_ports *]
    #reset_property IOSTANDARD [get_ports *]
    write_xdc -exclude_physical ${top_module}.xdc 
    reset_timing
    source ${top_module}.xdc
    write_checkpoint ${top_module}.dcp -force
    write_verilog -mode synth_stub ${top_module}_stub.v -force 
    report_utilization -file ${top_module}_resource.txt -force 
    #start_gui
    #opt_design
    #place_design
    #route_design
    ##write_checkpoint $tempDir/${top_module}_route.dcp -force
    #write_bitstream -bin_file -file $bitDir/${top_module}.bit  -force
    #write_debug_probes $bitDir/${top_module}.ltx  -force

    ##start_gui
    #exit
}
