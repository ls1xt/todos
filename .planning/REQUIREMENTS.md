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

- [ ] **TEST-01**: Integration test creates a fresh temp git repo and runs full workflow end-to-end
- [ ] **TEST-02**: Test covers: `add`, `done`, `block`, `drop`, `list` (with filter combinations), `review`
- [ ] **TEST-03**: Test verifies git commits were created for each operation (correct message format, correct files)
- [ ] **TEST-04**: Test verifies error cases: zero matches returns exit 1, multiple matches lists candidates

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
| SCPT-01 | — | Pending |
| SCPT-02 | — | Pending |
| SCPT-03 | — | Pending |
| SCPT-04 | — | Pending |
| SCPT-05 | — | Pending |
| SCPT-06 | — | Pending |
| SCPT-07 | — | Pending |
| SCPT-08 | — | Pending |
| SCPT-09 | — | Pending |
| SCPT-10 | — | Pending |
| SCPT-11 | — | Pending |
| INFR-01 | — | Pending |
| INFR-02 | — | Pending |
| INFR-03 | — | Pending |
| TEST-01 | — | Pending |
| TEST-02 | — | Pending |
| TEST-03 | — | Pending |
| TEST-04 | — | Pending |

**Coverage:**
- v1 requirements: 18 total
- Mapped to phases: 0 (pre-roadmap)
- Unmapped: 18 ⚠️

---
*Requirements defined: 2026-02-23*
*Last updated: 2026-02-23 after initial definition*
