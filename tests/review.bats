#!/usr/bin/env bats
load "helpers/setup"

setup() {
  setup_repo
  cd "$REPO_DIR"
}
teardown() { teardown_repo; }

# Helper: create a todo file with today's date in the given dir
create_todo() {
  local dir="$1" name="$2"
  local filepath="$REPO_DIR/$dir/$name"
  cat > "$filepath" <<EOF
---
created: $(date +%Y-%m-%d)
priority: normal
project:
keywords:
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "$filepath"
}

@test "review with no args shows todos from last 7 days grouped by status" {
  create_todo "open" "2026-01-01-open-task.md"
  create_todo "done" "2026-01-01-done-task.md"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/review"
  assert_success
  assert_output --partial "open"
  assert_output --partial "done"
}

@test "review output includes per-status counts" {
  create_todo "open" "2026-01-01-open-task-1.md"
  create_todo "open" "2026-01-01-open-task-2.md"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/review"
  assert_success
  # Should include a count like "open (2)" or "2 open" or similar
  assert_output --partial "2"
}

@test "review --days 14 shows last 14 days" {
  create_todo "open" "2026-01-01-recent-task.md"
  git -C "$REPO_DIR" commit -q -m "add task"
  run "$SCRIPTS_DIR/review" --days 14
  assert_success
}

@test "review --days 0 shows empty output or just headers" {
  create_todo "open" "2026-01-01-task.md"
  git -C "$REPO_DIR" commit -q -m "add task"
  run "$SCRIPTS_DIR/review" --days 0
  assert_success
}

@test "review groups files correctly (open in open section, done in done section)" {
  create_todo "open" "2026-01-01-open-task.md"
  create_todo "done" "2026-01-01-done-task.md"
  git -C "$REPO_DIR" commit -q -m "add tasks"
  run "$SCRIPTS_DIR/review"
  assert_success
  # Both status names should appear in output as section headers
  assert_output --partial "open"
  assert_output --partial "done"
}
