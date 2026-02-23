---
phase: 04-discovery-scripts
plan: "04-03"
status: complete
completed: 2026-02-23
---

## Summary

Implemented the `session` bash script at the repo root and verified 100% test pass across the full bats suite. The script resolves the repo path from the `business` or `personal` argument (with env var override support), checks if a `todo` tmux session exists, and either attaches to it or creates a new session in the correct repo directory before launching `claude`.

## What Was Built

### Key Files Created

- `session` — executable bash script (32 lines)

### Implementation Notes

- Session name: hardcoded `todo`
- Repo paths: `$HOME/business` and `$HOME/personal` with `TODOS_BUSINESS_REPO` / `TODOS_PERSONAL_REPO` env var overrides
- No-arg guard: prints `usage: session [business|personal]` to stderr and exits 1
- Unknown arg: same usage error, exits 1
- Session check: `tmux has-session -t "$SESSION" 2>/dev/null`
- New session: `tmux new-session -d -s todo -c "$REPO_PATH"` then `tmux send-keys "claude" Enter`, then attaches
- Existing session: `tmux attach-session -t todo`
- Tests inject a mock `tmux` binary via `$PATH` — script correctly calls `new-session` with `todo` and `attach-session` based on mock return value

## Test Results

```
./tests/libs/bats-core/bin/bats tests/session.bats
1..4 — 4 passed, 0 failed
```

Full suite:
```
./tests/libs/bats-core/bin/bats tests/add.bats tests/done.bats tests/block.bats tests/drop.bats tests/hooks.bats tests/templates.bats tests/list.bats tests/review.bats tests/session.bats
1..52 — 52 passed, 0 failed
```

All tests covering SCPT-11 pass. Full bats suite at 100% — Phase 4 success criteria met.

## Self-Check: PASSED
