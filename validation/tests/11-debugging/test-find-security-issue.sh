#!/bin/bash
# Test: Ask yo to find security issues in auth.rs
# Expected: yo identifies the hardcoded API key

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "find-security-issue"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to review auth.rs for security issues
OUTPUT=$(run_yo_in_mock_webapp "Review src/services/auth.rs for security issues. Report any problems you find.")

# Assert yo found the hardcoded API key issue
assert_output_contains_any "$OUTPUT" "hardcoded" "api_key" "secret" "sk-secret" "credential"

cleanup_mock_webapp
report_result
