---
phase: 02-infrastructure
plan: 01
subsystem: infra
tags: [bash, git-hooks, yaml-frontmatter, bats]

requires:
  - phase: 01-test-suite
    provides: Failing bats tests defining exact contract for templates and hooks

provides:
  - templates/todo.md skeleton with 6 required YAML frontmatter keys
  - hooks/pre-commit executable validating staged todo filename pattern and frontmatter fields

affects: [03-core-scripts, 04-discovery-scripts]

tech-stack:
  added: []
  patterns:
    - Git hook reads staged content via git show :<filepath> (not working tree)
    - Todo file detection by directory membership (open/, done/, blocked/, dropped/)
    - Filename pattern YYYY-MM-DD-<slug>.md enforced at commit time

key-files:
  created:
    - templates/todo.md
    - hooks/pre-commit
  modified: []

key-decisions:
  - "Used directory-based todo detection (open/done/blocked/dropped) rather than pure filename matching — allows non-todo .md files like README.md to be staged without triggering hook"
  - "Hook reads staged content via git show :<filepath> so validation applies to exactly what will be committed, not the working tree version"

patterns-established:
  - "Pre-commit hook pattern: iterate staged files, skip non-todo dirs, validate filename then frontmatter, exit 1 with stderr message on failure"

requirements-completed:
  - INFR-01
  - INFR-02
  - INFR-03

duration: 1min
completed: 2026-02-23
---

# Phase 02 Plan 01: Infrastructure Summary

**templates/todo.md YAML skeleton and hooks/pre-commit bash validator turning 12 failing bats tests green**

## Performance

- **Duration:** ~1 min
- **Started:** 2026-02-23T11:40:50Z
- **Completed:** 2026-02-23T11:41:47Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Created `templates/todo.md` with all 6 required frontmatter keys (created, priority, project, keywords, body, transcription)
- Created `hooks/pre-commit` executable that validates staged todo files: filename must match `YYYY-MM-DD-*.md`, must contain `created:` and `priority:` frontmatter fields
- All 12 bats tests in `tests/hooks.bats` and `tests/templates.bats` now pass (0 failures)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create templates/todo.md skeleton** - `d88b01e` (feat)
2. **Task 2: Create hooks/pre-commit validator** - `3805583` (feat)

## Files Created/Modified
- `templates/todo.md` - YAML frontmatter skeleton with 6 required keys for new todo files
- `hooks/pre-commit` - Executable bash script; validates staged todo files for correct filename format and required frontmatter fields

## Decisions Made
- Used directory-based todo detection: files in `open/`, `done/`, `blocked/`, `dropped/` are treated as todos; files elsewhere (e.g. `README.md` in root) are silently skipped. This is more robust than pure filename pattern matching because it handles the edge case of non-todo markdown files.
- Hook reads staged content via `git show :<filepath>` — validates exactly what will be committed, not the working tree, satisfying the test contract.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Infrastructure complete: todo template and pre-commit hook are in place
- All Phase 2 requirements satisfied: INFR-01 (frontmatter validation), INFR-02 (filename validation), INFR-03 (template skeleton)
- Phase 3 (Core Scripts) can proceed: the hook will validate any todos committed by `add`, `done`, `block`, `drop`

## Self-Check

- [x] `templates/todo.md` exists on disk
- [x] `hooks/pre-commit` exists on disk and is executable
- [x] `git log --oneline --all --grep="02-01"` returns 2 commits
- [x] No `## Self-Check: FAILED` marker

## Self-Check: PASSED

---
*Phase: 02-infrastructure*
*Completed: 2026-02-23*
