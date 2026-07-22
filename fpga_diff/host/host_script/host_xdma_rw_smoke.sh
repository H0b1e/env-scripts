#!/usr/bin/env bash
set -u

H2C_DEV="${XDMA_H2C_DEV:-/dev/xdma0_h2c_0}"
C2H_DEV="${XDMA_C2H_DEV:-/dev/xdma0_c2h_0}"
SIZE="${XDMA_SMOKE_BYTES:-4096}"
H2C_TIMEOUT="${XDMA_H2C_TIMEOUT_SEC:-10}"
C2H_TIMEOUT="${XDMA_C2H_TIMEOUT_SEC:-10}"
ORDER="${XDMA_SMOKE_ORDER:-concurrent}"
START_GAP="${XDMA_SMOKE_START_GAP_SEC:-0.2}"
COMPARE="${XDMA_SMOKE_COMPARE:-1}"
OUT_DIR="${XDMA_SMOKE_DIR:-/tmp/xdma_smoke_$(date +%Y%m%d_%H%M%S)}"
LOG="${XDMA_SMOKE_LOG:-}"

if [ -n "$LOG" ]; then
  mkdir -p "$(dirname "$LOG")"
  exec > >(tee -a "$LOG") 2>&1
fi

mkdir -p "$OUT_DIR"
payload="$OUT_DIR/h2c_payload.bin"
c2h_out="$OUT_DIR/c2h_read.bin"

echo "## host_xdma_rw_smoke $(date '+%Y-%m-%dT%H:%M:%S%z')"
hostname || true
uname -a || true
echo "H2C_DEV=$H2C_DEV"
echo "C2H_DEV=$C2H_DEV"
echo "SIZE=$SIZE"
echo "ORDER=$ORDER"
ls -l /dev/xdma* 2>/dev/null || true

if [ ! -e "$H2C_DEV" ] || [ ! -e "$C2H_DEV" ]; then
  echo "ERROR: required XDMA device nodes are missing" >&2
  exit 2
fi

python3 - "$payload" "$SIZE" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
size = int(sys.argv[2], 0)
data = bytes((i % 251 for i in range(size)))
path.write_bytes(data)
print(f"payload_bytes={len(data)}")
PY

echo "## dmesg before"
dmesg -T 2>/dev/null | tail -120 || true

set +e
case "$ORDER" in
  concurrent)
    timeout "${C2H_TIMEOUT}s" dd if="$C2H_DEV" of="$c2h_out" bs="$SIZE" count=1 iflag=fullblock status=none &
    c2h_pid=$!
    sleep "$START_GAP"
    timeout "${H2C_TIMEOUT}s" dd if="$payload" of="$H2C_DEV" bs="$SIZE" count=1 status=none
    h2c_rc=$?
    wait "$c2h_pid"
    c2h_rc=$?
    ;;
  h2c_then_c2h)
    timeout "${H2C_TIMEOUT}s" dd if="$payload" of="$H2C_DEV" bs="$SIZE" count=1 status=none
    h2c_rc=$?
    timeout "${C2H_TIMEOUT}s" dd if="$C2H_DEV" of="$c2h_out" bs="$SIZE" count=1 iflag=fullblock status=none
    c2h_rc=$?
    ;;
  c2h_then_h2c)
    timeout "${C2H_TIMEOUT}s" dd if="$C2H_DEV" of="$c2h_out" bs="$SIZE" count=1 iflag=fullblock status=none &
    c2h_pid=$!
    sleep "$START_GAP"
    timeout "${H2C_TIMEOUT}s" dd if="$payload" of="$H2C_DEV" bs="$SIZE" count=1 status=none
    h2c_rc=$?
    wait "$c2h_pid"
    c2h_rc=$?
    ;;
  *)
    echo "ERROR: XDMA_SMOKE_ORDER must be concurrent, h2c_then_c2h, or c2h_then_h2c" >&2
    h2c_rc=98
    c2h_rc=98
    ;;
esac
set -e

h2c_bytes=$(wc -c < "$payload" 2>/dev/null || echo 0)
c2h_bytes=$(wc -c < "$c2h_out" 2>/dev/null || echo 0)
if [ -s "$c2h_out" ]; then
  c2h_sha256=$(sha256sum "$c2h_out" | awk '{print $1}')
else
  c2h_sha256=none
fi
payload_sha256=$(sha256sum "$payload" | awk '{print $1}')
cmp_rc=99
if [ "$COMPARE" = 1 ] && [ -s "$c2h_out" ]; then
  cmp -s "$payload" "$c2h_out"
  cmp_rc=$?
fi

echo "h2c_rc=$h2c_rc"
echo "h2c_bytes_attempted=$h2c_bytes"
echo "c2h_rc=$c2h_rc"
echo "c2h_bytes_read=$c2h_bytes"
echo "payload_sha256=$payload_sha256"
echo "c2h_sha256=$c2h_sha256"
echo "cmp_rc=$cmp_rc"
echo "payload=$payload"
echo "c2h_out=$c2h_out"

echo "## dmesg after"
dmesg -T 2>/dev/null | tail -200 || true

if [ "$h2c_rc" -eq 0 ] && [ "$c2h_rc" -eq 0 ] && { [ "$COMPARE" != 1 ] || [ "$cmp_rc" -eq 0 ]; }; then
  exit 0
fi
exit 1
