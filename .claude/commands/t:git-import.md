---
name: t:git-import
description: Scan linked repo commits in parallel and propose new follow-up todos in batch
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
  - Task
---

<objective>
Spawn one Bash agent per linked repo in parallel. Each agent identifies commits suggesting missing todos and returns compact PROPOSE: results. Aggregate, present batch, create confirmed ones. Keep main context lean.
</objective>

<process>
## Step 1 — Resolve paths

- If `./todos/list` exists → list=`./todos/list`, add=`./todos/add`, role=`./todos/.claude/git-agent-role.md`
- Else strip `todos/` prefix

Parse `--days N` from `$ARGUMENTS` (default: 7).

## Step 2 — Load open todos (compact, to avoid duplicates)

```bash
<list> --status open
```

Build compact list: `#id [keywords] title`

## Step 3 — Find linked repos

```bash
ls linked/
```

## Step 4 — Spawn one agent per repo (ALL in parallel — single message)

For each repo in `linked/`, spawn a Task tool call with subagent_type=`Bash`:

```
Read the role file at <role> — it defines your output contract.

REPO_PATH: linked/<repo-name>
DAYS: <N>
TODOS:
<compact todos list>

Return only PROPOSE: lines (and REPO: header). No CLOSE: needed here.
If no commits: REPO: <name> — no commits
```

**Critical**: launch ALL agents in a single response (parallel tool calls).

## Step 5 — Aggregate proposals

Collect all `PROPOSE:` lines. Parse: title, priority, project, keywords, source hash.
Deduplicate (same concept from multiple repos = one proposal, note both sources).
Cap at 10 proposals — quality over quantity.

## Step 6 — Present batch

```
t:git-import — N proposals from last D days

  1. [enty] medium   Write integration tests for login endpoint
             ← def5678 feat: implement login endpoint with JWT
  2. [enty] low      Document crawler adapter API
             ← abc1234 add: adapter between pipeline and crawler
  3. [murmur] low    Clean up TODO in tmux injector
             ← ghi9012 fix: edge case in injector

Add which? ("all", "1 3", "skip") →
```

## Step 7 — Create confirmed todos

For each confirmed:
```bash
<add> "<title>" --priority <p> --project <project> --keywords <kw1,kw2,kw3> --body "<1-2 sentence expansion>"
```

## Step 8 — Report

```
t:git-import: added 2 (#23 #24), skipped 1.
```
</process>
