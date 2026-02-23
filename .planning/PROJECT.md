# todos-general

## What This Is

A voice-driven todo capture system built around shell scripts, git, and markdown files. The user presses a hotkey, speaks a thought, and a structured todo file is created and committed — no GUI, no database, no friction. This repo (`general`) provides the scripts, hooks, and templates used as a git submodule in separate `business` and `personal` todo repos.

## Core Value

Voice capture to committed file in under 3 seconds, reliably, with no required interaction beyond speaking.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] `add` script creates a todo file from title + flags and auto-commits
- [ ] `done`, `block`, `drop` scripts move files between status directories and auto-commit
- [ ] `list` script searches todos by project, keyword, date, or status
- [ ] `review` script shows a weekly summary grouped by status
- [ ] `session` script launches Claude Code in a named tmux session pointed at the right repo
- [ ] `hooks/pre-commit` validates frontmatter and filename format
- [ ] `templates/todo.md` provides the skeleton frontmatter
- [ ] CLAUDE.md for this repo covers development instructions
- [ ] Scripts handle edge cases cleanly: zero matches, multiple matches, non-terminal detection

### Out of Scope

- GUI or web interface — file system IS the interface
- Database — grep is the query engine
- GitHub Actions / email digests — deferred, open question
- Moving todos between business/personal repos — deferred, open question
- Claude Code skills/slash commands — CLAUDE.md + scripts approach is simpler

## Context

- Three-repo design: `general` (this repo, scripts/hooks/templates), `business`, `personal`
- Business and personal repos include `general` as a git submodule at `todos/`
- Scripts live at repo root (no `scripts/` subdirectory) so commands read as `todos/add`, `todos/done`
- Voice flow: Murmur (AssemblyAI STT) → tmux session `todo:0.0` → Claude Code → script → file
- Claude corrects transcription errors using a vocabulary mapping in the target repo's CLAUDE.md
- Raw transcription preserved in `--transcription` frontmatter field for correction later
- Todo files: `YYYY-MM-DD-<slug>.md` in `open/`, `done/`, `blocked/`, `dropped/` directories
- Priority concern: script reliability and clean error handling on edge cases

## Constraints

- **Tech stack**: Bash shell scripts — portable, no dependencies, easy to audit
- **Git**: Every status change must be a commit; scripts handle git internally, no manual git
- **Non-interactive**: Scripts must work without a TTY (Claude calls them non-interactively); detect via stdin/isatty
- **Output format**: Structured stdout for Claude parsing; errors to stderr with exit 1

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Files over database | Grep is the query engine; markdown survives any tooling change | — Pending |
| Status via directories | Moving a file changes status; no metadata to sync | — Pending |
| CLAUDE.md over skills | Voice flow uses free-form text; skills require explicit invocation | — Pending |
| Repo-per-context | Business and personal kept separate; no cross-contamination of Claude context | — Pending |

---
*Last updated: 2026-02-23 after initialization*
