---
name: t:review
description: Summarize and analyze open todos by priority, with optional repo context
argument-hint: [--days N] [--no-repos]
allowed-tools:
  - Bash
  - Read
---

<objective>
Give a clear, prioritized overview of all open todos. Identify themes, clusters, and blockers. Optionally scan linked repos for recent commits that shed light on what's already in progress.
</objective>

<process>
## Step 1 — Find scripts

Determine if todos is a submodule or direct checkout:
- If `./todos/list` exists → use `./todos/list`, `./todos/sync`
- If `./list` exists → use `./list`, `./sync`

## Step 2 — Load all open todos

```bash
<list-script> --status open
```

For each file returned, read its full content to get: title, priority, project, keywords, body, created date.

## Step 3 — Check linked repos (unless --no-repos passed)

Parse `$ARGUMENTS` for `--days N` (default: 7) and `--no-repos`.

Unless `--no-repos` is set, run:
```bash
<sync-script> --days <N>
```

Capture the git log output to see what's been shipped recently.

## Step 4 — Analyze

Group todos by priority (high → medium → low). Within each group, cluster by project or theme.

For each todo, note if:
- A recent commit appears to be working toward it (mark as **in progress**)
- It depends on another todo (note the dependency)
- It has been open a long time relative to others (flag as **stale** if >14 days old)

Look for:
- **Overloaded areas**: multiple todos in the same subsystem
- **Quick wins**: low-effort todos that could be knocked out fast
- **Blockers**: high-priority items with no recent commit activity

## Step 5 — Report

Print a structured summary:

```
## Todo Review — <date>

### High Priority (<N>)
  [project] Title                          created: YYYY-MM-DD  [in progress / stale]
    → body snippet

### Medium Priority (<N>)
  ...

### Low Priority (<N>)
  ...

---
### Insights
- **Quick wins**: ...
- **Stale items**: ...
- **Active areas** (recent commits): ...
- **Suggested next action**: ...
```

Keep the report tight. Use one line per todo in the list, expand only notable items.
</process>
