#!/usr/bin/env bash
set -euo pipefail

BDF="${XDMA_BDF:-0000:01:00.0}"
DEV="/sys/bus/pci/devices/$BDF"
TAG="${FPGA_DIFF_RUN_TAG:?set a unique FPGA_DIFF_RUN_TAG}"
LOAD="${XDMA_CHR_LOAD:-0}"
LOAD_TAG="${XDMA_CHR_LOAD_TAG:-}"
KO_EXPLICIT="${XDMA_CHR_KO:-}"
BIND="${XDMA_CHR_BIND:-1}"
CLEAR_OVERRIDE="${XDMA_CLEAR_DRIVER_OVERRIDE:-0}"
RESTORE_BARS="${XDMA_RESTORE_BARS_BEFORE_LOAD:-1}"
LOG="${XDMA_CHR_LOG:-}"
DO_LOAD=0
if [ "$LOAD" = 1 ] && [ "$LOAD_TAG" = "$TAG" ]; then
  DO_LOAD=1
fi

case "$TAG" in
  ""|*[!A-Za-z0-9_.-]*)
    echo "ERROR: FPGA_DIFF_RUN_TAG contains unsafe characters: $TAG" >&2
    exit 2
    ;;
esac
if [ "${#TAG}" -gt 120 ]; then
  echo "ERROR: FPGA_DIFF_RUN_TAG is longer than 120 characters" >&2
  exit 2
fi

if [ -n "$LOG" ]; then
  case "$LOG" in
    *"$TAG"*) ;;
    *) echo "ERROR: XDMA_CHR_LOG must contain exact tag '$TAG': $LOG" >&2; exit 2 ;;
  esac
  if [ -e "$LOG" ]; then
    echo "ERROR: refusing reused FPGA_DIFF_RUN_TAG log: $LOG" >&2
    exit 2
  fi
  mkdir -p "$(dirname "$LOG")"
  exec > >(tee "$LOG") 2>&1
fi

ts() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

find_ko() {
  if [ -n "${XDMA_CHR_KO:-}" ]; then
    printf '%s\n' "$XDMA_CHR_KO"
    return
  fi
  for cand in \
    "$HOME/dma_ip_drivers/XDMA/linux-kernel/xdma/xdma-chr.ko" \
    "$HOME/project/minjie-playground/dma_ip_drivers/XDMA/linux-kernel/xdma/xdma-chr.ko"; do
    if [ -f "$cand" ]; then
      printf '%s\n' "$cand"
      return
    fi
  done
}

module_loaded() {
  lsmod | awk '{print $1}' | grep -Eq '^(xdma_chr|xdma-chr)$'
}

echo "## host_xdma_chr_probe $(ts)"
hostname || true
uname -a || true
echo "BDF=$BDF"
echo "tag=$TAG"
echo "load=$LOAD"
echo "load_tag=$LOAD_TAG"

if [ ! -d "$DEV" ]; then
  echo "ERROR: PCI device not found: $DEV" >&2
  exit 2
fi

KO="$(find_ko)"
if [ -z "$KO" ] || [ ! -f "$KO" ]; then
  echo "ERROR: MinJie xdma-chr.ko not found; set XDMA_CHR_KO=/path/to/xdma-chr.ko" >&2
  exit 3
fi
if [ "$DO_LOAD" = 1 ] && [ -z "$KO_EXPLICIT" ]; then
  echo "ERROR: actual load requires explicit XDMA_CHR_KO for the MinJie mainline module" >&2
  exit 3
fi

echo "xdma_chr_ko=$KO"
sha256sum "$KO"
modinfo "$KO" | sed -n '1,120p'

kernel="$(uname -r)"
vermagic="$(modinfo -F vermagic "$KO" 2>/dev/null || true)"
aliases="$(modinfo -F alias "$KO" 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
case "$vermagic" in
  "$kernel"*) echo "vermagic_ok=$vermagic" ;;
  *) echo "ERROR: vermagic mismatch: kernel=$kernel module=$vermagic" >&2; exit 4 ;;
esac
if printf '%s\n' "$aliases" | grep -q 'v000010eed00009048'; then
  echo "alias_ok=10ee:9048"
else
  echo "ERROR: xdma_chr module alias does not cover 10ee:9048" >&2
  exit 5
fi

