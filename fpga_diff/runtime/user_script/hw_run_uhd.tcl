# UVHS runtime UHD capture flow for the probe build (UVHS_ENABLE_PROBE_NET=1).
# Prerequisite: rtdb_test must be regenerated from the UHD hw.dat:
#   make -C ../uvhs rtdb

set_option runtime.database.remapping_enable true
set_option runtime.result.tclobj true

query -user
query -fpgas -all
query -version

load_db -release
load_db -db rtdb_test
load_rdb
dump_rdb -type debug -file debug.txt

config -connector

# Physical daughter card inventory from the EEPROMs. Check which F0 slot
# actually holds the spare PDDR4DME: binding.log bound the SoC DDR to
# b0.F0_FMC3, so F0_FMC3 must report a PDDR4DME here.
query -daughter_card
query -connector -type fmc
query -voltage

query -clock -default
# Dump the capture-station signal list as a wave session (.sg); in uvd/uvgui
# use Wave Session -> Restore Wave Session to load all probed signals at once.
query -capture -sgfile test.sg
config -clock -default
config -clock -commit
query -clock

reset -name rstn_sw6 -value 0
reset -name rstn_sw5 -value 0
reset -name rstn_sw4 -value 0
query -reset

download

# DDR instance <-> daughter card binding as detected at runtime.
query -ddr
query -ipinfo
initialize
after 1000

# Arm UHD trigger/capture before releasing the DUT reset so the capture
# window covers the whole bring-up.
# Declare the gated-clock frequencies before setting trigger conditions
# (RTM-103). Both are active-high gate enables:
#   SOC_CLK_CTRL BUFGCE output = inter_soc_clk = gated sys_clk_i (clk6_p,
#   90.422 ns -> 11.0592 MHz, see UVHS_CPU_CLK_PERIOD_NS).
#   TO_DIFFTEST_PCIE_CLK = XDMA user clock (phy_pclk, 8 ns -> 125 MHz).
# If probe.tcl is ever reduced to sys_clk-only domains, these two lines can be
# dropped (all capture stations then use runtime-known clocks).
trigger -set -gatedclk b0/f2/part_2/core_def/SOC_CLK_CTRL_UVin_u_bufgce/O -frequency 11.0592M -polarity H
trigger -set -gatedclk b0/f2/part_2/core_def/xdma_ep_i/TO_DIFFTEST_PCIE_CLK -frequency 125M -polarity H

query -trigger
trigger -ini_check ./user_script/uhd_setting.ini
trigger -set -condition ./user_script/uhd_setting.ini -position 5
capture -enable
trigger -enable

reset -name rstn_sw6 -value 0
reset -name rstn_sw5 -value 0
reset -name rstn_sw4 -value 0
after 1000

reset -name rstn_sw6 -value 1
reset -name rstn_sw4 -value 1
after 1000

reset -name rstn_sw5 -value 1
after 1000

# The trigger (first C2H tvalid beat) fires when the host side starts the
# difftest traffic; start the host workload within this timeout.
set trigger_tag [trigger -status -wait 1 -timeout 420 -tclobj]
puts "trigger_tag: $trigger_tag"

# 10M-cycle depth ~= 50 ms window at the 200 MHz UHD timebase, so host
# software startup latency (tvalid -> first tready beat) fits in the window.
upload_uhd -depth 10000000 -out uvhs_uhd -force
after 1000

wavegen -bindir ./UHD/uvhs_uhd
# Waveform: ./UHD/uvhs_uhd/UvData.usdb
# View: uvgui -u ./UHD/uvhs_uhd/UvData.usdb   (needs X11)
#    or uvd   -u ./UHD/uvhs_uhd/UvData.usdb   (command line)

puts "uvhs2 uhd capture done"
