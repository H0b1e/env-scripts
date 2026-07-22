# -----------------------------------------------------------------------------
# CDC constraint for the XDMA PCIe GT internal clock.
#
# The XDMA IP creates a free-running clock on bufg_gt_intclk/O with no
# analyzable primary-clock master. It is asynchronous to pcie_refclk.
# -----------------------------------------------------------------------------
set fp     [get_pins -quiet -hierarchical *bufg_gt_intclk/O]
set intclk [get_clocks -quiet -of_objects $fp]
set refclk [get_clocks -quiet pcie_refclk]

if {[llength $intclk] && [llength $refclk]} {
    puts "INFO: Setting XDMA GT internal clock as asynchronous to pcie_refclk"
    set_clock_groups -name xdma_gt_intclk_async -asynchronous \
        -group $refclk \
        -group $intclk
} else {
    puts "UV-WARN: bufg_gt_intclk or pcie_ep_refclk not found (fp=[llength $fp] intclk=[llength $intclk] refclk=[llength $refclk]), async group skipped"
}
