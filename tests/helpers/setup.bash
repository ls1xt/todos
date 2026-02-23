#!/usr/bin/env bash
# Shared bats helpers for todos-general test suite

# Load bats-support and bats-assert (order matters: support first)
# BATS_TEST_DIRNAME is the directory of the running .bats file (tests/)
# libs/ is a sibling of the .bats files, so we use BATS_TEST_DIRNAME directly
load "$BATS_TEST_DIRNAME/libs/bats-support/load"
load "$BATS_TEST_DIRNAME/libs/bats-assert/load"

# Create a fresh isolated temp git repo for each test.
# Sets: REPO_DIR (path to temp repo), SCRIPTS_DIR (path to project root scripts)
setup_repo() {
  REPO_DIR="$(mktemp -d)"
  SCRIPTS_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

  cd "$REPO_DIR"
  git init -q
  git config user.email "test@test.com"
  git config user.name "Test"

  # Create the standard directory structure
  mkdir -p open done blocked dropped

  # Initial commit so git status works
  git commit -q --allow-empty -m "init"

  export REPO_DIR SCRIPTS_DIR
}

# Remove temp repo after each test
teardown_repo() {
  rm -rf "$REPO_DIR"
}
