#!/bin/bash
# Test: Ask yo to check git status and summarize
# Expected: yo describes the current git state

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "git-status"

# Reset mock_webapp scratch
reset_mock_webapp

# Make a change to create a dirty state
echo "// Test change" >> "$MOCK_WEBAPP_SCRATCH/src/main.rs"

# Ask yo to check git status
OUTPUT=$(run_yo_in_mock_webapp "Check the git status and tell me what files have been modified.")

# Assert yo mentions the modified file
assert_output_contains_any "$OUTPUT" "main.rs" "modified" "changed"

cleanup_mock_webapp
report_result
