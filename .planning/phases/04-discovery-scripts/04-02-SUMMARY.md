---
phase: 04-discovery-scripts
plan: "04-02"
status: complete
completed: 2026-02-23
---

## Summary

Implemented the `review` bash script at the repo root. The script accepts `--days N` (default 7), computes a cutoff date, scans all four status directories (open, done, blocked, dropped), collects matching files per directory using string-comparison on `created:` frontmatter dates, and prints section headers with per-status counts followed by filenames.

## What Was Built

### Key Files Created

- `review` — executable bash script (36 lines)

### Implementation Notes

- `--days 0` edge case: exits 0 immediately with empty output (simpler than computing a same-day cutoff)
- Cutoff computation uses `date -d "${DAYS} days ago"` (GNU) with BSD fallback
- File inclusion condition: `[[ "$CREATED" > "$CUTOFF" || "$CREATED" == "$CUTOFF" ]]` — string comparison is valid for YYYY-MM-DD dates
- Section header format: `${STATUS} (${COUNT})` — e.g., `open (2)`, `done (1)`
- Filenames listed under each header with 2-space indent
- Directories that don't exist are silently skipped

## Test Results

```
./tests/libs/bats-core/bin/bats tests/review.bats
1..5 — 5 passed, 0 failed
```

All tests covering SCPT-10 pass.

## Self-Check: PASSED
