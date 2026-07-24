#!/usr/bin/env python3
"""Count XDMA C2H read activity from strace -ff -ttt -yy logs.

Consumed by host_fpga_diff_strace_run.sh, which greps the final summary line:
  c2h_read_totals opened=<n> reads=<n> bytes=<n> last_ts=<epoch|None>

Only read() calls whose fd is decoded by strace -yy as a *c2h* device path
count as DiffTest liveness; unfinished reads are attributed via their
<... read resumed> completion in the same per-pid log file.
"""

import re
import sys

TS = r"(?P<ts>\d+\.\d+)"
OPEN_RE = re.compile(TS + r'\s+openat\([^)]*"[^"]*c2h[^"]*"[^)]*\)\s*=\s*(?P<fd>\d+)<')
READ_RE = re.compile(TS + r"\s+read\(\d+<[^>]*c2h[^>]*>.*\)\s*=\s*(?P<n>-?\d+)")
UNFINISHED_RE = re.compile(TS + r"\s+read\(\d+<[^>]*c2h[^>]*>.*<unfinished")
RESUMED_RE = re.compile(TS + r"\s+<\.\.\. read resumed>.*\)\s*=\s*(?P<n>-?\d+)")


def parse_file(path, totals):
    pending_read = False
    try:
        with open(path, errors="replace") as f:
            for line in f:
                m = OPEN_RE.search(line)
                if m:
                    totals["opened"] += 1
                    continue
                if UNFINISHED_RE.search(line):
                    pending_read = True
                    continue
                m = READ_RE.search(line)
                if not m:
                    m = RESUMED_RE.search(line)
                    if not (m and pending_read):
                        continue
                pending_read = False
                n = int(m.group("n"))
                if n > 0:
                    totals["reads"] += 1
                    totals["bytes"] += n
                    totals["last_ts"] = float(m.group("ts"))
    except OSError:
        pass


def main():
    totals = {"opened": 0, "reads": 0, "bytes": 0, "last_ts": None}
    for path in sys.argv[1:]:
        parse_file(path, totals)
    last_ts = totals["last_ts"]
    print("c2h_read_totals opened={} reads={} bytes={} last_ts={}".format(
        totals["opened"], totals["reads"], totals["bytes"],
        "{:.6f}".format(last_ts) if last_ts is not None else "None"))


if __name__ == "__main__":
    main()
