# Optional UVHS probe overlay for NutShell fpga_diff bring-up.
#
# This uses Hejian UVHS probe_net/trigger_net only. It does not add Vivado/LTX
# ILA, does not touch the PCIe/XDMA IP internals, and does not change XDMA
# parameters.
#
# Enabled by default via the Makefile knob UVHS_ENABLE_PROBE_NET=1 (exported to
# both fe and be). On U2/VU19P_X4, enabling probe_net instantiates UHD and the
# platform mandates FMC3 for its capture DDR. f2 has only that one DDR slot, so
# script/partition.tcl pins the SoC AXI2DDR controller to b0.f0 (bind_system
# attaches it to the F0_FMC3 PDDR4DME card) and F2_FMC3 is left to UHD. The
# same constraint file also pins CPU+PCIe to f2 and the UART peripheral to f1
# so the auto-partitioner cannot drift. The same env var gates both files; set
# UVHS_ENABLE_PROBE_NET=0 to return to the non-UHD build with the SoC DDR back
# on F2_FMC3.

if {![info exists ::env(UVHS_ENABLE_PROBE_NET)] || $::env(UVHS_ENABLE_PROBE_NET) ne "1"} {
    puts "INFO: skip UVHS probe_net/trigger_net because UVHS_ENABLE_PROBE_NET is not 1"
    return
}

# sys_clk domain: reset/status and the BAR0 debug AXI-Lite readback mux.
probe_net -clock { fpga_top_debug.core_def.sys_clk_i } -add { \
    fpga_top_debug.core_def.sys_rstn_io \
    fpga_top_debug.core_def.cpu_rstn_io \
    fpga_top_debug.core_def.io_host_reset \
    fpga_top_debug.core_def.io_host_diff_enable \
    fpga_top_debug.core_def.xdma_link_up \
    fpga_top_debug.core_def.difftest_axil_cdc_m_resetn \
    fpga_top_debug.core_def.difftest_cfg_axilite_araddr[11:0] \
    fpga_top_debug.core_def.difftest_cfg_axilite_arvalid \
    fpga_top_debug.core_def.difftest_cfg_axilite_arready \
    fpga_top_debug.core_def.difftest_cfg_axilite_rdata[31:0] \
    fpga_top_debug.core_def.difftest_cfg_axilite_rresp[1:0] \
    fpga_top_debug.core_def.difftest_cfg_axilite_rvalid \
    fpga_top_debug.core_def.difftest_cfg_axilite_rready \
    fpga_top_debug.core_def.uvhs_debug_ar_select \
    fpga_top_debug.core_def.uvhs_debug_ar_fire \
    fpga_top_debug.core_def.uvhs_debug_rvalid \
    fpga_top_debug.core_def.uvhs_debug_rdata[31:0] \
}

# cpu_clk domain: CPU reset/difftest handshake and the memory AXI read channel.
probe_net -clock { fpga_top_debug.core_def.inter_soc_clk } -add { \
    fpga_top_debug.core_def.U_CPU_TOP.sys_rstn_i \
    fpga_top_debug.core_def.U_CPU_TOP.global_reset \
    fpga_top_debug.core_def.U_CPU_TOP.difftest_clock_enable \
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_arvalid \
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_arready \
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_araddr[31:0] \
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_rvalid \
    fpga_top_debug.core_def.U_CPU_TOP.mem_core_rready \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop._endpoint_fpgaIO_valid \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop._difftest_host_io_difftest_ready \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop._endpoint_step \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.cpu.nutcore.backend.io_in_0_valid \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.cpu.nutcore.backend.io_in_0_bits_cf_pc \
}

# pcie_clk domain: difftest streaming and the XDMA AXI-Lite config channel.
probe_net -clock { fpga_top_debug.core_def.difftest_pcie_clock } -add { \
    fpga_top_debug.core_def.cpu_rstn_pcie \
    fpga_top_debug.core_def.io_host_diff_enable_pcie \
    fpga_top_debug.core_def.xdma_link_up_pcie \
    fpga_top_debug.core_def.difftest_startup_ready_pcie \
    fpga_top_debug.core_def.difftest_startup_done_pcie \
    fpga_top_debug.core_def.difftest_startup_wait_pcie \
    fpga_top_debug.core_def.difftest_stream_enable_pcie \
    fpga_top_debug.core_def.difftest_c2h_rstn \
    fpga_top_debug.core_def.difftest_to_host_axis_tready \
    fpga_top_debug.core_def.difftest_to_host_axis_tvalid \
    fpga_top_debug.core_def.difftest_to_host_axis_tlast \
    fpga_top_debug.core_def.difftest_to_host_axis_tready_io \
    fpga_top_debug.core_def.difftest_to_host_axis_tvalid_io \
    fpga_top_debug.core_def.difftest_axil_cdc_s_resetn \
    fpga_top_debug.core_def.XDMA_AXI_LITE_araddr[11:0] \
    fpga_top_debug.core_def.XDMA_AXI_LITE_arvalid \
    fpga_top_debug.core_def.XDMA_AXI_LITE_arready \
    fpga_top_debug.core_def.XDMA_AXI_LITE_rdata[31:0] \
    fpga_top_debug.core_def.XDMA_AXI_LITE_rresp[1:0] \
    fpga_top_debug.core_def.XDMA_AXI_LITE_rvalid \
    fpga_top_debug.core_def.XDMA_AXI_LITE_rready \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.valid \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.diff2axis.io_axis_ready \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.diff2axis.io_axis_valid \
    fpga_top_debug.core_def.U_CPU_TOP.u_SimTop.difftest_host.diff2axis.io_axis_bits_last \
}

# Trigger groups; group names must match uhd_setting.ini and hw_run.tcl.
trigger_net -add -group uvhs_lite \
    -clock fpga_top_debug.core_def.difftest_pcie_clock \
    -signal { \
    fpga_top_debug.core_def.difftest_stream_enable_pcie \
    fpga_top_debug.core_def.difftest_to_host_axis_tvalid \
    }

trigger_net -add -group uvhs_bar0 \
    -clock fpga_top_debug.core_def.difftest_pcie_clock \
    -signal { \
    fpga_top_debug.core_def.XDMA_AXI_LITE_arvalid \
    }

trigger_net -add -group uvhs_bar0_sys \
    -clock fpga_top_debug.core_def.sys_clk_i \
    -signal { \
    fpga_top_debug.core_def.uvhs_debug_ar_fire \
    }
