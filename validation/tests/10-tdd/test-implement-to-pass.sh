#!/bin/bash
# Test: First create a failing test, then ask yo to implement the function
# Expected: yo implements the function to make the test pass

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "implement-to-pass"

# Reset mock_webapp scratch
reset_mock_webapp

# First, add a test that will fail
cat >> "$MOCK_WEBAPP_SCRATCH/tests/unit_tests.rs" << 'EOF'

#[test]
fn test_is_valid_username_char() {
    use mock_webapp::utils::validation::is_valid_username_char;
    assert!(is_valid_username_char('a'));
    assert!(is_valid_username_char('Z'));
    assert!(is_valid_username_char('5'));
    assert!(is_valid_username_char('_'));
    assert!(!is_valid_username_char('@'));
    assert!(!is_valid_username_char(' '));
}
EOF

echo "  Added failing test" >> "$TEST_LOG"

# Verify it doesn't compile (function doesn't exist)
cd "$MOCK_WEBAPP_SCRATCH" && ! cargo test test_is_valid_username_char >> "$TEST_LOG" 2>&1

# Ask yo to implement the function
OUTPUT=$(run_yo_in_mock_webapp "There's a test called test_is_valid_username_char in tests/unit_tests.rs that's failing because the function doesn't exist. Implement is_valid_username_char in src/utils/validation.rs to make the test pass.")

# Assert the function was added
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/utils/validation.rs" "is_valid_username_char"

# Assert the test now passes
assert_single_test_passes "$MOCK_WEBAPP_SCRATCH" "test_is_valid_username_char"

cleanup_mock_webapp
report_result
