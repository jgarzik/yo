#!/bin/bash
# Test: Ask yo to create a commit
# Expected: yo stages changes and creates a commit

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "create-commit"

# Reset mock_webapp scratch
reset_mock_webapp

# Make a change
echo "// Added for testing git commit" >> "$MOCK_WEBAPP_SCRATCH/src/main.rs"

# Ask yo to commit the change
OUTPUT=$(run_yo_in_mock_webapp "Stage the changes to main.rs and create a commit with an appropriate message describing the change.")

# Assert a new commit was created (more than initial commit)
assert_git_has_commits "$MOCK_WEBAPP_SCRATCH" 2

# Assert working tree is now clean
assert_git_clean "$MOCK_WEBAPP_SCRATCH"

cleanup_mock_webapp
report_result
