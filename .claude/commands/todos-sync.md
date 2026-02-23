---
name: todos:sync
description: Analyze recent git commits in linked repos and auto-mark completed todos as done
argument-hint: [--days N]
allowed-tools:
  - Bash
  - Read
---

<objective>
Fetch recent git commits from all repos symlinked in `linked/` and intelligently match them against open todos. Auto-mark todos as done when a commit clearly delivers on the todo's goal.
</objective>

<process>
## Step 1 — Find scripts

Determine if todos is a submodule or direct checkout:
- If `./todos/sync` exists → use `./todos/sync` and `./todos/done`
- If `./sync` exists → use `./sync` and `./done`

## Step 2 — Run sync

```bash
<sync-script> $ARGUMENTS
```

`$ARGUMENTS` may contain `--days N` (default: 3 days). Capture full output.

## Step 3 — Parse output

From the sync output, extract:
- **OPEN TODOS**: each block between `FILE:` and `---` gives you slug, title, project, keywords, body
- **GIT LOG**: each repo section lists commits as `<hash> <date> <subject>`

## Step 4 — Match commits to todos

For each open todo, check all commits across all repos. A match is **confident** when:
- The commit subject directly references the todo's keywords, slug words, or project
- The commit clearly implements or completes what the todo describes
- Example: todo "implement login endpoint" + commit "feat: implement login endpoint with JWT" → confident

**Skip** vague commits: "fix", "wip", "update", "cleanup", "refactor" with no specific overlap.

When multiple todos could match one commit, pick the best fit or skip if ambiguous.

## Step 5 — Apply matches

For each confident match, run:
```bash
<done-script> <slug>
```

Where `<slug>` is the slug field from the todo (e.g. `implement-login` for `2026-02-20-implement-login.md`).

If `done` exits with "multiple matches", try a more specific substring of the slug.
If `done` exits with "no match", skip and note it in the report.

## Step 6 — Report

Print a summary:

```
Synced last N days across X repos.

Marked done (M):
  ✓ implement-login  ← abc1234 feat: implement login endpoint

Left open (K):
  · fix-parser-bug   (no matching commit found)

No open todos remaining.   ← if applicable
```
</process>
