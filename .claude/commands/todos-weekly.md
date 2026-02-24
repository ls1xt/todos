---
name: todos:weekly
description: Weekly digest — completed todos + shipped code narrative, grouped by project
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
---

<objective>
Zero-interaction weekly summary. Combines done todos from the last 7 days with git log across linked repos into a readable digest grouped by project. Good for async updates, personal logs, or investor notes.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/list` exists → list=`./todos/list`, sync=`./todos/sync`
- Else strip `todos/` prefix

## Step 2 — Collect data

**Done todos** (last N days, default 7):
```bash
<list> --status done --since <N>d
```
Read each file for: title, project, body.

**Git log per linked repo:**
```bash
git -C linked/<repo> log --since="<N> days ago" --no-merges --format="%h %ad %s" --date=short
```

## Step 3 — Synthesize

Group everything by project. For each project:
1. List completed todos
2. Summarize shipped commits (cluster related commits into 1-2 sentences, skip pure chores)
3. Note any open high-priority todos still pending

Identify cross-cutting themes (e.g. "heavy infra week", "mostly frontend polish", "data pipeline focus").

## Step 4 — Output

```
Week of Feb 17–24, 2026

── enty ──────────────────────────────────────────
Shipped:
  · Implement login endpoint with JWT auth
  · Add adapter between extraction pipeline and crawler
  · Fix 3 parser edge cases in enty-crawler

Commits: 14 across enty-crawler, enty-search, enty-db

Still open:
  · Clean up frontend for realtor demos (high)
  · Design PR-based data quality system (high)

── murmur ────────────────────────────────────────
Shipped:
  · Fix tmux injector edge case

Commits: 3

── Summary ───────────────────────────────────────
Focus: backend infrastructure and data pipeline
Todos closed: 5  |  Still open: 17  |  Repos active: 3
```
</process>
