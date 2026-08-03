# Ad-hoc DDR backdoor read snippet, sourced INSIDE a live runtime session
# (DB loaded, bitstream downloaded, DUT running or hung). Use cases: crash
# forensics (kernel log_buf after a hang), signature/result readout from
# baremetal workloads, cross-checking the XDMA H2C load path.
#
# There is deliberately NO batch mode / Makefile target for this: uv_shell
# tears down the FPGA image when the session exits, so by the time a fresh
# session could attach there is nothing left to read. The read must happen
# in the SAME session that downloaded the design:
#
#   1. Interactive, at the hspRun> prompt:
#        set ::env(UVHS_RD_ADDR) 0x80340000
#        set ::env(UVHS_RD_SIZE) 0x10000
#        set ::env(UVHS_RD_OUT) logbuf.bin
#        source ./user_script/ddr_read.tcl
#      (For a raw word range you can equally just type the one-line readmem;
#      this snippet only saves the byte-address -> 32-byte-word arithmetic.)
#   2. Embedded in a hw_run script: `source ./user_script/ddr_read.tcl` at
#      the point of interest (after trigger, on hang timeout, ...), with the
#      knobs exported before launching uv_shell.
#
# Knobs (environment):
#   UVHS_RD_ADDR  start BYTE address; >= 0x8000_0000 is treated as
#                 CPU-visible and the DDR base is subtracted, anything
#                 smaller is a raw DDR offset. Default 0.
#   UVHS_RD_SIZE  bytes to read (hex or dec). Default 0x8000 (32 KiB).
#   UVHS_RD_OUT   output file. Default ddr_readback.bin / ddr_readback.txt.
#   UVHS_RD_HEX   1 = hex text (one 256-bit word per line, ~2x size
#                 inflation — keep SIZE small); default = raw binary.

proc _rd_env {name default} {
    if {[info exists ::env($name)] && $::env($name) ne ""} { return $::env($name) }
    return $default
}

set RD_HEX  [_rd_env UVHS_RD_HEX 0]
set RD_ADDR [_rd_env UVHS_RD_ADDR 0]
set RD_SIZE [_rd_env UVHS_RD_SIZE 0x8000]
set RD_OUT  [_rd_env UVHS_RD_OUT [expr {$RD_HEX ? "ddr_readback.txt" : "ddr_readback.bin"}]]

# CPU-visible DDR base; addresses at or above it get the base subtracted.
set DDR_BASE 0x80000000
set off [expr {$RD_ADDR}]
if {$off >= $DDR_BASE} { set off [expr {$off - $DDR_BASE}] }

# Addresses handed to readmem count 32-byte DDR words (Width = 256).
set WORD 32
set first_word [expr {$off / $WORD}]
set last_word  [expr {($off + $RD_SIZE + $WORD - 1) / $WORD - 1}]
if {$off % $WORD != 0} {
    puts "WARNING: offset $off is not ${WORD}B-aligned; the readback starts at word boundary [expr {$first_word * $WORD}] (up to 31 leading bytes)"
}
puts "readback: offset [format 0x%x $off], $RD_SIZE bytes -> words \[$last_word:$first_word\] -> $RD_OUT"

if {$RD_HEX} {
    readmem -rtl fpga_top_debug.core_def.U_UVHS_UVW_AXI4_TO_DDR4\[$last_word:$first_word\] -hex -file $RD_OUT
} else {
    readmem -rtl fpga_top_debug.core_def.U_UVHS_UVW_AXI4_TO_DDR4\[$last_word:$first_word\] -file_type bin -file $RD_OUT
}
puts "ddr_read done"
