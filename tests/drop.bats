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

@test "drop moves file from open/ to dropped/" {
  create_open_todo "2026-01-01-abandoned-idea.md"
  run "$SCRIPTS_DIR/drop" "abandoned-idea"
  assert_success
  run test -f "$REPO_DIR/dropped/2026-01-01-abandoned-idea.md"
  assert_success
  run test -f "$REPO_DIR/open/2026-01-01-abandoned-idea.md"
  assert_failure
}

@test "drop auto-commits with 'drop: <title>' message" {
  create_open_todo "2026-01-01-abandoned-idea.md"
  run "$SCRIPTS_DIR/drop" "abandoned-idea"
  assert_success
  run git -C "$REPO_DIR" log --oneline
  assert_output --partial "drop:"
}

@test "drop with zero matches exits 1 and prints error" {
  run "$SCRIPTS_DIR/drop" "nonexistent-task"
  assert_failure
  assert_output --partial "no match"
}

@test "drop with multiple matches lists candidates and does not move any" {
  create_open_todo "2026-01-01-abandoned-idea-alpha.md"
  create_open_todo "2026-01-01-abandoned-idea-beta.md"
  run "$SCRIPTS_DIR/drop" "abandoned-idea"
  assert_failure
  assert_output --partial "abandoned-idea-alpha"
  assert_output --partial "abandoned-idea-beta"
  # Neither file should be moved
  run test -f "$REPO_DIR/open/2026-01-01-abandoned-idea-alpha.md"
  assert_success
  run test -f "$REPO_DIR/open/2026-01-01-abandoned-idea-beta.md"
  assert_success
}
