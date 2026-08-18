proc src_manage {addr_width data_width id_width wr_outstanding rd_outstanding ecc_en IP_LOCATION } { 

############################################################################
set srcDir      $IP_LOCATION/src
set tclDir      $IP_LOCATION/script

############################################################################
#source manage
############################################################################
#design source filelist
#    set source_list $srcDir/source_list.f
#    set fd_source [open $source_list r]

#		while {[gets $fd_source line_src] >= 0} {
#		    add_files -fileset sources_1  -norecurse $srcDir$line_src
#		}

#    close $fd_source
############################################################################
#constraint filelist
    #set const_list $srcDir/const_list.f
    #set fd_const [open $const_list r]
		
#		while {[gets $fd_const line_cst] >= 0} {
#		    add_files -fileset constrs_1 -norecurse $srcDir$line_cst
#		}

#    close $fd_const
############################################################################
#ip/bd generate
   # source $tclDir/run_ip_gen.tcl
   # source $tclDir/run_bd_gen.tcl
source $tclDir/axi_to_ddr_bd.tcl
create_root_design $addr_width $data_width $id_width $wr_outstanding $rd_outstanding $ecc_en
############################################################################
        set_property top design_1_wrapper [get_filesets sources_1]
	update_compile_order -fileset sources_1
 	update_compile_order -fileset constrs_1
###########################################################################
}
