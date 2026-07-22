ENV_SCRIPTS_HOME ?= $(CURDIR)
VIVADO_SCRIPT_DIR ?= $(ENV_SCRIPTS_HOME)/vivado

CORE_DIR ?=
CHI_DIR ?=
FPGA_BIT_HOME ?=
WORKLOAD ?=
AXI_WIDTH ?= 64
PLATFORM ?= U2.2
# Host-trigger ILA capture is opt-in. Keep the trigger mark_debug net in RTL,
# but avoid instantiating the ILA core by default to reduce routing pressure.
ENABLE_ILA ?= 0
ILA_DEPTH ?= 16384
XDMA_LINK_WIDTH ?= X4
XDMA_ENABLE_PF0_BAR1 ?= 1
XDMA_AXILITE_MASTER_SCALE ?= Kilobytes
XDMA_AXILITE_MASTER_SIZE ?= 512
XDMA_EXPECTED_VENDOR ?= 0x10ee
XDMA_EXPECTED_DEVICE ?= 0x9048
XDMA_EXPECTED_BAR0_SIZE ?= 0x80000
XDMA_EXPECTED_BAR1_SIZE ?= 0x10000
VIVADO_JOBS ?=
DDR_RANK_WIDTH ?= 2
export PLATFORM ENABLE_ILA ILA_DEPTH XDMA_LINK_WIDTH XDMA_ENABLE_PF0_BAR1 XDMA_AXILITE_MASTER_SCALE XDMA_AXILITE_MASTER_SIZE XDMA_EXPECTED_VENDOR XDMA_EXPECTED_DEVICE XDMA_EXPECTED_BAR0_SIZE XDMA_EXPECTED_BAR1_SIZE VIVADO_JOBS DDR_RANK_WIDTH
# Supported CPU parameters:
#   kmh
#   nutshell
#   nanhu
CPU ?=
SUFFIX ?=
PRJ_NAME = fpga_$(CPU)$(if $(strip $(SUFFIX)),-$(strip $(SUFFIX)),)
PRJ_DIR ?= $(ENV_SCRIPTS_HOME)/$(PRJ_NAME)
PRJ ?= $(PRJ_DIR)/$(PRJ_NAME).xpr

ROOT_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
UVHS_DIR := $(dir $(ROOT_MAKEFILE))uvhs
UVHS_FORWARD_TARGETS := \
	uvhs_preflight uvhs_prepare uvhs_filelist uvhs_check_modules \
	uvhs_frontend uvhs_backend uvhs_all uvhs_rtdb \
	uvhs_generate_ddr_dcp uvhs_export_vivado_ip uvhs_clean

.PHONY: bitstream vivado dump_ila write_jtag_flash $(UVHS_FORWARD_TARGETS)

# Get Vivado version
VIVADO_VERSION := $(shell vivado -version 2>/dev/null | head -1 | grep -o '[0-9]\{4\}\.[0-9]' || echo "unknown")

check_vivado_version:
	@vivado -version 2>/dev/null | head -1 | grep -o '[0-9]\{4\}\.[0-9]' || echo "unknown"

# Run synthesis using Vivado
synth:
	vivado -mode batch -source "$(VIVADO_SCRIPT_DIR)/gen_synth.tcl" -tclargs $(PRJ)

# Generate FPGA bitstream
bitstream:
	vivado -mode batch -source "$(VIVADO_SCRIPT_DIR)/gen_bitstream.tcl" -tclargs $(PRJ) impl_1 $(VIVADO_JOBS)

# Update file list for core RTL files
update_core_flist:
	rm -rf $(CORE_DIR)/rtl/verification
	find "$(CORE_DIR)" -type f \( -name "*.v" -o -name "*.sv" -o -name "*.svh" \) -printf '%p\n' | \
	awk -f ./core_flist.awk > ./src/tcl/cpu_files.tcl

# Update file list for CHI interface files
update_chi_flist:
	find "$(CHI_DIR)" -type f \( -name "*.v" -o -name "*.sv" -o -name "*.svh" \) -printf '%p\n' | \
	awk -f ./chi_flist.awk > ./src/tcl/chi_files.tcl;

uvhs_preflight:
	$(MAKE) -C "$(UVHS_DIR)" preflight

uvhs_prepare:
	$(MAKE) -C "$(UVHS_DIR)" prepare

uvhs_filelist:
	$(MAKE) -C "$(UVHS_DIR)" filelist

