#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TAG="${FPGA_DIFF_RUN_TAG:?set a unique FPGA_DIFF_RUN_TAG}"
case "$TAG" in
  *[!A-Za-z0-9_.-]*|.|..)
    echo "ERROR: FPGA_DIFF_RUN_TAG may contain only A-Z, a-z, 0-9, _, ., and -" >&2
    exit 5
    ;;
esac
if [ "${#TAG}" -gt 120 ]; then
  echo "ERROR: FPGA_DIFF_RUN_TAG is longer than 120 characters" >&2
  exit 5
fi
DDR_PRELOADED="${FPGA_HOST_DDR_PRELOADED:-0}"
WORKDIR="${FPGA_HOST_WORKDIR:-$PWD}"
HOST_BIN="${FPGA_HOST_BIN:?set FPGA_HOST_BIN}"
NEMU_SO="${FPGA_NEMU_SO:-}"
WORKLOAD_BIN="${FPGA_WORKLOAD_BIN:?set FPGA_WORKLOAD_BIN}"
NO_DIFF="${FPGA_NO_DIFF:-0}"
GUARD_TIMEOUT="${FPGA_HOST_GUARD_TIMEOUT_SEC:-1800}"
IDLE_TIMEOUT="${FPGA_HOST_IDLE_TIMEOUT_SEC:-300}"
POLL_INTERVAL="${FPGA_HOST_PROGRESS_POLL_SEC:-10}"
TERM_GRACE="${FPGA_HOST_TERM_GRACE_SEC:-10}"
LOG_DIR="${FPGA_HOST_LOG_DIR:-$WORKDIR/logs}"
EXTRA_ARGS="${FPGA_HOST_EXTRA_ARGS:-}"
EXTRA_ARGV=()
if [ -n "$EXTRA_ARGS" ]; then
  read -r -a EXTRA_ARGV <<<"$EXTRA_ARGS"
fi
STRACE_BIN="${STRACE_BIN:-strace}"
REBOOT_ON_C2H_IDLE="${FPGA_HOST_REBOOT_ON_C2H_IDLE:-0}"
REBOOT_DELAY="${FPGA_HOST_REBOOT_DELAY_SEC:-10}"
REBOOT_SETTLE="${FPGA_HOST_REBOOT_SETTLE_SEC:-5}"
REBOOT_DRY_RUN="${FPGA_HOST_REBOOT_DRY_RUN:-0}"

mkdir -p "$LOG_DIR"

HOST_LOG="$LOG_DIR/${TAG}.fpga-host.log"
STRACE_LOG="$LOG_DIR/${TAG}.strace.log"
SUMMARY_LOG="$LOG_DIR/${TAG}.summary.log"
REBOOT_LOG="$LOG_DIR/${TAG}.auto-reboot.log"

for existing in \
  "$HOST_LOG" \
  "$SUMMARY_LOG" \
  "$REBOOT_LOG" \
  "$STRACE_LOG" \
  "$STRACE_LOG".*; do
  if [ -e "$existing" ]; then
    echo "ERROR: refusing reused FPGA_DIFF_RUN_TAG; artifact already exists: $existing" >&2
    exit 5
  fi
done

# The board is always programmed by the tagged UVHS runtime.  Workload data can
# either be preloaded through that runtime or sent by an H2C-enabled fpga-host.
# Remove historical hooks first so neither mode can trigger another download.
unset FPGA_DDR_LOAD_CMD UVHS_DOWNLOAD_CMD UVHS_STAGE_DIR UVHS_COMMAND_FILE
export UVHS_DISABLE_DOWNLOAD=1
case "$DDR_PRELOADED" in
  0)
    unset UVHS_DDR_LOAD_CMD
    WORKLOAD_LOAD_PATH=PCIe_XDMA_H2C_bin_to_DDR
    ;;
  1)
    export UVHS_DDR_LOAD_CMD=/bin/true
    WORKLOAD_LOAD_PATH=preloaded_UVHS_DDR
    ;;
  *)
    echo "ERROR: FPGA_HOST_DDR_PRELOADED must be 0 or 1" >&2
    exit 5
    ;;
esac
export FPGA_HOST_DEBUG_INIT=1

