# todos-general — Development Instructions

This is the `general` repo: shared scripts, hooks, and templates for the voice-driven todo system. It is included as a git submodule at `todos/` in the `business` and `personal` repos.

## ⚠️ WARNING: Do NOT run `./test` directly

`./test` runs the full bats suite (52+ tests) and produces massive output that will flood your context window.

**Instead, run individual test files:**

```bash
# Run tests for a single script
./tests/libs/bats-core/bin/bats tests/add.bats
./tests/libs/bats-core/bin/bats tests/done.bats
./tests/libs/bats-core/bin/bats tests/hooks.bats

# Run a single test by name
./tests/libs/bats-core/bin/bats tests/add.bats --filter "creates file in open/"

# Run tests for one phase's scripts only (e.g. Phase 2 — infra)
./tests/libs/bats-core/bin/bats tests/hooks.bats tests/templates.bats
```

**If you need the full suite result:** run `./test 2>&1 | tail -20` to see just the summary line.

## Repo Structure

```
add, done, block, drop, list, review, session  — scripts at repo root
hooks/pre-commit                               — git hook
templates/todo.md                              — todo skeleton
tests/                                         — bats test suite
tests/libs/                                    — vendored bats-core, bats-assert, bats-support
tests/helpers/setup.bash                       — shared test setup/teardown helpers
.planning/                                     — GSD planning artifacts
```

## Scripts

Scripts live at the repo root (no `scripts/` subdirectory). When used as a submodule, commands read as `todos/add`, `todos/done`, etc.

Each script must:
- Be executable (`chmod +x`)
- Work without a TTY (Claude calls them non-interactively)
- Output to stdout, errors to stderr with `exit 1`
- Handle git internally (no manual git commands needed by caller)
