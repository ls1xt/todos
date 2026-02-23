# Vision & Implementation Plan

## Vision

A personal todo system that captures thoughts at the speed of speech. Hold a hotkey, say what's on your mind, release — a structured todo file appears, committed, searchable, organized. No apps, no GUIs, no friction. Just voice → file → git.

The system is split into three repos:
- **general** (this repo): Shared scripts, hooks, templates, and the Claude system prompt
- **business**: Work todos (enty.ai, murmur, professional)
- **personal**: Personal todos (health, errands, learning, social)

Business and personal repos include general as a git submodule at `todos/`. Scripts live at the root of this repo (no `scripts/` subdirectory), so commands read naturally:

```bash
todos/add "My task" --priority high
todos/done 2026-02-23-some-task.md
todos/list --since 7d
todos/review
```

## Core Design Principles

1. **Files over databases.** Every todo is a markdown file. Grep is the query engine.
2. **Directories are status.** `open/`, `done/`, `blocked/`, `dropped/` — move the file to change status.
3. **Dates in filenames.** `YYYY-MM-DD-<slug>.md` makes time-based filtering trivial.
4. **Auto-commit everything.** Every todo creation and status change is a git commit.
5. **Voice-first capture.** Optimized for Murmur → tmux → Claude Code flow.
6. **Works without voice too.** Scripts and manual file creation work just as well.

## Data Flow

### Voice capture (primary)

```
┌─────────┐    ┌──────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────┐
│ Hotkey   │───▶│ Murmur STT   │───▶│ tmux "todo"  │───▶│ Claude Code │───▶│ .md  │
│ Ctrl+T   │    │ AssemblyAI   │    │ session      │    │ (silent)    │    │ file │
└─────────┘    └──────────────┘    └──────────────┘    └─────────────┘    └──────┘
                                                                              │
                                                                         git commit
```

### CLI capture (secondary)

```bash
todos/add "Validate SigLIP-2 classification" --priority high --keywords siglip2,images
```

### Status change

```bash
todos/done 2026-02-23-siglip2-validation.md
# → git mv open/... done/... && git commit
```

## Todo File Format

```markdown
---
created: 2026-02-23 14:30
keywords: [keyword1, keyword2]
priority: high|medium|low
project: enty|murmur|personal
transcription: "raw voice transcription if captured via voice"
---

# Title

Description. Context. Links. Whatever is useful.

## Notes

Additional notes added over time.
```

The `transcription` field is optional — only present for voice-captured todos. It preserves the raw speech-to-text output so transcription errors can be corrected later by re-reading the original intent.

---

## Workflows

### Workflow 1: Voice capture (primary)

**What happens end-to-end:**

1. User presses **Ctrl+Cmd+T** (Murmur hotkey)
2. User speaks: *"I need to validate sig lip two classification for the enty search, high priority"*
3. User releases hotkey
4. Murmur transcribes via AssemblyAI → `"I need to validate sig lip two classification for the enty search, high priority"`
5. Murmur injects the text into tmux session `todo:0.0` where Claude Code is running
6. Claude receives the text as a user message
7. Claude interprets:
   - "sig lip two" → **SigLIP-2** (corrected via vocabulary in CLAUDE.md)
   - "enty search" → project **enty** (corrected via known project list in CLAUDE.md)
   - "high priority" → `--priority high`
8. Claude runs:
   ```bash
   todos/add "Validate SigLIP-2 classification" \
     --priority high --project enty --keywords siglip2,classification \
     --body "Check SigLIP-2 model performance on enty image classification pipeline." \
     --transcription "I need to validate sig lip two classification for the enty search, high priority"
   ```
9. Script creates `open/2026-02-23-validate-siglip2-classification.md`, commits, prints:
   ```
   created: open/2026-02-23-validate-siglip2-classification.md
   ```
10. Claude responds briefly: *"Created: Validate SigLIP-2 classification (high, enty)"*

