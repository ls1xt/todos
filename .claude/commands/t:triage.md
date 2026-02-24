---
name: t:triage
description: Batch-process open todos — compact table, one command to done/drop/reprioritize multiple
argument-hint: [--project <name>]
allowed-tools:
  - Bash
  - Read
---

<objective>
High-throughput triage. Show all open todos as a compact table. Accept one batch command to close/drop/reprioritize multiple at once. One round-trip, done.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/list` exists → list=`./todos/list`, done=`./todos/done`, drop=`./todos/drop`, block=`./todos/block`, add=`./todos/add`
- Else strip `todos/` prefix

## Step 2 — Load todos

```bash
<list> [--project <name if given>]
```

Read each file to get: id, priority, project, title (from filename slug), age in days, body snippet.

## Step 3 — Print compact table

Sort: high → medium → low, then by age descending.

```
#   P  AGE  PROJECT   TITLE
──────────────────────────────────────────────────────
 1  H   3d  enty      Add adapter between pipeline and crawler
 5  H   3d  enty      Clean up frontend for realtor demos
12  H   3d  enty      Design PR-based data quality system
 3  M   3d  enty      Automate error handling — emit to Kafka
 4  M   3d  enty      Build enty-data-edit tool
 2  L   3d  murmur    Add emojis and bling to murmur readme
...

Batch commands:
  done 1 5       → mark done
  drop 2         → drop
  block 3        → block
  high/med/low 4 → reprioritize
  Combine: "done 1 5, drop 2, low 12"
  Or: "skip" to do nothing
```

## Step 4 — Parse batch command

Wait for one user response. Parse it:
- `done <ids>` → run `<done> <id>` for each
- `drop <ids>` → run `<drop> <id>` for each
- `block <ids>` → run `<block> <id>` for each
- `high/med/medium/low <ids>` → edit the `priority:` field in each file and commit: `git add <file> && git commit -m "reprioritize: <title>"`
- Multiple ops separated by `,` or newline — process all

On ambiguous ID: try numeric id: search first, then slug substring.

## Step 5 — Report

```
Triage complete:
  ✓ done:  #1 #5
  ✓ drop:  #2
  ✓ repri: #12 → low
  · skipped: 18 todos unchanged
```
</process>
