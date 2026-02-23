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

@test "block moves file from open/ to blocked/" {
  create_open_todo "2026-01-01-waiting-on-pr.md"
  run "$SCRIPTS_DIR/block" "waiting-on-pr"
  assert_success
  run test -f "$REPO_DIR/blocked/2026-01-01-waiting-on-pr.md"
  assert_success
  run test -f "$REPO_DIR/open/2026-01-01-waiting-on-pr.md"
  assert_failure
}

@test "block auto-commits with 'block: <title>' message" {
  create_open_todo "2026-01-01-waiting-on-pr.md"
  run "$SCRIPTS_DIR/block" "waiting-on-pr"
  assert_success
  run git -C "$REPO_DIR" log --oneline
  assert_output --partial "block:"
}

@test "block with zero matches exits 1 and prints error" {
  run "$SCRIPTS_DIR/block" "nonexistent-task"
  assert_failure
  assert_output --partial "no match"
}

@test "block with multiple matches lists candidates and does not move any" {
  create_open_todo "2026-01-01-waiting-on-pr-alpha.md"
  create_open_todo "2026-01-01-waiting-on-pr-beta.md"
  run "$SCRIPTS_DIR/block" "waiting-on-pr"
  assert_failure
  assert_output --partial "waiting-on-pr-alpha"
  assert_output --partial "waiting-on-pr-beta"
  # Neither file should be moved
  run test -f "$REPO_DIR/open/2026-01-01-waiting-on-pr-alpha.md"
  assert_success
  run test -f "$REPO_DIR/open/2026-01-01-waiting-on-pr-beta.md"
  assert_success
}
