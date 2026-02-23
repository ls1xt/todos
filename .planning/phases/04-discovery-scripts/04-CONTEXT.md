# Phase 4: Discovery Scripts - Context

**Gathered:** 2026-02-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement three scripts — `list`, `review`, `session` — so users can find, review, and resume work on todos from any terminal. All bats tests must pass (100% green).

Scope is strictly these three scripts. Business/personal repo setup, integration with Murmur/hotkeys, and scheduling/digest features are out of scope.

</domain>

<decisions>
## Implementation Decisions

### `list` — output format and filtering
- Output: one line per file, format `path  priority  project  [keywords]` — tab or double-space separated, grep-friendly (SCPT-09)
- Default: show `open/` todos when no `--status` given (confirmed by test "list with no flags prints open todos one per line")
- `--status <dir>` narrows to that status directory (open, done, blocked, dropped)
- `--project <name>` filters on frontmatter `project:` field (exact match)
- `--keyword <word>` filters on frontmatter `keywords:` field (substring match)
- `--since Nd` filters by frontmatter `created:` date field (NOT filename date, NOT file mtime — tests create_old_todo sets `created: 2020-01-01` while filename has today's date)
- Empty result: exit 0, empty stdout (no error message)
- Nonexistent project filter: exit 0, empty stdout

### `review` — grouping and output
- Default window: last 7 days (filter by frontmatter `created:` date)
- `--days N` overrides the window
- `--days 0`: exit 0, empty output or headers only (tests accept either)
- Group todos by status directory (open/, done/, blocked/, dropped/)
- Show per-status counts inline with section header (e.g., `open (2)` or `2 open`)
- Human-readable output: section headers for each status, filenames listed under each
- Both `open` and `done` labels must appear in output when files in both statuses exist

### `session` — tmux and repo paths
- Accepts `business` or `personal` as positional argument (no arg = error/usage, non-zero exit OR print usage)
- Always uses tmux session name: `todo`
- If session not running (`tmux has-session` fails): call `tmux new-session` with `-s todo`
- If session running (`tmux has-session` succeeds): call `tmux attach-session`
- New session must `cd` into the correct repo before launching `claude`
- Repo path resolution: use `$HOME/business` and `$HOME/personal` conventions — simple, consistent with "files over databases" philosophy; planner may use env vars (`$TODOS_BUSINESS_REPO`, `$TODOS_PERSONAL_REPO`) as override mechanism if that's cleaner

### Claude's Discretion
- Exact column separator for `list` output (tab vs double-space — tests only use `--partial`)
- `review` section header formatting (e.g., `open (2):` vs `=== open (2) ===` vs `## open`)
- Exact tmux `new-session` flags (e.g., `-d` to detach, `-c` for start-directory, `-e` for shell command)
- How `session` launches `claude` — `send-keys` vs shell `-e` arg vs `default-command`
- How `--since` parses the `Nd` format (strip trailing 'd', compute date N days ago)

</decisions>

<specifics>
## Specific Ideas

- The PLAN.md workflow shows `todos/list --keyword siglip` used by Claude to find a file before `todos/done` — so `list` doubles as a search tool for Claude's own internal use, not just human browsing. Output should be easy for Claude to parse (one file per line, predictable columns).
- The voice capture workflow targets `tmux session todo:0.0` — `session` script creates exactly this setup.
- Business repo likely at `~/business`, personal at `~/personal` (inferred from PLAN.md project naming: enty, murmur = business; personal = personal).

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-discovery-scripts*
*Context gathered: 2026-02-23*
