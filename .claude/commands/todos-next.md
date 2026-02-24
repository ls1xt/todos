---
name: todos:next
description: Show ranked open todos so you can pick what to work on next
argument-hint: [--time <2h|day|week>] [--project <name>]
allowed-tools:
  - Bash
  - Read
---

<objective>
Don't pick for the user — rank and present. Show open todos scored by priority + age + recent git activity, filtered by available time and project. User picks by ID. Optionally context-check the top candidates against linked repos.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/list` exists → list=`./todos/list`, sync=`./todos/sync`
- Else strip `todos/` prefix

## Step 2 — Parse arguments

From `$ARGUMENTS`:
- `--time <value>`: `2h` / `30m` / `day` / `week` — affects scope filter
- `--project <name>`: filter to one project

Time scope → max estimated effort:
- `30m`/`1h`/`2h` → "quick" items (small scope keywords: fix, update, check, review, add)
- `day` → medium scope
- `week` / (none) → all

## Step 3 — Load and score todos

```bash
<list> [--project <name>]
```

Score each todo (higher = more urgent):
- priority: high=30, medium=15, low=5
- age: +1 per day open (max 20)
- recent git activity in that project: +10 if commits in last 3 days, +5 if last 7 days
  (check with: `git -C linked/<project> log --since="7 days ago" --oneline 2>/dev/null | wc -l`)

## Step 4 — Filter by time scope

If `--time` given, prefer todos whose title/body match the scope:
- Quick scope: deprioritize todos with scope words like "design", "research", "implement full", "refactor"
- Keep high-priority regardless of scope

## Step 5 — Print ranked list

```
Next up  [time: day | project: enty]

SCORE  #   P  AGE  TITLE
─────────────────────────────────────────────────────
   55   1  H   3d  Add adapter between pipeline and crawler
   48   5  H   3d  Clean up frontend for realtor demos
   43  12  H   3d  Design PR-based data quality system
   28   3  M   3d  Automate error handling — emit to Kafka
   ...

Pick one (number), or "all" to see full list →
```

If user picks a number, confirm:
```
Starting #1 — Add adapter between pipeline and crawler
```
And optionally offer: "Run /todos:contextualize 1 for code context first?"
</process>
