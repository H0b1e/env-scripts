Core RTL to FPGA Steps
======================

The legacy standalone Vivado project-generation entry points are grouped under
[`vivado/`](vivado/). The UVHS flow remains under [`uvhs/`](uvhs/); its shared
SoC RTL, constraints, CDC reports, and runtime scripts stay at their existing
paths.

1. modify Makefile, assign CORE_DIR

2. make vivado CPU=XXX
  (this step compile a project,CPU Parameter support "kmh" "nutshell" "nanhu")
  (from this step on, you may use vivado gui)

3. make bitstream
  (start background bitstream gen)

4. wait
  (watch "fpga_$cpu/$cpu$.runs/xxxx/runme.log")
  (wait for bitstream gen to finish)

5. (first) Add file execution permission
  chmod u+x tools/pcie-remove.sh
  chmod u+x tools/pcie-rescan.sh

6. make write_bitstream

7. write DDR and run with diff/no-diff
```shell
case 1: No fpga-host
stty -F /dev/ttyUSB0 raw 115200 ...
<New terminal>
make halt_soc
make write_jtag_ddr
make reset_cpu

case 2: With fpga-host (no-diff mode)
FPGA_DDR_LOAD_CMD="bash -lc ' \
  source ~/.bash_profile && \
  make -C /path/to/fpga_diff write_jtag_ddr \
    FPGA_BIT_HOME=... \
    WORKLOAD=<workload>.txt \
'" \
./fpga-host --no-diff

case 3: With fpga-host (diff mode)
FPGA_DDR_LOAD_CMD="bash -lc ' \
  source ~/.bash_profile && \
  make -C /path/to/fpga_diff write_jtag_ddr \
    FPGA_BIT_HOME=... \
    WORKLOAD=<workload>.txt \
'" \
./fpga-host --diff <nemu> -i <workload>.bin
```

UVHS FPGA Flow
==============

The self-contained UVHS profile is documented in [uvhs/README.md](uvhs/README.md).
It uses staged scripts, RTL, DCP inputs, and a frozen NutShell source closure
inside `uvhs/`; it does not use the standalone Vivado project flow above.

Run the profile directly:

```shell
make -C uvhs preflight
make -C uvhs generate_ddr_dcp
make -C uvhs prepare
make -C uvhs check_modules
make -C uvhs fe
make -C uvhs be
make -C uvhs rtdb
```

The DDR DCP is not committed; `generate_ddr_dcp` rebuilds it locally with
Vivado (and `fe` does so automatically when it is missing).

Or use the root bridge aliases:

```shell
make uvhs_preflight
make uvhs_generate_ddr_dcp
make uvhs_prepare
make uvhs_check_modules
make uvhs_frontend
make uvhs_backend
make uvhs_rtdb
```

The UVHS flow creates `uvhs/hw.dat` and `uvhs/logs/`. `make -C uvhs rtdb`
links `hw.dat` to `fpga_diff/hw.dat` and extracts the runtime DB to
`runtime/rtdb_test/` for the [runtime download flow](runtime/). `hw.dat` is a
UVHS runtime database and is not compatible with the standalone Vivado
`.bit`/`.ltx` programming commands.

End-to-end, the flow spans three machines/roles:

1. **Build** (compile server): [`uvhs/`](uvhs/) — `make fe be rtdb`.
2. **Download** (runtime host): [`runtime/`](runtime/) — `make run` programs
   the bitstream and keeps the `uv_shell` session alive.
3. **DiffTest** (PCIe host): [`host/`](host/) — loads `xdma-chr.ko` and runs
   `fpga-host` to burn the workload via XDMA H2C and check against NEMU.
