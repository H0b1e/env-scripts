# VP1902 IP staging (isolated)

Pre-built IPs for the xcvp1902-vsva6865-2MP-e-S migration. **Nothing here is
referenced by the active fe/be flow** (rtl/soc, rtl/device/pcie, script/*.tcl
still serve the VU19P build). These artifacts get wired in together with the
board-side switch (create_system_design name, assemble, assign_pin) — until
then this directory is pure staging.

Per repo convention DCPs are gitignored (`fpga_diff/.gitignore: *.dcp`) and
regenerated from the profile/scripts below; the stubs and all sources are
committed.

## Environment (both IPs)

- **Vivado 2025.1.1** (the uvhs.sh shell env: `XILINX_VIVADO` already points
  there; both artifacts were built and validated with it). Requires a
  synthesis license covering xcvp1902.

## ddr/ — UVW AXI4-to-DDR4 controller (axi2ddr_soft profile)

- `profile/` — vendor `axi2ddr_soft` profile from
  `UVH_2025.06.P5.W1/platform/V1/Prototype/ips/memory/axi2ddr/axi2ddr_soft`,
  configured to the frozen contract:
  `PLATFORM_PART=xcvp1902-vsva6865-2MP-e-S, DATA_WIDTH=256, ADDR_WIDTH=34,
  ID_WIDTH=14, ECC_EN=0, DC_NAME=UV_APCP_DDR4`.
  `IP_LOCATION` in the json is this repo copy (absolute path — vendor script
  limitation; adjust after relocating the clone).
- `uvw_axi4_to_ddr4.dcp` / `_Stub.v` — generated 2026-08-17, Vivado 2025.1.1.
  Stub annotation: `DATA_WIDTH:256`, `toFPGA:<UV_APCP_DDR4>`.
  Port delta vs the VU19P stub: `ddr4ip_ddr4_user_clk/rst` outputs removed.

Regenerate (any writable scratch dir; writes `uvw_axi4_to_ddr4/` and
`proj_uvw_axi4_to_ddr4/` in the CWD, ~10 min):

```sh
HERE=$(pwd)/..   # repo fpga_diff/uvhs dir
cd $(mktemp -d)
python3 $HERE/vp1902/ddr/profile/gen_ddr4_ip.py \
  -j $HERE/vp1902/ddr/profile/uvw_axi4_to_ddr4.json
# -> uvw_axi4_to_ddr4/uvw_axi4_to_ddr4.dcp + uvw_axi4_to_ddr4_Stub.v
```

## pcie/ — PCIe EP stack (xdma split-mode + CPM)

Vivado 2025.1.1 BD: `xdma_ep_wrapper` = xdma 4.2 (bar512c config) + vendor
support hierarchy `qdma_0_support` (pcie_versal CPM + pcie_phy_versal +
gt_quad_base + BUFGs), retargeted **Gen3 x4 / 256-bit** to match the old
design and unlock the 256-bit CPM interface. `VALIDATE-RC=0`, OOC-synthesized.

- `build/` — exact proven scripts: `prelude.tcl` + `hier5.tcl` (vendor
  hierarchy, Gen3-x4-ified) + `root5.tcl` (top level: xdma + smartconnect
  CDC + externals, self-contained incl. the full xdma config) + `gen.tcl`
  (project-run synth -> DCP/stub).
- `xdma_ep.dcp` / `xdma_ep_Stub.v` / `xdma_ep_regen.tcl`.

Regenerate (two steps, both self-locating; the BD project lands in the
gitignored `pcie/build_prj/`, the artifacts refresh in place at `pcie/`;
step 1 ~3 min, step 2 ~10 min):

```sh
# 1) rebuild + validate + save the BD project (deletes build_prj/ first)
vivado -mode batch -nojournal -nolog -source pcie/build/root5.tcl
#    expect: VALIDATE-RC=0, EXPORT-DONE
# 2) synthesize -> refresh pcie/{xdma_ep.dcp,xdma_ep_Stub.v,xdma_ep_regen.tcl}
vivado -mode batch -nojournal -nolog -source pcie/build/gen.tcl
#    expect: GEN-ALL-DONE
```

Stub delta vs VU19P (`rtl/device/pcie/xdma_ep_stub.v`):

| change | old -> new |
|---|---|
| top module | `xdma_ep` -> `xdma_ep_wrapper` |
| GT pins | `pci_exp_rxn/rxp/txn/txp` -> `pcie_mgt_grx_n/grx_p/gtx_n/gtx_p` ([3:0]) |
| `cpu_rstn` | removed (smartconnect CDC no longer needs it) |
| streams / AXI-Lite / clocks / perstn / lnk_up | identical |

## Integration checklist (execute at the board switch)

1. `rtl/core_def_xdma.sv`: instantiate `xdma_ep_wrapper`, rename the 4 GT
   port connections, drop `.cpu_rstn(...)` (and its wire if unreferenced).
2. `script/frontend_run.tcl:114`: `set_blackbox -module xdma_ep_wrapper ...`.
3. Stage DCP/stub into `rtl/device/pcie/` and `rtl/soc/` (DDR).
4. `Makefile` DDR_IP_DIR/EXPECTED guard -> vp1902 profile (contract is
   unchanged except PLATFORM_PART and ECC field name DDR_ECC_EN -> ECC_EN).
5. `script/assign_pin.tcl` / `1B_4F_HGC_assemble.tcl` / `create_system_design
   -name`: board binding (pending inputs).
6. DDR wrapper: `core_def_xdma.sv:2366-2367` user_clk/rst connections removed;
   `init_calib_complete = rstn_sw4` (runtime initialize owns calibration).

## Known leftovers (tracked, non-blocking)

- pcie/phy `axisten_freq=250`, `userclk2_freq=500` are vendor Gen4 values;
  Gen3 x4 wants 125/250 — fix one line in hier5.tcl and regenerate before be.
- `xdma_0/pcie4_cfg_msi` dangles (vendor hierarchy exposes no msi boundary) —
  confirm whether host-side difftest depends on /dev/xdma MSI events.
- `pcie_blk_locn=S0X0Y0` placeholder — needs the real GT/CPM site for the new
  box wiring.
- Vendor hierarchy truncates `s_axis_cc_tuser` 81->33 and
  `cfg_interrupt_pending` 8->4 at its boundary (qdma-era widths; same as the
  vendor's own demo).
