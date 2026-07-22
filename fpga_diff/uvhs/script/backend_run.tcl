##########################################################################################
#backend
##########################################################################################
# set the HW database at the beginning
 
 	set_working_space hw.dat
	
	#set_parallel_option -max_threads 4 -max_processes 16 -label fpga
	#set_parallel_option -max_threads 4 -max_processes 4 -label fpga
    set_parallel_option -max_threads 8 -max_processes 16 -label fpga ; # Run FPGA implementation locally
		# set_parallel_option -max_threads 8 -max_processes 16 -submit_command {bsub -R "rusage[mem=80000]"} -terminate_command bkill -label fpga 
	# set_parallel_option -max_threads 4 -max_processes 20 -submit_command bsub -terminate_command bkill -label fpga; # set lsf commands for compile_fpga
	set_option time.auto_clock_config true
	set_option clock.transform_clock.multi_iteration true
	set_option clock.glitch.force_transform true
	set_option clock.async_control.force_accept true
	set_option time.enable_sign_off true
	set_option time.incremental_sign_off true

     if { [info exists env(PLATFORM)] } {
        set platform $env(PLATFORM)
    } else {
        set platform U2.2
    }
    create_system_design -name VU19P_X4 -platform U2.2

#    create_system_design -name VU19P_X4 -platform U2
	#source ./script/1B_4F_HGC_assemble.tcl
    #source ./4B_16F_HGC_assemble.tcl
	#source ./2core_6B_24F_4_2_HGC_assemble_multi_user.tcl
	source ./script/1B_4F_HGC_assemble.tcl
	source ./script/assign_pin.tcl

##########################################################################################
#backend
##########################################################################################
    create_design -name test
    read_netlist
    #report_synth_resource

## uniquify netlist:
    link_design
    report_resource -depth 4

## some optimization actions:
    instrument_design
    sanitize_design
    check_design
    init_runtime_data
    trigger_probe -check

## constant progagation here:
    sweep_design 
	
# clock inference and transform here
    infer_clock
    report_clock -inferred
    # Apply XDMA and DDR CDC exceptions after inferred clocks exist.
    source ./script/async_clocks.tcl
    transform_clock
## Please review the config_clock results to make sure the clock definition/resolution are expected
    #config_clock -check
	# Inside transform_clock, now config_clock -auto scheme will be called if auto_clock_config = true
	# if there is failure of clock scheme for internal (non-global (GCLK), non-transformed) clock, you can apply config_clock
	# config_clock -feedback | localize | assign_group [get_clock xxx]
	# config_clock -apply
	# config_clock -check
	# however we perfered to use following before transform clock to specify the strategy to apply for those internal clock
	#   create_generated_clock -name clk_internal_1 [get_xxx ]
	#   config_clock -feedback | localize | assign_group
	# the logic is you can handle those clock you concerned or you know; and leave others for tool to handle automatically

# instrument design for probe/trigger
    trigger_probe -group
    sweep_design -remap 
    #sweep_design
    report_clock


# design partition  
    check_design
    report_resource -depth 4
    report_system_resource
    list_partition_constraints -all
    #save_design -as pre_part
	#set_fill_rate -lut 50
	#set_fill_rate -lut 70 -lut6 30
	#set_fpga_count -number 2
	partition_design -tdc -tdss true 
	#partition_design -tdc -tdss true -target_max_cut 20000 -optimize_max_cut true -effort high 
	#partition_design -incremental auto -design_fpga_mapping ./Mapping
	#return
	#close_design
	#open_design pre_part
	#list_design
    report_resource -depth 4

## Localization:
    instrument_design
    localize_design -replicate_cell -clock -self_check
    sweep_design -keep_feedthrough
    localize_design -data

## Routing:
    route_design

## Please review check_timing result to make sure there are no critical warning/errors
    check_timing -verbose

# report timing data after routing
    report_system_performance -show_clock_relation -verbose
    report_path -normalize -exception -tdr -net -rtl -max_path 100 -sort_by fmax

# set binding  
    insert_tdm
    reopt_design -verbose
    bind_system
    save_runtime_data

# run P&R here
    #compile_fpga
	set_option compile.resourceUsageLimit 100
	# set_option compile.strategyNumRetry 1 ; # Unsupported by the installed UVHS version
	#set_option compile.selectBest true
	set_option compile.strategyNum 3
	set_option compile.strategy0 uv_placer_extra_timing_opt
	set_option compile.strategy1 uv_placer_balance_slrs
    set_option compile.strategy2 uv_high_fanout_explore
	#set_option compile.stage.prePlace /nfs/home/ningyu/uvhs_prj/uvhs_1core_cpu0906_soc0906_19p/script/uvw_axi4_to_ddr4_pblock.tcl

	set_option compile.stage.preOpt ./script/pre_opt.tcl
	set_option compile.stage.prePlace ./script/pre_place.tcl
	compile_fpga -parallel_option fpga -genScriptOnly -explore
	#compile_fpga -parallel_option fpga -genScriptOnly -explore -strategy /nfs/home/qiuzhichao/v1/uvhs_1core_cpu0906_soc0906_19p/script/user_strategy_template.tcl
	#compile_fpga -parallel_option fpga -genScriptOnly -strategy /nfs/home/qiuzhichao/v1/uvhs_1core_cpu0906_soc0906_19p/script/user_strategy_template.tcl
	compile_fpga -parallel_option fpga -runOnly -explore
	#compile_fpga -parallel_option fpga -runOnly -explore -strategy /nfs/home/qiuzhichao/v1/uvhs_1core_cpu0906_soc0906_19p/script/user_strategy_template.tcl
	#compile_fpga -parallel_option fpga -runOnly -strategy /nfs/home/qiuzhichao/v1/uvhs_1core_cpu0906_soc0906_19p/script/user_strategy_template.tcl

# report system performance based on P&R result
	report_path -max_path 100
	report_system_performance

# final merge and commit runtime DB
    commit_runtime_data

exit

