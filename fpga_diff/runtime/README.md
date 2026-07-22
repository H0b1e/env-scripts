# UVHS Runtime Download

Minimal runtime bring-up for the U2 board: load an RTDB produced by the UVHS
build, configure the board, download the bitstream, and release the resets.

This directory is deployed to the FPGA runtime server as part of `fpga_diff/`.
The expected layout on the server is:

```text
fpga_diff/
├── hw.dat              # UVHS build database (symlink to uvhs/hw.dat, or a copy)
└── runtime/
    ├── rtdb_test/      # runtime DB extracted from hw.dat
    ├── Makefile
    └── user_script/hw_run_download.tcl
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

## Usage

```sh
make run
```

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
state the host driver relies on.

The script performs, in order:

1. Query user / FPGAs / runtime version.
2. `load_db` the RTDB (`rtdb_test`, extracted here by `make -C ../uvhs rtdb`).
3. Configure the connector and program the default clocks.
4. Assert `rstn_sw6/5/4`, `download` the bitstream, `initialize`.
5. Deassert the resets in order: `rstn_sw6` + `rstn_sw4`, then `rstn_sw5`.

`make clean-logs` removes the generated log files.

## Files

Only the flow sources are tracked in Git; the RTDB copy, `u2_work_dir/`,
logs, and any other runtime output are ignored (see `.gitignore`).
