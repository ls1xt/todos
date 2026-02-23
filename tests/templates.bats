#!/usr/bin/env bats
load "helpers/setup"

setup() { setup_repo; }
teardown() { teardown_repo; }

@test "templates/todo.md exists" {
  run test -f "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}

@test "template contains created placeholder" {
  run grep "created:" "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}

@test "template contains priority placeholder" {
  run grep "priority:" "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}

@test "template contains project placeholder" {
  run grep "project:" "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}

@test "template contains keywords placeholder" {
  run grep "keywords:" "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}

@test "template contains body placeholder" {
  run grep "body:" "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}

@test "template contains transcription placeholder" {
  run grep "transcription:" "$SCRIPTS_DIR/templates/todo.md"
  assert_success
}
