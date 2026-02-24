---
name: todos:contextualize
description: Deep-check a todo against linked repos — is it still relevant, already done, or changed shape?
argument-hint: <id-or-slug>
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Task
---

<objective>
Spawn a research agent to investigate a specific todo across all linked repos. The agent checks current code state and git history to answer: is this todo still valid? Already shipped? Evolved into something different?
</objective>

<process>
## Step 1 — Load the todo

Find the todo by ID or slug:
```bash
<list> | grep "^<id>\b"
```
Read the file to extract: id, title, body, keywords, project.

## Step 2 — Spawn research agent

Use the Task tool with subagent_type=`Explore` and this prompt (fill in todo details):

```
Research this todo against the linked repositories at /home/leon/dev/enty/todos/linked/.

Todo #<id>: <title>
Body: <body>
Keywords: <keywords>
Project: <project>

Answer these questions:
1. Is there code in the relevant repo(s) that already implements this? Check files matching the keywords.
2. Is there a recent git commit (last 30 days) that shipped this? Check: git -C linked/<repo> log --all --oneline --since="30 days ago"
3. Has the relevant code area changed significantly since this todo was likely created? Look at git log for the relevant files.
4. Are there any TODO/FIXME comments in the code related to this?
5. What specific files/functions are most relevant to this todo?

Be concrete: list file paths, commit hashes, function names. Keep the report under 20 lines.
```

## Step 3 — Synthesize and report

After the agent returns, synthesize into a verdict:

```
#<id> — <title>

Verdict: STILL VALID | LIKELY DONE | CHANGED SHAPE | SUPERSEDED

Evidence:
  · <1-2 concrete findings from the agent>

Relevant code:
  · <file>:<line> — <what it does>

Recent git:
  · <hash> <date> — <commit subject>

Suggested action: keep | done <id> | update body | drop <id>
```

If verdict is LIKELY DONE or SUPERSEDED, offer to run `<done> <id>` or `<drop> <id>` immediately.
</process>