case "$NO_DIFF" in
  0)
    if [ -z "$NEMU_SO" ]; then
      echo "ERROR: set FPGA_NEMU_SO for DiffTest mode" >&2
      exit 5
    fi
    HOST_ARGV=("$HOST_BIN" --diff "$NEMU_SO" -i "$WORKLOAD_BIN" "${EXTRA_ARGV[@]}")
    ;;
  1)
    if [ "$REBOOT_ON_C2H_IDLE" = 1 ]; then
      echo "ERROR: C2H-idle reboot is invalid in --no-diff mode because that mode intentionally does not read C2H" >&2
      exit 5
    fi
    HOST_ARGV=("$HOST_BIN" --no-diff -i "$WORKLOAD_BIN" "${EXTRA_ARGV[@]}")
    ;;
  *)
    echo "ERROR: FPGA_NO_DIFF must be 0 or 1" >&2
    exit 5
    ;;
esac

printf -v HOST_COMMAND_Q '%q ' "${HOST_ARGV[@]}"
HOST_COMMAND_Q="${HOST_COMMAND_Q% }"

ts() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

reboot_scheduled=0
schedule_idle_reboot() {
  local min_delay effective_delay
  [ "$REBOOT_ON_C2H_IDLE" = 1 ] || return 0
  if [ "$REBOOT_DRY_RUN" != 1 ] && [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: automatic reboot requested but runner is not root" | tee -a "$SUMMARY_LOG" >&2
    return 1
  fi
  min_delay=$((TERM_GRACE + REBOOT_SETTLE))
  effective_delay="$REBOOT_DELAY"
  if [ "$effective_delay" -lt "$min_delay" ]; then
    effective_delay="$min_delay"
  fi
  {
    echo "auto_reboot_trigger=$(ts)"
    echo "reason=c2h_idle_timeout"
    echo "idle_timeout=$IDLE_TIMEOUT"
    echo "last_reads=$last_reads"
    echo "last_bytes=$last_bytes"
    echo "requested_delay_seconds=$REBOOT_DELAY"
    echo "effective_delay_seconds=$effective_delay"
    echo "dry_run=$REBOOT_DRY_RUN"
    echo "summary_log=$SUMMARY_LOG"
  } | tee "$REBOOT_LOG" | tee -a "$SUMMARY_LOG"
  sync
  # Pass TAG as an explicit argument so the scheduled process remains
  # attributable to this exact run in ps output until reboot.
  setsid nohup bash -c '
    tag="$2"
    dry_run="$3"
    reboot_log="$4"
    sleep "$1"
    if [ "$dry_run" = 1 ]; then
      printf "auto_reboot_dry_run_fired=%s tag=%s\n" "$(date +%Y-%m-%dT%H:%M:%S%z)" "$tag" >>"$reboot_log"
      exit 0
    fi
    systemctl reboot
  ' _ "$effective_delay" "$TAG" "$REBOOT_DRY_RUN" "$REBOOT_LOG" \
    >>"$REBOOT_LOG" 2>&1 </dev/null &
  echo "auto_reboot_scheduled_pid=$! tag=$TAG" | tee -a "$SUMMARY_LOG" "$REBOOT_LOG"
  reboot_scheduled=1
}

runner_alive_non_zombie() {
  local stat
  kill -0 "$runner_pid" 2>/dev/null || return 1
  stat="$(ps -o stat= -p "$runner_pid" 2>/dev/null | awk 'NR == 1 {print $1}')"
  [ -n "$stat" ] && [ "${stat#Z}" = "$stat" ]
}

pgid_has_live_members() {
  ps -eo pgid=,stat= 2>/dev/null | awk -v pgid="$runner_pid" '
    $1 == pgid && $2 !~ /^Z/ { found = 1 }
    END { exit(found ? 0 : 1) }
  '
}

verify_owned_pgid() {
  local leader_row group_rows
  leader_row="$(ps -o pid=,pgid=,ppid=,user=,stat=,args= -p "$runner_pid" 2>/dev/null || true)"
  group_rows="$(ps -eo pid=,pgid=,ppid=,user=,stat=,args= 2>/dev/null | awk -v pgid="$runner_pid" '$2 == pgid')"
  printf 'owned_pgid_leader=%s\n' "$leader_row" | tee -a "$SUMMARY_LOG"
  printf 'owned_pgid_members_begin\n%s\nowned_pgid_members_end\n' "$group_rows" | tee -a "$SUMMARY_LOG"
  case "$leader_row" in
    *"$TAG"*) return 0 ;;
    *)
      echo "ERROR: pgid leader command line does not contain exact tag=$TAG; refusing signal/reboot" | tee -a "$SUMMARY_LOG" >&2
      return 1
      ;;
  esac
}

