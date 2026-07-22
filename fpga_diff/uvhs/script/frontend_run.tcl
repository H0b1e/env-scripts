##########################################################################################
#frontend
##########################################################################################
# create the HW database at the beginning

    create_working_space hw.dat -force
    set_option syn.computeFeCheckSum true
#set parallel options; need to refined according to computing resource
	set_parallel_option -max_threads 4 -max_processes 16 -label frontend ; # Run frontend synthesis locally
	# set_parallel_option -max_threads 16 -max_processes 64 -submit_command bsub -terminate_command bkill -label frontend
	set_parallel_option -max_threads 4 -max_processes 16 -label fpga ; # Run FPGA implementation locally
	# set_parallel_option -max_threads 8 -max_processes 32 -submit_command {bsub -R "rusage[mem=80000]"} -terminate_command bkill -label fpga
	# set_parallel_option -max_threads 4 -max_processes 8 -submit_command bsub -terminate_command bkill -label fpga; # LSF configuration
	#set_parallel_option -max_threads 16 ; # set multi-threads for uvaps

## in normal flow, stop the flow with error; you can change the setting to true to continue the flow with error
	##set_option global.shell.continue_on_error true
	set_option global.msg.maxerror 1000000
## this is reqired for 22.10 for now
	#config_message -name MEM-016 -severity WARN
	config_message -name VERI-1180 -severity WARN
	config_message -name VERI-1930 -severity WARN
	#config_message -name VERI-1042 -severity WARN

## option to enable eco flow to specify how much resource to reserve when -eco is enabled in bind_system
	#set_option bind.eco.reserve_group 4
	## option will be ignored for U1
	#set_option bind.eco.reserve_trigger_cond 4

# add compile options

    set_option global.log.label MEMORY

# enable timing sign-off

	set_option syn.checkMultiDriver false
	set_option syn.multipleDriverConflict WOR
	set_option time.auto_clock_config true
	set_option clock.transform_clock.multi_iteration true
	set_option clock.glitch.force_transform true
	set_option clock.async_control.force_accept true
    set_option time.enable_sign_off true
	set_option time.incremental_sign_off true
	set_option signal.uhd.sampling_clock.allow_local_clock true
	#set_option syn.strategy AlternateRoutability
	#set_option syn.engine uvsyn
	set_option syn.logicFillingRateThreshold 0.001

# config the board configuration file here (board, daughter card, cables, etc)
    
    if { [info exists env(PLATFORM)] } {
        set platform $env(PLATFORM)
    } else {
        set platform U2.2
    }
    create_system_design -name VU19P_X4 -platform U2.2
	#source ./user_script/1B_4F_HGC_assemble.tcl
    #source ./user_script/4B_16F_HGC_assemble.tcl
	#source ./2core_6B_24F_4_2_HGC_assemble_multi_user.tcl
	source ./script/1B_4F_HGC_assemble.tcl

# assign_memory
	#assign_memory -instance simple_uart.u_ram -array_name BRAM -connector b0.F0_FMC2 -type EXSRAM
#    assign_memory -instance ram_1port_1inst.single_port_ram_inst1 -array_name BRAM -connector b0.F0_FMC2 -type EXSRAM
		
# replace_driver -original system.chipset.clk_mmcm.chipset_clk -new top_chipset_clk -port -clock chipset_clk

## config probe, trigger signal here
#
    if {[file exists ./script/probe.tcl]} {
        source ./script/probe.tcl
    }

#	probe_net -clock { ram_1port_1inst.gclk } -add {\
#        ram_1port_1inst.ram_traffic_1w1r_inst1.ram_addr ram_1port_1inst.ram_traffic_1w1r_inst1.ram_en\
#        ram_1port_1inst.ram_traffic_1w1r_inst1.ram_din ram_1port_1inst.ram_traffic_1w1r_inst1.ram_dout\
#        ram_1port_1inst.ram_traffic_1w1r_inst1.ram_we ram_1port_1inst.error_cnt1\
#    }
#
#	trigger_net -add -group test1 -probe\
#        -clock ram_1port_1inst.gclk\
#        -signal {\
#		    ram_1port_1inst.reset_logic\
#            ram_1port_1inst.ram_traffic_1w1r_inst1.error\
# 	}
#
# add constraints file here
    
    set_constraint_files ./script/timing.tcl

# create reset

    #create_reset -port simple_uart.i_rstn -active 0
	create_reset -port fpga_top_debug.rstn_sw6 -active 0
	create_reset -port fpga_top_debug.rstn_sw5 -active 0
	create_reset -port fpga_top_debug.rstn_sw4 -active 0


# set partition and assign pin
    
    set_partition_constraint_file ./script/partition.tcl
	source ./script/assign_pin.tcl

#assign route
#   assign_route -signals [get_nets top.din] -path {b0.f0 b0.f1 b0.f2 b0.f3}

# add black_box here
    
#   set_blackbox -module generalBD -source_file ./demo_common_script/gBD_force_monitor/gbd_ip/generalBD/generalBD.dcp -clock_enable_pairs {dut_clk dut_clk_en 1} -generalbd
#   set_blackbox -module ddr3_1 -source_file ./0_design/ip/ddr3_1/ddr3_1.dcp
	set_blackbox -module blk_mem_gen_0  			-source_file ./rtl/soc/blk_mem_gen_0.dcp
	set_blackbox -module data_bridge     			-source_file ./rtl/soc/data_bridge.dcp
	set_blackbox -module AXI_bridge      			-source_file ./rtl/soc/AXI_bridge.dcp
	set_blackbox -module xdma_ep					-source_file ./rtl/device/pcie/xdma_ep.dcp \
		-script_file {postLink ./script/bufg_gt_async.tcl}
	#set_blackbox -module jtag_ddr_subsys_wrapper 	-source_file ./rtl/soc/jtag_ddr_subsys_wrapper.dcp 
	set_ip -module uvw_axi4_to_ddr4			-source_file ./rtl/soc/uvw_axi4_to_ddr4.dcp -clock_enable_pairs {ddr4ip_dut_axi_aclk ddr4ip_dut_axi_aclk_en 1} -script_file {prePlace ./script/uvw_axi4_to_ddr4_pblock.tcl}
	read_verilog ./rtl/soc/uvw_axi4_to_ddr4_Stub.v

# add design filelist here
    #read_verilog -file ./rtl/filelist.f -mfcu 
    read_verilog -f ./rtl/filelist.f -mfcu 
	#read_verilog -file ./read_verilog.tcl -mfcu

# run elaborate here
    
    #elaborate_design simple_uart
    elaborate_design fpga_top_debug
    #elaborate_design DWC_ddrctl

# run synth here

    synthesize_design -parallel_option frontend

    #read_netlist -file [glob hw.dat/Synthesis/Vivado/Edif/*/*.v]
    #write_eqcheck_files  	
    
    save_working_space

exit

