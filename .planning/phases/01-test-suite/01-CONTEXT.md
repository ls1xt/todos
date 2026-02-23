# Phase 1: Test Suite - Context

**Gathered:** 2026-02-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Write the complete bats test suite upfront — all tests fail (red baseline). No scripts are implemented yet. The suite covers every script and hook that will be built in Phases 2-4: `add`, `done`, `block`, `drop`, `list`, `review`, `session`, and `hooks/pre-commit`. This is a TDD phase: write tests first, implement later.

</domain>

<decisions>
## Implementation Decisions

### bats installation
- Vendored as git submodules under `tests/libs/` — no system install required
- Three libs: `bats-core`, `bats-assert`, `bats-support`
- Run with: `./tests/libs/bats-core/bin/bats tests/`
- Add a `test` script at repo root for convenience: `./test` runs the full suite

### Test isolation
- Each test runs in a fresh temp git repo (created in `setup()`, destroyed in `teardown()`)
- `setup()` creates a temp dir, runs `git init`, configures minimal git user
- Scripts under test are invoked via absolute path to the repo root (e.g., `$BATS_TEST_DIRNAME/../add`)
- No shared state between tests — every test is independent

### Test file structure
- One `.bats` file per script: `tests/add.bats`, `tests/done.bats`, `tests/block.bats`, `tests/drop.bats`, `tests/list.bats`, `tests/review.bats`, `tests/session.bats`
- Infrastructure tests in `tests/hooks.bats` (pre-commit) and `tests/templates.bats`
- Shared setup helpers in `tests/helpers/setup.bash` (sourced by each test file)

### Failing test strategy
- Tests naturally fail because scripts don't exist yet — no `skip` markers needed
- A test like `run ./add "buy milk"` fails with "command not found" or "permission denied" — that's the red state
- No artificial skipping — the failure IS the signal

### Test coverage targets
- `add.bats`: happy path, all flags, non-TTY behavior
- `done/block/drop.bats`: successful move, zero-match error, multiple-match error, commit message format
- `list.bats`: all filter flags, default behavior, output format
- `review.bats`: default 7 days, `--days N`, grouped output with counts
- `session.bats`: tmux session creation (may need to mock tmux)
- `hooks.bats`: valid file passes, missing frontmatter fails, bad filename fails
- `templates.bats`: `templates/todo.md` exists with correct placeholders

### Claude's Discretion
- Exact `setup.bash` helper implementation
- Whether to mock tmux in `session.bats` or mark as integration-only
- Order of tests within each file

</decisions>

<specifics>
## Specific Ideas

- The user explicitly wants a TDD red-to-green experience: tests written first, implementation turns them green phase by phase
- Running `./tests/libs/bats-core/bin/bats tests/` after Phase 1 should show a wall of red — that's the goal
- bats output format naturally shows ✓/✗ per test — satisfies the "green/yellow/red dashboard" vision

</specifics>

<deferred>
## Deferred Ideas

- None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-test-suite*
*Context gathered: 2026-02-23*
