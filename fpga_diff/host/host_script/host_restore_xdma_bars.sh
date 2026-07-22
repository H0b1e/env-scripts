#!/usr/bin/env bash
set -euo pipefail

BDF="${XDMA_BDF:-0000:01:00.0}"
DEV="/sys/bus/pci/devices/$BDF"
EXPECTED_VENDOR="${XDMA_EXPECTED_VENDOR:-0x10ee}"
EXPECTED_DEVICE="${XDMA_EXPECTED_DEVICE:-0x9048}"
EXPECTED_BAR0_SIZE="${XDMA_EXPECTED_BAR0_SIZE:-0x80000}"
EXPECTED_BAR1_SIZE="${XDMA_EXPECTED_BAR1_SIZE:-0x10000}"
APPLY="${XDMA_RESTORE_APPLY:-0}"
VERIFY_SIGNATURE="${XDMA_RESTORE_VERIFY_SIGNATURE:-1}"
ALLOW_BOUND="${XDMA_RESTORE_ALLOW_BOUND:-0}"
ALLOW_SIZE_MISMATCH="${XDMA_RESTORE_ALLOW_SIZE_MISMATCH:-0}"
READ_TIMEOUT="${XDMA_BAR_READ_TIMEOUT_SEC:-5}"
LOG="${XDMA_RESTORE_LOG:-}"

if [ -n "$LOG" ]; then
  mkdir -p "$(dirname "$LOG")"
  exec > >(tee -a "$LOG") 2>&1
fi

ts() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

norm_hex() {
  local width="$1"
  local value="${2#0x}"
  value="${value#0X}"
  value="${value,,}"
  if [ -z "$value" ]; then
    value=0
  fi
  printf "%0${width}x" "$((16#$value))"
}

read_resource_field() {
  local idx="$1"
  local field="$2"
  awk -v line="$((idx + 1))" -v field="$field" 'NR == line {print $field}' "$DEV/resource"
}

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

echo "## host_restore_xdma_bars $(ts)"
hostname || true
uname -a || true
echo "BDF=$BDF"

[ -d "$DEV" ] || die "PCI device not found: $DEV"
[ -f "$DEV/resource" ] || die "PCI resource file not found: $DEV/resource"
if [ "$APPLY" = 1 ] && [ "$(id -u)" != 0 ]; then
  die "XDMA_RESTORE_APPLY=1 requires root"
fi
if [ -e "$DEV/driver" ] && [ "$ALLOW_BOUND" != 1 ]; then
  die "device is already bound to $(readlink "$DEV/driver"); unload/unbind intentionally before BAR restore"
fi

vendor="$(tr -d '[:space:]' < "$DEV/vendor")"
device="$(tr -d '[:space:]' < "$DEV/device")"
vendor_norm="0x$(norm_hex 4 "$vendor")"
device_norm="0x$(norm_hex 4 "$device")"
expected_vendor_norm="0x$(norm_hex 4 "$EXPECTED_VENDOR")"
expected_device_norm="0x$(norm_hex 4 "$EXPECTED_DEVICE")"
echo "vendor=$vendor_norm"
echo "device=$device_norm"
[ "$vendor_norm" = "$expected_vendor_norm" ] || die "unexpected vendor $vendor_norm, expected $expected_vendor_norm"
[ "$device_norm" = "$expected_device_norm" ] || die "unexpected device $device_norm, expected $expected_device_norm"

