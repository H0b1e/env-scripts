# Hejian UVHS FPGA-host package

Runs on the FPGA host (e.g. `19p-host`). After the **runtime host** (e.g.
`19p-runtime`) finishes the download (`make -C ../runtime run`, see
[`../runtime/`](../runtime/)), this side:

1. Enumerates PCIe (read-only)
2. Loads `xdma-chr.ko` (sudo)
3. Runs `fpga-host` to burn workload via XDMA H2C and run DiffTest

Keep the runtime-side `uv_shell` session alive for the whole difftest — the
driver/DiffTest here depends on that runtime state; closing it tears the
session down.

## Layout

```
fpga_diff/host/
├── Makefile               # entry point
├── README.md              # this file
├── host_script/           # 10 host_*.sh helpers (self-contained)
└── ready-to-run/
    ├── microbench-riscv64-nutshell.bin  # default workload burned via H2C
    ├── microbench-nutshell.bin          # legacy default
    ├── microbench-xs-no-uart.bin
    ├── hello-xs.bin
    ├── xdma-chr.ko               # bundled known-good kernel module
    ├── fpga-host.with-uart       # bundled fpga-host bridge binary
    └── riscv64-nemu-interpreter-so
```

## Prerequisites

Known-good binaries are bundled under `ready-to-run/`; override any of them
via environment/make variables when needed:

- **`xdma-chr.ko`** — MinJie mainline kernel module. `vermagic` MUST match the
  running kernel on this host; if it does not, rebuild and set
  `XDMA_CHR_KO=/path/to/xdma-chr.ko`.
- **`fpga-host`** binary — Hejian host-side bridge (default:
  `ready-to-run/fpga-host.with-uart`). Set `FPGA_HOST_BIN=/path/to/fpga-host`.
- **`riscv64-nemu-interpreter-so`** — NEMU shared object for DiffTest.
  Set `FPGA_NEMU_SO=/path/to/riscv64-nemu-interpreter-so`.

Expected hardware after the download on the runtime host:
- PCIe Gen3 x4 endpoint, vendor/device `10ee:9048`
- BAR0 = 512 KiB, BAR1 = 64 KiB
- BAR1 signatures: offset `0x2000` high16=`0x1fc2`, offset `0x3000` high16=`0x1fc3`

## Flow

Deploy this directory to the FPGA host (it is self-contained), then:

```bash
cd fpga_diff/host

# Optional overrides (defaults point at ready-to-run/):
export XDMA_BDF=0000:01:00.0
# export XDMA_CHR_KO=/path/to/xdma-chr.ko
# export FPGA_HOST_BIN=/path/to/fpga-host
# export FPGA_NEMU_SO=/path/to/riscv64-nemu-interpreter-so
# export FPGA_HOST_WORKDIR=/path/to/writable/workdir

make check          # sanity-check that everything is staged
make preflight      # readonly PCIe enumeration
make bars           # peek BAR0/BAR1 + signatures (read-only)
make driver         # sudo: load xdma-chr.ko, expect /dev/xdma* to appear
make workload       # fpga-host H2C + DiffTest; expect HIT GOOD TRAP
```

## Switching workload

```bash
make workload WORKLOAD_BIN=$(pwd)/ready-to-run/hello-xs.bin
# or any absolute path to a .bin
```

For a no-diff CPU/UART-only run (does not consume C2H):

```bash
make workload FPGA_NO_DIFF=1
```

## Logs

All commands tee to `logs/<RUN_TAG>.<phase>.log`. `RUN_TAG` defaults to
`<hostname>-<timestamp>`; override with `make ... RUN_TAG=mytag`.
