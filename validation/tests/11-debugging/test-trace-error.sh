#!/bin/bash
# Test: Give yo a simulated error and ask it to diagnose
# Expected: yo traces the error to the validation function

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "trace-error"

# Reset mock_webapp scratch
reset_mock_webapp

# Simulated error message that points to validation issue
ERROR_MSG="Error: Email validation accepted invalid input '@.' - validation should have rejected this malformed email address"

# Ask yo to trace the error
OUTPUT=$(run_yo_in_mock_webapp "I'm getting this error in production: '$ERROR_MSG'. Find where this bug is in the codebase and explain what's wrong.")

# Assert yo traced it to validation.rs
assert_output_contains_any "$OUTPUT" "validation.rs" "validate_email" "contains('@')" "only checks"

cleanup_mock_webapp
report_result
