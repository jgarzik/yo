#!/bin/bash
# Test: Ask yo to find undocumented functions
# Expected: yo identifies functions without doc comments in handlers.rs

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "find-undocumented"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to find undocumented functions in api/
OUTPUT=$(run_yo_in_mock_webapp "Find functions in src/api/ that don't have doc comments (/// comments). List them.")

# Assert yo found the undocumented handlers
assert_output_contains_any "$OUTPUT" "get_user" "create_user" "login" "list_users" "delete_user" "handlers.rs"

cleanup_mock_webapp
report_result