**Multiple todos from one utterance:**

User says: *"Two things — validate sig lip two, high priority, and also update the murmur config for the new hotkey, low priority"*

Claude runs `todos/add` twice, once per todo. Each gets its own file and commit.

**Status changes via voice:**

User says: *"Mark the sig lip validation as done"*

Claude searches with `todos/list --keyword siglip` to find the file, then runs `todos/done 2026-02-23-validate-siglip2-classification.md`.

### Workflow 2: Manual CLI

```bash
# Create a todo
todos/add "Fix login timeout bug" --priority high --project enty --keywords auth,timeout

# Edit the created file in your editor
$EDITOR open/2026-02-23-fix-login-timeout-bug.md

# Check what's open
todos/list --project enty

# Mark it done
todos/done 2026-02-23-fix-login-timeout-bug.md
```

No Claude involved. Scripts handle file creation, git add, git commit internally. The user never needs to run git commands manually.

---

## Handling Transcription Errors

Voice transcription will mangle technical terms, project names, and proper nouns. The strategy has three layers:

### Layer 1: Known vocabulary in CLAUDE.md

Each repo's CLAUDE.md includes a **vocabulary section** mapping common mis-transcriptions to correct terms:

```markdown
## Vocabulary

When processing voice transcriptions, correct these terms:
- "sig lip" / "sick lip" / "sig lip two" → SigLIP-2
- "enty" / "entity" / "N.T." → enty (the project)
- "murmur" → Murmur (voice dictation tool)
- "assembly AI" → AssemblyAI
```

Claude uses this to fix obvious errors before creating the todo. The vocabulary grows over time as new mis-transcriptions are observed.

### Layer 2: Preserve raw transcription

The `--transcription` flag on `todos/add` stores the original speech-to-text output in the frontmatter. This means:

- If Claude guesses wrong, the original intent is still readable
- You can grep for transcription errors later: `grep -r "transcription:" open/`
- A future review step could flag todos where the title diverges significantly from the transcription

### Layer 3: Context from previous todos and project knowledge

CLAUDE.md tells Claude which projects exist and what they're about. When Claude sees ambiguous transcription, it uses project context to disambiguate. For example, "entity search" in the business repo almost certainly means "enty", not a literal entity search.

---

## Script Design for Claude

Scripts must be Claude-friendly: deterministic, structured output, no interactivity when called programmatically.

### `add` — the key script

```
Usage: todos/add <title> [options]

Options:
  --priority <high|medium|low>   Default: medium
  --keywords <k1,k2,...>         Comma-separated
  --project <name>               Project name
  --body <text>                  Description (otherwise empty)
  --transcription <text>         Raw voice transcription to preserve
  --no-edit                      Skip opening in $EDITOR (implicit when not a terminal)

Output (stdout):
  created: open/YYYY-MM-DD-<slug>.md

Behavior:
  1. Generates slug from title (lowercase, hyphens, no special chars)
  2. Creates file from template with frontmatter filled in
  3. git add + git commit -m "add: <title>"
  4. Prints created filename
  5. If stdin is a terminal and --no-edit not set, opens in $EDITOR after commit
```

Claude always gets `--no-edit` behavior (not a terminal). The script detects this automatically — no flag needed.

### `done`, `block`, `drop` — status change scripts

```
Usage: todos/done <filename-or-pattern>

Accepts:
  - Full filename: 2026-02-23-validate-siglip2.md
  - Glob pattern: *siglip*
  - Partial match: siglip (script searches open/ for matches)

Output (stdout):
  moved: open/2026-02-23-validate-siglip2.md → done/

Error (stderr + exit 1):
  error: no match for "siglip" in open/
  error: multiple matches for "sig" — be more specific:
    open/2026-02-23-validate-siglip2.md
    open/2026-02-23-siglip-benchmark.md

Behavior:
  1. Find matching file(s) in open/
  2. If exactly one match: git mv + git commit -m "done: <title>"
  3. If zero matches: error
  4. If multiple matches: list them, exit 1 (Claude can then pick the right one)
```

