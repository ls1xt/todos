---
name: t:standup
description: One-shot standup digest — what was done recently, what's open and high priority
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
---

<objective>
Zero-interaction standup snapshot. Scans done/ for recently completed todos and lists open high-priority items. Outputs clean text ready to paste into Slack/Notion/wherever.
</objective>

<process>
## Step 1 — Resolve scripts

- If `./todos/list` exists → list=`./todos/list`
- Else use `./list`

## Step 2 — Collect data in parallel

**Done recently** (default: 1 day; Monday → 3 days to cover weekend):
```bash
<list> --status done --since <N>d
```
Read each file for title.

**Open high-priority:**
```bash
<list> --status open
```
Filter to `priority: high`. Read titles.

**Optional git context** (if `linked/` exists):
```bash
git -C linked/<repo> log --since="<N> days ago" --no-merges --format="%s" 2>/dev/null
```
for each linked repo.

## Step 3 — Output

Print a clean standup block — no fluff, no markdown headers, copy-paste ready:

```
Done:
  · Add adapter between pipeline and crawler
  · Fix parser edge case in enty-crawler
  · Implement login endpoint

Up next (high priority):
  · Clean up frontend for realtor demos (#5)
  · Design PR-based data quality system (#12)
  · Automate error handling — emit to Kafka (#3)

Blocked: (none)
```

If nothing done: "Done: (nothing closed in last N days)"
If no high-priority open: "Up next: (no high-priority todos open)"
</process>
