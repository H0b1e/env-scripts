# Minimal univista runtime bringup flow.
# peplace your rtdb with rtdb_test

set_option runtime.database.remapping_enable true
set_option runtime.result.tclobj true

query -user
query -fpgas -all
query -version

#allocate -board {b0.f1, b0.f2}

load_db -release
load_db -db rtdb_test

config -connector
query -connector -type fmc
query -voltage

query -clock -default
config -clock -default
config -clock -commit
query -clock

reset -name rstn_sw6 -value 0
reset -name rstn_sw5 -value 0
reset -name rstn_sw4 -value 0
query -reset

download

query -ipinfo
initialize
after 1000

reset -name rstn_sw6 -value 0
reset -name rstn_sw5 -value 0
reset -name rstn_sw4 -value 0
after 1000

reset -name rstn_sw6 -value 1
reset -name rstn_sw4 -value 1
after 1000

# Optional DDR backdoor load (UVHS_FW_BIN set): stage the boot image into DDR
# while the CPU reset is held, so the CPU boots from it below.
if {[info exists ::env(UVHS_FW_BIN)] && $::env(UVHS_FW_BIN) ne ""} {
    source ./user_script/ddr_backdoor.tcl
}

reset -name rstn_sw5 -value 1
after 1000


