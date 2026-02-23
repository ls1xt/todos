---
phase: 01-test-suite
plan: 02
subsystem: testing
tags: [bats, tdd, pre-commit, hooks, templates, add, done, block, drop, bash]

requires:
  - phase: 01-01
    provides: "bats-core, bats-assert, bats-support submodules and shared setup helper"
provides:
  - "tests/hooks.bats: 5 failing tests for pre-commit hook validation"
  - "tests/templates.bats: 7 failing tests for templates/todo.md frontmatter"
  - "tests/add.bats: 9 failing tests for add script (happy path, flags, non-TTY)"
  - "tests/done.bats: 4 failing tests for done script (move, commit, error cases)"
  - "tests/block.bats: 4 failing tests for block script (move, commit, error cases)"
  - "tests/drop.bats: 4 failing tests for drop script (move, commit, error cases)"
  - "TDD red baseline: 33 failing tests, 0 passing — contract for Phases 2 and 3"
affects: [02-infrastructure, 03-core-scripts]

tech-stack:
  added: []
  patterns:
    - "TDD red-first: write failing tests before implementation"
    - "Temp git repo isolation via setup_repo()/teardown_repo() in every test"
    - "Scripts invoked via $SCRIPTS_DIR/<name> — no PATH pollution"

key-files:
  created:
    - tests/hooks.bats
    - tests/templates.bats
    - tests/add.bats
    - tests/done.bats
    - tests/block.bats
    - tests/drop.bats
  modified:
    - tests/helpers/setup.bash (fixed load paths)

key-decisions:
  - "Fixed setup.bash load paths: use $BATS_TEST_DIRNAME/libs/... not $(dirname $BATS_TEST_DIRNAME)/libs/... — libs live inside tests/, not at repo root"
  - "Tests use assert_failure for zero-match and multi-match cases (exits 1 with error message)"
  - "Non-TTY test uses < /dev/null as stdin to simulate non-interactive mode"

patterns-established:
  - "Pattern 1: All test files use load helpers/setup at top"
  - "Pattern 2: setup()/teardown() call setup_repo()/teardown_repo()"
  - "Pattern 3: create_open_todo() helper in done/block/drop tests for committed file setup"

requirements-completed: [TDD-02, TDD-03]

duration: 1min
completed: 2026-02-23
---

# Phase 01 Plan 02: Infrastructure and Core Script Test Suite Summary

**33 failing bats tests across 6 files defining the complete behavioral contract for pre-commit hook, todo template, and core status-change scripts (add, done, block, drop)**

## Performance

- **Duration:** 1 min
- **Started:** 2026-02-23T11:18:07Z
- **Completed:** 2026-02-23T11:19:44Z
- **Tasks:** 6 test files written
- **Files modified:** 7

## Accomplishments
- 6 bats test files written with 33 tests total — all failing (correct TDD red state)
- hooks.bats covers valid/invalid files, missing frontmatter, bad filename, non-todo files
- templates.bats covers all 6 required frontmatter placeholders
- add.bats covers happy path, all 5 flags, non-TTY mode (9 tests)
- done/block/drop.bats each cover successful move, auto-commit, zero-match and multi-match errors

## Task Commits

1. **All 6 test files + setup.bash fix** - `97c1e46` (test(01-02))

## Files Created/Modified
- `tests/hooks.bats` - 5 pre-commit hook test cases
- `tests/templates.bats` - 7 template frontmatter test cases
- `tests/add.bats` - 9 add script test cases
- `tests/done.bats` - 4 done script test cases
- `tests/block.bats` - 4 block script test cases
- `tests/drop.bats` - 4 drop script test cases
- `tests/helpers/setup.bash` - fixed load paths (deviation, documented below)

## Decisions Made
- Tests use `assert_failure` for both zero-match and multi-match error cases (scripts must exit 1 in both)
- `< /dev/null` passed to add for non-TTY test (stdin closed = no TTY = no $EDITOR opened)
- `create_open_todo()` helper committed each todo before calling done/block/drop (required for realistic state)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed setup.bash load paths**
- **Found during:** First test run
- **Issue:** `load "$(dirname "$BATS_TEST_DIRNAME")/libs/bats-support/load"` resolved incorrectly — bats libs live inside `tests/` (same dir as .bats files), not at repo root
- **Fix:** Changed to `load "$BATS_TEST_DIRNAME/libs/bats-support/load"` and same for bats-assert
- **Files modified:** tests/helpers/setup.bash
- **Verification:** All tests load correctly (previously load error on line 2, now all tests reach execution)
- **Committed in:** 97c1e46

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Essential fix — without it, no test files could load at all. No scope creep.

## Issues Encountered

None beyond the path fix above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 33 failing tests define complete contract for Phases 2 (infrastructure) and 3 (core scripts)
- Plan 01-03 (discovery scripts) can proceed in parallel
- Zero passing tests confirmed — correct TDD red state

---
*Phase: 01-test-suite*
*Completed: 2026-02-23*
