#!/usr/bin/env bash
# Regenerate rtl/filelist.f for the Stage09 trim project.
#
# Source sets, in emission order (consumed by `read_verilog -f`):
#   1. fixed +define+/+incdir+ header for the UVHS NutShell configuration
#   2. vendor/platform, with the staged rtl/ top-level files replacing
#      their vendored baselines and unused SoC variants excluded
#   3. vendor/cpu top level (CPU wrapper)
#   4. vendor/cpu generated headers, then the core build RTL closure
set -euo pipefail

cd "$(dirname "$0")/.."

out=${1:-rtl/filelist.f}

{
    # Fixed header: keep in sync with the UVHS trim configuration.
    cat <<'EOF'
+define+SYNTHESIS
+define+XIANGSHAN_FPGA
+define+RANDOMIZE_GARBAGE_ASSIGN
+define+RANDOMIZE_REG_INIT
+define+RANDOMIZE_MEM_INIT
+define+RANDOMIZE_DELAY=1
+define+UVHS_SOC_ADAPT
+define+UVHS_NO_XILINX_CLK_PRIMS
+define+DDR4_16G_X8
+define+DQ64
+define+DDR4_2400
+define+DQ=64
+define+MICRON_DDR
+define+DDR4_16Gbx8
+define+DDR4
+define+SRAM_SYN
+define+DATA_VERSION=0
+define+CPU_NUTSHELL
+define+UVHS_EXTERNAL_UVW_AXI4_TO_DDR4
+define+UVHS_UVW_AXI4_TO_DDR4
+define+CONFIG_USE_XSCORE_AXI
+incdir+vendor/platform
+incdir+vendor/cpu
+incdir+vendor/cpu/generated-src
EOF

    # Platform RTL sorted by basename so the staged rtl/ overrides sit at the
    # same positions their vendored baselines would occupy.
    {
        find vendor/platform -maxdepth 1 -type f \
            \( -name '*.v' -o -name '*.sv' -o -name '*.vh' -o -name '*.svh' \) \
            ! -name 'u0_xdma.v' \
            ! -name 'core_def_native_nutshell.sv' \
            ! -name 'core_def_xdma.sv' \
            ! -name 'fpga_top_debug.sv' \
            ! -name 'uvhs_native_blackbox_stubs.v'
        printf '%s\n' rtl/core_def_xdma.sv rtl/fpga_top_debug.sv
    } | awk -F/ '{print $NF "\t" $0}' | LC_ALL=C sort | cut -f2-

    find vendor/cpu -maxdepth 1 -type f \
        \( -name '*.v' -o -name '*.sv' -o -name '*.vh' -o -name '*.svh' \) | LC_ALL=C sort

    find vendor/cpu/generated-src -maxdepth 1 -type f \
        \( -name '*.vh' -o -name '*.svh' \) | LC_ALL=C sort

    find vendor/cpu/rtl -maxdepth 1 -type f \
        \( -name '*.v' -o -name '*.sv' -o -name '*.vh' -o -name '*.svh' \) | LC_ALL=C sort
} > "$out"

echo "INFO: regenerated $out ($(wc -l < "$out") lines)"
