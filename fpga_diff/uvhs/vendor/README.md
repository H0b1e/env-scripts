# Vendored source snapshots

Frozen, self-contained copies of the upstream sources this project compiles.
They are snapshots, not development trees: update them only by intentionally
re-vendoring a newer upstream state, then run `make filelist`.

## cpu/

Processor core closure. Currently a **NutShell** snapshot (2026-07):

- `rtl/` — Chisel-generated core RTL (124 files), from `NutShell/build/rtl`
- `generated-src/` — difftest headers, from `NutShell/build/generated-src`
- `SimTop_wrapper.sv` — SoC top wrapper binding the core to the XDMA host
  interface, from fpga_diff `src/rtl/nutshell`

For the future Nanhu/Kunminghu adaptation, replace this subtree with the
corresponding core build closure and wrapper.

## platform/

CPU-agnostic fpga_diff platform glue (19 files), from fpga_diff
`src/rtl/common`: `syscfg`, `xilnx_crg`, AXI width/CD adapters, subsystem
wrappers and blackbox stubs.

Note: `vendor/platform` also carries baseline `fpga_top_debug.sv` /
`core_def_xdma.sv` copies that are NOT compiled — the staged trimmed top level
under `rtl/` takes their place in the filelist.
