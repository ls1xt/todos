# Requirements: todos-general

**Defined:** 2026-02-23
**Core Value:** Voice capture to committed file in under 3 seconds, reliably, with no required interaction beyond speaking.

## v1 Requirements

Requirements for the general repo — scripts, hooks, templates, and tests.

### Scripts

- [ ] **SCPT-01**: User can create a todo with `add <title>` — auto-commits and prints `created: open/YYYY-MM-DD-<slug>.md`
- [ ] **SCPT-02**: `add` accepts `--priority`, `--keywords`, `--project`, `--body`, `--transcription` flags
- [ ] **SCPT-03**: `add` skips opening `$EDITOR` when not in a terminal (non-interactive safe for Claude)
- [ ] **SCPT-04**: `done <pattern>` finds file in `open/`, moves to `done/`, auto-commits with `done: <title>`
- [ ] **SCPT-05**: `block <pattern>` finds file in `open/`, moves to `blocked/`, auto-commits with `block: <title>`
- [ ] **SCPT-06**: `drop <pattern>` finds file in `open/`, moves to `dropped/`, auto-commits with `drop: <title>`
- [ ] **SCPT-07**: Status scripts error clearly on zero matches (stderr + exit 1); list all candidates on multiple matches
- [ ] **SCPT-08**: `list` filters todos by `--project`, `--keyword`, `--since <Nd>`, `--status` (default: open)
- [ ] **SCPT-09**: `list` output is structured one-per-line and grep-friendly: `path  priority  project  [keywords]`
- [ ] **SCPT-10**: `review [--days N]` shows todos from last N days (default 7) grouped by status with counts
- [ ] **SCPT-11**: `session [business|personal]` creates or attaches to tmux session `todo`, cds into correct repo, launches `claude`

### Infrastructure

- [ ] **INFR-01**: `hooks/pre-commit` validates YAML frontmatter has required fields (`created`, `priority`)
- [ ] **INFR-02**: `hooks/pre-commit` validates staged todo files match `YYYY-MM-DD-*.md` filename pattern
- [ ] **INFR-03**: `templates/todo.md` provides skeleton with all frontmatter placeholders filled

### Testing

- [ ] **TDD-01**: bats-core test suite is set up with bats-assert and bats-support available (installed or vendored in `tests/`)
- [ ] **TDD-02**: bats test cases written for infrastructure: pre-commit hook validation (valid files, missing frontmatter, bad filename) and template structure
- [ ] **TDD-03**: bats test cases written for core scripts: `add` (all flags, non-interactive), `done`/`block`/`drop` (move + commit), error cases (zero matches, multiple matches)
- [ ] **TDD-04**: bats test cases written for discovery scripts: `list` (all filter combinations), `review` (default and --days), `session` (tmux attach/create)

## v2 Requirements

Deferred to next milestone.

### Repo Setup

- **REPO-01**: Business repo initialized with `open/`, `done/`, `blocked/`, `dropped/` directories
- **REPO-02**: Business repo adds `general` as git submodule at `todos/`
- **REPO-03**: Business repo configures `core.hooksPath = todos/hooks`
- **REPO-04**: Business repo has CLAUDE.md with projects, vocabulary, and capture rules
- **REPO-05**: Personal repo mirrors business repo structure with personal projects/vocabulary

### Integration

- **INTG-01**: Murmur hotkey (Ctrl+Cmd+T) injects to tmux session `todo:0.0` where Claude is running
- **INTG-02**: End-to-end test: speak a todo, verify file and commit appear

## Out of Scope

| Feature | Reason |
|---------|--------|
| GUI or web interface | File system IS the interface; grep is the query engine |
| Database | Files + grep is simpler and more durable |
| Moving todos between repos | Open question; deferred |
| Review summary reports (weekly .md file) | Open question; deferred |
| GitHub Actions / email digest | Open question; deferred |
| Claude Code skills/slash commands | CLAUDE.md + scripts is simpler for voice flow |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| TDD-01 | Phase 1 | Pending |
| TDD-02 | Phase 1 | Pending |
| TDD-03 | Phase 1 | Pending |
| TDD-04 | Phase 1 | Pending |
| INFR-01 | Phase 2 | Pending |
| INFR-02 | Phase 2 | Pending |
| INFR-03 | Phase 2 | Pending |
| SCPT-01 | Phase 3 | Pending |
| SCPT-02 | Phase 3 | Pending |
| SCPT-03 | Phase 3 | Pending |
| SCPT-04 | Phase 3 | Pending |
| SCPT-05 | Phase 3 | Pending |
| SCPT-06 | Phase 3 | Pending |
| SCPT-07 | Phase 3 | Pending |
| SCPT-08 | Phase 4 | Pending |
| SCPT-09 | Phase 4 | Pending |
| SCPT-10 | Phase 4 | Pending |
| SCPT-11 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0

---
*Requirements defined: 2026-02-23*
*Last updated: 2026-02-23 after TDD restructure*
