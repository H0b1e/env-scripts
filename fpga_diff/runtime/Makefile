.PHONY: run clean-logs


run:
	uv_shell -t runtime -d U2 -workdir ./u2_work_dir -script user_script/hw_run_download.tcl 2>&1 | tee download.log


clean-logs:
	rm -rf *.log

