#!/usr/bin/env bats
load "helpers/setup"

setup() {
  setup_repo
  cd "$REPO_DIR"
}
teardown() { teardown_repo; }

# Helper: create a todo file with frontmatter in the given dir
create_todo() {
  local dir="$1" name="$2" priority="${3:-normal}" project="${4:-}" keywords="${5:-}"
  local filepath="$REPO_DIR/$dir/$name"
  cat > "$filepath" <<EOF
---
created: $(date +%Y-%m-%d)
priority: $priority
project: $project
keywords: $keywords
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "$filepath"
}

# Helper: create a todo with an old date in the created field
create_old_todo() {
  local dir="$1" name="$2"
  local filepath="$REPO_DIR/$dir/$name"
  cat > "$filepath" <<'EOF'
---
created: 2020-01-01
priority: normal
project:
keywords:
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "$filepath"
}

@test "list with no flags prints open todos one per line" {
  create_todo "open" "2026-01-01-task-a.md"
  git -C "$REPO_DIR" commit -q -m "add task-a"
  run "$SCRIPTS_DIR/list"
  assert_success
  assert_output --partial "open/"
}

@test "list output format is: path  priority  project  keywords" {
  create_todo "open" "2026-01-01-task-b.md" "high" "work" "meeting"
  git -C "$REPO_DIR" commit -q -m "add task-b"
  run "$SCRIPTS_DIR/list"
  assert_success
  assert_output --partial "open/"
  assert_output --partial "high"
}

@test "list --status done shows done/ files not open/" {
  create_todo "open" "2026-01-01-task-c.md"
  create_todo "done" "2026-01-01-finished-task.md"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/list" --status done
  assert_success
  assert_output --partial "done/"
  refute_output --partial "open/"
}

@test "list --status blocked shows blocked/ files" {
  create_todo "blocked" "2026-01-01-blocked-task.md"
  git -C "$REPO_DIR" commit -q -m "add blocked task"
  run "$SCRIPTS_DIR/list" --status blocked
  assert_success
  assert_output --partial "blocked/"
}

@test "list --project filters by project frontmatter field" {
  create_todo "open" "2026-01-01-work-task.md" "normal" "work"
  create_todo "open" "2026-01-01-personal-task.md" "normal" "personal"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/list" --project work
  assert_success
  assert_output --partial "work-task"
  refute_output --partial "personal-task"
}

@test "list --keyword filters by keyword frontmatter" {
  create_todo "open" "2026-01-01-meeting-task.md" "normal" "" "meeting,standup"
  create_todo "open" "2026-01-01-code-task.md" "normal" "" "coding"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/list" --keyword meeting
  assert_success
  assert_output --partial "meeting-task"
  refute_output --partial "code-task"
}

@test "list --since 1d only shows files from last 1 day" {
  create_todo "open" "2026-01-01-new-task.md"
  create_old_todo "open" "2020-01-01-old-task.md"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/list" --since 1d
  assert_success
  assert_output --partial "new-task"
  refute_output --partial "old-task"
}

@test "list --since 7d shows files from last 7 days" {
  create_todo "open" "2026-01-01-recent-task.md"
  git -C "$REPO_DIR" commit -q -m "add task"
  run "$SCRIPTS_DIR/list" --since 7d
  assert_success
  assert_output --partial "recent-task"
}

@test "list with no matching files exits 0 with empty output" {
  run "$SCRIPTS_DIR/list"
  assert_success
  assert_output ""
}

@test "list --project nonexistent returns empty output" {
  create_todo "open" "2026-01-01-work-task.md" "normal" "work"
  git -C "$REPO_DIR" commit -q -m "add task"
  run "$SCRIPTS_DIR/list" --project nonexistent
  assert_success
  assert_output ""
}
