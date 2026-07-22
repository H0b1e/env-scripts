#!/usr/bin/env bash
set -u

BDF="${XDMA_BDF:-0000:01:00.0}"
DEV="/sys/bus/pci/devices/$BDF"
LOAD="${XDMA_OFFICIAL_LOAD:-0}"
BIND="${XDMA_OFFICIAL_BIND:-0}"
CLEAR_OVERRIDE="${XDMA_CLEAR_DRIVER_OVERRIDE:-0}"
RESTORE_BARS="${XDMA_RESTORE_BARS_BEFORE_LOAD:-0}"
LOG="${XDMA_OFFICIAL_LOG:-}"

if [ -n "$LOG" ]; then
  mkdir -p "$(dirname "$LOG")"
  exec > >(tee -a "$LOG") 2>&1
fi

ts() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

find_ko() {
  if [ -n "${XDMA_OFFICIAL_KO:-}" ]; then
    printf '%s\n' "$XDMA_OFFICIAL_KO"
    return
  fi
  for cand in \
    "$HOME/dma_ip_drivers/XDMA/linux-kernel/xdma/xdma.ko" \
    "$HOME/xdma_official/xdma.ko" \
    /tmp/xilinx-dma-ip-drivers-official/XDMA/linux-kernel/xdma/xdma.ko \
    /tmp/codex_xilinx_dma_ip_drivers/XDMA/linux-kernel/xdma/xdma.ko; do
    if [ -f "$cand" ]; then
      printf '%s\n' "$cand"
      return
    fi
  done
}

echo "## host_xdma_official_probe $(ts)"
hostname || true
uname -a || true
echo "BDF=$BDF"

if [ ! -d "$DEV" ]; then
  echo "ERROR: PCI device not found: $DEV" >&2
  exit 2
fi

KO="$(find_ko)"
if [ -z "$KO" ] || [ ! -f "$KO" ]; then
  echo "ERROR: official xdma.ko not found; set XDMA_OFFICIAL_KO=/path/to/xdma.ko" >&2
  exit 3
fi

echo "official_ko=$KO"
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
  echo "ERROR: official module alias does not cover 10ee:9048" >&2
  exit 5
fi

echo "## pre-load state"
cat "$DEV/vendor" "$DEV/device" "$DEV/class" "$DEV/revision" 2>/dev/null || true
echo "driver=$(readlink "$DEV/driver" 2>/dev/null || echo none)"
echo "driver_override=$(cat "$DEV/driver_override" 2>/dev/null || true)"
setpci -s "$BDF" 00.l 04.w 10.l 14.l || true
ls -l /dev/xdma* 2>/dev/null || true
dmesg -T 2>/dev/null | tail -120 || true

if [ "$RESTORE_BARS" = 1 ]; then
  if [ "$(id -u)" != 0 ]; then
    echo "ERROR: XDMA_RESTORE_BARS_BEFORE_LOAD=1 requires root" >&2
    exit 6
  fi
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  XDMA_BDF="$BDF" XDMA_RESTORE_APPLY=1 "$SCRIPT_DIR/host_restore_xdma_bars.sh"
fi

if [ "$LOAD" != 1 ]; then
  echo "Dry run only. Set XDMA_OFFICIAL_LOAD=1 to insmod the official driver."
  exit 0
fi

if [ "$(id -u)" != 0 ]; then
  echo "ERROR: XDMA_OFFICIAL_LOAD=1 requires root" >&2
  exit 9
fi

if [ -e "$DEV/driver" ]; then
  echo "ERROR: device is already bound; this script will not unbind it" >&2
  exit 10
fi

override="$(cat "$DEV/driver_override" 2>/dev/null || true)"
if [ -n "$override" ]; then
  if [ "$CLEAR_OVERRIDE" = 1 ]; then
    printf '\n' > "$DEV/driver_override"
    echo "cleared driver_override"
  else
    echo "ERROR: driver_override is set to '$override'; set XDMA_CLEAR_DRIVER_OVERRIDE=1 to clear it" >&2
    exit 11
  fi
fi

if ! lsmod | awk '{print $1}' | grep -qx xdma; then
  insmod "$KO"
  echo "insmod_rc=$?"
else
  echo "xdma module already loaded"
fi

if [ ! -e "$DEV/driver" ] && [ "$BIND" = 1 ] && [ -e /sys/bus/pci/drivers/xdma/bind ]; then
  echo "$BDF" > /sys/bus/pci/drivers/xdma/bind
  echo "manual_bind_rc=$?"
fi

sleep 1
echo "## post-load state"
echo "driver=$(readlink "$DEV/driver" 2>/dev/null || echo none)"
ls -l /dev/xdma* 2>/dev/null || true
dmesg -T 2>/dev/null | tail -200 || true

if ls /dev/xdma* >/dev/null 2>&1; then
  echo "official_probe_result=nodes_present"
  exit 0
fi

echo "official_probe_result=no_xdma_nodes"
exit 30
