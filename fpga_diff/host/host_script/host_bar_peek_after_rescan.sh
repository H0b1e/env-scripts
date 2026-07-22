#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDMA_HOST_RESCAN="${XDMA_HOST_RESCAN:-0}"
XDMA_RESTORE_BAR_REGS_AFTER_RESCAN="${XDMA_RESTORE_BAR_REGS_AFTER_RESCAN:-0}"
XDMA_RESCAN_SETTLE_SEC="${XDMA_RESCAN_SETTLE_SEC:-1}"

echo "host_bar_peek_after_rescan: no PCIe remove/reset/unbind is performed by this script."
if [ "$XDMA_HOST_RESCAN" = 1 ]; then
  if [ "$(id -u)" != 0 ]; then
    echo "ERROR: XDMA_HOST_RESCAN=1 requires root" >&2
    exit 2
  fi
  echo "host_bar_peek_after_rescan: writing /sys/bus/pci/rescan"
  echo 1 > /sys/bus/pci/rescan
  sleep "$XDMA_RESCAN_SETTLE_SEC"
else
  echo "host_bar_peek_after_rescan: skip PCIe rescan because XDMA_HOST_RESCAN=$XDMA_HOST_RESCAN"
fi

if [ "$XDMA_RESTORE_BAR_REGS_AFTER_RESCAN" = 1 ]; then
  echo "host_bar_peek_after_rescan: restore endpoint BAR config registers from sysfs resources"
  XDMA_RESTORE_APPLY=1 "$SCRIPT_DIR/host_restore_xdma_bars.sh"
else
  echo "host_bar_peek_after_rescan: skip BAR restore because XDMA_RESTORE_BAR_REGS_AFTER_RESCAN=$XDMA_RESTORE_BAR_REGS_AFTER_RESCAN"
fi

exec "$SCRIPT_DIR/host_peek_xdma_bars.sh"