echo "## pre-load state"
cat "$DEV/vendor" "$DEV/device" "$DEV/class" "$DEV/revision" 2>/dev/null || true
echo "driver=$(readlink "$DEV/driver" 2>/dev/null || echo none)"
echo "driver_override=$(cat "$DEV/driver_override" 2>/dev/null || true)"
setpci -s "$BDF" 00.l 04.w 10.l 14.l || true
ls -l /dev/xdma* 2>/dev/null || true
dmesg -T 2>/dev/null | tail -120 || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$DO_LOAD" != 1 ]; then
  echo "Dry run only. Set XDMA_CHR_LOAD=1 and XDMA_CHR_LOAD_TAG=$TAG to restore/load/bind."
  if [ "$RESTORE_BARS" = 1 ]; then
    if [ -e "$DEV/driver" ]; then
      echo "read_only_bar_check=skipped_driver_bound"
      exit 0
    fi
    set +e
    XDMA_BDF="$BDF" XDMA_RESTORE_APPLY=0 "$SCRIPT_DIR/host_restore_xdma_bars.sh"
    restore_rc=$?
    set -e
    echo "read_only_bar_check_rc=$restore_rc"
    exit "$restore_rc"
  fi
  exit 0
fi

if [ "$RESTORE_BARS" != 1 ]; then
  echo "ERROR: actual load requires XDMA_RESTORE_BARS_BEFORE_LOAD=1 for BAR1 signature evidence" >&2
  exit 6
fi

if [ "$(id -u)" != 0 ]; then
  echo "ERROR: XDMA_CHR_LOAD=1 requires root" >&2
  exit 7
fi

if [ -e "$DEV/driver" ]; then
  echo "ERROR: device is already bound; this script will not unbind it" >&2
  exit 8
fi

if [ "$RESTORE_BARS" = 1 ]; then
  XDMA_BDF="$BDF" XDMA_RESTORE_APPLY=1 "$SCRIPT_DIR/host_restore_xdma_bars.sh"
fi

override="$(cat "$DEV/driver_override" 2>/dev/null || true)"
case "$override" in
  ""|"(null)") override="" ;;
esac
if [ -n "$override" ]; then
  if [ "$CLEAR_OVERRIDE" = 1 ]; then
    printf '\n' > "$DEV/driver_override"
    echo "cleared driver_override"
  else
    echo "ERROR: driver_override is set to '$override'; set XDMA_CLEAR_DRIVER_OVERRIDE=1 to clear it" >&2
    exit 9
  fi
fi

if ! module_loaded; then
  insmod "$KO"
  echo "insmod_rc=$?"
else
  echo "xdma_chr module already loaded"
fi

if [ ! -e "$DEV/driver" ] && [ "$BIND" = 1 ] && [ -e /sys/bus/pci/drivers/xdma-chr/bind ]; then
  echo "$BDF" > /sys/bus/pci/drivers/xdma-chr/bind
  echo "manual_bind_rc=$?"
fi

sleep 1
echo "## post-load state"
echo "driver=$(readlink "$DEV/driver" 2>/dev/null || echo none)"
ls -l /dev/xdma* 2>/dev/null || true
dmesg -T 2>/dev/null | tail -200 || true

missing_nodes=0
for node in /dev/xdma0_user /dev/xdma0_c2h_0 /dev/xdma0_h2c_0; do
  if [ -e "$node" ]; then
    echo "required_node_present=$node"
  else
    echo "required_node_missing=$node"
    missing_nodes=$((missing_nodes + 1))
  fi
done
if [ "$missing_nodes" -ne 0 ]; then
  echo "xdma_chr_probe_result=required_nodes_missing count=$missing_nodes"
  exit 30
fi
if [ ! -e "$DEV/driver" ]; then
  echo "xdma_chr_probe_result=nodes_present_but_driver_unbound"
  exit 31
fi

echo "xdma_nodes_result=required_nodes_present"
BAR0_STATUS_READER="${XDMA_BAR0_STATUS_READER:-$SCRIPT_DIR/read_uvhs_debug_status.py}"
if [ ! -f "$BAR0_STATUS_READER" ]; then
  echo "xdma_chr_probe_result=bar0_status_reader_missing path=$BAR0_STATUS_READER"
  exit 33
fi
echo "bar0_status_reader=$BAR0_STATUS_READER"
sha256sum "$BAR0_STATUS_READER"
set +e
python3 "$BAR0_STATUS_READER" --dev /dev/xdma0_user --count 1
bar0_rc=$?
set -e
echo "bar0_status_rc=$bar0_rc"
if [ "$bar0_rc" -eq 2 ]; then
  echo "xdma_chr_probe_result=bar0_magic_mismatch expected=0x55484442"
  exit 32
fi
if [ "$bar0_rc" -ne 0 ]; then
  echo "xdma_chr_probe_result=bar0_status_read_error rc=$bar0_rc"
  exit 33
fi
echo "bar0_magic_result=ok value=0x55484442"
echo "xdma_chr_probe_result=required_nodes_and_bar0_magic_present"
exit 0