uvhs_check_modules:
	$(MAKE) -C "$(UVHS_DIR)" check_modules

uvhs_frontend:
	$(MAKE) -C "$(UVHS_DIR)" fe

uvhs_backend:
	$(MAKE) -C "$(UVHS_DIR)" be

uvhs_all:
	$(MAKE) -C "$(UVHS_DIR)" all

uvhs_rtdb:
	$(MAKE) -C "$(UVHS_DIR)" rtdb

uvhs_generate_ddr_dcp:
	$(MAKE) -C "$(UVHS_DIR)" generate_ddr_dcp

uvhs_export_vivado_ip:
	$(MAKE) -C "$(UVHS_DIR)" export_vivado_ip

uvhs_clean:
	$(MAKE) -C "$(UVHS_DIR)" clean

# Launch Vivado with FPGA project configuration
vivado: check_vivado_version
	vivado -mode batch -source "$(VIVADO_SCRIPT_DIR)/xs_uart.tcl" -tclargs --origin_dir "$(ENV_SCRIPTS_HOME)" --cpu $(CPU) --project_name $(PRJ_NAME) --vivado_version $(VIVADO_VERSION)

# Check Vivado version compatibility
check_version:
	vivado -mode batch -source src/tcl/common/check_version.tcl -tclargs --vivado_version $(VIVADO_VERSION) --cpu $(CPU) --project_name $(PRJ_NAME)

# Write bitstream to FPGA via PCIe
write_bitstream:
ifeq ($(strip $(FPGA_SKIP_PCIE_RESCAN)),0)
	sh tools/pcie-remove.sh
endif
	vivado -mode tcl -source tools/write_bitstream.tcl -tclargs $(FPGA_BIT_HOME)
ifeq ($(strip $(FPGA_SKIP_PCIE_RESCAN)),0)
	sh tools/pcie-rescan.sh
endif
	vivado -mode tcl -source tools/reset_ddr.tcl -tclargs $(FPGA_BIT_HOME)/fpga_top_debug.ltx
	$(MAKE) reset_cpu

# Halt the FPGA SoC (for Write Jtag DDR)
halt_soc:
	vivado -mode tcl -source tools/halt_soc.tcl -tclargs $(FPGA_BIT_HOME)/fpga_top_debug.ltx

# Write workload to FPGA DDR via JTAG
write_jtag_ddr:
	vivado -mode tcl -source tools/jtag_write_ddr.tcl -tclargs $(WORKLOAD) $(AXI_WIDTH)

# Write a raw binary image to the BRAM-backed flash via the flash-only JTAG AXI
write_jtag_flash:
	vivado -mode tcl -source tools/jtag_write_flash.tcl -tclargs $(WORKLOAD)

# Reset CPU on FPGA
reset_cpu:
	vivado -mode tcl -source tools/reset_cpu.tcl -tclargs $(FPGA_BIT_HOME)/fpga_top_debug.ltx

ILA_OUT ?= $(ENV_SCRIPTS_HOME)/ila-dump
TIMEOUT_MIN ?= 2
FPGA_SKIP_PCIE_RESCAN ?= 0

# Dump host-trigger ILA data to ila/csv/vcd files
dump_ila:
	mkdir -p $(ILA_OUT)
	vivado -mode tcl -source tools/dump_ila.tcl -tclargs $(FPGA_BIT_HOME)/fpga_top_debug.ltx $(ILA_OUT) $(TIMEOUT_MIN)

# Add system options for memory optimization
add_sys_option:
	sed -i "s/reg \(\[[0-9]*:[0-9]*\]\) ram \[\([4-9][0-9]\{3,\}\|[1-9][0-9]\{4,\}\):0\];/(\* ram_style = \"ultra\" \*)\treg \1 ram \[\2:0\];/g" $(CORE_DIR)/rtl/array_*.v

# Display implementation log
get_impl_log:
	cat $(PRJ_DIR)/$(PRJ_NAME).runs/impl_1/runme.log

# Display synthesis log
get_synth_log:
	cat $(PRJ_DIR)/$(PRJ_NAME).runs/synth_1/runme.log

# Build complete FPGA project
all:
ifneq ($(strip $(CHI_DIR)),)
	$(MAKE) update_chi_flist CHI_DIR="$(CHI_DIR)"
endif
	$(MAKE) update_core_flist CORE_DIR=$(CORE_DIR)
	$(MAKE) vivado CPU=$(CPU) SUFFIX="$(SUFFIX)"
