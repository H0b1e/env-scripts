#!/usr/bin/env bash
set -euo pipefail

BDF="${XDMA_BDF:-0000:01:00.0}"
DEV="/sys/bus/pci/devices/$BDF"
KO="${XDMA_CHR_KO:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$KO" ]; then
  for candidate in \
    "$HOME/project/minjie-playground/dma_ip_drivers/XDMA/linux-kernel/xdma/xdma-chr.ko" \
    "$HOME/dma_ip_drivers/XDMA/linux-kernel/xdma/xdma-chr.ko"; do
    if [ -f "$candidate" ]; then
      KO="$candidate"
      break
    fi
  done
fi

ts() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

failures=0

show_file() {
  local label="$1"
  local path="$2"
  if [ -e "$path" ]; then
    printf '%s=' "$label"
    cat "$path" 2>/dev/null || true
  else
    printf '%s=<missing>\n' "$label"
  fi
}

echo "## host_preflight_readonly $(ts)"
hostname || true
uname -a || true
echo "BDF=$BDF"
echo "DEV=$DEV"
echo "XDMA_CHR_KO=${KO:-<not-found>}"
echo "note=no rescan, no remove/reset/unbind, no driver load"

echo "## process residue"
ps -eo pid,ppid,user,etime,stat,wchan:24,cmd \
  | awk -v self="$$" -v parent="$PPID" \
      '$1 != self && $1 != parent && $0 ~ /fpga-host|strace|trigger_ddr|timeout|xdma/ && $0 !~ /awk -v self=/ {print}' || true

echo "## device nodes and modules"
ls -l /dev/xdma* 2>/dev/null || true
lsmod | grep -i xdma || true

echo "## lspci target scan"
lspci -Dnn | grep -Ei '10ee:9048|xilinx|xdma' || true
if [ -d "$DEV" ]; then
  echo "## sysfs target"
  show_file vendor "$DEV/vendor"
  show_file device "$DEV/device"
  show_file class "$DEV/class"
  show_file revision "$DEV/revision"
  show_file enable "$DEV/enable"
  show_file driver_override "$DEV/driver_override"
  if [ -e "$DEV/driver" ]; then
    printf 'driver='
    readlink "$DEV/driver" || true
  else
    echo 'driver=<none>'
  fi
  vendor="$(tr -d '[:space:]' <"$DEV/vendor" 2>/dev/null || true)"
  device="$(tr -d '[:space:]' <"$DEV/device" 2>/dev/null || true)"
  revision="$(tr -d '[:space:]' <"$DEV/revision" 2>/dev/null || true)"
  if [ "${vendor,,}" = 0x10ee ] && [ "${device,,}" = 0x9048 ] && [ "${revision,,}" != 0xff ]; then
    echo "endpoint_identity_ok=10ee:9048 revision=$revision"
  else
    echo "endpoint_identity_fail vendor=$vendor device=$device revision=$revision"
    failures=$((failures + 1))
  fi

  echo "## lspci verbose target"
  lspci_out="$(lspci -Dvvv -s "$BDF" 2>&1 || true)"
  printf '%s\n' "$lspci_out" | sed -n '1,180p'
  if printf '%s\n' "$lspci_out" | grep -Eq 'LnkSta:.*Speed (8|8[.]0)GT/s.*Width x4'; then
    echo "pcie_link_ok=Gen3_x4"
  else
    echo "pcie_link_fail=expected_Gen3_x4"
    failures=$((failures + 1))
  fi
  echo "## config registers"
  setpci -s "$BDF" 00.l 04.w 10.l 14.l || true
  echo "## resources"
  cat "$DEV/resource" 2>/dev/null || true
  bar0_size="$(stat -c '%s' "$DEV/resource0" 2>/dev/null || echo 0)"
  bar1_size="$(stat -c '%s' "$DEV/resource1" 2>/dev/null || echo 0)"
  echo "bar0_size_bytes=$bar0_size"
  echo "bar1_size_bytes=$bar1_size"
  if [ "$bar0_size" = 524288 ] && [ "$bar1_size" = 65536 ]; then
    echo "bar_sizes_ok=BAR0_512KiB_BAR1_64KiB"
  else
    echo "bar_sizes_fail=expected_524288_65536"
    failures=$((failures + 1))
  fi
else
  echo "target_present=0"
  failures=$((failures + 1))
fi

echo "## xdma-chr module candidate"
if [ -n "$KO" ] && [ -f "$KO" ]; then
  stat -c 'ko=%n size=%s mtime=%y' "$KO"
  modinfo "$KO" | sed -n '1,120p'
  kernel="$(uname -r)"
  vermagic="$(modinfo -F vermagic "$KO" 2>/dev/null || true)"
  aliases="$(modinfo -F alias "$KO" 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
  case "$vermagic" in
    "$kernel"*) echo "vermagic_ok=$vermagic" ;;
    *) echo "vermagic_mismatch kernel=$kernel module=$vermagic"; failures=$((failures + 1)) ;;
  esac
  if printf '%s\n' "$aliases" | grep -q 'v000010eed00009048'; then
    echo "alias_ok=10ee:9048"
  else
    echo "alias_missing=10ee:9048"
    failures=$((failures + 1))
  fi
else
  echo "ko_missing=${KO:-set XDMA_CHR_KO to the MinJie mainline module path}"
  failures=$((failures + 1))
fi

echo "## helper hashes"
sha256sum \
  "$SCRIPT_DIR/host_bar_peek_after_rescan.sh" \
  "$SCRIPT_DIR/host_peek_xdma_bars.sh" \
  "$SCRIPT_DIR/host_restore_xdma_bars.sh" \
  "$SCRIPT_DIR/host_xdma_chr_probe.sh" \
  "$SCRIPT_DIR/host_fpga_diff_strace_run.sh" \
  "$SCRIPT_DIR/host_parse_strace_c2h_reads.py" \
  "$SCRIPT_DIR/host_preflight_readonly.sh" \
  2>/dev/null || true

echo "## dmesg tail"
dmesg -T 2>/dev/null | grep -iE 'xdma|xilinx|10ee|9048|pcie|pci ' | tail -160 || true

echo "## host_preflight_readonly done $(ts)"
if [ "$failures" -ne 0 ]; then
  echo "host_preflight_result=fail count=$failures"
  exit 20
fi
echo "host_preflight_result=ok"
