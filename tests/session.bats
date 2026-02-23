#!/usr/bin/env bats
load "helpers/setup"

setup() {
  setup_repo
  cd "$REPO_DIR"

  # Create a mock tmux that records invocations to $REPO_DIR/tmux-calls.log
  mkdir -p "$REPO_DIR/bin"
  cat > "$REPO_DIR/bin/tmux" <<'TMUX_MOCK'
#!/usr/bin/env bash
# Mock tmux — records all invocations, simulates basic behavior
echo "$@" >> "$REPO_DIR/tmux-calls.log"

case "$1" in
  has-session)
    # Return failure by default (no session running)
    # Tests that need "already running" can override by pre-creating the log
    exit 1
    ;;
  new-session)
    exit 0
    ;;
  attach-session)
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
TMUX_MOCK
  chmod +x "$REPO_DIR/bin/tmux"

  # Inject mock tmux into PATH before real tmux
  export PATH="$REPO_DIR/bin:$PATH"
}
teardown() { teardown_repo; }

@test "session business creates tmux session named 'todo' if not running" {
  run "$SCRIPTS_DIR/session" business
  assert_success
  run grep "new-session" "$REPO_DIR/tmux-calls.log"
  assert_success
  assert_output --partial "todo"
}

@test "session personal creates tmux session named 'todo'" {
  run "$SCRIPTS_DIR/session" personal
  assert_success
  run grep "new-session" "$REPO_DIR/tmux-calls.log"
  assert_success
  assert_output --partial "todo"
}

@test "session with no arg prints usage or exits with error" {
  run "$SCRIPTS_DIR/session"
  # No arg should fail or print usage — either is acceptable behavior
  # The test documents the expected contract: no arg = non-zero exit OR usage output
  [ "$status" -ne 0 ] || assert_output --partial "usage"
}

@test "session attaches if tmux session 'todo' already running" {
  # Override mock to return success for has-session (session exists)
  cat > "$REPO_DIR/bin/tmux" <<'TMUX_MOCK_ATTACHED'
#!/usr/bin/env bash
echo "$@" >> "$REPO_DIR/tmux-calls.log"
case "$1" in
  has-session)
    exit 0  # Session IS running
    ;;
  attach-session)
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
TMUX_MOCK_ATTACHED
  chmod +x "$REPO_DIR/bin/tmux"

  run "$SCRIPTS_DIR/session" business
  assert_success
  run grep "attach-session" "$REPO_DIR/tmux-calls.log"
  assert_success
}