echo "## host_fpga_diff_strace_run $(ts)" | tee "$SUMMARY_LOG"
echo "tag=$TAG" | tee -a "$SUMMARY_LOG"
echo "workdir=$WORKDIR" | tee -a "$SUMMARY_LOG"
echo "host_bin=$HOST_BIN" | tee -a "$SUMMARY_LOG"
echo "nemu_so=$NEMU_SO" | tee -a "$SUMMARY_LOG"
echo "workload_bin=$WORKLOAD_BIN" | tee -a "$SUMMARY_LOG"
echo "no_diff=$NO_DIFF" | tee -a "$SUMMARY_LOG"
echo "workload_load_path=$WORKLOAD_LOAD_PATH" | tee -a "$SUMMARY_LOG"
echo "guard_timeout=$GUARD_TIMEOUT" | tee -a "$SUMMARY_LOG"
echo "idle_timeout=$IDLE_TIMEOUT" | tee -a "$SUMMARY_LOG"
echo "progress_poll=$POLL_INTERVAL" | tee -a "$SUMMARY_LOG"
echo "term_grace=$TERM_GRACE" | tee -a "$SUMMARY_LOG"
echo "reboot_on_c2h_idle=$REBOOT_ON_C2H_IDLE" | tee -a "$SUMMARY_LOG"
echo "reboot_delay=$REBOOT_DELAY" | tee -a "$SUMMARY_LOG"
echo "reboot_settle=$REBOOT_SETTLE" | tee -a "$SUMMARY_LOG"
echo "reboot_dry_run=$REBOOT_DRY_RUN" | tee -a "$SUMMARY_LOG"
echo "host_log=$HOST_LOG" | tee -a "$SUMMARY_LOG"
echo "strace_log=$STRACE_LOG" | tee -a "$SUMMARY_LOG"
echo "ddr_preloaded=$DDR_PRELOADED" | tee -a "$SUMMARY_LOG"
echo "UVHS_DISABLE_DOWNLOAD=$UVHS_DISABLE_DOWNLOAD" | tee -a "$SUMMARY_LOG"
echo "UVHS_DDR_LOAD_CMD=${UVHS_DDR_LOAD_CMD-<unset>}" | tee -a "$SUMMARY_LOG"
echo "FPGA_HOST_DEBUG_INIT=$FPGA_HOST_DEBUG_INIT" | tee -a "$SUMMARY_LOG"
echo "stale_host_hooks_unset=FPGA_DDR_LOAD_CMD,UVHS_DOWNLOAD_CMD,UVHS_STAGE_DIR,UVHS_COMMAND_FILE" | tee -a "$SUMMARY_LOG"
echo "fpga_host_command=$HOST_COMMAND_Q" | tee -a "$SUMMARY_LOG"

case "$REBOOT_ON_C2H_IDLE" in
  0|1) ;;
  *)
    echo "ERROR: FPGA_HOST_REBOOT_ON_C2H_IDLE must be 0 or 1" | tee -a "$SUMMARY_LOG" >&2
    exit 4
    ;;
esac
case "$REBOOT_DRY_RUN" in
  0|1) ;;
  *)
    echo "ERROR: FPGA_HOST_REBOOT_DRY_RUN must be 0 or 1" | tee -a "$SUMMARY_LOG" >&2
    exit 4
    ;;
esac
case "$REBOOT_DELAY" in
  ''|*[!0-9]*|0[0-9]*)
    echo "ERROR: FPGA_HOST_REBOOT_DELAY_SEC must be a non-negative integer" | tee -a "$SUMMARY_LOG" >&2
    exit 4
    ;;