Same interface for `block` and `drop` — only the target directory and commit message prefix differ.

### `list` — search script

```
Usage: todos/list [options]

Options:
  --since <Nd>        Filter by date in filename (e.g. 7d = last 7 days)
  --keyword <K>       Match in frontmatter keywords
  --project <P>       Match in frontmatter project
  --status <S>        open|done|blocked|dropped|all (default: open)

Output (stdout, one per line):
  open/2026-02-23-validate-siglip2.md  high  enty  [siglip2, classification]
  open/2026-02-21-fix-login-bug.md     medium enty  [auth, timeout]
```

Structured, grep-friendly output. Claude can parse this to answer questions like "what enty todos are open?"

---

## Claude Integration: CLAUDE.md Design

### CLAUDE.md in this repo (general)

Development instructions for working on the scripts themselves. Not relevant to the voice/todo flow.

### CLAUDE.md in business repo

This is the critical file — it's what Claude reads when launched in the todo session.

```markdown
# Todo Capture System — Business

You are a todo capture and management assistant. You receive voice
transcriptions and CLI input, and manage todos using the scripts in `todos/`.

## Rules

1. ALWAYS use `todos/add` to create todos. NEVER create files manually.
2. ALWAYS use `todos/done`, `todos/block`, `todos/drop` to change status. NEVER use git mv directly.
3. Use `todos/list` to search before performing status changes.
4. Keep responses short — just confirm what you did. No explanations unless asked.
5. If a voice transcription is ambiguous, make your best guess and note the uncertainty.
6. If one utterance contains multiple todos, create each one separately.
7. NEVER ask for confirmation before creating a todo. Speed is the priority. The user can always edit or drop it later.

## Creating a Todo

When you receive text (voice or typed), extract:
- **Title**: concise, imperative form ("Validate X", "Fix Y", "Research Z")
- **Priority**: high/medium/low — default medium unless stated
- **Project**: infer from context, use vocabulary below
- **Keywords**: 2-4 relevant terms for searchability
- **Body**: expand the title into 1-2 sentences of context if possible
- **Transcription**: if from voice, preserve the raw text

Then run:
```bash
todos/add "<title>" --priority <P> --project <P> --keywords <k1,k2> \
  --body "<description>" --transcription "<raw text>"
```

## Status Changes

- "mark X as done" / "finished X" / "completed X" → `todos/done <file>`
- "X is blocked" / "waiting on X" → `todos/block <file>`
- "drop X" / "nevermind about X" / "cancel X" → `todos/drop <file>`

Use `todos/list --keyword <term>` to find the file first.

## Projects

- **enty** — enty.ai, the event search platform (/Users/leonsixt/projects/event_search/enty)
- **enty-docs** — strategic documentation (/Users/leonsixt/projects/event_search/enty-docs)
- **murmur** — voice dictation tool (/Users/leonsixt/projects/murmur)

## Vocabulary

When processing voice transcriptions, correct these terms:
- "sig lip" / "sick lip" / "sig lip two" → SigLIP-2
- "enty" / "entity" / "entity search" / "N.T." / "auntie" → enty (the project)
- "murmur" / "murmor" → Murmur
- "assembly AI" / "assembly" → AssemblyAI
- (add more as you discover them)
```

### CLAUDE.md in personal repo

Same structure, but with personal projects/vocabulary and no business context.

```markdown
# Todo Capture System — Personal

You are a todo capture and management assistant for personal tasks.

## Rules
(same as business)

## Projects
(personal projects, hobbies, etc.)

## Vocabulary
(personal terms, names, places)
```

---

## Do We Need Claude Code Skills?

**No.** Skills are slash commands (`/add-todo`) that users invoke explicitly. But in the voice flow, the user isn't typing commands — they're speaking naturally. Claude interprets free-form text using the instructions in CLAUDE.md.

