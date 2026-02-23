---
phase: 01-test-suite
plan: 03
subsystem: testing
tags: [bats, tdd, list, review, session, tmux, bash]

requires:
  - phase: 01-01
    provides: "bats-core, bats-assert, bats-support submodules and shared setup helper"
provides:
  - "tests/list.bats: 10 failing tests for list script (filter flags, output format, empty cases)"
  - "tests/review.bats: 5 failing tests for review script (default 7d, --days N, grouped output)"
  - "tests/session.bats: 4 tests for session script (tmux mock strategy)"
  - "TDD red baseline for discovery scripts: Phase 4 implementation contract defined"
affects: [04-discovery-scripts]

tech-stack:
  added: []
  patterns:
    - "Tmux mock via fake binary in $REPO_DIR/bin injected before real tmux in PATH"
    - "create_todo() helper with inline frontmatter for list/review filter tests"

key-files:
  created:
    - tests/list.bats
    - tests/review.bats
    - tests/session.bats
  modified: []

key-decisions:
  - "Used Option A (mock tmux) for session tests — fake tmux at $REPO_DIR/bin/tmux records invocations to tmux-calls.log"
  - "session with-no-arg test uses flexible assertion: non-zero exit OR usage output — accommodates implementation choice"
  - "list --since tests use 'created' frontmatter field for date filtering (not filesystem mtime)"

patterns-established:
  - "Pattern 1: Tmux mock via PATH-injected fake binary records calls to log file for assertion"
  - "Pattern 2: create_todo() helper creates frontmatter-complete files for filter tests"
  - "Pattern 3: Old todo uses 'created: 2020-01-01' to test --since filtering"

requirements-completed: [TDD-04]

duration: 1min
completed: 2026-02-23
---

# Phase 01 Plan 03: Discovery Script Test Suite Summary

**19 bats tests across 3 files defining the behavioral contract for list (10 tests), review (5 tests), and session (4 tests) discovery scripts — 18 failing, establishing TDD red baseline for Phase 4**

## Performance

- **Duration:** 1 min
- **Started:** 2026-02-23T11:20:20Z
- **Completed:** 2026-02-23T11:21:33Z
- **Tasks:** 3 test files written
- **Files modified:** 3

## Accomplishments
- tests/list.bats: 10 tests covering all filter flags (--project, --keyword, --since, --status), output format, and empty cases
- tests/review.bats: 5 tests covering default 7-day window, --days N, grouped output with status sections and counts
- tests/session.bats: 4 tests using tmux mock strategy (Option A) — fake tmux binary records invocations to log file
- Full suite: 52 total tests, 51 failing, 1 passing (acceptable — see below)

## Task Commits

1. **All 3 discovery test files** - `9ffe6eb` (test(01-03))

## Files Created/Modified
- `tests/list.bats` - 10 list script test cases with create_todo() helper
- `tests/review.bats` - 5 review script test cases
- `tests/session.bats` - 4 session script test cases with tmux mock

## Decisions Made
- Chose Option A (mock tmux) over Option B (skip integration tests) for richer test coverage
- "session with no arg" test uses `[ "$status" -ne 0 ] || assert_output --partial "usage"` — flexible contract that accommodates the implementation's choice of behavior
- list tests separate "no files" (empty repo) from "project nonexistent" (files exist, none match) cases

## Deviations from Plan

None — plan executed exactly as written. The tmux mock approach (Option A) was explicitly specified in the plan.

## Issues Encountered

**1 test passes in the current red state:** "session with no arg prints usage or exits with error" passes because `$SCRIPTS_DIR/session` doesn't exist — bats returns exit 127, which satisfies `[ "$status" -ne 0 ]`. This is intentional: the test documents that no-arg should fail, and "command not found" is a failing exit code. When the script is implemented, either an error exit or "usage" output will satisfy the assertion.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All 9 bats files written — complete test suite for all scripts across the project
- Full suite: 51/52 tests failing (correct TDD red baseline)
- Phase 2 (infrastructure) can begin implementing templates and hooks
- Phase 4 (discovery) has its contract fully defined in list/review/session tests

---
*Phase: 01-test-suite*
*Completed: 2026-02-23*
