#!/bin/bash
# Test: Ask yo to write a test for a new feature
# Expected: yo writes a test that currently fails

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "write-failing-test"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to write a test for a feature that doesn't exist yet
OUTPUT=$(run_yo_in_mock_webapp "Write a test called test_validate_phone_number in tests/unit_tests.rs that tests a validate_phone_number function. The function should accept numbers like '555-1234' and '+1-555-555-1234'. Just write the test, don't implement the function yet.")

# Assert the test was added
assert_file_contains "$MOCK_WEBAPP_SCRATCH/tests/unit_tests.rs" "test_validate_phone_number"

# Assert the project builds but tests fail (function doesn't exist)
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
# The build should fail because the function doesn't exist
# or the test should fail because the function returns wrong result

cleanup_mock_webapp
report_result
