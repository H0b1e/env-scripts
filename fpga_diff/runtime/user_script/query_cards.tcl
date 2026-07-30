# Minimal daughter card inventory: read the EEPROMs and report what is
# physically plugged into each slot, without downloading any bitstream.
# Use this to check which F0 slot holds the spare PDDR4DME (the UHD build's
# binding.log bound the SoC DDR to b0.F0_FMC3).

set_option runtime.database.remapping_enable true
set_option runtime.result.tclobj true

load_db -release
load_db -db rtdb_test

config -connector
query -daughter_card
query -connector -type fmc

puts "daughter card query done"
