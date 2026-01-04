#!/bin/bash
# Test: Full TDD cycle - write test, see it fail, implement, see it pass
# Expected: yo follows the TDD cycle

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "tdd-cycle"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to do a full TDD cycle
OUTPUT=$(run_yo_in_mock_webapp "Follow TDD to add a new feature: a function called 'is_strong_password' in validation.rs that returns true if a password has at least 8 chars, contains a number, and contains an uppercase letter. First write the test, then implement the function to make it pass.")

# Assert the test exists
assert_file_contains "$MOCK_WEBAPP_SCRATCH/tests/unit_tests.rs" "strong_password"

# Assert the function exists
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/utils/validation.rs" "is_strong_password"

# Assert all tests pass
assert_cargo_test_passes "$MOCK_WEBAPP_SCRATCH"

cleanup_mock_webapp
report_result
