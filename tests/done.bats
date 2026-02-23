#!/usr/bin/env bats
load "helpers/setup"

setup() {
  setup_repo
  cd "$REPO_DIR"
}
teardown() { teardown_repo; }

# Helper: create a committed todo in open/
create_open_todo() {
  local name="$1"
  cat > "$REPO_DIR/open/$name" <<'EOF'
---
created: 2026-01-01
priority: normal
project:
keywords:
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "open/$name"
  git -C "$REPO_DIR" commit -q -m "add: $(basename "$name" .md)"
}

@test "done moves file from open/ to done/" {
  create_open_todo "2026-01-01-fix-bug.md"
  run "$SCRIPTS_DIR/done" "fix-bug"
  assert_success
  run test -f "$REPO_DIR/done/2026-01-01-fix-bug.md"
  assert_success
  run test -f "$REPO_DIR/open/2026-01-01-fix-bug.md"
  assert_failure
}

@test "done auto-commits with 'done: <title>' message" {
  create_open_todo "2026-01-01-fix-bug.md"
  run "$SCRIPTS_DIR/done" "fix-bug"
  assert_success
  run git -C "$REPO_DIR" log --oneline
  assert_output --partial "done:"
}

@test "done with zero matches exits 1 and prints error" {
  run "$SCRIPTS_DIR/done" "nonexistent-task"
  assert_failure
  assert_output --partial "no match"
}

@test "done with multiple matches lists candidates and does not move any" {
  create_open_todo "2026-01-01-fix-bug-alpha.md"
  create_open_todo "2026-01-01-fix-bug-beta.md"
  run "$SCRIPTS_DIR/done" "fix-bug"
  assert_failure
  assert_output --partial "fix-bug-alpha"
  assert_output --partial "fix-bug-beta"
  # Neither file should be moved
  run test -f "$REPO_DIR/open/2026-01-01-fix-bug-alpha.md"
  assert_success
  run test -f "$REPO_DIR/open/2026-01-01-fix-bug-beta.md"
  assert_success
}
