#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${XDMA_OFFICIAL_SRC_DIR:-$HOME/xdma_official_src}"
REPO_URL="${XDMA_OFFICIAL_REPO_URL:-https://github.com/Xilinx/dma_ip_drivers.git}"
REF="${XDMA_OFFICIAL_REF:-}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
LOG="${XDMA_OFFICIAL_BUILD_LOG:-}"

if [ -n "$LOG" ]; then
  mkdir -p "$(dirname "$LOG")"
  exec > >(tee -a "$LOG") 2>&1
fi

echo "## host_build_official_xdma $(date '+%Y-%m-%dT%H:%M:%S%z')"
hostname || true
uname -a || true
echo "SRC_DIR=$SRC_DIR"
echo "REPO_URL=$REPO_URL"
echo "REF=${REF:-<default>}"

if [ ! -d "$SRC_DIR/.git" ]; then
  git clone --depth 1 "$REPO_URL" "$SRC_DIR"
fi

if [ -n "$REF" ]; then
  git -C "$SRC_DIR" fetch --depth 1 origin "$REF"
  git -C "$SRC_DIR" checkout FETCH_HEAD
fi

git -C "$SRC_DIR" rev-parse HEAD

XDMA_DIR="$SRC_DIR/XDMA/linux-kernel/xdma"
if [ ! -d "$XDMA_DIR" ]; then
  echo "ERROR: XDMA driver directory not found: $XDMA_DIR" >&2
  exit 2
fi

if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
  echo "ERROR: kernel headers missing: /lib/modules/$(uname -r)/build" >&2
  exit 3
fi

make -C "$XDMA_DIR" clean
make -C "$XDMA_DIR" -j"$JOBS" DEBUG="${DEBUG:-1}"

KO="$XDMA_DIR/xdma.ko"
if [ ! -f "$KO" ]; then
  echo "ERROR: build did not produce $KO" >&2
  exit 4
fi

modinfo "$KO" | sed -n '1,140p'
kernel="$(uname -r)"
vermagic="$(modinfo -F vermagic "$KO" 2>/dev/null || true)"
aliases="$(modinfo -F alias "$KO" 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
case "$vermagic" in
  "$kernel"*) echo "vermagic_ok=$vermagic" ;;
  *) echo "ERROR: vermagic mismatch: kernel=$kernel module=$vermagic" >&2; exit 5 ;;
esac
if printf '%s\n' "$aliases" | grep -q 'v000010eed00009048'; then
  echo "alias_ok=10ee:9048"
else
  echo "ERROR: official module alias does not cover 10ee:9048" >&2
  exit 6
fi

echo "official_xdma_ko=$KO"
echo "No install or module load was performed."
