#!/usr/bin/env bats
load "helpers/setup"

setup() {
  setup_repo
  # Set HOME and GIT env vars so add script's git commits work in REPO_DIR
  export HOME="$REPO_DIR"
  cd "$REPO_DIR"
}
teardown() { teardown_repo; }

@test "add creates file in open/ with date prefix" {
  run "$SCRIPTS_DIR/add" "buy milk" < /dev/null
  assert_success
  # Check that a file matching the date pattern was created in open/
  run bash -c "ls '$REPO_DIR/open/'*buy-milk.md 2>/dev/null | wc -l"
  assert_output "1"
}

@test "add prints 'created: open/...' on stdout" {
  run "$SCRIPTS_DIR/add" "buy milk" < /dev/null
  assert_success
  assert_output --partial "created: open/"
}

@test "add auto-commits the file" {
  run "$SCRIPTS_DIR/add" "buy milk" < /dev/null
  assert_success
  run git -C "$REPO_DIR" log --oneline
  assert_output --partial "add: buy milk"
}

@test "add --priority sets frontmatter" {
  run "$SCRIPTS_DIR/add" "priority task" --priority high < /dev/null
  assert_success
  run bash -c "grep 'priority: high' '$REPO_DIR/open/'*priority-task.md"
  assert_success
}

@test "add --keywords sets frontmatter" {
  run "$SCRIPTS_DIR/add" "keyword task" --keywords "foo,bar" < /dev/null
  assert_success
  run bash -c "grep 'keywords: foo,bar' '$REPO_DIR/open/'*keyword-task.md"
  assert_success
}

@test "add --project sets frontmatter" {
  run "$SCRIPTS_DIR/add" "project task" --project myproject < /dev/null
  assert_success
  run bash -c "grep 'project: myproject' '$REPO_DIR/open/'*project-task.md"
  assert_success
}

@test "add --body sets frontmatter" {
  run "$SCRIPTS_DIR/add" "body task" --body "some body text" < /dev/null
  assert_success
  run bash -c "grep 'body: some body text' '$REPO_DIR/open/'*body-task.md"
  assert_success
}

@test "add --transcription sets frontmatter" {
  run "$SCRIPTS_DIR/add" "transcription task" --transcription "spoken words" < /dev/null
  assert_success
  run bash -c "grep 'transcription: spoken words' '$REPO_DIR/open/'*transcription-task.md"
  assert_success
}

@test "add without TTY does not open editor and completes without blocking" {
  run "$SCRIPTS_DIR/add" "no tty task" < /dev/null
  assert_success
}
