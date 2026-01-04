#!/bin/bash
# Test: Ask yo to find and fix a failing test
# Expected: yo identifies the failing test and fixes the bug in validation.rs

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "fix-failing-test"

# Reset mock_webapp scratch
reset_mock_webapp

# Verify test is failing initially
assert_cargo_test_fails "$MOCK_WEBAPP_SCRATCH"
assert_single_test_fails "$MOCK_WEBAPP_SCRATCH" "test_validate_malformed_email"

# Ask yo to fix the failing test
OUTPUT=$(run_yo_in_mock_webapp "Run cargo test to find the failing test. Then fix the bug in the source code so the test passes. The test is correct - the source code has a bug.")

# Assert yo identified the issue
assert_output_contains_any "$OUTPUT" "validate_email" "validation.rs" "malformed" "@."

# Assert the test now passes
assert_single_test_passes "$MOCK_WEBAPP_SCRATCH" "test_validate_malformed_email"

# Verify all tests pass
assert_cargo_test_passes "$MOCK_WEBAPP_SCRATCH"

cleanup_mock_webapp
report_result
