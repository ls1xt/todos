---
phase: 03-core-scripts
plan: "03-02"
status: complete
completed: 2026-02-23
---

## Summary

Implemented `done`, `block`, and `drop` bash scripts at the repo root. All three share identical pattern-matching logic — they search `open/` for files whose filename contains the pattern as a substring, handle zero-match and multiple-match error cases, and for a single match use `git mv` to atomically move the file and commit with the correct message prefix.

## What Was Built

### Key Files Created

- `done` — executable bash script (moves file to `done/`, commits `done: <title>`)
- `block` — executable bash script (moves file to `blocked/`, commits `block: <title>`)
- `drop` — executable bash script (moves file to `dropped/`, commits `drop: <title>`)

### Implementation Notes

- Pattern matching: `for f in open/*"${PATTERN}"*` loop with `-f` guard handles glob expansion safely
- Title derivation: `basename | sed 's/\.md$//' | sed 's/^YYYY-MM-DD-//'` strips date prefix and extension
- `git mv` used instead of plain `mv` — atomically stages removal and addition in one command
- Zero matches: `echo "no match: $PATTERN" >&2; exit 1`
- Multiple matches: lists all basenames to stderr, exits 1, moves nothing
- `set -e` ensures git failures propagate

## Test Results

```
./tests/libs/bats-core/bin/bats tests/done.bats tests/block.bats tests/drop.bats
1..12 — 12 passed, 0 failed
```

All tests covering SCPT-04, SCPT-05, SCPT-06, SCPT-07 pass.

## Self-Check: PASSED
