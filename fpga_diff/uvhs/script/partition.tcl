# Keep the platform default fill rates. On UVHS U2.2/VU19P_X4, calling
# set_fill_rate with only LUT/BRAM resets Probe-Group capacity to 0, which
# rejects any trigger/probe insertion during partition.

# UHD build DDR remap. With probe_net enabled, UHD claims f2's only DDR slot
# (F2_FMC3) for its capture DDR, so the SoC AXI2DDR controller cannot stay on
# f2. Pin the controller to b0.f0; bind_system then attaches it to the F0_FMC3
# PDDR4DME card (pddr4dme_inst0; F0_FMC0 and F0_FMC3 both physically hold
# PDDR4DME cards, confirmed by runtime "query -daughter_card") and the SoC
# memory AXI crosses f2<->f0 over the inter-FPGA TDM links. The SoC body and
# the PCIe EP stay pinned on f2 (the PCIe GT/pads are physically wired to f2)
# and the UART peripheral on f1 (its pads are on F1_FMC0), mirroring the
# reference 1-core project layout, so the auto-partitioner cannot drift the
# CPU toward f0.
# With probing disabled, leave everything unconstrained (fully auto partition,
# SoC DDR keeps binding to F2_FMC3).
if {[info exists ::env(UVHS_ENABLE_PROBE_NET)] && $::env(UVHS_ENABLE_PROBE_NET) eq "1"} {
    create_fpga -name b0.f2 -cells [get_cell core_def/U_CPU_TOP]
    create_fpga -name b0.f2 -cells [get_cell core_def/xdma_ep_i] -update
    create_fpga -name b0.f1 -cells [get_cell core_def/U_SYS_CFG] -update
    create_fpga -name b0.f0 -cells [get_cell core_def/U_UVHS_UVW_AXI4_TO_DDR4] -update
}
