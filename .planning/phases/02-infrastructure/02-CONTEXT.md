# Phase 2: Infrastructure - Context

**Gathered:** 2026-02-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Create `templates/todo.md` and `hooks/pre-commit` — the two infrastructure files that protect every future commit. Nothing else. The tests for these already exist in `tests/hooks.bats` and `tests/templates.bats` from Phase 1 and define the exact contract.

</domain>

<decisions>
## Implementation Decisions

### templates/todo.md
- Location: `templates/todo.md` at repo root
- Must be a YAML frontmatter skeleton with all six fields present: `created:`, `priority:`, `project:`, `keywords:`, `body:`, `transcription:`
- Values can be empty (e.g. `project:` with no value) — tests only check that the key exists via grep
- Based on the valid todo in hooks.bats tests, `created:` takes a date value and `priority:` takes a word like `normal`/`high`/`low`

### hooks/pre-commit
- Location: `hooks/pre-commit` at repo root, must be executable
- Invoked directly as a script (not via git's hook mechanism in tests — run as `GIT_DIR="$REPO_DIR/.git" ./hooks/pre-commit`)
- Reads staged files using git plumbing (`git diff --cached --name-only` or equivalent)
- Only validates files matching `YYYY-MM-DD-*.md` filename pattern — ignores all other staged files (e.g. README.md)
- For each matching staged file, checks:
  1. Filename matches `YYYY-MM-DD-*.md` — if not, print "YYYY-MM-DD" to stderr, exit 1
  2. Staged content contains `created:` — if not, print "created" to stderr, exit 1
  3. Staged content contains `priority:` — if not, print "priority" to stderr, exit 1
- Valid files: exit 0 silently
- Non-todo staged files: pass through silently (exit 0)

### Hook reads staged content (not working tree)
- Must use `git show :path` or `git diff --cached` to read staged version of files
- Tests stage the file with `git add` before running the hook

### Claude's Discretion
- Exact wording of error messages (tests only check `--partial "created"`, `--partial "priority"`, `--partial "YYYY-MM-DD"`)
- Whether to loop over all failing files or exit on first failure
- Shebang (`#!/bin/bash` or `#!/bin/sh`)
- Whether to read staged content via `git show :filename` or `git diff --cached -p`

</decisions>

<specifics>
## Specific Ideas

- The valid todo template from hooks.bats shows the canonical format:
  ```
  ---
  created: 2026-01-01
  priority: normal
  project:
  keywords:
  body:
  transcription:
  ---
  ```
- Hook is tested by running directly with `GIT_DIR` set — no need to install it as a git hook during tests
- The `open/` subdirectory is created by `setup_repo` in `tests/helpers/setup.bash` — the hook must work with files in subdirectories

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-infrastructure*
*Context gathered: 2026-02-23*