For manual CLI use, you'd just run the scripts directly (`todos/add "..."`). Skills would add another layer of indirection without benefit.

The CLAUDE.md + scripts approach is simpler and more maintainable.

---

## Implementation Tasks

### Phase 1: General repo (this repo)

Scripts go at the repo root — no `scripts/` subdirectory. Each is a short, executable shell script.

- [ ] **Write `add`** — create a todo from CLI or Claude
  - CLI: `add <title> [--priority P] [--keywords k1,k2] [--project P] [--body TEXT] [--transcription TEXT]`
  - Creates file from template in `open/`
  - Prints `created: open/YYYY-MM-DD-<slug>.md` to stdout
  - Auto-commits with message `add: <title>`
  - Opens in `$EDITOR` if stdin is a terminal (skipped automatically when called by Claude)

- [ ] **Write `done`** — mark a todo as done
  - CLI: `done <filename-or-pattern>` (full name, glob, or partial match)
  - `git mv open/<file> done/` + auto-commit
  - Prints `moved: open/<file> → done/` to stdout
  - Errors clearly on zero or multiple matches (lists candidates on multiple)

- [ ] **Write `block`** — mark a todo as blocked (same interface as `done`)

- [ ] **Write `drop`** — drop a todo (same interface as `done`)

- [ ] **Write `list`** — search and list todos
  - `list [--since 7d] [--keyword K] [--project P] [--status open|done|all]`
  - Searches filenames and frontmatter
  - `--since 7d` filters by date pattern in filename

- [ ] **Write `review`** — weekly review helper
  - `review [--days 7]`
  - Shows all todos from last N days grouped by status
  - Summary counts

- [ ] **Write `session`** — launch Claude Code in a tmux session
  - Takes argument: `business` or `personal` (default: `business`)
  - Creates/attaches tmux session named `todo`
  - `cd`s into `~/projects/todos/<business|personal>/`
  - Launches `claude` (picks up CLAUDE.md automatically — no `--system-prompt` needed)
  - Supports `--detach` flag

- [ ] **Write `hooks/pre-commit`**
  - Validates YAML frontmatter has required fields
  - Checks filename matches YYYY-MM-DD pattern

- [ ] **Write `templates/todo.md`**
  - Skeleton with YAML frontmatter placeholders

- [ ] **Write CLAUDE.md** for this repo (development instructions)

### Phase 2: Business repo

- [ ] **Initialize `~/projects/todos/business/` git repo**
- [ ] **Create directories**: `open/`, `done/`, `blocked/`, `dropped/`
- [ ] **Add general as submodule at `todos/`**: `git submodule add ../general todos`
- [ ] **Configure git hooks**: `git config core.hooksPath todos/hooks`
- [ ] **Write CLAUDE.md** (instructions for Claude, including related repo paths for enty, enty-docs, murmur)

### Phase 3: Personal repo

- [ ] **Initialize `~/projects/todos/personal/` git repo**
- [ ] **Create directories**: `open/`, `done/`, `blocked/`, `dropped/`
- [ ] **Add general as submodule at `todos/`**: `git submodule add ../general todos`
- [ ] **Configure git hooks**: `git config core.hooksPath todos/hooks`
- [ ] **Write CLAUDE.md** (including any related repo paths)

### Phase 4: Wire up Murmur

- [ ] **Update `~/.config/murmur/config.json`** — no changes needed if Ctrl+Cmd+T already points to `tmux:todo:0.0`
- [ ] **Test**: run `todos/session business`, dictate a test todo, verify file + commit
- [ ] **Test**: `todos/done`, `todos/list`, `todos/review`
- [ ] **Optional**: Add a second Murmur binding for personal todos (e.g. different tmux session name)

---

## Open Questions

- Should there be a way to move todos between business and personal?
- Should `review` generate a summary report (e.g. weekly markdown file)?
- Should there be GitHub Actions for anything (e.g. daily email digest)?
