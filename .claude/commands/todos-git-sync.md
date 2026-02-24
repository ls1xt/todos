---
name: todos:git-sync
description: Full git sync — mark completed todos as done AND propose new follow-up todos from linked repo commits
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
---

<objective>
Bidirectional sync between linked repos and todos. Runs git-close then git-import in sequence. Use this as your default post-coding-session command.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/sync` exists → sync=`./todos/sync`, done=`./todos/done`, add=`./todos/add`, list=`./todos/list`
- Else strip `todos/` prefix

## Step 2 — Run sync script once

```bash
<sync> --days <N>   # default 7
```

Capture full output — reuse it for both phases below.

## Step 3 — Phase 1: Close (git → mark done)

Follow the same logic as `/todos:git-close`:
- Match open todos against commits
- Mark confident matches as done
- Collect results

## Step 4 — Phase 2: Import (git → propose new todos)

Follow the same logic as `/todos:git-import`:
- Find commits that suggest missing todos (follow-ups, TODOs in code, partial work)
- Skip anything already covered by an open todo
- Present proposals, collect user response, create confirmed ones

## Step 5 — Combined report

```
git-sync: last N days, X repos

── Closed ──────────────────────────────
✓ #3  fix-parser-bug       ← abc1234 fix: parser handles edge cases
✓ #7  implement-login      ← def5678 feat: login endpoint with JWT
· #1  add-adapter          no match

── Imported ────────────────────────────
  1. [enty] medium  Write tests for login endpoint
  2. [enty] low     Document crawler adapter API
  (skip remaining)

Add which? (e.g. "1 2", "all", "skip") →
```

After import confirmation:
```
git-sync done.
  Closed: 2  |  Imported: 2  |  Open: 17
```
</process>
