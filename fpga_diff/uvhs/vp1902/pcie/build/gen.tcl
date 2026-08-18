set _srcdir [file dirname [file normalize [info script]]]
open_project [file join $_srcdir .. build_prj xdma_ep_1902 xdma_ep_1902.xpr]
open_bd_design [get_files xdma_ep.bd]
generate_target all [get_files xdma_ep.bd]
add_files -norecurse [make_wrapper -files [get_files xdma_ep.bd] -top]
set_property top xdma_ep_wrapper [current_fileset]
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} { puts "SYNTH-FAILED"; exit 1 }
open_run synth_1
set outdir [file normalize [file join $_srcdir ..]]
# refresh the staged artifacts in place (xdma_ep.dcp is gitignored, tcl/stub committed)
write_checkpoint -force $outdir/xdma_ep.dcp
write_verilog -mode synth_stub -force $outdir/xdma_ep_Stub.v
write_bd_tcl -force $outdir/xdma_ep_regen.tcl
puts "GEN-ALL-DONE"
