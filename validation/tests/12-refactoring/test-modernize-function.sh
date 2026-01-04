#!/bin/bash
# Test: Ask yo to remove a deprecated function
# Expected: yo removes old_query and updates any callers

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "modernize-function"

# Reset mock_webapp scratch
reset_mock_webapp

# Verify old_query exists initially
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/services/database.rs" "old_query"

# Ask yo to remove the deprecated function
OUTPUT=$(run_yo_in_mock_webapp "The function old_query in src/services/database.rs is deprecated. Remove it from the codebase. Make sure the code still compiles after removal.")

# Assert file was modified
assert_git_dirty "$MOCK_WEBAPP_SCRATCH"

# Assert old_query is no longer in the file
assert_file_not_contains "$MOCK_WEBAPP_SCRATCH/src/services/database.rs" "fn old_query"

# Verify the project still compiles
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
assert_success $?

cleanup_mock_webapp
report_result
