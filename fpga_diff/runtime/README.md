# UVHS Runtime

Runtime flows for the U2 board: load an RTDB produced by the UVHS build,
configure the board, download the bitstream, and release the resets. Also
includes the UHD waveform capture flow and the DDR backdoor load/read
helpers.

This directory is deployed to the FPGA runtime server as part of `fpga_diff/`.
The expected layout on the server is:

```text
fpga_diff/
├── hw.dat              # UVHS build database (symlink to uvhs/hw.dat, or a copy)
└── runtime/
    ├── rtdb_test/      # runtime DB extracted from hw.dat (uvsim.db included)
    ├── Makefile
    └── user_script/
        ├── hw_run_download.tcl   # plain download + reset release
        ├── hw_run_uhd.tcl        # download + UHD trigger/capture/upload
        ├── ddr_backdoor.tcl      # DDR backdoor write snippet (UVHS_FW_BIN)
        ├── ddr_read.tcl          # DDR backdoor read snippet (live session)
        ├── uhd_setting.ini       # UHD trigger conditions
        └── query_cards.tcl       # daughter-card EEPROM inventory
```

## Prerequisites

- `uv_shell` on `PATH` (same environment as `uvhs/make preflight`).
- A runtime database, produced on the build machine by:

  ```sh
  make -C ../uvhs fe be rtdb
  ```

  `make rtdb` links the UVHS `hw.dat` to `../hw.dat` (the `fpga_diff/` level)
  and extracts the runtime DB directly into `runtime/rtdb_test/`. Copy
  `hw.dat` and `runtime/` to the runtime server preserving that layout
  (use `rsync -L`/`cp -L` so the `hw.dat` symlink is resolved).

## Targets

| Target | What it does |
|--------|--------------|
| `make run` | Download + release resets (`hw_run_download.tcl`) |
| `make uhd` | Download + arm UHD trigger + capture + upload + wavegen (`hw_run_uhd.tcl`) |
| `make wave` | Open the last UHD capture in `uvd` with hierarchy + all probed signals (X11) |
| `make query-cards` | Daughter-card EEPROM inventory only, no download |
| `make backdoor UVHS_FW_BIN=<img>` | `make run` with the DDR backdoor load enabled |
| `make clean-logs` | Remove generated log files |

## `make run`

This runs:

```sh
uv_shell -t runtime -d U2 -workdir ./u2_work_dir -script user_script/hw_run_download.tcl
```

and tees the session to `download.log`.

**`make run` only downloads the bitstream — it does not exit `uv_shell`.**
The runtime session must stay alive because the PCIe host side still attaches
to it: after the download you run the driver/difftest from the PCIe host
([`../host/`](../host/)) against this session. Keep the terminal (and
`uv_shell`) open for the whole difftest; closing it tears down the runtime
state (including the FPGA image) the host driver relies on.

The script performs, in order:

1. Query user / FPGAs / runtime version.
2. `load_db` the RTDB (`rtdb_test`, extracted here by `make -C ../uvhs rtdb`).
3. Configure the connector and program the default clocks.
4. Assert `rstn_sw6/5/4`, `download` the bitstream, `initialize`.
5. Deassert `rstn_sw6` + `rstn_sw4`, optionally run the DDR backdoor write
   (below), then deassert `rstn_sw5`.

## `make uhd`

UHD capture flow for the probe build (`UVHS_ENABLE_PROBE_NET=1`; refresh
`rtdb_test` first with `make -C ../uvhs rtdb`). Arms the trigger before
releasing the resets, waits up to 420 s for the trigger (start the host
workload within that window), uploads 10M samples and runs wavegen.
Artifacts: `u2_work_dir/UHD/uvhs_uhd/UvData.usdb` and `u2_work_dir/test.sg`.
See `docs/FpgaDiff/uhd-probe.md` for the full guide.

## DDR backdoor load (`UVHS_FW_BIN`)

When `UVHS_FW_BIN` is set (empty by default), both `make run` and `make uhd`
stage the named image into the SoC DDR via the UVHS memory backdoor
(`writemem`, DDR offset 0 = CPU base `0x8000_0000`) while `rstn_sw5` is still
held, then boot the CPU from it:

```sh
make backdoor UVHS_FW_BIN=<image.bin>   # shorthand for "make run" + backdoor
make uhd      UVHS_FW_BIN=<image.bin>   # backdoor write + UHD capture of the boot
```

The payload is zero-padded **in place** to the 32-byte DDR word. The image
must be on the runtime server's local disk. In the `uhd` form the trigger is
armed before the write, so the capture window covers the CPU booting from the
staged image.

## Ad-hoc DDR backdoor reads (`ddr_read.tcl`)

Reads must happen in the **same live session** that downloaded the design
(exiting `uv_shell` tears down the FPGA image). Since `make run` leaves the
`hspRun>` prompt open, just set the knobs and source the snippet there:

```tcl
hspRun> set ::env(UVHS_RD_ADDR) 0x80340000   # byte address (>= 0x8000_0000 -> base subtracted)
hspRun> set ::env(UVHS_RD_SIZE) 0x10000      # bytes to read (default 0x8000)
hspRun> set ::env(UVHS_RD_OUT)  logbuf.bin   # output file (lands in u2_work_dir/ if relative)
hspRun> source ./user_script/ddr_read.tcl
```

`UVHS_RD_HEX=1` switches to hex-text output (one 256-bit word per line, ~2x
size inflation). The snippet can also be embedded in a `hw_run_*.tcl` script
at a deterministic point (e.g. on trigger timeout). For a raw word range the
one-line `readmem` at the prompt works too — `ddr_read.tcl` only saves the
byte-address → 32-byte-word arithmetic.

## Files

Only the flow sources are tracked in Git; the RTDB copy, `u2_work_dir/`,
logs, and any other runtime output are ignored (see `.gitignore`).
