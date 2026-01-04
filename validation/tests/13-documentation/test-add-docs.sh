#!/bin/bash
# Test: Ask yo to add doc comments to undocumented functions
# Expected: yo adds /// comments to handlers.rs functions

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/assertions.sh"

check_yo_binary

setup_test "add-docs"

# Reset mock_webapp scratch
reset_mock_webapp

# Verify handlers.rs has undocumented functions initially
# The 'pub fn get_user' line should not have a /// comment above it
if grep -B1 "pub fn get_user" "$MOCK_WEBAPP_SCRATCH/src/api/handlers.rs" | head -1 | grep -q "///"; then
    echo "  SKIP: get_user already has docs" >> "$TEST_LOG"
    cleanup_mock_webapp
    echo -e "${YELLOW}SKIP${NC}: add-docs (already documented)"
    exit 0
fi

# Ask yo to add documentation
OUTPUT=$(run_yo_in_mock_webapp "Add doc comments (///) to all undocumented public functions in src/api/handlers.rs. Each function should have a brief description of what it does.")

# Assert handlers.rs was modified
assert_git_dirty "$MOCK_WEBAPP_SCRATCH"

# Assert file now contains doc comments for the functions
assert_file_contains "$MOCK_WEBAPP_SCRATCH/src/api/handlers.rs" "/// "

# Verify the project still compiles
cd "$MOCK_WEBAPP_SCRATCH" && cargo build >> "$TEST_LOG" 2>&1
assert_success $?

cleanup_mock_webapp
report_result
