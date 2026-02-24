---
name: t:git-import
description: Scan recent git commits and propose new follow-up todos not yet tracked
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
---

<objective>
Other direction: git → new todos. Scan commits for work that suggests missing follow-ups, undone tasks, TODOs left in code, or areas that need docs/tests/cleanup. Propose them in batch — user confirms which to create.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/sync` exists → sync=`./todos/sync`, add=`./todos/add`, list=`./todos/list`
- If `./sync` exists → sync=`./sync`, add=`./add`, list=`./list`

## Step 2 — Load context

Run sync script to get:
1. All open todos (to avoid proposing duplicates)
2. Git log for last N days (default: 7)

## Step 3 — Scan for import candidates

For each commit, look for signals that suggest a missing todo:

- **Follow-ups**: commit adds feature X → maybe "Write docs for X", "Add tests for X"
- **TODOs in diff**: `TODO`, `FIXME`, `HACK` comments added in commit
- **Partial work**: commit message says "WIP", "partial", "initial", "scaffold" → suggest completion todo
- **Breaking changes**: commit renames/removes something → suggest "Update usages of X"
- **New dependencies**: commit adds a lib → maybe "Evaluate/document <lib> usage"

Skip if an open todo already clearly covers the same ground.
Propose max 8 candidates — quality over quantity.

## Step 4 — Present proposals

Print a numbered list:
```
git-import: N candidates from last D days

  1. [enty] high  Write integration tests for login endpoint
             → abc1234 feat: implement login endpoint with JWT

  2. [enty] medium  Document new crawler adapter API
             → def5678 add: adapter between pipeline and crawler

  3. [murmur] low  Clean up TODO comment in injector.py
             → ghi9012 fix: handle edge case in tmux injector

  (skip remaining)
```

Then ask:
```
Add which? (e.g. "all", "1 3", "skip") →
```

## Step 5 — Create confirmed todos

For each confirmed candidate, run:
```bash
<add> "<title>" --priority <p> --project <project> --keywords <k1,k2,k3> --body "<1-2 sentences>"
```

## Step 6 — Report

```
git-import: added 2 todos (#23, #24). Skipped 1.
```
</process>
