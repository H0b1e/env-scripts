# UVHS FPGA-Diff Flow

This directory contains a self-contained UVHS profile. Its staged scripts, RTL,
DCP inputs, and frozen NutShell source closure live under `script/`, `rtl/`,
and `vendor/`; run the build from this directory.

## Build

```sh
make preflight
make generate_ddr_dcp   # only needed once, or after deleting rtl/soc/uvw_axi4_to_ddr4.*
make prepare
make check_modules
make fe
make be
make rtdb
```

`make all` runs the frontend and backend stages; `make fe` regenerates the DDR
DCP/stub automatically when they are missing. `make filelist` regenerates
`rtl/filelist.f`; `make export_vivado_ip` is an optional, slow DCP/IP export.

The parent `fpga_diff/Makefile` provides equivalent prefixed bridge targets:

```sh
make -C .. uvhs_preflight
make -C .. uvhs_prepare
make -C .. uvhs_check_modules
make -C .. uvhs_frontend
make -C .. uvhs_backend
make -C .. uvhs_rtdb
```

## Outputs

Build outputs are created in this directory:

```text
hw.dat/
logs/
```

`make rtdb` links `hw.dat` to `../hw.dat` (the `fpga_diff/` level) and
extracts the runtime database to `../runtime/rtdb_test/` for the download
flow in [`../runtime/`](../runtime/). `hw.dat` is the UVHS runtime database;
it is not interchangeable with the legacy standalone Vivado `.bit` and `.ltx`
artifacts under `../vivado/`.

## DDR DCP Generation

The DDR checkpoint is **not** committed to Git. `make generate_ddr_dcp` (alias
`make ddr_ip`) runs Vivado locally via `tools/ddr_ip/gen_ddr4_ip.py` and
installs:

```text
rtl/soc/uvw_axi4_to_ddr4.dcp
rtl/soc/uvw_axi4_to_ddr4_Stub.v
```

The configuration in `tools/ddr_ip/UV_FMCH_PDDR4DME/uvw_axi4_to_ddr4.json`
reproduces the frozen UVHS checkpoint behavior: 256-bit AXI data, 34-bit
address, 14-bit ID, controller ECC disabled (`DDR_ECC_EN=0`), part
`xcvu19p-fsva3824-2-e`. The generator enforces these values and refuses other
configurations. Vivado intermediates go to the disposable `.ddr_ip_build/`
directory; both it and the installed artifacts are git-ignored.

## PCIe And DCP Configuration

The other staged DCP files are used as-is. To inspect or regenerate PCIe, XDMA,
and bridge configuration, read the DCP-generation Tcl scripts under `script/ip/`
(especially `script/ip/xdma_ep.tcl`) and `script/export_vivado_ip.tcl`.

## Cleanup

```sh
make clean
```

This removes only generated UVHS artifacts from this directory.
