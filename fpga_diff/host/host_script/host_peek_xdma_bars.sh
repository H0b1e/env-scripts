#!/usr/bin/env bash
set -u

BDF="${XDMA_BDF:-0000:01:00.0}"
DEV="/sys/bus/pci/devices/$BDF"
READ_TIMEOUT="${XDMA_BAR_READ_TIMEOUT_SEC:-5}"
LOG="${XDMA_BAR_PEEK_LOG:-}"
ALLOW_BOUND_RAW_READ="${XDMA_BAR_PEEK_ALLOW_BOUND_RAW_READ:-0}"

if [ -n "$LOG" ]; then
  mkdir -p "$(dirname "$LOG")"
  exec > >(tee -a "$LOG") 2>&1
fi

ts() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

show_file() {
  local label="$1"
  local path="$2"
  if [ -e "$path" ]; then
    printf '%s: ' "$label"
    cat "$path" 2>/dev/null || true
  else
    printf '%s: <missing>\n' "$label"
  fi
}

run_maybe() {
  printf '+ %s\n' "$*"
  "$@"
  local rc=$?
  printf 'rc=%d\n' "$rc"
  return 0
}

restore_enable() {
  if [ "${ENABLE_CHANGED:-0}" = 1 ] && [ -w "$DEV/enable" ]; then
    echo 0 > "$DEV/enable" 2>/dev/null || true
    printf '[%s] restored sysfs enable to 0\n' "$(ts)"
  fi
}

echo "## host_peek_xdma_bars $(ts)"
hostname || true
uname -a || true
id || true
echo "BDF=$BDF"

if [ ! -d "$DEV" ]; then
  echo "ERROR: PCI device not found: $DEV" >&2
  exit 2
fi

show_file vendor "$DEV/vendor"
show_file device "$DEV/device"
show_file class "$DEV/class"
show_file revision "$DEV/revision"
show_file modalias "$DEV/modalias"
show_file enable "$DEV/enable"
show_file driver_override "$DEV/driver_override"
if [ -e "$DEV/driver" ]; then
  DRIVER_BOUND=1
  printf 'driver: '
  readlink "$DEV/driver" || true
else
  DRIVER_BOUND=0
  echo 'driver: <none>'
fi

echo "## config space"
run_maybe setpci -s "$BDF" 00.l
run_maybe setpci -s "$BDF" 04.w
run_maybe setpci -s "$BDF" 10.l
run_maybe setpci -s "$BDF" 14.l

echo "## lspci"
run_maybe lspci -nnvvvs "$BDF"

echo "## modules and device nodes"
run_maybe sh -c "lsmod | grep -E '(^xdma|xdma_chr|xdma-chr)' || true"
run_maybe sh -c "ls -l /dev/xdma* 2>/dev/null || true"
run_maybe sh -c "modinfo xdma 2>/dev/null | sed -n '1,80p' || true"
run_maybe sh -c "modinfo xdma_chr 2>/dev/null | sed -n '1,80p' || true"
run_maybe sh -c "modinfo xdma-chr 2>/dev/null | sed -n '1,80p' || true"

echo "## resources"
if [ -f "$DEV/resource" ]; then
  cat "$DEV/resource"
fi
for idx in 0 1; do
  res="$DEV/resource$idx"
  if [ -e "$res" ]; then
    size=$(stat -c '%s' "$res" 2>/dev/null || echo unknown)
    echo "resource$idx size=$size path=$res"
  else
    echo "resource$idx missing"
  fi
done

ENABLE_CHANGED=0
if [ "${XDMA_BAR_PEEK_ENABLE_DEVICE:-0}" = 1 ]; then
  if [ "$(id -u)" != 0 ]; then
    echo "ERROR: XDMA_BAR_PEEK_ENABLE_DEVICE=1 requires root" >&2
    exit 3
  fi
  old_enable="$(cat "$DEV/enable" 2>/dev/null || echo unknown)"
  if [ "$old_enable" = 0 ]; then
    trap restore_enable EXIT
    echo 1 > "$DEV/enable"
    ENABLE_CHANGED=1
    printf '[%s] wrote sysfs enable=1 for BAR read\n' "$(ts)"
  else
    echo "sysfs enable already $old_enable; not changing it"
  fi
  show_file enable_after "$DEV/enable"
  run_maybe setpci -s "$BDF" 04.w
else
  echo "XDMA_BAR_PEEK_ENABLE_DEVICE is not set; not changing sysfs enable"
fi

read_u32() {
  local res="$1"
  local off="$2"
  timeout "${READ_TIMEOUT}s" python3 - "$res" "$off" <<'PY'
import mmap
import os
import struct
import sys

path = sys.argv[1]
offset = int(sys.argv[2], 0)
page = mmap.PAGESIZE
base = offset & ~(page - 1)
delta = offset - base
fd = os.open(path, os.O_RDONLY | getattr(os, "O_SYNC", 0))
try:
    mm = mmap.mmap(fd, page, mmap.MAP_SHARED, mmap.PROT_READ, offset=base)
    try:
        data = mm[delta:delta + 4]
        if len(data) != 4:
            raise RuntimeError(f"short read: {len(data)}")
        print(f"0x{struct.unpack('<I', data)[0]:08x}")
    finally:
        mm.close()
finally:
    os.close(fd)
PY
}

echo "## raw XDMA signature reads"
if [ "$DRIVER_BOUND" = 1 ] && [ "$ALLOW_BOUND_RAW_READ" != 1 ]; then
  echo "ERROR: refusing sysfs resource mmap while a PCI driver is bound" >&2
  echo "Use the driver's control/user character devices, or explicitly set" >&2
  echo "XDMA_BAR_PEEK_ALLOW_BOUND_RAW_READ=1 only for a separately approved destructive diagnostic." >&2
  exit 4
fi
for idx in 0 1; do
  res="$DEV/resource$idx"
  if [ ! -e "$res" ]; then
    echo "BAR$idx missing"
    continue
  fi
  for off in 0x2000 0x3000; do
    printf 'BAR%d+%s: ' "$idx" "$off"
    value="$(read_u32 "$res" "$off" 2>&1)"
    rc=$?
    printf '%s rc=%d\n' "$value" "$rc"
  done
done

echo "## dmesg tail"
dmesg -T 2>/dev/null | tail -200 || true

echo "## host_peek_xdma_bars done $(ts)"
