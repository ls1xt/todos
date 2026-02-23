# Roadmap: todos-general

## Overview

Build the `general` repo — the shared scripts, hooks, and templates that power voice-driven todo capture across business and personal repos. This roadmap follows a TDD approach using bats-core (Bash Automated Testing System) with bats-assert and bats-support. Phase 1 writes the full test suite upfront — all tests fail (red/yellow baseline). Each subsequent phase implements the code that makes those tests go green.

## Phases

- [ ] **Phase 1: Test Suite** - Full bats test suite written upfront, all tests failing (TDD baseline)
- [ ] **Phase 2: Infrastructure** - Templates and git hooks implemented; infrastructure tests go green
- [ ] **Phase 3: Core Scripts** - `add`, `done`, `block`, `drop` implemented; core script tests go green
- [ ] **Phase 4: Discovery Scripts** - `list`, `review`, `session` implemented; all tests green

## Phase Details

### Phase 1: Test Suite
**Goal**: The complete bats test suite exists and every test fails — establishing the TDD baseline
**Depends on**: Nothing (first phase)
**Requirements**: TDD-01, TDD-02, TDD-03, TDD-04
**Success Criteria** (what must be TRUE):
  1. `tests/` directory contains bats files covering all scripts and infrastructure: `add`, `done`, `block`, `drop`, `list`, `review`, `session`, `pre-commit` hook, `todo.md` template
  2. Running `bats tests/` reports every test as failed or skipped — zero passing tests (nothing is implemented yet)
  3. Test cases cover the full workflow: fresh temp git repo setup, each command invocation, git commit verification, and all error cases (zero matches, multiple matches)
  4. bats-assert and bats-support are available (installed or vendored) so `assert_output`, `assert_failure`, etc. work
**Plans**: 3 plans

Plans:
- [ ] 01-01-PLAN.md — Vendor bats-core/assert/support as git submodules; create shared setup helper and ./test runner
- [ ] 01-02-PLAN.md — Write failing bats tests for infrastructure (hooks, templates) and core scripts (add, done, block, drop)
- [ ] 01-03-PLAN.md — Write failing bats tests for discovery scripts (list, review, session)

### Phase 2: Infrastructure
**Goal**: The template and pre-commit hook exist and protect every future commit; infrastructure tests go green
**Depends on**: Phase 1
**Requirements**: INFR-01, INFR-02, INFR-03
**Success Criteria** (what must be TRUE):
  1. `templates/todo.md` exists with all frontmatter placeholders (created, priority, project, keywords, body, transcription)
  2. `hooks/pre-commit` rejects a staged todo file missing required frontmatter fields (`created`, `priority`) with a clear error message to stderr
  3. `hooks/pre-commit` rejects a staged file whose name does not match `YYYY-MM-DD-*.md` with a clear error message to stderr
  4. Valid files pass the pre-commit hook without errors
  5. All bats tests tagged for infrastructure now pass
**Plans**: 1 plan

Plans:
- [ ] 02-01-PLAN.md — Create templates/todo.md skeleton and hooks/pre-commit validator; all 12 infrastructure tests green

### Phase 3: Core Scripts
**Goal**: User can capture a todo by speaking and have it committed in under 3 seconds; core script tests go green
**Depends on**: Phase 2
**Requirements**: SCPT-01, SCPT-02, SCPT-03, SCPT-04, SCPT-05, SCPT-06, SCPT-07
**Success Criteria** (what must be TRUE):
  1. `add "buy milk"` creates `open/YYYY-MM-DD-buy-milk.md`, auto-commits, and prints `created: open/YYYY-MM-DD-buy-milk.md`
  2. `add` accepts `--priority`, `--keywords`, `--project`, `--body`, `--transcription` flags and populates frontmatter accordingly
  3. `add` called without a TTY does not open `$EDITOR` and completes without blocking
  4. `done <pattern>`, `block <pattern>`, `drop <pattern>` each move the matched file to the correct directory and auto-commit with the right message format (`done: <title>`, `block: <title>`, `drop: <title>`)
  5. Running a status script with no matches exits 1 with a stderr message; multiple matches lists all candidates without acting
  6. All bats tests for `add`, `done`, `block`, `drop` now pass
**Plans**: TBD

### Phase 4: Discovery Scripts
**Goal**: User can find, review, and resume work on todos from any terminal; all tests green
**Depends on**: Phase 3
**Requirements**: SCPT-08, SCPT-09, SCPT-10, SCPT-11
**Success Criteria** (what must be TRUE):
  1. `list --project work --status open` prints one line per match in `path  priority  project  [keywords]` format, grep-friendly
  2. `list --keyword meeting --since 7d` narrows results correctly; `list` with no flags defaults to open todos
  3. `review` (and `review --days 14`) shows todos grouped by status with per-status counts for the specified window
  4. `session business` creates or attaches to a tmux session named `todo`, cds into the business repo, and launches `claude`
  5. `bats tests/` reports 100% passing — zero failures
**Plans**: TBD

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Test Suite | 0/TBD | Not started | - |
| 2. Infrastructure | 0/TBD | Not started | - |
| 3. Core Scripts | 0/TBD | Not started | - |
| 4. Discovery Scripts | 0/TBD | Not started | - |
