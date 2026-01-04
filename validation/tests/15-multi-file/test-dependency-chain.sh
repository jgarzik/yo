#!/bin/bash
# Test: Ask yo to add a config option and thread it through layers
# Expected: yo updates config, service, and usage sites

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "dependency-chain"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to add a new config option and use it
OUTPUT=$(run_yo_in_mock_webapp "Add a new config option 'max_sessions: u32' with a default value of 100 to the Config struct. Then add a method to AuthService that uses this config value. Make sure the code compiles.")

# Assert config was updated
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/config.rs" "max_sessions"

# Assert auth service uses it
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/services/auth.rs" "max_sessions"

# Verify the project still compiles
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
assert_success $?

cleanup_mock_webapp
report_result
