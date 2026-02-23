#!/usr/bin/env bats
load "helpers/setup"

setup() { setup_repo; }
teardown() { teardown_repo; }

# Helper: create a valid todo file with required frontmatter
create_valid_todo() {
  local name="${1:-2026-01-01-test-task.md}"
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
}

@test "valid todo file passes pre-commit hook" {
  create_valid_todo "2026-01-01-test-task.md"
  GIT_DIR="$REPO_DIR/.git" run "$SCRIPTS_DIR/hooks/pre-commit"
  assert_success
}

@test "pre-commit rejects file missing 'created' field" {
  cat > "$REPO_DIR/open/2026-01-01-no-created.md" <<'EOF'
---
priority: normal
project:
keywords:
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "open/2026-01-01-no-created.md"
  GIT_DIR="$REPO_DIR/.git" run "$SCRIPTS_DIR/hooks/pre-commit"
  assert_failure
  assert_output --partial "created"
}

@test "pre-commit rejects file missing 'priority' field" {
  cat > "$REPO_DIR/open/2026-01-01-no-priority.md" <<'EOF'
---
created: 2026-01-01
project:
keywords:
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "open/2026-01-01-no-priority.md"
  GIT_DIR="$REPO_DIR/.git" run "$SCRIPTS_DIR/hooks/pre-commit"
  assert_failure
  assert_output --partial "priority"
}

@test "pre-commit rejects file with bad filename (no date prefix)" {
  cat > "$REPO_DIR/open/buy-milk.md" <<'EOF'
---
created: 2026-01-01
priority: normal
project:
keywords:
body:
transcription:
---
EOF
  git -C "$REPO_DIR" add "open/buy-milk.md"
  GIT_DIR="$REPO_DIR/.git" run "$SCRIPTS_DIR/hooks/pre-commit"
  assert_failure
  assert_output --partial "YYYY-MM-DD"
}

@test "pre-commit ignores non-todo staged files" {
  echo "# README" > "$REPO_DIR/README.md"
  git -C "$REPO_DIR" add "README.md"
  GIT_DIR="$REPO_DIR/.git" run "$SCRIPTS_DIR/hooks/pre-commit"
  assert_success
}
