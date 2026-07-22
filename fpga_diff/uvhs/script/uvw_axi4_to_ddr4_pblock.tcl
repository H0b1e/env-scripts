proc xchar {str pat} {
    set len_pat [string length $pat]
    set index [string first $pat $str]
    set x " "
    if {$index == -1} { 
        puts "$pat does not exist in $str"
        return -1} else { 
        set x [string range $str 0 [expr $len_pat -1 + $index]] 
        return $x }
}
set region_pattern [0-9]+
set path_pattern u_uvw_axi4_to_ddr4_design_1_wrapper_987cukl
set nets [get_nets -hierarchical -filter "NAME=~*${path_pattern}/C0_DDR4_0_ba[0]"]
foreach net $nets { 
    set path [xchar $net $path_pattern] 
    set pblock_top_cell  [string range $net 0 [string first $path_pattern $net]-2 ]
    set ba0_loc [get_package_pins  -of_objects [get_ports -of_objects [get_nets -hierarchical -filter "NAME=~${path}/C0_DDR4_0_ba[0]" ] ] ]
    #set ddr_ui_clock_loads [all_fanout -flat -only_cells  [get_pins -hierarchical  -filter "NAME=~${path}/design_1_i/ddr4_0/inst/u_ddr4_infrastructure/u_bufg_divClk/O" ]]
    set ddr_clock_regions [get_clock_regions -of_objects [get_sites -of_objects [ get_cells -hierarchical  -filter "NAME=~${path}/design_1_i/ddr4_0"]]]
    set x []
    set y []
    foreach region $ddr_clock_regions {
        set pot [regexp -all -inline $region_pattern $region ]
        puts $pot
        foreach {i j} $pot {
            lappend x $i
            lappend y $j
        }
    }
    set x [lsort $x]
    set y [lsort $y]
    set x_min [lindex $x 0]
    if { [expr $x_min - 1 ] < 0 } { set x_max [expr [lindex $x [expr [llength $x] - 1] ] + 2 ] } else { 
        set x_max [expr [lindex $x [expr [llength $x] - 1] ] + 1 ]
        set x_min [ expr  $x_min -1  ]}
    set y_min [lindex $y 0] 
    set y_max [lindex $y [expr [llength $y] - 1 ]] 
    set ddr_clock_region_left CLOCKREGION_X${x_min}Y${y_min}
    set ddr_clock_region_right CLOCKREGION_X${x_max}Y${y_max}

    set pb_clock_region ${ddr_clock_region_left}:${ddr_clock_region_right}
    puts "----------------------------------------------------"
    puts "pblock region ${pb_clock_region}"
    puts "----------------------------------------------------"
    set pb_loc DDR_BA0_loc${ba0_loc}
    delete_pblocks [get_pblocks $pb_loc]
    create_pblock $pb_loc
    set_property IS_SOFT 0 [get_pblocks $pb_loc]
    #add_cells_to_pblock [get_pblocks $pb_loc] [get_cells $ddr_ui_clock_loads]
    add_cells_to_pblock [get_pblocks $pb_loc] [get_cells -hierarchical  -filter "NAME=~${pblock_top_cell}"]
    puts "add pblock ,dat-24-07-03"
    resize_pblock [get_pblocks $pb_loc] -add $pb_clock_region
}




