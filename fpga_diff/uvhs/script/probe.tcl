# Optional UVHS probe overlay for NutShell fpga_diff bring-up.
#
# This uses Hejian UVHS probe_net/trigger_net only. It does not add Vivado/LTX
# ILA, does not touch the PCIe/XDMA IP internals, and does not change XDMA
# parameters.
#
# Keep this disabled by default. On U2/VU19P_X4, enabling probe_net instantiates
# UHD and the platform mandates FMC3 for its capture DDR. That conflicts with a
# functional SoC AXI2DDR using the board's FMC3 DIMM; declaration order does not
# change the binding. Use this overlay only for a dedicated waveform build.

if {![info exists ::env(UVHS_ENABLE_PROBE_NET)] || $::env(UVHS_ENABLE_PROBE_NET) ne "1"} {
    puts "INFO: skip UVHS probe_net/trigger_net because UVHS_ENABLE_PROBE_NET is not 1"
    return
}

proc uvhs_try_probe {clock signal} {
    if {[catch {probe_net -clock $clock -add [list $signal]} err]} {
        puts "WARNING: skip probe $signal: $err"
    }
}

proc uvhs_try_trigger {clock group signal} {
    if {[info exists ::env(UVHS_ENABLE_TRIGGER_NET)] && $::env(UVHS_ENABLE_TRIGGER_NET) eq "0"} {
        puts "INFO: skip trigger_net group $group because UVHS_ENABLE_TRIGGER_NET=0"
        return
    }
    if {[catch {trigger_net -add -group $group -clock $clock -signal [list $signal]} err]} {
        puts "WARNING: skip trigger $signal: $err"
    }
}

set core fpga_top_debug.core_def
set cpu ${core}.U_CPU_TOP
set sys_clk ${core}.sys_clk_i
set cpu_clk ${core}.inter_soc_clk
set pcie_clk ${core}.difftest_pcie_clock

foreach signal {
    fpga_top_debug.core_def.sys_rstn_io
    fpga_top_debug.core_def.cpu_rstn_io
    fpga_top_debug.core_def.io_host_reset
    fpga_top_debug.core_def.io_host_diff_enable
    fpga_top_debug.core_def.xdma_link_up
    fpga_top_debug.core_def.difftest_axil_cdc_m_resetn
    fpga_top_debug.core_def.difftest_cfg_axilite_araddr[11:0]
    fpga_top_debug.core_def.difftest_cfg_axilite_arvalid
    fpga_top_debug.core_def.difftest_cfg_axilite_arready
    fpga_top_debug.core_def.difftest_cfg_axilite_rdata[31:0]
    fpga_top_debug.core_def.difftest_cfg_axilite_rresp[1:0]
    fpga_top_debug.core_def.difftest_cfg_axilite_rvalid
    fpga_top_debug.core_def.difftest_cfg_axilite_rready
    fpga_top_debug.core_def.uvhs_debug_ar_select
    fpga_top_debug.core_def.uvhs_debug_ar_fire
    fpga_top_debug.core_def.uvhs_debug_rvalid
    fpga_top_debug.core_def.uvhs_debug_rdata[31:0]
} {
    uvhs_try_probe $sys_clk $signal
}

foreach signal {
    fpga_top_debug.core_def.U_CPU_TOP.sys_rstn_i
    fpga_top_debug.core_def.U_CPU_TOP.global_reset
    fpga_top_debug.core_def.U_CPU_TOP.difftest_clock_enable
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_arvalid
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_arready
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_araddr[31:0]
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_rvalid
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_rready
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop._endpoint_fpgaIO_valid
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop._difftest_host_io_difftest_ready
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop._endpoint_step
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.cpu.nutcore.backend.io_in_0_valid
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.cpu.nutcore.backend.io_in_0_bits_cf_pc
} {
    uvhs_try_probe $cpu_clk $signal
}

foreach signal {
    fpga_top_debug.core_def.cpu_rstn_pcie
    fpga_top_debug.core_def.io_host_diff_enable_pcie
    fpga_top_debug.core_def.xdma_link_up_pcie
    fpga_top_debug.core_def.difftest_startup_ready_pcie
    fpga_top_debug.core_def.difftest_startup_done_pcie
    fpga_top_debug.core_def.difftest_startup_wait_pcie
    fpga_top_debug.core_def.difftest_stream_enable_pcie
    fpga_top_debug.core_def.difftest_c2h_rstn
    fpga_top_debug.core_def.difftest_to_host_axis_tready
    fpga_top_debug.core_def.difftest_to_host_axis_tvalid
    fpga_top_debug.core_def.difftest_to_host_axis_tlast
    fpga_top_debug.core_def.difftest_to_host_axis_tready_io
    fpga_top_debug.core_def.difftest_to_host_axis_tvalid_io
    fpga_top_debug.core_def.difftest_axil_cdc_s_resetn
    fpga_top_debug.core_def.XDMA_AXI_LITE_araddr[11:0]
    fpga_top_debug.core_def.XDMA_AXI_LITE_arvalid
    fpga_top_debug.core_def.XDMA_AXI_LITE_arready
    fpga_top_debug.core_def.XDMA_AXI_LITE_rdata[31:0]
    fpga_top_debug.core_def.XDMA_AXI_LITE_rresp[1:0]
    fpga_top_debug.core_def.XDMA_AXI_LITE_rvalid
    fpga_top_debug.core_def.XDMA_AXI_LITE_rready
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.valid
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.diff2axis.io_axis_ready
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.diff2axis.io_axis_valid
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.diff2axis.io_axis_bits_last
} {
    uvhs_try_probe $pcie_clk $signal
}

uvhs_try_trigger $pcie_clk uvhs_lite fpga_top_debug.core_def.difftest_stream_enable_pcie
uvhs_try_trigger $pcie_clk uvhs_lite fpga_top_debug.core_def.difftest_to_host_axis_tvalid
uvhs_try_trigger $pcie_clk uvhs_bar0 fpga_top_debug.core_def.XDMA_AXI_LITE_arvalid
uvhs_try_trigger $sys_clk uvhs_bar0_sys fpga_top_debug.core_def.uvhs_debug_ar_fire
