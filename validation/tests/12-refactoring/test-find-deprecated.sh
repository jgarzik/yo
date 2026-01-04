#!/bin/bash
# Test: Ask yo to find deprecated functions
# Expected: yo identifies old_query() in database.rs

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "find-deprecated"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to find deprecated functions
OUTPUT=$(run_yo_in_mock_webapp "Find all deprecated functions in the codebase. Look for #[deprecated] attributes or 'deprecated' comments.")

# Assert yo found the deprecated function
assert_output_contains_any "$OUTPUT" "old_query" "deprecated" "database.rs"

cleanup_mock_webapp
report_result
