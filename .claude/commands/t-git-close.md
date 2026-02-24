---
name: t:git-close
description: Scan recent git commits and auto-mark matching open todos as done
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
---

<objective>
One direction only: git → todos. Scan commits from linked repos and mark open todos as done when a commit clearly delivers on that todo. Fast, no prompting.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/sync` exists → sync=`./todos/sync`, done=`./todos/done`
- If `./sync` exists → sync=`./sync`, done=`./done`

## Step 2 — Run sync script

```bash
<sync> --days <N>   # default 7
```

Capture full output.

## Step 3 — Parse

From output extract:
- OPEN TODOS: each `FILE:` block → id, filename, project, keywords, body
- GIT LOG: each repo section → `<hash> <date> <subject>`

## Step 4 — Match

A todo is **done** when a commit:
- Directly references the todo's keywords, id, slug words, or body concepts
- Clearly implements/ships what the todo describes

Skip vague commits: "fix", "wip", "update", "cleanup" with no specific overlap.
One commit can close at most one todo (best fit wins).

## Step 5 — Apply

For each confident match:
```bash
<done> <id>
```

On "multiple matches": retry with a longer slug substring.
On "no match": skip and note it.

## Step 6 — Report (compact)

```
git-close: last N days, X repos

✓ #3  fix-parser-bug       ← abc1234 fix: parser now handles edge cases
✓ #7  implement-login      ← def5678 feat: login endpoint with JWT

· #1  add-adapter          no match
· #5  clean-up-frontend    no match

Closed 2 of 9 open todos.
```
</process>