esac
for item in \
  "FPGA_HOST_GUARD_TIMEOUT_SEC:$GUARD_TIMEOUT" \
  "FPGA_HOST_IDLE_TIMEOUT_SEC:$IDLE_TIMEOUT" \
  "FPGA_HOST_PROGRESS_POLL_SEC:$POLL_INTERVAL"; do
  name="${item%%:*}"
  value="${item#*:}"
  case "$value" in
    ''|*[!0-9]*|0*)
      echo "ERROR: $name must be a positive integer" | tee -a "$SUMMARY_LOG" >&2
      exit 4
      ;;
  esac
done
case "$TERM_GRACE" in
  ''|*[!0-9]*|0[0-9]*)
    echo "ERROR: FPGA_HOST_TERM_GRACE_SEC must be a non-negative integer" | tee -a "$SUMMARY_LOG" >&2
    exit 4
    ;;
esac
case "$REBOOT_SETTLE" in
  ''|*[!0-9]*|0[0-9]*)
    echo "ERROR: FPGA_HOST_REBOOT_SETTLE_SEC must be a non-negative integer" | tee -a "$SUMMARY_LOG" >&2
    exit 4
    ;;
esac

required_files=("$HOST_BIN" "$WORKLOAD_BIN")
if [ "$NO_DIFF" = 0 ]; then
  required_files+=("$NEMU_SO")
fi
for f in "${required_files[@]}"; do
  if [ ! -e "$f" ]; then
    echo "ERROR: missing required file: $f" | tee -a "$SUMMARY_LOG" >&2
    exit 2
  fi
done
if ! command -v "$STRACE_BIN" >/dev/null 2>&1; then
  echo "ERROR: strace not found; set STRACE_BIN or install strace" | tee -a "$SUMMARY_LOG" >&2
  exit 3
fi
if ! "$STRACE_BIN" -yy -V >/dev/null 2>&1; then
  echo "ERROR: strace does not support -yy fd-path decoding; reliable C2H attribution unavailable" | tee -a "$SUMMARY_LOG" >&2
  exit 3
fi
echo "strace_fd_decode=yy" | tee -a "$SUMMARY_LOG"

echo "## pre-run host state" | tee -a "$SUMMARY_LOG"
{
  hostname || true
  uname -a || true
  ls -l /dev/xdma* 2>/dev/null || true
  lsmod | grep -i xdma || true
  fuser -v /dev/xdma0_c2h_0 /dev/xdma0_h2c_0 /dev/xdma0_user 2>&1 || true
} | tee -a "$SUMMARY_LOG"

cd "$WORKDIR"

set +e
setsid bash -c '
  run_tag=$1
  shift
  set +e
  timeout "$@"
  rc=$?
  exit "$rc"
' _ "$TAG" "${GUARD_TIMEOUT}s" "$STRACE_BIN" -ff -ttt -yy -e trace=read,write,openat,close \
  -o "$STRACE_LOG" \
  "${HOST_ARGV[@]}" \
  > >(tee "$HOST_LOG") 2>&1 &
runner_pid=$!
set -e

echo "runner_pid=$runner_pid" | tee -a "$SUMMARY_LOG"
echo "runner_pgid=$runner_pid" | tee -a "$SUMMARY_LOG"
last_reads=0
last_bytes=0
idle_since=0
last_success_ts=None
stop_reason=process_exit
early_exit=0

if runner_alive_non_zombie; then
  if ! verify_owned_pgid; then
    echo "fpga_host_stop_reason=unsafe_process_identity" | tee -a "$SUMMARY_LOG"
    exit 126
  fi
else
  early_exit=1
  echo "runner_exited_before_identity_check=1" | tee -a "$SUMMARY_LOG"
fi

