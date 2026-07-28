SHELL := /bin/bash

# Stage09 trim project flow. The repository root is the working directory:
# hw.dat, logs/ and the RTDB archive are produced in place.
#
# Stage pipeline (ported from the legacy uv_script/Makefile):
#   preflight      - check uv_shell / vivado / csh availability
#   generate_ddr_dcp - regenerate the DDR DCP/stub locally with Vivado
#   prepare        - verify staged scripts and DCP inputs (XDMA hash-guarded)
#   filelist       - regenerate rtl/filelist.f from vendor/ + rtl/
#   check_modules  - grep the filelist sources for required modules
#   fe / be        - UVHS frontend (synthesis) / backend (P&R)
#   rtdb           - link hw.dat to ../hw.dat and extract ../runtime/rtdb_test
#   export_vivado_ip - regenerate the Vivado IP/BD checkpoints (slow, optional)

VIVADO ?= vivado
JOBS   ?= 8
# clk6_p target period (ns). 11.0592 MHz = 115200*16*6: exact 115200 baud at
# 16550 divisor 6, ~23% margin under the ~14.4 MHz runtime ceiling (higher
# targets get auto-relaxed by estimate_fmax_relax_mode and detune the UART).
# Keep nexus-am serial-16550.c divisor (11059200/(16*115200) == 6) consistent
# with 1e9 / this period, so clk6_p / (16 * divisor) stays at 115200.
UVHS_CPU_CLK_PERIOD_NS ?= 90.422

export UVHS_CPU_CLK_PERIOD_NS

# Local DDR DCP regeneration (frozen-compatible: 256b AXI / 34b addr / 14b ID / ECC off).
DDR_IP_DIR   := tools/ddr_ip
DDR_IP_JSON  := $(DDR_IP_DIR)/UV_FMCH_PDDR4DME/uvw_axi4_to_ddr4.json
DDR_IP_BUILD := .ddr_ip_build
DDR_DCP      := rtl/soc/uvw_axi4_to_ddr4.dcp
DDR_STUB     := rtl/soc/uvw_axi4_to_ddr4_Stub.v

# Modules that must be reachable from the RTL filelist before synthesis.
REQUIRED_MODULES ?= fpga_top_debug SimTop

# IP export selection. Default: regenerate every IP under script/ip/
# (AXI_bridge, blk_mem_gen_0, data_bridge, xdma_ep). The xdma_ep defaults in
# script/ip/xdma_ep.tcl reproduce the verified bar512c BAR layout (see the
# XDMA_AXILITE_MASTER_*/XDMA_ENABLE_PF0_BAR1 knobs there).
#   EXPORT_IP_ONLY=xdma_ep   regenerate just one IP
#   EXPORT_IP_SKIP=xdma_ep   regenerate all but the listed IPs
# jtag_ddr_subsys has no export entry: the trim flow never binds its DCP (the
# wrapper is synthesized as RTL with an implicit blackbox inner module).
EXPORT_IP_ONLY ?=
EXPORT_IP_SKIP ?=

.PHONY: all fe be rtdb clean preflight prepare filelist check_modules export_vivado_ip \
	generate_ddr_dcp ddr_ip

all: fe be

preflight:
	command -v uv_shell
	command -v vivado
	command -v csh
	$(VIVADO) -version | head -1

# Regenerate the DDR DCP/stub with Vivado when they are missing. Delete the
# installed artifacts (or the build dir) to force a rebuild.
generate_ddr_dcp:
	@if test -s "$(DDR_DCP)" && test -s "$(DDR_STUB)"; then \
		echo "INFO: DDR DCP/stub already present (remove them to regenerate)"; \
	else \
		python3 "$(DDR_IP_DIR)/gen_ddr4_ip.py" -j "$(DDR_IP_JSON)" \
			--build-dir "$(DDR_IP_BUILD)" --out-dir rtl/soc --force; \
	fi

ddr_ip: generate_ddr_dcp

prepare:
	@# All runtime scripts and staged inputs must exist in-tree; the DDR DCP and
	@# stub are produced locally by `make generate_ddr_dcp`.
	for f in script/frontend_run.tcl script/backend_run.tcl script/1B_4F_HGC_assemble.tcl \
	         script/assign_pin.tcl script/timing.tcl script/partition.tcl script/probe.tcl \
	         script/bufg_gt_async.tcl script/uvw_axi4_to_ddr4_pblock.tcl \
	         rtl/fpga_top_debug.sv rtl/core_def_xdma.sv \
	         rtl/soc/blk_mem_gen_0.dcp rtl/soc/data_bridge.dcp rtl/soc/AXI_bridge.dcp \
	         rtl/soc/uvw_axi4_to_ddr4.dcp rtl/soc/uvw_axi4_to_ddr4_Stub.v \
	         rtl/device/pcie/xdma_ep.dcp; do \
		test -s "$$f" || { echo "ERROR: missing staged input $$f (run make generate_ddr_dcp for DDR)" >&2; exit 1; }; \
	done
	mkdir -p logs

filelist:
	bash script/gen_filelist.sh rtl/filelist.f

check_modules: filelist
	bash script/check_modules.sh rtl/filelist.f "$(REQUIRED_MODULES)"

fe: generate_ddr_dcp prepare check_modules
	set -o pipefail; uv_shell -bypass_vivado_version_check -s ./script/frontend_run.tcl |& tee logs/frontend_run.log

be:
	mkdir -p logs
	set -o pipefail; uv_shell -bypass_vivado_version_check -s ./script/backend_run.tcl |& tee logs/backend_run.log

# Runtime-server layout: hw.dat is exposed at the fpga_diff level and the
# extracted runtime DB lands in ../runtime/rtdb_test for `make -C ../runtime run`.
RTDB_OUT ?= ../runtime/rtdb_test

rtdb:
	ln -sfn uvhs/hw.dat ../hw.dat
	bash ./script/extract_rtdb.sh hw.dat "$(RTDB_OUT)" -all -force

export_vivado_ip:
	mkdir -p logs
	set -o pipefail; $(VIVADO) -mode batch -source ./script/export_vivado_ip.tcl \
		-tclargs --origin_dir . --out_dir . --cpu nutshell --core_dir vendor/cpu \
			--jobs $(JOBS) \
			$(if $(strip $(EXPORT_IP_ONLY)),--only "$(EXPORT_IP_ONLY)",$(foreach ip,$(EXPORT_IP_SKIP),--skip "$(ip)")) \
			--force |& tee logs/export_vivado_ip.log

clean:
	rm -rf hw.dat hw.dat.incr rtdb rtdb.tar.gz logs vivado_ip_export vivado.* .Xil uv_stacktrace.txt .genSaveCpt.tcl "$(DDR_IP_BUILD)"
	rm -rf "$(RTDB_OUT)"
	@test ! -L ../hw.dat || rm ../hw.dat
	find . -type f -name "*.sw*" -delete
