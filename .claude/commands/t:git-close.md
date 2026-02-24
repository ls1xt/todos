---
name: t:git-close
description: Scan linked repo commits in parallel and auto-mark matching todos as done
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
  - Task
---

<objective>
Spawn one Bash agent per linked repo in parallel. Each agent checks git log and returns compact CLOSE: results. Aggregate and apply. Keep main context lean.
</objective>

<process>
## Step 1 — Resolve paths

- If `./todos/list` exists → list=`./todos/list`, done=`./todos/done`, role=`./todos/.claude/git-agent-role.md`
- Else → list=`./list`, done=`./done`, role=`./.claude/git-agent-role.md`

Parse `--days N` from `$ARGUMENTS` (default: 7).

## Step 2 — Load open todos (compact)

```bash
<list> --status open
```

Read each file for id, keywords, body. Build compact string (one line per todo):
```
#1 [pipeline,crawler,adapter] Add adapter between pipeline and crawler
#3 [kafka,error-handling] Automate error handling
```

## Step 3 — Find linked repos

```bash
ls linked/
```

If no `linked/` or empty → print `(no linked repos)` and exit.

## Step 4 — Spawn one agent per repo (ALL in parallel — single message)

For each repo in `linked/`, spawn a Task tool call with subagent_type=`Bash`:

```
Read the role file at <role> — it defines your output contract.

REPO_PATH: linked/<repo-name>
DAYS: <N>
TODOS:
<compact todos list>

Return only CLOSE: lines (and REPO: header). No PROPOSE: needed here.
If no commits in this repo, return: REPO: <name> — no commits
```

**Critical**: launch ALL agents in a single response (parallel tool calls), one per repo.

## Step 5 — Aggregate and apply

Collect all agent responses. For each `CLOSE:` line, extract the id:
```bash
<done> <id>
```

Skip on error, note it.

## Step 6 — Report (compact, grouped by repo)

```
t:git-close — last N days

enty (8 commits):     ✓ #3 fix-parser-bug  ✓ #7 implement-login
enty-docs (no commits)
murmur (2 commits):   · no matches

Closed 2 / 9 todos.
```
</process>
