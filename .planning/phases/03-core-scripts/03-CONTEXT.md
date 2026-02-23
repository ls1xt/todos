# Phase 3: Core Scripts - Context

**Gathered:** 2026-02-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement `add`, `done`, `block`, `drop` bash scripts at the repo root. Scripts must pass the bats tests written in Phase 1. User can capture a todo by speaking and have it committed in under 3 seconds. Discovery scripts (`list`, `review`, `session`) are Phase 4.

</domain>

<decisions>
## Implementation Decisions

All behavior is fully specified by the bats tests in `tests/`. No user discussion needed — decisions below are read directly from the test suite.

### add script
- Title arg → slug: lowercase, spaces-to-hyphens, strip non-alphanumeric (e.g. "buy milk" → `buy-milk`)
- File created at: `open/YYYY-MM-DD-<slug>.md` (date = today)
- Stdout: `created: open/<filename>`
- Git commit message: `add: <original title>`
- Flags populate frontmatter fields: `--priority`, `--keywords`, `--project`, `--body`, `--transcription`
- Without TTY (`< /dev/null`): must complete without opening `$EDITOR` and without blocking

### done / block / drop scripts
- Each takes a single `<pattern>` argument
- Pattern matched against filenames in `open/` (substring match against filename)
- Zero matches: exit 1, stderr message containing "no match"
- Multiple matches: exit 1, list all matching filenames, do not move anything
- Single match: move file to target dir (`done/`, `blocked/`, `dropped/`), auto-commit
- Git commit message: `done: <title>` / `block: <title>` / `drop: <title>` (title = slug from filename)

### Frontmatter format
- All fields present in every file (from template): `created`, `priority`, `project`, `keywords`, `body`, `transcription`
- Default values when flag not passed: empty (bare key with no value, e.g. `project:`)
- When flag passed: `priority: high`, `keywords: foo,bar`, etc.

### Git operations
- Each script commits only the file(s) it creates or moves
- Scripts run `git add <file> && git commit` internally
- No staging of unrelated changes

### Claude's Discretion
- Exact slug sanitization regex (tests only verify lowercase hyphenation for simple titles)
- Handling of very long titles (truncation threshold)
- Whether title in commit message is the raw arg or the slug

</decisions>

<specifics>
## Specific Ideas

- Tests use `$SCRIPTS_DIR` pointing to the repo root — scripts live at repo root with no subdirectory
- Tests set `HOME="$REPO_DIR"` for the `add` test so git commits work in the temp repo
- `done`/`block`/`drop` tests use a `create_open_todo` helper that places files in `open/` with full frontmatter
- Scripts must be executable (`chmod +x`)
- Must work non-interactively (tests run with bats, no TTY)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-core-scripts*
*Context gathered: 2026-02-23*
