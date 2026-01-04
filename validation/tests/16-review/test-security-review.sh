#!/bin/bash
# Test: Ask yo to do a security review of services/
# Expected: yo identifies the hardcoded API key

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "security-review"

# Reset mock_webapp scratch
reset_mock_webapp

# Ask yo to do a security review
OUTPUT=$(run_yo_in_mock_webapp "Do a security review of all files in src/services/. Look for hardcoded secrets, credentials, SQL injection risks, and other security issues. Report what you find.")

# Assert yo found the security issue
assert_output_contains_any "$OUTPUT" "hardcoded" "api_key" "secret" "sk-secret" "credential" "security"

cleanup_mock_webapp
report_result