while runner_alive_non_zombie; do
  sleep "$POLL_INTERVAL"
  progress="$(python3 "$SCRIPT_DIR/host_parse_strace_c2h_reads.py" "$STRACE_LOG"* 2>/dev/null || true)"
  totals="$(printf '%s\n' "$progress" | awk '/^c2h_read_totals / {line=$0} END {print line}')"
  now_epoch="$(date +%s)"
  opened="$(printf '%s\n' "$totals" | sed -n 's/.* opened=\([0-9][0-9]*\).*/\1/p')"
  reads="$(printf '%s\n' "$totals" | sed -n 's/.* reads=\([0-9][0-9]*\).*/\1/p')"
  bytes="$(printf '%s\n' "$totals" | sed -n 's/.* bytes=\([0-9][0-9]*\).*/\1/p')"
  last_success_ts="$(printf '%s\n' "$totals" | sed -n 's/.* last_ts=\([^ ]*\).*/\1/p')"
  opened="${opened:-0}"
  reads="${reads:-0}"
  bytes="${bytes:-0}"
  last_success_ts="${last_success_ts:-None}"

  printf 'progress_ts=%s opened=%s reads=%s bytes=%s last_success_ts=%s\n' \
    "$(ts)" "$opened" "$reads" "$bytes" "$last_success_ts" | tee -a "$SUMMARY_LOG"

  if [ "$reads" -gt "$last_reads" ] || [ "$bytes" -gt "$last_bytes" ]; then
    idle_since="$now_epoch"
    last_reads="$reads"
    last_bytes="$bytes"
  elif [ "$NO_DIFF" = 0 ] && [ "$opened" -gt 0 ]; then
    if [ "$idle_since" -eq 0 ]; then
      idle_since="$now_epoch"
    elif [ $((now_epoch - idle_since)) -ge "$IDLE_TIMEOUT" ]; then
      stop_reason=c2h_idle_timeout
      echo "stop_reason=$stop_reason idle_seconds=$((now_epoch - idle_since))" | tee -a "$SUMMARY_LOG"
      if ! verify_owned_pgid; then
        stop_reason=unsafe_process_identity
        break
      fi
      schedule_idle_reboot || true
      # runner_pid is the session/process-group leader created by this script.
      kill -TERM -- "-$runner_pid" 2>/dev/null || true
      break
    fi
  fi
done

runner_still_alive=0
if [ "$early_exit" = 1 ]; then
  set +e
  wait "$runner_pid"
  rc=$?
  set -e
elif [ "$stop_reason" = unsafe_process_identity ]; then
  runner_still_alive=1
  rc=126
  echo "runner_signal_refused=1; skip blocking wait" | tee -a "$SUMMARY_LOG"
elif [ "$stop_reason" = c2h_idle_timeout ]; then
  term_deadline=$(( $(date +%s) + TERM_GRACE ))
  while pgid_has_live_members && [ "$(date +%s)" -lt "$term_deadline" ]; do
    sleep 1
  done
  if pgid_has_live_members; then
    echo "runner_term_grace_expired=${TERM_GRACE}s; sending KILL to owned pgid=$runner_pid" | tee -a "$SUMMARY_LOG"
    kill -KILL -- "-$runner_pid" 2>/dev/null || true
    sleep 1
  fi
  if pgid_has_live_members; then
    runner_still_alive=1
    rc=125
    echo "runner_still_alive_after_kill=1; skip blocking wait" | tee -a "$SUMMARY_LOG"
  else
    set +e
    wait "$runner_pid"
    rc=$?
    set -e
  fi
else
  set +e
  wait "$runner_pid"
  rc=$?
  set -e
  if [ "$rc" -eq 124 ]; then
    stop_reason=guard_timeout
  fi
fi

echo "fpga_host_rc=$rc" | tee -a "$SUMMARY_LOG"
echo "fpga_host_stop_reason=$stop_reason" | tee -a "$SUMMARY_LOG"
echo "runner_still_alive=$runner_still_alive" | tee -a "$SUMMARY_LOG"
echo "auto_reboot_scheduled=$reboot_scheduled" | tee -a "$SUMMARY_LOG"
echo "c2h_last_success_ts=$last_success_ts" | tee -a "$SUMMARY_LOG"

echo "## post-run host state" | tee -a "$SUMMARY_LOG"
{
  ps -eo pid,ppid,user,pcpu,etime,stat,wchan:24,cmd | grep -E 'fpga-host|timeout|strace' | grep -v grep || true
  fuser -v /dev/xdma0_c2h_0 /dev/xdma0_h2c_0 /dev/xdma0_user 2>&1 || true
  dmesg -T 2>/dev/null | grep -iE 'xdma|xilinx|10ee|9048|pcie|pci ' | tail -200 || true
} | tee -a "$SUMMARY_LOG"

python3 "$SCRIPT_DIR/host_parse_strace_c2h_reads.py" "$STRACE_LOG"* | tee -a "$SUMMARY_LOG" || true

exit "$rc"