id_reg="$(setpci -s "$BDF" 00.l)"
id_reg_norm="$(norm_hex 8 "$id_reg")"
expected_id_reg="$(printf '%04x%04x' "$((16#$(norm_hex 4 "$EXPECTED_DEVICE")))" "$((16#$(norm_hex 4 "$EXPECTED_VENDOR")))")"
echo "config_id=0x$id_reg_norm"
[ "$id_reg_norm" = "$expected_id_reg" ] || die "config-space ID is 0x$id_reg_norm, expected 0x$expected_id_reg"

bar0_start_raw="$(read_resource_field 0 1)"
bar0_end_raw="$(read_resource_field 0 2)"
bar1_start_raw="$(read_resource_field 1 1)"
bar1_end_raw="$(read_resource_field 1 2)"
[ -n "$bar0_start_raw" ] && [ -n "$bar1_start_raw" ] || die "BAR0/BAR1 resources are missing"

bar0_start=$((bar0_start_raw))
bar0_end=$((bar0_end_raw))
bar1_start=$((bar1_start_raw))
bar1_end=$((bar1_end_raw))
bar0_size=$((bar0_end - bar0_start + 1))
bar1_size=$((bar1_end - bar1_start + 1))
expected_bar0_size=$((EXPECTED_BAR0_SIZE))
expected_bar1_size=$((EXPECTED_BAR1_SIZE))

printf 'resource0=0x%08x-0x%08x size=0x%x\n' "$bar0_start" "$bar0_end" "$bar0_size"
printf 'resource1=0x%08x-0x%08x size=0x%x\n' "$bar1_start" "$bar1_end" "$bar1_size"
if [ "$expected_bar0_size" -ne 0 ] && [ "$bar0_size" -ne "$expected_bar0_size" ]; then
  msg="$(printf 'BAR0 size is 0x%x, expected 0x%x' "$bar0_size" "$expected_bar0_size")"
  [ "$ALLOW_SIZE_MISMATCH" = 1 ] || die "$msg"
  echo "WARN: $msg"
fi
if [ "$expected_bar1_size" -ne 0 ] && [ "$bar1_size" -ne "$expected_bar1_size" ]; then
  msg="$(printf 'BAR1 size is 0x%x, expected 0x%x' "$bar1_size" "$expected_bar1_size")"
  [ "$ALLOW_SIZE_MISMATCH" = 1 ] || die "$msg"
  echo "WARN: $msg"
fi
if [ "$bar0_start" -eq 0 ] || [ "$bar1_start" -eq 0 ]; then
  die "BAR resource base is zero; rescan/enumeration did not assign usable resources"
fi
if ((bar0_start > 0xffffffff || bar1_start > 0xffffffff)); then
  die "BAR base above 32-bit range is not supported by this recovery script"
fi

printf -v bar0_hex '%08x' "$bar0_start"
printf -v bar1_hex '%08x' "$bar1_start"
cmd_before="$(setpci -s "$BDF" 04.w)"
bar0_before="$(setpci -s "$BDF" 10.l)"
bar1_before="$(setpci -s "$BDF" 14.l)"
cmd_before_norm="$(norm_hex 4 "$cmd_before")"
bar0_before_norm="$(norm_hex 8 "$bar0_before")"
bar1_before_norm="$(norm_hex 8 "$bar1_before")"
cmd_after_val=$((16#$cmd_before_norm | 0x0006))
printf -v cmd_after_hex '%04x' "$cmd_after_val"

echo "config_before: command=0x$cmd_before_norm bar0=0x$bar0_before_norm bar1=0x$bar1_before_norm"
echo "config_target: command=0x$cmd_after_hex bar0=0x$bar0_hex bar1=0x$bar1_hex"

if [ "$bar0_before_norm" = "$bar0_hex" ] \
  && [ "$bar1_before_norm" = "$bar1_hex" ] \
  && [ $((16#$cmd_before_norm & 0x0006)) -eq 6 ]; then
  echo "BAR config registers already match sysfs resources and COMMAND has memory+bus-master enabled"
else
  if [ "$APPLY" != 1 ]; then
    echo "Dry run only. Set XDMA_RESTORE_APPLY=1 to write BAR registers."
    exit 10
  fi
  setpci -s "$BDF" 10.l="$bar0_hex" 14.l="$bar1_hex" 04.w="$cmd_after_hex"
  echo "setpci_restore_rc=$?"
fi

cmd_now="$(norm_hex 4 "$(setpci -s "$BDF" 04.w)")"
bar0_now="$(norm_hex 8 "$(setpci -s "$BDF" 10.l)")"
bar1_now="$(norm_hex 8 "$(setpci -s "$BDF" 14.l)")"
echo "config_after: command=0x$cmd_now bar0=0x$bar0_now bar1=0x$bar1_now"
[ "$bar0_now" = "$bar0_hex" ] || die "BAR0 config register restore failed"
[ "$bar1_now" = "$bar1_hex" ] || die "BAR1 config register restore failed"
[ $((16#$cmd_now & 0x0006)) -eq 6 ] || die "COMMAND memory+bus-master bits are not enabled"

if [ "$VERIFY_SIGNATURE" = 1 ]; then
  echo "## raw XDMA config BAR signature check"
  irq_sig="$(read_u32 "$DEV/resource1" 0x2000)"
  cfg_sig="$(read_u32 "$DEV/resource1" 0x3000)"
  echo "BAR1+0x2000=$irq_sig"
  echo "BAR1+0x3000=$cfg_sig"
  irq_hi=$(( (16#${irq_sig#0x} >> 16) & 0xffff ))
  cfg_hi=$(( (16#${cfg_sig#0x} >> 16) & 0xffff ))
  [ "$irq_hi" -eq $((16#1fc2)) ] || die "BAR1+0x2000 high16 is not 0x1fc2"
  [ "$cfg_hi" -eq $((16#1fc3)) ] || die "BAR1+0x3000 high16 is not 0x1fc3"
fi

echo "restore_result=ok"
