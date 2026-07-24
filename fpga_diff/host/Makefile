# Hejian UVHS FPGA-host Makefile.
#
# Runs on the FPGA host (19p-host). Does NOT program the board — that is done
# on the runtime host (19p-runtime) via ../runtime (`make -C ../runtime run`,
# uv_shell -t runtime). After the runtime side finishes the download, this
# side enumerates PCIe, loads xdma-chr.ko, and runs fpga-host to burn the
# workload via XDMA H2C and run DiffTest.
#
# Common usage:
#   make check          verify required binaries/paths are set
#   make preflight      readonly PCIe enumeration check
#   make bars           peek BAR0/BAR1 + signatures
#   make driver         load xdma-chr.ko (sudo)
#   make workload       run fpga-host H2C + DiffTest
#   make smoke          quick XDMA H2C/C2H read-write smoke test (optional)
#   make clean-logs

RUN_TAG       ?= $(shell hostname)-$(shell date +%Y%m%d-%H%M%S)
WORKDIR       ?= $(CURDIR)
SCRIPT_DIR    ?= $(WORKDIR)/host_script
WORKLOAD_BIN  ?= $(WORKDIR)/ready-to-run/microbench-riscv64-nutshell.bin
LOG_DIR       ?= $(WORKDIR)/logs

# Caller MUST provide these (no silent defaults — better to fail loud).
XDMA_BDF      ?= 0000:01:00.0
XDMA_CHR_KO   ?= $(WORKDIR)/ready-to-run/xdma-chr.ko
FPGA_HOST_BIN ?= $(WORKDIR)/ready-to-run/fpga-host.with-uart
FPGA_NEMU_SO  ?= $(WORKDIR)/ready-to-run/riscv64-nemu-interpreter-so
FPGA_HOST_WORKDIR ?= $(WORKDIR)/ready-to-run/fpga-host-build

export WORKDIR ?= $(CURDIR)
export XDMA_BDF          ?= 0000:01:00.0
export XDMA_CHR_KO       ?= $(WORKDIR)/ready-to-run/xdma-chr.ko
export FPGA_HOST_BIN     ?= $(WORKDIR)/ready-to-run/fpga-host.with-uart
export FPGA_NEMU_SO      ?= $(WORKDIR)/ready-to-run/riscv64-nemu-interpreter-so
export FPGA_HOST_WORKDIR ?= $(WORKDIR)/ready-to-run/fpga-host-build
export FPGA_DIFF_RUN_TAG := $(RUN_TAG)
export XDMA_CHR_LOAD_TAG := $(RUN_TAG)
export FPGA_WORKLOAD_BIN := $(WORKLOAD_BIN)
export FPGA_HOST_LOG_DIR := $(LOG_DIR)
export FPGA_HOST_DDR_PRELOADED ?= 0
export FPGA_NO_DIFF ?= 0
export XDMA_CLEAR_DRIVER_OVERRIDE ?= 0

.PHONY: help check rescan preflight bars driver workload smoke clean-logs

help:
	@echo "Hejian UVHS FPGA-host targets (workdir: $(WORKDIR))"
	@echo "  make preflight   readonly PCIe enumeration check (host_preflight_readonly.sh)"
	@echo "  make bars        peek BAR0/BAR1 + signatures (host_peek_xdma_bars.sh)"
	@echo "  make driver      load xdma-chr.ko (host_xdma_chr_probe.sh, needs sudo)"
	@echo "  make workload    run fpga-host H2C + DiffTest (host_fpga_diff_strace_run.sh)"
	@echo "  make smoke       XDMA H2C/C2H read-write smoke (host_xdma_rw_smoke.sh)"
	@echo "  make check       verify required binaries/paths are set"
	@echo "  make clean-logs  remove logs/*.log"
	@echo ""
	@echo "Required variables (set via env or make override):"
	@echo "  XDMA_BDF=$(XDMA_BDF)"
	@echo "  XDMA_CHR_KO=$(XDMA_CHR_KO)"
	@echo "  FPGA_HOST_BIN=$(FPGA_HOST_BIN)"
	@echo "  FPGA_NEMU_SO=$(FPGA_NEMU_SO)"
	@echo "Optional:"
	@echo "  WORKLOAD_BIN=$(WORKLOAD_BIN)"
	@echo "  FPGA_HOST_WORKDIR=$(FPGA_HOST_WORKDIR)"
	@echo "  RUN_TAG=$(RUN_TAG)"

check:
	@test -d "$(SCRIPT_DIR)" || { echo "ERROR: host_script/ missing at $(SCRIPT_DIR)"; exit 1; }
	@test -f "$(WORKLOAD_BIN)" || { echo "ERROR: workload bin missing: $(WORKLOAD_BIN)"; exit 1; }
	@test -n "$(XDMA_CHR_KO)" -a -f "$(XDMA_CHR_KO)" || { echo "ERROR: XDMA_CHR_KO missing or not a file: '$(XDMA_CHR_KO)'"; exit 1; }
	@test -n "$(FPGA_HOST_BIN)" -a -x "$(FPGA_HOST_BIN)" || { echo "ERROR: FPGA_HOST_BIN missing or not executable: '$(FPGA_HOST_BIN)'"; exit 1; }
	@test -n "$(FPGA_NEMU_SO)" -a -f "$(FPGA_NEMU_SO)" || { echo "ERROR: FPGA_NEMU_SO missing or not a file: '$(FPGA_NEMU_SO)'"; exit 1; }
	@echo "OK: scripts + workload=$(WORKLOAD_BIN) + driver + fpga-host + NEMU all present"
	@echo "RUN_TAG=$(RUN_TAG)"

rescan:
	sudo bash $(SCRIPT_DIR)/host_rescan.sh 

preflight:
	@mkdir -p $(LOG_DIR)
	bash $(SCRIPT_DIR)/host_preflight_readonly.sh 2>&1 | tee $(LOG_DIR)/$(RUN_TAG).preflight.log

bars:
	@mkdir -p $(LOG_DIR)
	bash $(SCRIPT_DIR)/host_peek_xdma_bars.sh 2>&1 | tee $(LOG_DIR)/$(RUN_TAG).bar.log

driver: check
	@mkdir -p $(LOG_DIR)
	sudo env \
		FPGA_DIFF_RUN_TAG=$(RUN_TAG) \
		XDMA_CLEAR_DRIVER_OVERRIDE=$(XDMA_CLEAR_DRIVER_OVERRIDE) \
		XDMA_CHR_LOAD=1 \
		XDMA_CHR_LOAD_TAG=$(RUN_TAG) \
		XDMA_CHR_KO=$(XDMA_CHR_KO) \
		XDMA_BDF=$(XDMA_BDF) \
	  bash $(SCRIPT_DIR)/host_xdma_chr_probe.sh 2>&1 | tee $(LOG_DIR)/$(RUN_TAG).driver.log
	@ls -l /dev/xdma* 2>&1 || echo "WARN: /dev/xdma* not found after driver load"
	sudo chmod 666 /dev/xdma0_*

workload: check
	@mkdir -p $(LOG_DIR) $(FPGA_HOST_WORKDIR)
	bash $(SCRIPT_DIR)/host_fpga_diff_strace_run.sh 2>&1 | tee $(LOG_DIR)/$(RUN_TAG).difftest.log

smoke:
	@mkdir -p $(LOG_DIR)
	bash $(SCRIPT_DIR)/host_xdma_rw_smoke.sh 2>&1 | tee $(LOG_DIR)/$(RUN_TAG).smoke.log

clean-logs:
	rm -rf $(LOG_DIR)
