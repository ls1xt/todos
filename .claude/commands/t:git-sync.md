---
name: t:git-sync
description: Full bidirectional git sync — one agent per linked repo in parallel, close + propose
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
  - Task
---

<objective>
Spawn one Bash agent per linked repo in parallel. Each agent returns both CLOSE: and PROPOSE: results in a single git log pass. Aggregate: apply closes first, then present import proposals. Minimal context overhead — the heavy work happens in subagents.
</objective>

<process>
## Step 1 — Resolve paths

- If `./todos/list` exists → list=`./todos/list`, done=`./todos/done`, add=`./todos/add`, role=`./todos/.claude/git-agent-role.md`
- Else strip `todos/` prefix

Parse `--days N` from `$ARGUMENTS` (default: 7).

## Step 2 — Load open todos (compact)

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

Return CLOSE: and PROPOSE: lines per the role file contract.
If no commits: single line REPO: <name> — no commits
```

**Critical**: launch ALL agents in a **single message** (parallel tool calls), one per repo.

## Step 5 — Apply closes immediately

Parse all `CLOSE:` lines from all agents. For each:
```bash
<done> <id>
```

## Step 6 — Present combined report + proposals

```
t:git-sync — last N days, X repos

── Closed ──────────────────────────────────────────────
enty (8 commits):      ✓ #3 fix-parser-bug  ✓ #7 implement-login
enty-docs (no commits)
murmur (2 commits):    · no matches

── Proposed ────────────────────────────────────────────
  1. [enty] medium   Write tests for login endpoint     ← def5678
  2. [enty] low      Document crawler adapter API        ← abc1234
  3. [murmur] low    Clean up TODO in tmux injector      ← ghi9012

Add which? ("all", "1 3", "skip") →
```

## Step 7 — Create confirmed todos

For each confirmed proposal:
```bash
<add> "<title>" --priority <p> --project <project> --keywords <kw1,kw2,kw3> --body "<description>"
```

## Step 8 — Final summary (one line)

```
t:git-sync done.  Closed: 2  |  Imported: 1  |  Open: 16
```
</process>
