# DDR backdoor load snippet, sourced by hw_run_download.tcl / hw_run_uhd.tcl
# when UVHS_FW_BIN is set (see the Makefiles' UVHS_FW_BIN knob). Expected
# state: bitstream downloaded, DDR initialized, system resets (rstn_sw6/sw4)
# released and the CPU reset (rstn_sw5) still held low. The image lands at
# DDR offset 0 (CPU-visible DDR base 0x8000_0000); afterwards the caller
# releases rstn_sw5 and the CPU boots from it.
#
# NOTE: the payload file is zero-padded IN PLACE to the 32-byte DDR word
# width (query -ddr Width = 256, so writemem addresses count 32-byte words).

set FW_BIN $::env(UVHS_FW_BIN)
if {![file exists $FW_BIN]} {
    error "fw payload not found: $FW_BIN (UVHS_FW_BIN)"
}

set FW_ALIGN 32
set fw_size [file size $FW_BIN]
set fw_rem [expr {$fw_size % $FW_ALIGN}]
if {$fw_rem != 0} {
    set fw_pad [expr {$FW_ALIGN - $fw_rem}]
    set fd [open $FW_BIN a+]
    fconfigure $fd -translation binary
    puts -nonewline $fd [string repeat "\x00" $fw_pad]
    close $fd
    set fw_size [expr {$fw_size + $fw_pad}]
    puts "padded $FW_BIN by $fw_pad bytes to $fw_size bytes (${FW_ALIGN}B aligned)"
}
set fw_last_addr [expr {$fw_size / $FW_ALIGN - 1}]

# Runtime DDR instance name from query -ddr (UHD build: B0.F0 / F0_FMC3).
writemem -rtl fpga_top_debug.core_def.U_UVHS_UVW_AXI4_TO_DDR4\[$fw_last_addr:0\] -file_type bin -file $FW_BIN
after 1000

# To verify the write landed, read the range back in the SAME session (a
# fresh uv_shell session finds the FPGA image already torn down) — e.g.
# source ./user_script/ddr_read.tcl with UVHS_RD_* set, or type the one-line
# readmem at the hspRun> prompt. See ddr_read.tcl.
