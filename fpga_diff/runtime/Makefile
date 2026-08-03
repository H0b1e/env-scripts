.PHONY: run uhd query-cards wave backdoor clean-logs

# Optional DDR backdoor load during "run"/"uhd": when set, the named image
# is written into the SoC DDR via the UVHS memory backdoor while the CPU
# reset is held (see user_script/ddr_backdoor.tcl). Empty = disabled.
UVHS_FW_BIN ?=
export UVHS_FW_BIN


run:
	uv_shell -t runtime -d U2 -workdir ./u2_work_dir -script user_script/hw_run_download.tcl 2>&1 | tee download.log

# UHD capture run (probe build). Refresh rtdb_test first: make -C ../uvhs rtdb
uhd:
	uv_shell -t runtime -d U2 -workdir ./u2_work_dir -script user_script/hw_run_uhd.tcl 2>&1 | tee uhd.log

# Daughter card EEPROM inventory only (no download); checks which F0 slot
# physically holds the spare PDDR4DME.
query-cards:
	uv_shell -t runtime -d U2 -workdir ./u2_work_dir -script user_script/query_cards.tcl 2>&1 | tee query_cards.log

# Open the last UHD capture with all probed signals pre-loaded (test.sg is
# written by query -capture -sgfile in hw_run_uhd.tcl) and the full RTL
# hierarchy (-d uvsim.db, bundled into rtdb_test by extract_rtdb.sh -all).
# Needs X11.
wave:
	uvd -d ./rtdb_test/Uvd/uvsim.db -usdb ./u2_work_dir/UHD/uvhs_uhd/UvData.usdb --wses ./u2_work_dir/test.sg

# Shorthand for "make run" with the DDR backdoor load enabled.
backdoor:
	@test -n "$(UVHS_FW_BIN)" || { echo "usage: make backdoor UVHS_FW_BIN=<image.bin>"; exit 1; }
	uv_shell -t runtime -d U2 -workdir ./u2_work_dir -script user_script/hw_run_download.tcl 2>&1 | tee backdoor.log

clean-logs:
	rm -rf *.log
