---
phase: 04-discovery-scripts
plan: "04-01"
status: complete
completed: 2026-02-23
---

## Summary

Implemented the `list` bash script at the repo root. The script accepts four optional flags, scans the target status directory for `.md` files, extracts five frontmatter fields per file using `grep`, applies filter logic, and prints matching files one per line in `path  priority  project  keywords` format.

## What Was Built

### Key Files Created

- `list` — executable bash script (52 lines)

### Implementation Notes

- Default status: `open` (when `--status` not passed)
- `--status VALUE`: scans `VALUE/` directory instead of `open/`
- `--project VALUE`: exact match against `project:` frontmatter field
- `--keyword VALUE`: substring match against `keywords:` frontmatter field using `[[ "$KEYWORDS_VAL" == *"$KEYWORD"* ]]`
- `--since Nd`: strips trailing `d`, computes cutoff with `date -d "${DAYS} days ago"` (GNU) falling back to `date -v-${DAYS}d` (BSD); skips files where `created:` < cutoff via string comparison (YYYY-MM-DD is lexicographically sortable)
- Empty result: exits 0 with empty stdout — no error message
- Nonexistent directory: `[[ -d "$STATUS_DIR" ]] || exit 0` guard

## Test Results

```
./tests/libs/bats-core/bin/bats tests/list.bats
1..10 — 10 passed, 0 failed
```

All tests covering SCPT-08 and SCPT-09 pass.

## Self-Check: PASSED
